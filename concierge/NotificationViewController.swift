

import UIKit

class NotificationViewController: CoreViewController {
    
    @IBOutlet weak var tableView: UITableView!

    var proposals: [Proposal] = []
    
    var isPresenting: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 180;
        tableView.rowHeight = UITableViewAutomaticDimension
        // Do any additional setup after loading the view.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showRequestFromNotification") {
            let dVC = segue.destinationViewController as! RequestViewController
            dVC.modalPresentationStyle = UIModalPresentationStyle.Custom
            dVC.transitioningDelegate = self
            dVC.proposal = sender as! Proposal
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        getProposals()
    }
    func getProposals() {
        startLoading()
        let query = PFQuery(className: "Proposal")
        let timeNow = NSDate()
        let minTime = NSDate().dateByAddingTimeInterval(-60*59)
        query.whereKey("createdAt", greaterThan: minTime)
        query.whereKey("accepted", equalTo: false)
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            if (error == nil) {
                self.proposals = Proposal.proposalsWithArray(objects!)
                self.tableView.reloadData()
            } else {
                print("Failure getting objects")
            }
            self.stopLoading()
        }
    }

}

extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let proposal = proposals[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("RequestCell") as! RequestViewCell
        cell.proposalTitle.text = proposal.sportName
        cell.proposalAddress.text = proposal.timeDisplay
        cell.proposalPlace.text = proposal.placeName
        cell.sportImage.image = UIImage(named: Sport.getSportImageName(proposal.sportName))
        cell.timeLeft.text = proposal.getTimeLeft()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("showRequestFromNotification", sender: proposals[indexPath.row])
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return proposals.count
    }
}

extension NotificationViewController: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.2
    }
    
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
