

import UIKit

class DateChooseController: CoreViewController {
    
    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionView.backgroundColor = CoreViewController.primaryBlueColor
        headerView.backgroundColor = CoreViewController.primaryGreenColor

        tableView.dataSource = self
        tableView.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dismiss", name: "dismissDate", object: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationController = segue.destinationViewController as! LocationChooseController
        let indexPath = tableView.indexPathForCell(sender as! GameCell)!
        let time = availableTimes![indexPath.row]
        newAvailability.time = time.object
        newAvailability.timeDisplay = time.displayName
    }


}

extension DateChooseController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("showLocation", sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let time = availableTimes![indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("GameCell") as! GameCell
        cell.gameLabel.text = time.displayName!
        return cell
    }
    
    @IBAction func dismissTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableTimes!.count
    }
}
