//
//  WebRequest.swift
//  EyeOfTheTiger
//
//  Created by Vladimir Khabarov on 17.04.2018.
//  Copyright © 2018 FTC. All rights reserved.
//

import Foundation

class WebRequest
{
    enum Result<T>
    {
        case success(data: T)
        case error(Error?)
    }
    
    let session: URLSession
    let decoder: JSONDecoder

    init(session: URLSession, decoder: JSONDecoder)
    {
        self.session = session
        self.decoder = decoder
    }
    
    func perform<ResponseType: Decodable>(request: URLRequest,
                                          completion: @escaping (_ result: Result<ResponseType>) -> Void) {
        
        let requestCompletion = { (data: Data?, response: URLResponse?, error: Error?) in
            
            guard let data = data else {
                completion(.error(error))
                return
            }

            do {
                let result = try self.decoder.decode(ResponseType.self, from: data)
                completion(.success(data: result))
            }
            catch let error
            {
                completion(.error(error))
            }
        }
        
        let dataTask = self.session.dataTask(with: request, completionHandler: requestCompletion)
        dataTask.resume()
    }
}

