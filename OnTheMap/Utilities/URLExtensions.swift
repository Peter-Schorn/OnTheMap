//
//  URLExtensions.swift
//  OnTheMap
//
//  Created by Peter Schorn on 7/2/20.
//  Copyright © 2020 Peter Schorn. All rights reserved.
//

import Foundation

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
