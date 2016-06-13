

import UIKit

class GameChooseController: CoreViewController {
    

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newAvailability = NewAvailability()
        
        questionView.backgroundColor = CoreViewController.primaryBlueColor
        headerView.backgroundColor = CoreViewController.primaryGreenColor
        tableView.dataSource = self
        tableView.delegate = self
        
        self.navigationController?.navigationBar.hidden = true
        self.tabBarController?.tabBar.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (newAvailability.sport != nil) {
            dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationController = segue.destinationViewController as! DateChooseController
        let indexPath = tableView.indexPathForCell(sender as! GameCell)!
        let sport = availableSports![indexPath.row]
        newAvailability.sport = sport.object
        newAvailability.minimum = sport.minimum
        newAvailability.sportName = sport.name
        newAvailability.searchQuery = sport.searchQuery
    }
}

extension GameChooseController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableSports!.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.row == availableSports!.count) {
            let cell = tableView.dequeueReusableCellWithIdentifier("GameCell") as! GameCell
            cell.gameLabel.text = "Request New Activity"
            cell.minLabel.text = ""
            cell.gameLabel.textColor = UIColor.redColor()
            return cell
        }
        
        let sport = availableSports![indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("GameCell") as! GameCell
        cell.gameLabel.text = sport.name!
        cell.minLabel.text = "Minimum players: \(sport.minimum)"
        cell.gameLabel.textColor = UIColor.blackColor()
        return cell
    }
    
    @IBAction func dismissTapped(sender: AnyObject) {
        self.navigationController?.navigationBar.hidden = false
        self.tabBarController?.tabBar.hidden = false
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let sport = availableSports![indexPath.row]
        self.performSegueWithIdentifier("showAvailableTimes", sender: tableView.cellForRowAtIndexPath(indexPath))
    }
}
