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
        getStudentLocations()
    }
    
    @IBAction func newPinButtonTapped(_ sender: Any) {
        
        let controller = self.storyboard!.instantiateViewController(
            identifier: "NewPinViewController"
        ) as! NewPinViewController
        
        controller.mapViewController = self
        
        present(controller, animated: true)
        
        
    }
    
    @IBAction func reloadButtonTapped(_ sender: Any) {
        getStudentLocations()
    }
    
    
    func addNewPin(placemark: CLPlacemark) {
        guard let coordinate = placemark.location?.coordinate else {
            mapViewLogger.error(
                "could not get coordinates from user-entered address"
            )
            return
        }
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        mapView.addAnnotation(pin)
        mapViewLogger.debug("did add new pin from user address")
        
    }
    
    
    func getStudentLocations() {
        
        UdacityAPI.getStudentLocations { result in
            do {
                StudentData.students = try result.get()
                self.addMapPins()
                
            } catch {
                DispatchQueue.main.async {
                    let alert = makeAlert(
                        title: "Couldn't get student locations",
                        msg: error.localizedDescription
                    )
                    self.present(alert, animated: true)
                }
                
            }
        }
        
    }
    
    func addMapPins() {
        DispatchQueue.main.async {
            for student in StudentData.students {
                let pin = MKPointAnnotation()
                pin.coordinate = student.mapCoordinate
                pin.title = student.fullName
                pin.subtitle = student.mediaURL
                self.mapView.addAnnotation(pin)
            }
            mapViewLogger.debug("added \(StudentData.students.count) pins")
        }
    }
    
    
    
    
    
}

extension MapViewController: MKMapViewDelegate {

    func mapView(
        _ mapView: MKMapView, viewFor annotation: MKAnnotation
    ) -> MKAnnotationView? {

        // mapViewLogger.debug(
        //     "making view for annotation: \((annotation.title as? String) ?? "no title")"
        // )
        
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
            // UIApplication.shared.open(url)
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

