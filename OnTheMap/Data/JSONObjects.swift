//
//  JSONObjects.swift
//  OnTheMap
//
//  Created by Peter Schorn on 6/11/20.
//  Copyright © 2020 Peter Schorn. All rights reserved.
//

import Foundation
import MapKit

/// The top-level object for udacity requests.
struct UdacityObject<T: Codable>: Codable {

    init(_ object: T) {
        self.udacity = object
    }

    let udacity: T
}

struct ErrorResponse: Codable, LocalizedError {
    
    let status: Int
    let error: String
    var httpStatusCode: Int? = nil
    
    var errorDescription: String? { error }
    
    enum CodingKeys: String, CodingKey {
        case status, error
    }
}

struct SessionResponse: Codable {
    
    struct Account: Codable {
        let registered: Bool
        let key: String
    }
    
    let account: Account
    let session: Session

    
}

struct Session: Codable {
    let id: String
    let expiration: String
}

struct DeleteSessionResponse: Codable {
    let session: Session
}

struct UserCredentials: Codable {
    
    let username: String
    let password: String
    
    
    /// Creates an instance of Self and then wraps it in
    /// `UdacityObject`.
    static func wrappedInit(
        email: String, password: String
    ) -> UdacityObject<UserCredentials> {
        
        return UdacityObject(
            Self(username: email, password: password)
        )
        
    }

}

struct Student: Codable, Equatable {
    
    let objectId: String
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
    let createdAt: String
    let updatedAt: String
    
    var mapCoordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
}

struct PostStudent: Codable {
  
  let uniqueKey: String
  let firstName: String
  let lastName: String
  let mapString: String
  let mediaURL: String
  let latitude: Double
  let longitude: Double

}



struct LocationResponse: Codable {
    
    let createdAt: String
    let objectId: String

}




