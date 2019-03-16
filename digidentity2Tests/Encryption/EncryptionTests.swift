//
//  EncryptionTests.swift
//  digidentity2Tests
//
//  Created by Adam Lovastyik on 16/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import XCTest
import CryptoSwift

class EncryptionTests: XCTestCase {

    func testLibraryFunctions() {
        
        let plainText = "This is the original text!"
        do {
            let aes = try AES(key: "passwordpasswordpasswordpassword", iv: "drowssapdrowssapdrowssapdrowssap")
            XCTAssertNotNil(aes)
            
            let encrypted = try aes.encrypt(Array(plainText.utf8))
            XCTAssertNotNil(encrypted)
            
            let encryptedText = String(bytes: encrypted, encoding: .utf8)!
            XCTAssertNotNil(encryptedText)
            XCTAssertNotEqual(plainText, encryptedText)
            
            let decrypted = try aes.decrypt(encrypted)
            XCTAssertNotNil(decrypted)
            
            let decryptedText = String(bytes: decrypted, encoding: .utf8)!
            XCTAssertNotNil(decryptedText)
            XCTAssertEqual(plainText, decryptedText)
        }
        catch let error {
            XCTAssertNotNil(error)
        }
    }
    
    func testEncryption() {

        let encryption = Encryption()

        let plainText = "Test String 1234567890!"

        let encrypted = encryption.encrypt(toBase64: plainText)
        XCTAssertNotNil(encrypted)

        let decrypted = encryption.decrypt(base64Encoded: encrypted!)
        XCTAssertNotNil(decrypted)

        XCTAssertNotEqual(plainText, encrypted)
        XCTAssertEqual(plainText, decrypted)
    }

}
