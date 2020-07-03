//
//  UdacityAPI.swift
//  OnTheMap
//
//  Created by Peter Schorn on 6/10/20.
//  Copyright © 2020 Peter Schorn. All rights reserved.
//

import Foundation


class UdacityAPI {
    
    private enum EndpointParts: String {
        
        case base = "https://onthemap-api.udacity.com/v1/"
        case session = "session"
        case studentLocations = "StudentLocation"

    }
    
    private class func makeEndpoint(_ parts: EndpointParts...) -> URL {
        
        let url = parts.reduce(into: "", { $0 += $1.rawValue })
        return URL(string: url)!

    }
    
    enum Endpoints {
        static let manageSession = makeEndpoint(.base, .session)
        static let studentLocations = makeEndpoint(.base, .studentLocations)
    }
    
    enum Session {
        static var id: String? = nil
        static var expirationDate: String? = nil
    }
    
    @discardableResult
    class func createSession(
        email: String, password: String,
        completion: @escaping (Error?) -> Void
    ) -> URLSessionDataTask? {
        
        let task = urlDataRequestWithBody(
            url: Endpoints.manageSession,
            httpMethod: "POST",
            body: UserCredentials.wrappedInit(
                email: email, password: password
            ),
            responseType: SessionResponse.self
        ) { result in
            do {
                apiLogger.debug("handling session response")
                
                let responseObject = try result.get()
                Session.id = responseObject.session.id
                Session.expirationDate = responseObject.session.expiration
                completion(nil)
                
            } catch {
                completion(error)
            }
        }
        
        return task
        
    }
    
    @discardableResult
    class func getStudentLocations(
        completion: @escaping (Result<[Student], Error>) -> Void
    ) -> URLSessionDataTask {
        
        let task = urlDataRequest(
            url: Endpoints.studentLocations,
            responseType: [String: [Student]].self
        ) { result in
            do {
                let reponseObject = try result.get()
                if let locations = reponseObject["results"] {
                    completion(.success(locations))
                }
                else {
                    completion(.failure("couldn't get results from student locations"))
                }
                
            } catch {
                completion(.failure(error))
            }
        }
        return task
        

    }
    
    

}



// MARK: - Private Wrappers -
extension UdacityAPI {
    
    private class func urlDataTaskDecodeJSON<ResponseObject: Decodable>(
        responseType: ResponseObject.Type,
        completion: @escaping (Result<ResponseObject, Error>) -> Void
    ) -> ((Result<(data: Data, urlResponse: URLResponse), Error>) -> Void) {
        
        return { result in
            do {
                var (data, urlResponse) = try result.get()
                let httpResponse = urlResponse as! HTTPURLResponse
                
                if responseType == SessionResponse.self {
                    data = data.dropFirst(5)
                }
                
                apiLogger.debug(
                    "status code for \(responseType): \(httpResponse.statusCode)"
                )
                
                // apiLogger.debug("\(String(data: data, encoding: .utf8) ?? "nil")")
                
                if [200, 201].contains(httpResponse.statusCode) {
                    
                    let responseObject = try JSONDecoder().decode(
                        ResponseObject.self, from: data
                    )
                    
                    completion(.success(responseObject))
                }
                else {
                    
                    var errorResponseObject = try JSONDecoder().decode(
                        ErrorResponse.self, from: data
                    )
                    
                    errorResponseObject.httpStatusCode = httpResponse.statusCode
                    completion(.failure(errorResponseObject))
                }
                
            } catch {
                apiLogger.error("urlDataTaskDecodeJSON:\n\(error)")
                completion(.failure(error))
            }
        }
        
    }
    
    @discardableResult
    private class func urlDataRequestWithBody<Body: Encodable, ResponseObject: Decodable>(
        url: URL,
        httpMethod: String,
        body: Body,
        headers: [(headerField: String, value: String)] = [
            (headerField: "Accept", value: "application/json"),
            (headerField: "Content-Type", value: "application/json"),
        ],
        responseType: ResponseObject.Type,
        completion: @escaping (Result<ResponseObject, Error>) -> Void
    ) -> URLSessionDataTask? {

        apiLogger.debug("performing url request for \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        for header in headers {
            request.addValue(
                header.value,
                forHTTPHeaderField: header.headerField
            )
        }
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
            apiLogger.debug("body: \(String(data: request.httpBody!, encoding: .utf8)!)")
        } catch {
            completion(.failure(error))
            return nil
        }
        
        let task = URLSession.shared.dataTask(
            with: request,
            completionHandler: urlDataTaskDecodeJSON(
                responseType: responseType,
                completion: completion
            )
        )
        task.resume()
        return task

    }
    
    @discardableResult
    private class func urlDataRequest<ResponseObject: Decodable>(
        url: URL,
        responseType: ResponseObject.Type,
        completion: @escaping (Result<ResponseObject, Error>) -> Void
    ) -> URLSessionDataTask {
        
        apiLogger.debug("performing url request for \(url.absoluteString)")
        
        let task = URLSession.shared.dataTask(
            with: url,
            completionHandler: urlDataTaskDecodeJSON(
                responseType: responseType,
                completion: completion
            )
        )
        task.resume()
        return task
        
    }

    
    
    


}
