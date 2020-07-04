import Foundation

var loginViewLogger = Logger(label: "loginView")
var apiLogger = Logger(label: "api")
var mapViewLogger = Logger(label: "mapView")
var newPinLogger = Logger(label: "newPin")
var tableViewLogger = Logger(label: "tableView")


// called in the AppDelegate
func configureLoggers() {
    
    apiLogger.level = .error
    loginViewLogger.level = .error
    mapViewLogger.level = .debug
    newPinLogger.level = .debug
    tableViewLogger.level = .debug
    
}
