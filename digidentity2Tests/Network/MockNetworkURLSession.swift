//
//  MockNetworkURLSession.swift
//  digidentity2
//
//  Created by Adam Lovastyik on 16/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import Foundation

class MockNetworkURLSession: NetworkSessionProtocol {
    
    let loader = JSONLoader()
    
    func startDataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) {
     
        var data: Data?
        
        if let url = request.url?.absoluteURL {
        
            if request.httpMethod == HTTPMethod.get.rawValue && url.lastPathComponent == Network.Configuration.items {
                data = loader.load(jsonFile: "TestItems")
            }
            else if request.httpMethod == HTTPMethod.post.rawValue && url.lastPathComponent == Network.Configuration.item {
                data = loader.load(jsonFile: "Upload")
            }            
        }
        
        completionHandler(data, nil, nil)
    }
}
