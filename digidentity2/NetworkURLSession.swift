//
//  NetworkURLSession.swift
//  digidentity2
//
//  Created by Adam Lovastyik on 16/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import Foundation

class NetworkURLSession: NetworkSessionProtocol {
    
    static let shared = NetworkURLSession()
    
    private lazy var session: URLSession = {
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: Network.shared, delegateQueue: nil)
        return session
    }()
    
    func startDataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) {
        
        let task = session.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
}
