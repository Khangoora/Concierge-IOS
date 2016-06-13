

import UIKit

class NearbyViewController: CoreViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var nearbyGames: [Game] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 180
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        getGames()
    }
    
    func getGames() {
        startLoading()
        let query = PFQuery(className: "Game")
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            self.stopLoading()
            if (error == nil) {
                let tmpGames = Game.gamesWithArray(objects!)
                self.nearbyGames = []
                for game in tmpGames {
                    if (userGames[game.object.objectId!] == nil) {
                        self.nearbyGames.append(game)
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func joinGame(nearbyViewCell: NearbyViewCell) {
        startLoading()
        let game = nearbyViewCell.game
        var users = game.object.valueForKey("players") as! [PFObject]
        users.append(PFUser.currentUser()!)
        let newObject = game.object
        newObject.setValue(users, forKey: "players")
        newObject.saveInBackground()
        
        let playerGame = PFObject(className: "PlayerGames")
        playerGame["user_id"] = PFUser.currentUser()!.objectId!
        playerGame["game_id"] = newObject.objectId!
        playerGame.saveInBackgroundWithBlock { (bool: Bool, error: NSError?) -> Void in
            if (bool) {
                nearbyViewCell.joinButton.selected = true
                self.showSuccessAlert(game)
                print("Successfully saved game")
            } else {
                print("Failed saving game")
            }
            self.stopLoading()
        }
        
    }
    
    func showSuccessAlert(successGame: Game) {
        let message = "You have joined a game of \(successGame.sportName) at \(successGame.placeName). Don't be late."
        SweetAlert().showAlert("Joined!", subTitle: message, style: AlertStyle.Success, buttonTitle: "Ok", buttonColor: CoreViewController.primaryBlueColor)
    }
}

extension NearbyViewController : NearbyViewCellDelegate {
    func replySelected(gameSelected nearbyViewCell: NearbyViewCell) {
        self.joinGame(nearbyViewCell)
    }
}

extension NearbyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let game = nearbyGames[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("NearbyCell") as! NearbyViewCell
        cell.proposalTitle.text = game.sportName
        cell.proposalAddress.text = game.timeDisplay
        cell.game = game
        cell.proposalPlace.text = game.placeName
        cell.delegate = self
        cell.sportImage.image = UIImage(named: Sport.getSportImageName(game.sportName))
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyGames.count
    }
    
}
