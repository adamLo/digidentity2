//
//  NetworkProtocols.swift
//  digidentity2
//
//  Created by Adam Lovastyik on 16/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import Foundation

typealias DataTaskResult = (Data?, URLResponse?, Error?) -> Void

protocol NetworkSessionProtocol {
    
    func startDataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult)
}
