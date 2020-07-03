//
//  NewPinView.swift
//  OnTheMap
//
//  Created by Peter Schorn on 7/2/20.
//  Copyright © 2020 Peter Schorn. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class NewPinViewController: UIViewController {
    
    @IBOutlet weak var findOnMapButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    var mapViewController: MapViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func tappedFindOnMapButton(_ sender: Any) {
        getCoordinatesFromAddress()
        
    }
    
    @IBAction func tappedCancelButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func getCoordinatesFromAddress() {
        
        newPinLogger.debug("getCoordinatesFromAddress")
        
        guard let address = textView.text else {
            newPinLogger.debug("could not get text")
            return
        }
        
        CLGeocoder().geocodeAddressString(address) { placemarks, error in
            guard let placemark = placemarks?.first else {
                DispatchQueue.main.async {
                    let alert = makeAlert(
                        title: "Invalid address",
                        msg: "The address you entered could not be found"
                    )
                    self.present(alert, animated: true)
                }
                return
            }
 
            
            if self.mapViewController?.addNewPin(placemark: placemark) == nil {
                newPinLogger.error("mapViewController was nil")
            }
            
        }

    }
    
    
    
}


