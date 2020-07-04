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
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var titleText: UILabel!
    
    var updateCallback: (() -> Void)? = nil

    var hasPlaceholderText = true
    var placeHolderText = "Enter an Address"
    var coordinate: CLLocationCoordinate2D? = nil
    
    var address: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = placeHolderText
        textView.delegate = self
        button.isEnabled = !textView.text.isEmpty && !hasPlaceholderText
    }
    
    @IBAction func tappedButton(_ sender: Any) {
        view.endEditing(true)
        switch mode {
            case .addAddress:
                getCoordinatesFromAddress()
            case .addLink:
                guard let coordinate = coordinate else {
                    presentInvalidAddressAlert(
                        title: "Could not get coordinate from address",
                        error: nil
                    )
                    return
                }
                postLocation(
                    coordinate: coordinate,
                    address: address!,
                    mediaURL: textView.text
                )
                dissmissView()
            
        }
        
    }
    
    @IBAction func tappedCancelButton(_ sender: Any) {
        dissmissView()
    }
    
    func dissmissView() {
        mode = .addAddress
        textView.text = placeHolderText
        hasPlaceholderText = true
        self.dismiss(animated: true)
    }
    
    func presentInvalidAddressAlert(title: String, error: Error?) {
        DispatchQueue.main.async {
            let alert = makeAlert(
                title: title,
                msg: error?.localizedDescription
                        ?? "no error message was provided"
            )
            self.present(alert, animated: true)
        }
    }
    
    enum Mode {
        case addAddress, addLink
    }
    
    var mode = Mode.addAddress {
        didSet {
            switch mode {
                case .addAddress:
                    placeHolderText = "Enter an Address"
                    titleText.text = "Where Are You Right Now?"
                    button.setTitle("Find on the Map", for: .normal)
                case .addLink:
                    placeHolderText = ""
                    titleText.text = "Enter a Link to share"
                    button.setTitle("Submit", for: .normal)
            } 
            if oldValue != mode {
                textView.text = placeHolderText
                button.isEnabled = !textView.text.isEmpty && !hasPlaceholderText
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func getCoordinatesFromAddress() {
        
        newPinLogger.debug("getCoordinatesFromAddress")
        
        CLGeocoder().geocodeAddressString(textView.text) { placemarks, error in
            
            guard let placemark = placemarks?.first,
                    let coordinate = placemark.location?.coordinate
            else {
                self.presentInvalidAddressAlert(
                    title: "The address you entered could not be found",
                    error: error
                )
                return
            }
            
            newPinLogger.debug("got coordinates")
            
            self.address = self.textView.text.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            self.coordinate = coordinate
            self.mode = .addLink
            self.placePinOnMap(coordinate: coordinate)
            
        }

    }
        
    func postLocation(
        coordinate: CLLocationCoordinate2D,
        address: String,
        mediaURL: String
    ) {
        
        newPinLogger.debug("will post Location")
        newPinLogger.debug("address: \(address)")
        newPinLogger.debug("mediaURL: \(mediaURL)\n")
        
        let dateString = Date().isoString()
        
        // For some bizarre reason, the json response for getting
        // student locations is different from the json object
        // you must send to post a location. This is why two different
        // structs must be made. Don't blame me.
        
        let student = Student(
            objectId: "",
            uniqueKey: "abc",
            firstName: "Peter",
            lastName: "Schorn",
            mapString: address,
            mediaURL: mediaURL,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            createdAt: dateString,
            updatedAt: dateString
        )
        
        StudentData.students.append(student)
        updateCallback?()
        newPinLogger.debug("CALLED UPDATE CALLBACK")
        
        let postStudent = PostStudent(
            uniqueKey: "abc",
            firstName: "Peter",
            lastName: "Schorn",
            mapString: address,
            mediaURL: mediaURL,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
        
        UdacityAPI.postStudentLocation(
            student: postStudent
        ) { result in
            
            do {
                let response = try result.get()
                newPinLogger.debug("did post location:\n\(response)")
                
            } catch {
                newPinLogger.error("error posting location:\n\(error)")
            }
        }
       
        
    }
    
    func placePinOnMap(
        coordinate: CLLocationCoordinate2D
    ) {
        
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        mapView.addAnnotation(pin)
        
        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(
                latitudeDelta: 0.5,
                longitudeDelta: 0.5
            )
        )
        self.mapView.setRegion(region, animated: true)
        newPinLogger.debug("did set new region")

    }
    
    
}



extension NewPinViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if hasPlaceholderText {
            textView.text = ""
            hasPlaceholderText = false
            textView.textColor = UIColor.label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            button.isEnabled = false
            textView.text = placeHolderText
            hasPlaceholderText = true
            textView.textColor = UIColor.placeholderText
        }
        else {
            button.isEnabled = true
        }
    }
    
    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        
        button.isEnabled = !textView.text.isEmpty && !hasPlaceholderText
        
        return true
    }
    

}
