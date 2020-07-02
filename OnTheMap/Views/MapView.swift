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
    
    var studentLocations: [StudentLocation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        getStudentLocations()
    }
    
    func getStudentLocations() {
        
        UdacityAPI.getStudentLocations { result in
            do {
                self.studentLocations = try result.get()
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
    
    
    // add a pin to the map
    func addMapPins() {
        DispatchQueue.main.async {
            for student in self.studentLocations {
                let pin = MKPointAnnotation()
                pin.coordinate = student.mapCoordinate
                pin.title = student.fullName
                pin.subtitle = student.mediaURL
                self.mapView.addAnnotation(pin)
            }
            mapViewLogger.debug("added \(self.studentLocations.count) pins")
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
            annotationView!.rightCalloutAccessoryView = UIButton(type: .custom)
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
        mapViewLogger.debug("calloutAccessoryControlTapped")
        if let string = (view.annotation?.subtitle as? String),
               let url = URL(string: string) {
        
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

