//
//  RequestConfiguraion.swift
//  EyeOfTheTiger
//
//  Created by Vladimir Khabarov on 19.04.2018.
//  Copyright © 2018 FTC. All rights reserved.
//

import Foundation

//TODO: move to extension of URLRequest
final class Request {
    
    static func configure(url: URL,
                          httpMethod: String,
                          headerFields: [String: String]) -> URLRequest {
        
        var request = URLRequest(url: url)
        
        request.httpMethod = httpMethod
        for pair in headerFields {
            request.addValue(pair.value, forHTTPHeaderField: pair.key)
        }
        
        return request
    }
    
    static func configure<ResponseType: Encodable>(with obj: ResponseType,
                                                   url: URL, httpMethod: String,
                                                   headerFields: [String: String]) throws -> URLRequest {
        
        do {
            let objBody = try JSONEncoder().encode(obj)
            
            var request = self.configure(url: url, httpMethod: httpMethod, headerFields: headerFields)
            request.httpBody = objBody
            
            return request
        }
        catch let error {
            throw error
        }
    }
}
