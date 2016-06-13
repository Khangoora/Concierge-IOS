

import UIKit

var userGames: [String:String] = [:]
class FeedController: CoreViewController {
    
    var proposals: [Proposal] = []
    var games: [Game] = []
    @IBOutlet weak var tableView: UITableView!
    
    var isPresenting: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 180;
        tableView.rowHeight = UITableViewAutomaticDimension
        ApiClient.getQuestionBundle()
        
        if(PFUser.currentUser() != nil && PFUser.currentUser()!.isAuthenticated()) {
            getProposals()
        }
    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if (PFUser.currentUser() != nil && PFUser.currentUser()!.isAuthenticated()) {
            getGames()
            PFUser.currentUser()?.fetch()
        }
    }
    
    @IBAction func newAvailabilityTapped(sender: AnyObject) {
        var addMatchInitialController = UIStoryboard(name: "BuildMatch", bundle: nil).instantiateInitialViewController() as! UIViewController
        self.showViewController(addMatchInitialController, sender: nil)
    }
    
    func getProposals() {
        let query = PFQuery(className: "Proposal")
        let timeNow = NSDate()
        let minTime = NSDate().dateByAddingTimeInterval(-60*59)
        query.whereKey("accepted", equalTo: false)
        query.whereKey("createdAt", greaterThan: minTime)
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            if (error == nil) {
                self.proposals = Proposal.proposalsWithArray(objects!)
                
                if self.proposals.count > 0 {
                    print("has stuff")
                    self.performSegueWithIdentifier("forceFeedToRequestSegue", sender: self.proposals[0])
                    
                }

            } else {
                print("Failure getting objects")
            }
        }
    }
    
    func getGames() {
        startLoading()
        let query = PFQuery(className: "PlayerGames")
        query.whereKey("user_id", equalTo: PFUser.currentUser()!.objectId!)
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            if (error == nil) {
                var games: [String] = []
                for object in objects as! [PFObject]! {
                    games.append(object.valueForKey("game_id") as! String)
                }
                print(games)
                let secondQuery = PFQuery(className: "Game")
                secondQuery.whereKey("objectId", containedIn: games)
                secondQuery.findObjectsInBackgroundWithBlock({ (gameObjects: [AnyObject]?, error: NSError?) -> Void in
                    print(gameObjects?.count)
                    if let error = error {
                        print("Failed getting games")
                    } else {
                        self.games = Array(Game.gamesWithArray(gameObjects!).reverse())
                        self.tableView.reloadData()
                        for game in self.games {
                            print("Storing all games")
                            userGames[game.object.objectId!] = game.sportName
                        }
                    }
                    self.startTrackingLocation()
                    self.stopLoading()
                })
                
            } else {
                print("Failure getting objects")
                self.stopLoading()
            }
        }
    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showRequest") {
            let destinationController = segue.destinationViewController as! RequestViewController
            let indexPath = tableView.indexPathForCell(sender as! ProposalCell)!
            let proposal = proposals[indexPath.row]
            destinationController.proposal = proposal
        } else if(segue.identifier == "showGame") {
            let destinationController = segue.destinationViewController as! GameViewController
            let indexPath = tableView.indexPathForCell(sender as! ProposalCell)!
            let game = games[indexPath.row]
            destinationController.game = game
        } else if (segue.identifier == "forceFeedToRequestSegue") {
            let dVC = segue.destinationViewController as! RequestViewController
            dVC.modalPresentationStyle = UIModalPresentationStyle.Custom
            dVC.transitioningDelegate = self
            dVC.proposal = sender as! Proposal
        }
    }
    
    func startTrackingLocation() {
        NSNotificationCenter.defaultCenter().postNotificationName("startTrackingUserLocation", object: nil)
    }

}

extension FeedController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let game = games[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("ProposalCell") as! ProposalCell
        cell.proposalTitle.text = game.sportName
        cell.proposalAddress.text = game.timeDisplay
        cell.proposalPlace.text = game.placeName
        cell.sportImage.image = UIImage(named: Sport.getSportImageName(game.sportName))
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("showGame", sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
}

extension FeedController: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
    
    // This is used for percent driven interactive transitions, as well as for container controllers that have companion animations that might need to
    // synchronize with the main animation.
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.2
    }
    
    // This method can only be a nop if the transition is interactive and not a percentDriven interactive transition.
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        print("animating transition")
        let containerView = transitionContext.containerView()
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        
        if (isPresenting) {
            containerView.addSubview(toViewController.view)
            toViewController.view.alpha = 0
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                toViewController.view.alpha = 1
                }) { (finished: Bool) -> Void in
                    transitionContext.completeTransition(true)
            }
        } else {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                fromViewController.view.alpha = 0
                }) { (finished: Bool) -> Void in
                    transitionContext.completeTransition(true)
                    fromViewController.view.removeFromSuperview()
            }
        }
    }
    
}

