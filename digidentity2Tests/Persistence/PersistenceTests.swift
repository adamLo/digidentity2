//
//  PersistenceTests.swift
//  digidentity2Tests
//
//  Created by Adam Lovastyik on 16/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import XCTest
import CoreData
//@testable import Item

class PersistenceTests: XCTestCase {
    
    private var persistence: Persistence!

    override func setUp() {
        
        persistence = Persistence()
        XCTAssertNotNil(persistence)
        persistence.setupInMemoryPersistentStore()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testMainContextNotNil() {
        
        XCTAssertNotNil(persistence)
        
        let context = persistence.managedObjectContext
        XCTAssertNotNil(context)
    }
    
    func testInsertItem() {
        
        let context = persistence.createNewManagedObjectContext()
        XCTAssertNotNil(context)
        
        var error: Error?
        context.performAndWait {
            do {
                
                let item = Item.new(in: context)
                item.identifier = UUID().uuidString
                try context.save()
            }
            catch let _error {
                error = _error
            }
        }
        
        XCTAssertNil(error, "Error saving item")
    }
    
    func testFindItem() {
        
        let context = persistence.createNewManagedObjectContext()
        XCTAssertNotNil(context)
        
        let id = UUID().uuidString
        var error: Error?
        context.performAndWait {
            do {
                
                let item = Item.new(in: context)
                item.identifier = id
                try context.save()
                
                let _item = Item.findEntity(by: id, in: context)
                XCTAssertNotNil(_item)
            }
            catch let _error {
                error = _error
            }
        }
        
        XCTAssertNil(error, "Error saving item")
    }
    
    func testJSONParsingUnencrypted() {
        
        let context = persistence.createNewManagedObjectContext()
        XCTAssertNotNil(context)
        
        let item = Item.new(in: context)
        XCTAssertNotNil(item)
        
        let json = JSONLoader().parse(jsonFile: "TestItems")!.first!
        XCTAssertNotNil(json)
        
        item.update(with: json, encrypt: false)
        XCTAssertEqual(item.identifier, "aa111")
        XCTAssertNotNil(item.imageData)
        XCTAssertEqual(item.text, "Hello world!")
        XCTAssertEqual(item.confidence, 0.7)
    }
    
    func testJSONParsingEncrypted() {
        
        let context = persistence.createNewManagedObjectContext()
        XCTAssertNotNil(context)
        
        let item = Item.new(in: context)
        XCTAssertNotNil(item)
        
        let json = JSONLoader().parse(jsonFile: "TestItems")!.first!
        XCTAssertNotNil(json)
        
        item.update(with: json, encrypt: true)
        XCTAssertTrue(item.encrypted)
        
        XCTAssertEqual(item.identifier, "aa111")
        
        XCTAssertNotNil(item.imageData)
        let encryptedData = Encryption.shared.decrypt(Data: item.imageData!)
        XCTAssertNotNil(encryptedData)
        
        let _img = json[Item.JSON.img] as? String
        XCTAssertNotNil(_img)
        let data = NSData(base64Encoded: _img!, options: .ignoreUnknownCharacters)
        XCTAssertNotNil(data)
        XCTAssertEqual(data! as Data, encryptedData)
        
        XCTAssertNotNil(item.text)
        let decryptedText = Encryption.shared.decrypt(base64String: item.text!)
        XCTAssertEqual(decryptedText, "Hello world!")
        
        XCTAssertEqual(item.confidence, 0.7)
    }

    func testUploadData() {
        
        let bundle = Bundle.init(for: PersistenceTests.self)
        let image = UIImage(named: "testimage", in: bundle, compatibleWith: nil)
        XCTAssertNotNil(image)
        
        let jsonData = Item.uploadData(image: image!, text: "TEST", confidence: 9.999)
        XCTAssertNotNil(jsonData)
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData!, options: []) as? JSONObject
            XCTAssertNotNil(jsonObject)
            
            XCTAssertEqual(jsonObject![Item.JSON.confidence] as? Double, 9.999)
            XCTAssertEqual(jsonObject![Item.JSON.text] as? String, "TEST")
            XCTAssertNotNil(jsonObject![Item.JSON.image])
        }
        catch let error {
            XCTAssertNotNil(error)
        }
        
    }
}
