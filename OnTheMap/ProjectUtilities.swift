import Foundation
import UIKit

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


extension URLSession {
    
    func dataTask(
       with url: URL,
       completionHandler: @escaping (Result<(data: Data, urlResponse: URLResponse), Error>) -> Void
    ) -> URLSessionDataTask {
        
        return self.dataTask(with: url) { data, response, error in
            assert(!(data == nil && error == nil))
            assert(!(data != nil && error != nil))
            
            if let data = data {
                completionHandler(.success((data: data, urlResponse: response!)))
            }
            else {
                completionHandler(.failure(error ?? NSError()))
            }
            
        }

    }
    
    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (
            Result<(data: Data, urlResponse: URLResponse), Error>
        ) -> Void
    ) -> URLSessionDataTask {
        
        return self.dataTask(with: request) { data, response, error in
            assert(!(data == nil && error == nil))
            assert(!(data != nil && error != nil))
            
            if let data = data {
                completionHandler(.success((data: data, urlResponse: response!)))
            }
            else {
                completionHandler(.failure(error ?? NSError()))
            }
            
        }

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
