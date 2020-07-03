import Foundation
import UIKit


/**
 Wrapper function for creating alerts
 - Parameters:
   - title: The title of the alert
   - msg: The message to display in the alert
   - buttons: A list of Strings representing the names of the buttons.
         Default is an "OK" button.
   - style: The style of the alert. Either .alert (default) or .actionsheet.
 - Returns: the alert
 
 - Warning: This function should be called on the main thread.
 */
func makeAlert(
    title: String? = nil,
    msg: String? = nil,
    buttons: [String] = ["OK"],
    style: UIAlertController.Style = .alert
) -> UIAlertController {
    
    let alert = UIAlertController(
        title: title, message: msg, preferredStyle: style
    )
    
    for button in buttons {
        alert.addAction(
            UIAlertAction(title: button, style: .default, handler: nil)
        )
    }
    
    return alert
}


/// Allows strings to be used as errors.
/// The localized description returns self.
extension String: Error, LocalizedError {
    
    /// Returns self.
    public var errorDescription: String? {
        return self
    }
    
}
