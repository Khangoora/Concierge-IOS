/**
 *   Processed after a user submits a 'match request'.
 *
 *   Gets all unpaired 'match requests' (a.k.a. availabilities)
 *   matching the sport, time, and place of the saved 'match request'
 *   and determines whether a 'match proposal' can be generated.
 *
 *   If a 'match proposal' can be generated, sends a push to all
 *   users to accept or reject the match.
 */
Parse.Cloud.afterSave("Availability", function(request) {
    if (request.object.get("matched") == true) {
        console.log("It has already been matched so returning")
        return;
    }

    var updatedObject = request.object;
    var minSize = updatedObject.get("minimum");

    // query for all 'similar' match requests that
    // can be used to generate a match proposal
    query = new Parse.Query("Availability");
    query.equalTo("matched", false);
    query.equalTo("sport", updatedObject.get("sport"));
    query.equalTo("time", updatedObject.get("time"));
    query.equalTo("placeId", updatedObject.get("placeId"));
    query.notEqualTo("objectId", updatedObject.id)
    query.find({
        success: function(results) {

            // if there are enough users with similar availabilities
            // then generate a match proposal and notify.
            if (results.length === minSize - 1) {

                // add the last availability to the list of matched
                // availabilities
                results.push(updatedObject);

                // generate a match proposal id... the last uploaded availabiilty
                // plus the match time.
                var proposalIdentifier = updatedObject.id + updatedObject.get("time");

                // for each availability used to generate this match proposal...
                for (var j = 0; j < results.length; j++) {

                    // set the availability to 'matched'
                    // ensuring it isn't used to generate future matches.
                    results[j].set("matched", true);
                    results[j].save();

                    // next, generate a match proposal for each player.
                    var Proposal = Parse.Object.extend("Proposal");
                    var proposal = new Proposal();
                    proposal.set("sport", results[j].get("sport"));
                    proposal.set("time", results[j].get("time"));
                    proposal.set("placeName", results[j].get("placeName"));
                    proposal.set("placeAddress", results[j].get("placeAddress"));
                    proposal.set("placeId", results[j].get("placeId"));
                    proposal.set("minimum", results[j].get("minimum"));
                    proposal.set("sportName", results[j].get("sportName"));
                    proposal.set("timeDisplay", results[j].get("timeDisplay"));
                    proposal.set("location", results[j].get("location"));
                    proposal.set("user", results[j].get("user"));
                    proposal.set("accepted", false);
                    proposal.set("proposalIdentifier", proposalIdentifier);
                    proposal.save();

                    // inform this availabilty / proposal's owner that the match
                    // request has been used to generate a match proposal.
                    var query = new Parse.Query(Parse.Installation);
                    query.equalTo("user", results[j].get("user"));
                    Parse.Push.send({
                        where: query,
                        data: {
                            alert: "You have a request for " + results[j].get("sportName") + " at " + results[j].get("placeName") + "!"
                        }
                    }, {
                        success: function() {
                            // Push was successful
                            console.log("proposal " + proposalIdentifier + ": successfully notified all players of proposal generation");
                        },
                        error: function(error) {
                            console.error("proposal " + proposalIdentifier + ": error notifying players of proposal generation");
                            // Handle error
                        }
                    });
                }
            }
        },
        error: function(error) {
            console.log("Error: " + error.code + " " + error.message);
        }
    });
});

/**
 *   Processed after a user accepts or rejects a 'match proposal'.
 *
 *   Gets all proposals with the responded-to proposal's proposalIdentifier.
 *
 *   If all proposals have been accepted, notifies all players that their
 *   match is ready to go.
 *
 *   If not all proposals have been accepted, does nothing.
 */
Parse.Cloud.afterSave("Proposal", function(request) {
    if (request.object.get("accepted") == false) {
        console.log("It has not been accepted so returning");
        return;
    }

    var proposalIdentifier = request.object.get("proposalIdentifier");
    var updatedProposal = request.object;
    var minimum = updatedProposal.get("minimum");

    // Gets proposals for other players that have this proposalIdentifier
    // (remember, one proposal per player for this match proposal)
    query = new Parse.Query("Proposal");
    query.equalTo("proposalIdentifier", proposalIdentifier);
    query.equalTo("accepted", true);
    query.find({
        success: function(results) {
            var readyForGame = true;

            if (results.length !== minimum) {
                console.log("proposal " + proposalIdentifier  + ": user accepted or rejected, but we are still waiting on more responses.");
                return;
            }

            console.log("proposal " + proposalIdentifier  + ": all users accepted. Generating Game object and notifying all players.");

            var users = [];
            for (var j = 0; j < results.length; j++) {
                users.push(results[j].get("user"));
            }

            var Game = Parse.Object.extend("Game");
            var game = new Game();
            game.set("sport", updatedProposal.get("sport"));
            game.set("time", updatedProposal.get("time"));
            game.set("placeName", updatedProposal.get("placeName"));
            game.set("placeAddress", updatedProposal.get("placeAddress"));
            game.set("placeId", updatedProposal.get("placeId"));
            game.set("minimum", updatedProposal.get("minimum"));
            game.set("sportName", updatedProposal.get("sportName"));
            game.set("timeDisplay", updatedProposal.get("timeDisplay"));
            game.set("location", updatedProposal.get("location"));
            game.set("players", users);
            game.set("proposalIdentifier", proposalIdentifier);

            game.save(null, {
                success: function(gameResult) {
                    console.log("Success saving game, adding relation and sending push");
                    var users = gameResult.get("players");
                    for (var j = 0; j < users.length; j++) {
                        var PlayerGames = Parse.Object.extend("PlayerGames");
                        var playerGames = new PlayerGames();
                        playerGames.set("user_id", users[j].id);
                        playerGames.set("game_id", gameResult.id);
                        playerGames.save();
                        var query = new Parse.Query(Parse.Installation);
                        query.equalTo("user", users[j]);
                        Parse.Push.send({
                            where: query,
                            data: {
                                alert: "All players have accepted and you are on for a game of " + gameResult.get("sportName") + ", " + gameResult.get("timeDisplay") + " at " + gameResult.get("placeName") + "!"
                            }
                        }, {
                            success: function() {
                                // Push was successful
                                console.log("game " + gameResult.id + ": successfully notified all players of game generation");
                            },
                            error: function(error) {
                                console.error("game " + gameResult.id + ": error notifying players of game generation");
                                // Handle error
                            }
                        });
                    }
                }
            });
        },
        error: function(error) {
            console.log("Error: " + error.code + " " + error.message);
        }
    });
});

/*
availabilities = []
if (availability matches)
availabilities << availability

if (availabilites.count) == sport
then
create proposals


Proposal Flow
if (all proposals accepted) {
  create game
}
*/
