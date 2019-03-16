//
//  MockPersistence.swift
//  digidentity2Tests
//
//  Created by Adam Lovastyik on 16/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import Foundation

class MockPersistence: PersistenceProtocol {
    
    let insertedIds: [String]
    let updatedIds: [String]
    
    init(expectedInserts: [String], expectedUpdates: [String]) {
        
        self.insertedIds = expectedInserts
        self.updatedIds = expectedUpdates
    }
    
    func process(items: [JSONObject]) -> (inserted: Int, updated: Int, error: Error?) {
        
        var inserts = 0
        var updates = 0
        
        for object in items {
            
            if let _id = object[Item.JSON.id] as? String {

                if insertedIds.contains(_id) {
                    inserts += 1
                }
                else if updatedIds.contains(_id) {
                    updates += 1
                }
            }
        }
        
        return (inserted: inserts, updated: updates, error: nil)
    }
}
