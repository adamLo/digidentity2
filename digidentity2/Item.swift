//
//  Item.swift
//  digidentity2
//
//  Created by Adam Lovastyik on 14/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import ImageIO

extension Item {
    
    static let entityName = "Item"
    static let identifier = "identifier"
    
    struct JSON {
        
        static let id = "_id"
        static let text = "text"
        static let confidence = "confidence"
        static let img = "img"
        static let image = "image"
    }
    
    class func findEntities(by idvalue: String, in context: NSManagedObjectContext) -> [Any]? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "%K = %@", identifier, idvalue)
        
        do {
            
            let results = try context.fetch(fetchRequest)
            return results
        }
        catch let error {
            print("Error fetching Items: \(error)")
        }
        
        return nil
    }
    
    class func findEntity(by idvalue: String, in context: NSManagedObjectContext) -> Any? {
        
        let item = findEntities(by: idvalue, in: context)?.first
        return item
    }
    
    class func find(by idvalue: String, in context: NSManagedObjectContext) -> Item? {
        
        return findEntity(by: idvalue, in: context) as? Item
    }
    
    class func new(in context: NSManagedObjectContext) -> Item {
        
        let description = NSEntityDescription.entity(forEntityName: entityName, in: context)!
        let item = Item(entity: description, insertInto: context)
        return item
    }
    
    func update(with json: JSONObject, encrypt: Bool) {
        
        encrypted = false
        
        if let _id = json[JSON.id] as? String {
            identifier = _id
        }
        
        if let _text = json[JSON.text] as? String {
            text = _text
            if encrypt && Encryption.shared.isSetup, let encryptedText = Encryption.shared.encrypt(toBase64: _text) {
                encrypted = true
                text = encryptedText
            }
        }
        
        if let _confidence = json[JSON.confidence] as? Double {
            confidence = _confidence
        }
        
        let img = json[JSON.img] ?? json[JSON.image]
        if let _img = img as? String, !_img.isEmpty, let data = NSData(base64Encoded: _img, options: .ignoreUnknownCharacters) {
            imageData = data
            if encrypt && Encryption.shared.isSetup, let encryptedData = Encryption.shared.encrypt(data: data) {
                encrypted = true
                imageData = encryptedData as NSData
            }
        }
    }
    
    static func uploadData(image: UIImage, text: String, confidence: Double) -> Data? {
        
        if let imageData = image.jpegData(compressionQuality: 0.7) {
            
            var json = JSONObject()
            json[JSON.confidence] = confidence
            json[JSON.text] = text
            json[JSON.image] = imageData.base64EncodedString()
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                return jsonData
            }
            catch {}
        }
        
        return nil
    }
    
    class func delete(identifier: String, in context: NSManagedObjectContext) -> Int {
        
        var deleted = 0
        
        if let entities = findEntities(by: identifier, in: context) {
            
            for entity in entities {
                
                if let _entity = entity as? NSManagedObject {
                    
                    context.delete(_entity)
                    deleted += 1
                }
            }
        }
        
        return deleted
    }
}
