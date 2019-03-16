//
//  NetworkTest.swift
//  digidentity2Tests
//
//  Created by Adam Lovastyik on 16/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import XCTest

class NetworkTest: XCTestCase {

    private var session: MockNetworkURLSession!
    
    override func setUp() {
        
        session = MockNetworkURLSession()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetchItemsInsertSuccess() {
        
        let mockPersistence = MockPersistence(expectedInserts: ["aa111"], expectedUpdates: [])
        
        let network = Network()
        network.session = session
        network.persistence = mockPersistence
        network.fetchItems { (inserted, updated, error) in

            XCTAssertEqual(inserted, 1)
            XCTAssertEqual(updated, 0)
            XCTAssertTrue(error == nil)
        }
    }
    
    func testFetchItemsUpdateSuccess() {

        let mockPersistence = MockPersistence(expectedInserts: [], expectedUpdates: ["aa111"])
        
        let network = Network()
        network.session = session
        network.persistence = mockPersistence
        network.fetchItems { (inserted, updated, error) in

            XCTAssertEqual(inserted, 0)
            XCTAssertEqual(updated, 1)
            XCTAssertTrue(error == nil)
        }
    }

    func testFetchItemsInsertFail() {

        let mockPersistence = MockPersistence(expectedInserts: ["wrong_id"], expectedUpdates: [])
        
        let network = Network()
        network.session = session
        network.persistence = mockPersistence
        network.fetchItems { (inserted, updated, error) in

            XCTAssertEqual(inserted, 0)
            XCTAssertEqual(updated, 0)
            XCTAssertTrue(error == nil)
        }
    }

    func testFetchItemsUpdateFail() {

        let mockPersistence = MockPersistence(expectedInserts: [], expectedUpdates: ["wrong_id"])
        
        let network = Network()
        network.session = session
        network.persistence = mockPersistence
        network.fetchItems { (inserted, updated, error) in

            XCTAssertEqual(inserted, 0)
            XCTAssertEqual(updated, 0)
            XCTAssertTrue(error == nil)
        }
    }

    func testUpload() {
        
        let mockPersistence = MockPersistence(expectedInserts: ["bbb222"], expectedUpdates: [])
        
        let network = Network()
        network.session = session
        network.persistence = mockPersistence
        
        let bundle = Bundle.init(for: PersistenceTests.self)
        let image = UIImage(named: "testimage", in: bundle, compatibleWith: nil)
        XCTAssertNotNil(image)
        
        let jsonData = Item.uploadData(image: image!, text: "TEST", confidence: 9.999)
        XCTAssertNotNil(jsonData)
        
        network.upload(image: image!, text: "Uploaded", confidence: 0.999) { (success, error) in
            
            XCTAssertTrue(error == nil)
            XCTAssertTrue(success)
        }
    }
}
