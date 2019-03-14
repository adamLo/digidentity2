//
//  NSURLRequest.swift
//  digidentity2
//
//  Created by Adam Lovastyik on 14/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    
    case post   = "POST"
    case patch  = "PATCH"
    case get    = "GET"
    case delete = "DELETE"
}

extension URLRequest {
    
    mutating func configure(method: HTTPMethod, authorization: String? = nil, data: Data? = nil, jsonContentType: Bool = true) {
        
        httpMethod = method.rawValue
        
        if jsonContentType {
            addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        addValue("application/json", forHTTPHeaderField: "Accept")
        
        if let _auth = authorization {
            addValue(_auth, forHTTPHeaderField: "Authorization")
        }
        
        httpBody = data
    }
}
