import Foundation
import UIKit
import MapKit

private let udacityDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

extension Date {
    
    init?(isoString: String) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = udacityDateFormat
        if let date = formatter.date(from: isoString) {
            self = date
        }
        else {
            return nil
        }
    }
    
    func isoString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = udacityDateFormat
        return formatter.string(from: self)
    }
    
}

extension CLLocationCoordinate2D: Equatable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.latitude == rhs.latitude &&
                lhs.longitude == rhs.longitude
    }
    
}

public extension RangeReplaceableCollection where Element: Equatable {
    
    /// Only appends the elements of the new array
    /// that are not contained in self.
    ///
    /// Duplicate elements of the new array
    /// will also not be appended. Duplicate elements of the
    /// original array will **NOT** be removed.
    mutating func appendUnique<C: Collection>(
        contentsOf collection: C
    ) where C.Element == Self.Element {
        
        for newItem in collection {
            if !self.contains(newItem) {
                self.append(newItem)
            }
        }
        
    }
    
}

extension RangeReplaceableCollection {
    
    /**
     Removes the first element that satisfies the given
     predicate.
     
     This method usually has better
     performance characteristics than `self.removeAll(where:)`
     if only a single element needs to be removed from the
     collection because it returns after the first time that
     the predicate returns true, whereas `self.removeAll(where:)`
     will traverse the entire collection.
     
     - Parameter shouldBeRemoved: A closure that takes an element of
           the collection as its argument and returns a Boolean value
           indicating whether the element should be removed
           from the collection.
     
     - Returns: The element of the collection that was removed
           or nil if an item was not removed.
     */
    @discardableResult
    mutating func removeFirst(
        where shouldBeRemoved: (Element) throws -> Bool
    ) rethrows -> Element? {
        
        for (indx, element) in zip(self.indices, self) {
            if try shouldBeRemoved(element) {
                self.remove(at: indx)
                return element
            }
        }
        return nil
    }

}


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
