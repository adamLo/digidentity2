//
//  Item.swift
//  digidentity2
//
//  Created by Adam Lovastyik on 14/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import Foundation
import CoreData

extension Item {
    
    static let entityName = "Item"
    static let identifier = "identifier"
    
    struct JSON {
        
        static let id = "_id"
        static let text = "text"
        static let confidence = "confidence"
        static let img = "img"
    }
    
    class func find(by idvalue: String, in context: NSManagedObjectContext) -> Item? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "%K = %@", identifier, idvalue)
        fetchRequest.fetchLimit = 1
        
        do {
            
            if let results = try context.fetch(fetchRequest) as? [Item] {
                return results.first
            }
        }
        catch let error {
            print("Error fetching Items: \(error)")
        }
        
        return nil
    }
    
    class func new(in context: NSManagedObjectContext) -> Item {
        
        let description = NSEntityDescription.entity(forEntityName: entityName, in: context)!
        let item = Item(entity: description, insertInto: context)
        return item
    }
    
    func update(with json: JSONObject) {
        
        if let _id = json[JSON.id] as? String {
            identifier = _id
        }
        
        if let _text = json[JSON.text] as? String {
            text = _text
        }
        
        if let _confidence = json[JSON.confidence] as? Double {
            confidence = _confidence
        }
        
        if let _img = json[JSON.img] as? String, !_img.isEmpty, let data = NSData(base64Encoded: _img, options: .ignoreUnknownCharacters) {
            imageData = data
        }
    }
}
