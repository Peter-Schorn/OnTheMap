import Foundation

var loginViewLogger = Logger(label: "loginView")
var apiLogger = Logger(label: "api")
var mapViewLogger = Logger(label: "mapView")
var newPinLogger = Logger(label: "newPin")


// called in the AppDelegate
func configureLoggers() {
    
    apiLogger.level = .error
    loginViewLogger.level = .error
    mapViewLogger.level = .debug
    newPinLogger.level = .debug
    
}
