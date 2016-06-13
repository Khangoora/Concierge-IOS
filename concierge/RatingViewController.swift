
import UIKit

class RatingViewController: CoreViewController {

    
    @IBOutlet weak var starOne: UIButton!
    @IBOutlet weak var starTwo: UIButton!
    @IBOutlet weak var starThree: UIButton!
    @IBOutlet weak var starFour: UIButton!
    @IBOutlet weak var starFive: UIButton!
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var healthLabel: UILabel!
    @IBOutlet weak var attendanceLabel: UILabel!
    
    @IBOutlet weak var yesButton: FUIButton!
    @IBOutlet weak var noButton: FUIButton!
    @IBOutlet weak var healthButton: FUIButton!
    @IBOutlet weak var healthStepper: UIStepper!
    
    var players: [Player]!
    var game: Game!
    var workoutType = -1
    var caloriesBurned: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sport = Sport.getWorkoutTypeForSport(game.sportName)
        workoutType = sport.workoutType
        caloriesBurned = sport.calories
        if (workoutType == -1) {
            hideWorkoutAssets()
        } else {
            updateLabel()
        }
        if (players != nil && players.count > 0) {
            for player in players {
                if (player.objectId != PFUser.currentUser()!.objectId!) {
                    titleLabel.text = "How was \(game.sportName) with \(player.firstName)?"
                    attendanceLabel.text = "Did \(player.firstName) show up?"
                    profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
                    profileImage.clipsToBounds = true
                    profileImage.setImageWithURL(NSURL(string:player.profileImage)!)
                }
            }
        }
        hideViews()
        
        self.title = "How was it?"
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.view.backgroundColor = UIColor.cloudsColor()
        healthButton.buttonColor = UIColor.whiteColor()
        healthButton.cornerRadius = 4.0
        healthButton.setTitleColor(CoreViewController.primaryGreenColor, forState: UIControlState.Normal)
        healthButton.setTitleColor(CoreViewController.primaryGreenColor, forState: UIControlState.Highlighted)
        
        yesButton.buttonColor = UIColor.clearColor()
        noButton.buttonColor = UIColor.clearColor()
        yesButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        yesButton.setTitleColor(CoreViewController.primaryGreenColor, forState: UIControlState.Selected)
        noButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        noButton.setTitleColor(CoreViewController.primaryGreenColor, forState: UIControlState.Selected)
    }
    
    func hideWorkoutAssets() {
        healthStepper.hidden = true
        healthLabel.hidden = true
        healthButton.hidden = true
    }
    
    @IBAction func starTapped(sender: AnyObject) {
        print("The tag is \(sender.tag!)")
        switch(sender.tag!) {
        case 1:
            starOne.selected = true
            starTwo.selected = false
            starThree.selected = false
            starFour.selected = false
            starFive.selected = false
        case 2:
            starOne.selected = true
            starTwo.selected = true
            starThree.selected = false
            starFour.selected = false
            starFive.selected = false
        case 3:
            starOne.selected = true
            starTwo.selected = true
            starThree.selected = true
            starFour.selected = false
            starFive.selected = false
        case 4:
            starOne.selected = true
            starTwo.selected = true
            starThree.selected = true
            starFour.selected = true
            starFive.selected = false
        case 5:
            starOne.selected = true
            starTwo.selected = true
            starThree.selected = true
            starFour.selected = true
            starFive.selected = true
        default:
            break
        }
    }


    @IBAction func dismissTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        showFeedbackAlert()
    }
    
    @IBAction func healthStepper(sender: AnyObject) {
        updateLabel()
    }
    
    @IBAction func trackWorkoutTapped(sender: AnyObject) {
        let kiloCalories = calculateCaloriesBurned()
        self.trackWorkout(kiloCalories)
        showHealthKitAlert(kiloCalories)
    }
    
    func updateLabel() {
        let calories = calculateCaloriesBurned()
        healthLabel.text = "In \(healthStepper.value) hrs, \(calories) calories were burned."
        
    }
    
    let healthManager = HealthManager()
    func trackWorkout(kiloCalories: Double) {
        let timeNow = NSDate()
        let endTime = NSDate().dateByAddingTimeInterval(-60)
        let startTime = endTime.dateByAddingTimeInterval(-3600*healthStepper.value)
                healthManager.saveRunningWorkout(startTime, endDate: endTime, workoutType: workoutType, kiloCalories: kiloCalories) { (bool: Bool, error: NSError!) -> Void in
                    if(!bool) {
                        print("Failure tracking workout")
                        print(error)
                    }
                }
    }
    
    
    func showHealthKitAlert(calories: Double) {
        let message = "You burned \(calories) calories by playing \(healthStepper.value) hrs of \(game.sportName). Your workout has been logged to your HealthKit profile successfully."
        SweetAlert().showAlert("Good work!", subTitle: message, style: AlertStyle.Success)
    }
    
    func hideViews() {
        starOne.alpha = 0
        starTwo.alpha = 0
        starThree.alpha = 0
        starFour.alpha = 0
        starFive.alpha = 0
        titleLabel.alpha = 0
    }
    
    func showViews() {
        starOne.alpha = 1
        starTwo.alpha = 1
        starThree.alpha = 1
        starFour.alpha = 1
        starFive.alpha = 1
        titleLabel.alpha = 1
    }
    
    func animateViews(show: Bool) {
        UIView.animateWithDuration(0.8, animations: {
            if (show) {
                self.showViews()
            } else {
                self.hideViews()
            }
        })
    }
    
    @IBAction func yesButtonTapped(sender: AnyObject) {
        yesButton.selected = true
        noButton.selected = false
        animateViews(true)
    }
    
    @IBAction func noButtonTapped(sender: AnyObject) {
        noButton.selected = true
        yesButton.selected = false
        animateViews(false)
    }
    
    func showFeedbackAlert() {
        let message = "We have received your feedback."
        SweetAlert().showAlert("Thank you", subTitle: message, style: AlertStyle.Success, buttonTitle: "Ok", buttonColor: CoreViewController.primaryBlueColor)
    }
    
    
    func calculateCaloriesBurned() -> Double {
        let multiplier = healthStepper.value
        return multiplier * caloriesBurned
    }

}
