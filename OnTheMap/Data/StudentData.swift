//
//  StudentData.swift
//  OnTheMap
//
//  Created by Peter Schorn on 7/2/20.
//  Copyright © 2020 Peter Schorn. All rights reserved.
//

import Foundation


class StudentData {
        
    static var students: [Student] = []
    
    static func sort() {
        mapViewLogger.debug("sorting students")
        Self.students.sort { lhs, rhs in
            guard let leftDate = Date(isoString: lhs.updatedAt),
                    let rightDate = Date(isoString: rhs.updatedAt)
            else {
                return true
            }
            
            return leftDate >= rightDate
        }
    }
    
    static func getStudentLocations(
        completion: @escaping (Error?) -> Void
    ) {
        
        UdacityAPI.getStudentLocations { result in
            do {
                let students = try result.get()
                StudentData.students.appendUnique(contentsOf: students)
                // self.updateMapPins()
                completion(nil)
                
            } catch {
                completion(error)
                // DispatchQueue.main.async {
                //     let alert = makeAlert(
                //         title: "Couldn't get student locations",
                //         msg: error.localizedDescription
                //     )
                //     self.present(alert, animated: true)
                // }
                
            }
        }
        
    }
    
    
}
