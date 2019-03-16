//
//  MockNetworkURLSession.swift
//  digidentity2
//
//  Created by Adam Lovastyik on 16/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import Foundation

class MockNetworkURLSession: NetworkSessionProtocol {
    
    private func load(jsonFile: String) -> Data? {
        
        let bundle = Bundle(for: type(of: self))
        
        if let url = bundle.url(forResource: jsonFile, withExtension: "json") {
            
            if let _data = try? Data(contentsOf: url) {
                return _data
            }
        }
        
        return nil
    }
    
    func startDataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) {
     
        let data = load(jsonFile: "TestItems")
        
        completionHandler(data, nil, nil)
    }
}
