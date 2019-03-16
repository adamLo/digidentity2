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
     
        let data = loader.load(jsonFile: "TestItems")
        
        completionHandler(data, nil, nil)
    }
}
