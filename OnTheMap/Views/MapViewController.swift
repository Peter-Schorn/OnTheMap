//
//  MapView.swift
//  OnTheMap
//
//  Created by Peter Schorn on 6/10/20.
//  Copyright © 2020 Peter Schorn. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var newPinButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        getStudentLocationsWrapper()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("map view viewWillAppear")
        updateMapPins()
    }
    
    
    @IBAction func newPinButtonTapped(_ sender: Any) {
        
        let controller = self.storyboard!.instantiateViewController(
            identifier: "NewPinViewController"
        ) as! NewPinViewController
        
        controller.updateCallback = updateMapPins
        present(controller, animated: true)
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        UdacityAPI.deleteSession { error in
            DispatchQueue.main.async {
                if let error = error {
                    let alert = makeAlert(
                        title: "Couldn't Log Out",
                        msg: error.localizedDescription
                    )
                    self.present(alert, animated: true)
                }
                else {
                    mapViewLogger.debug("should dismiss")
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func reloadButtonTapped(_ sender: Any) {
        getStudentLocationsWrapper()
    }
    
    func getStudentLocationsWrapper() {
        StudentData.getStudentLocations { error in
            if let error = error {
                DispatchQueue.main.async {
                    let alert = makeAlert(
                        title: "Couldn't get student locations",
                        msg: error.localizedDescription
                    )
                    self.present(alert, animated: true)
                }
            }
            else {
                self.updateMapPins()
            }
        }
    }
    
    func updateMapPins() {
        DispatchQueue.main.async {
            var addedPins = 0
            StudentData.sort()
            for student in StudentData.students {
                
                if self.mapView.annotations.contains(where: { annotation in
                    annotation.title == student.fullName &&
                            annotation.subtitle == student.mediaURL &&
                            annotation.coordinate == student.mapCoordinate
                }) {
                    continue
                }
                
                let pin = MKPointAnnotation()
                pin.coordinate = student.mapCoordinate
                pin.title = student.fullName
                pin.subtitle = student.mediaURL
                self.mapView.addAnnotation(pin)
                addedPins += 1
            }
            mapViewLogger.debug("added \(addedPins) pins")
        }
    }
    
    
    
    
    
}

extension MapViewController: MKMapViewDelegate {

    func mapView(
        _ mapView: MKMapView, viewFor annotation: MKAnnotation
    ) -> MKAnnotationView? {

        if annotation is MKUserLocation { return nil }

        var annotationView = mapView.dequeueReusableAnnotationView(
            withIdentifier: "student"
        )
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(
                annotation: annotation, reuseIdentifier: "student"
            )
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView?.isHidden = true
        }
        else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let title = (view.annotation?.subtitle as? String) ?? "no title"
        mapViewLogger.debug("did select view with title: \(title)")
    }
    
    func mapView(
        _ mapView: MKMapView,
        annotationView view: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl
    ) {
        if control == view.rightCalloutAccessoryView {
            print("is rightCalloutAccessoryView")
        }
        else {
            print("not rightCalloutAccessoryView")
        }
        
        
        mapViewLogger.debug("annotation tapped")
        if let string = (view.annotation?.subtitle as? String),
               let url = URL(string: string) {
        
            mapViewLogger.debug("will open url: \(url)")
            UIApplication.shared.open(url)
        }
        else {
            mapViewLogger.warning(
                "couldn't open url: \((view.annotation?.title as? String) ?? "nil")"
            )
            DispatchQueue.main.async {
                let alert = makeAlert(
                    title: "Could not open link",
                    msg: "This link is invalid"
                )
                self.present(alert, animated: true)
            }
        }
        
        
    }
    

}

