//
//  OCRTests.swift
//  digidentity2Tests
//
//  Created by Adam Lovastyik on 16/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import XCTest
import SwiftyTesseract

class OCRTests: XCTestCase {

    private var image: UIImage!
    private let testString = "The quick brown fox jumps over the lazy dog\n0123456789"
    
    override func setUp() {
        
        let bundle = Bundle.init(for: OCRTests.self)
        image = UIImage(named: "testimage", in: bundle, compatibleWith: nil)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testOCR() {
        
        XCTAssertNotNil(image)
        
        let swiftyTesseract = SwiftyTesseract(language: .custom("enm"))
        swiftyTesseract.performOCR(on: image) { recognizedString in
            
            XCTAssertEqual(self.testString, recognizedString?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        }
    }

}
