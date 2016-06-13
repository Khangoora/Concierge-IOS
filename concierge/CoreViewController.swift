

import UIKit
class CoreViewController: UIViewController {
    
    // Colors are still a work in progress
    // primary text color - UIColor.black
    static let secondaryTextColor = UIColor(red: 0.612, green: 0.612, blue: 0.612, alpha: 1) // #9C9C9C
    static let buttonPrimaryBackgroundColor = UIColor(red: 0.208, green: 0.271, blue: 0.322, alpha: 1) // #354552
    static let primaryBackgroundColor = UIColor(red: 0.094, green: 0.678, blue: 0.945, alpha: 1) // #18ADF1
    static let primaryGreenColor = UIColor(red: 0.125, green: 0.753, blue: 0.565, alpha: 1)
    static let primaryBlueColor = UIColor(red: 0.314, green: 0.51, blue: 0.898, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = CoreViewController.primaryGreenColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
    
    // Basic loading wheel to block ui during network calls
    func startLoading() {
        let loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.labelText = "Loading..."
    }
    
    func stopLoading() {
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
    }
    
    // TODO: fix highlighted state in the end
    // to be used when button is attached to bottom therefore no radius, make sure btn_height is 55px
    func setButtonStylePrimary(button: FUIButton) {
        button.buttonColor = CoreViewController.buttonPrimaryBackgroundColor
        button.titleLabel?.font = UIFont.systemFontOfSize(16.0)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
    
    // TODO: fix highlighted state
    // to be used when in middle of screen or something, make sure btn_height is 55px
    func setButtonStyleSecondary(button: FUIButton) {
        button.buttonColor = UIColor.whiteColor()
        button.cornerRadius = 6.0
        button.titleLabel?.font = UIFont.systemFontOfSize(16.0)
        button.setTitleColor(CoreViewController.primaryBackgroundColor, forState: UIControlState.Normal)
    }
}