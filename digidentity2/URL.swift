//
//  URL.swift
//  digidentity2
//
//  Created by Adam Lovastyik on 14/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import Foundation

extension URL {
    
    func appendQueryItem(with name: String, value: String) -> URL {
        
        let queryItem = URLQueryItem(name: name, value: value)
        
        var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false)!
        if urlComponents.queryItems != nil {
            
            urlComponents.queryItems?.append(queryItem)
        }
        else {
            urlComponents.queryItems = [queryItem]
        }
        
        let url = urlComponents.url!
        
        return url
    }
}
