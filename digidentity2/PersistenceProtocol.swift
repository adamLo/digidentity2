//
//  PersistenceProtocol.swift
//  digidentity2
//
//  Created by Adam Lovastyik on 16/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import Foundation

protocol PersistenceProtocol {
    
    func process(items: [JSONObject]) -> (inserted: Int, updated: Int, error: Error?)
}
