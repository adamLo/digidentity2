//
//  NetworkTest.swift
//  digidentity2Tests
//
//  Created by Adam Lovastyik on 16/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import XCTest

class NetworkTest: XCTestCase {

    override func setUp() {
        
        let session = MockNetworkURLSession()
        Network.shared.session = session
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNetworkExecute() {
        
        Network.shared.fetchItems { (success, error) in
            
            print("Success: \(success), error: \(error)")
            XCTAssertTrue(true, "Executed")
        }
    }

}
