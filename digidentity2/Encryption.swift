//
//  Encryption.swift
//  digidentity2
//
//  Created by Adam Lovastyik on 16/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import Foundation
import CryptoSwift

class Encryption {
    
    static let shared = Encryption()
    
    private struct Keys {
        static let key = "keykeykeykeykeykkeykeykeykeykeyk"
        static let vector = "drowssapdrowssap"
    }
    
    private lazy var cypher: AES? = {
       
        do {
            let aes = try AES(key: Keys.key, iv: Keys.vector)
            return aes
        }
        catch let error {
            print("Error initializing cypher: \(error)")
        }
        return nil
    }()
    
    var isSetup: Bool {        
        return cypher != nil
    }
    
    func encrypt(toBase64 plainText: String) -> String? {
        
        if let _cypher = cypher {
        
            do {
                let encrypted = try _cypher.encrypt(Array(plainText.utf8))
                let base64 = encrypted.toBase64()
                return base64
            }
            catch let error {
                print("Error encoding text: \(error)")
            }
        }
        
        return nil
    }
    
    func encrypt(data plainData: NSData) -> Data? {
        
        if let _cypher = cypher {
            
            do {
                let array = [UInt8](plainData as Data)
                let encrypted = try _cypher.encrypt(array)
                return Data(bytes: encrypted)
            }
            catch let error {
                print("Error encoding text: \(error)")
            }
        }
        
        return nil
    }
    
    func decrypt(base64String encrypted: String) -> String? {
        
        if let _cypher = cypher {
            
            do {
                
                let _encrypted = Array(base64: encrypted)
                let decrypted = try _cypher.decrypt(_encrypted)
                if let decryptedText = String(bytes: decrypted, encoding: .utf8) {
                    return decryptedText
                }
            }
            catch let error {
                print("Error encoding text: \(error)")
            }
        }
        
        return nil
    }
    
    func decrypt(Data encrypted: NSData) -> Data? {
        
        if let _cypher = cypher {
            
            do {
                
                let array = [UInt8](encrypted as Data)
                let _decrypted = try _cypher.decrypt(array)
                let data = Data(bytes: _decrypted)
                return data
//
//                if let encryptedString = String(data: encrypted as Data, encoding: .ascii) {
//
//                    let _encrypted = Array(base64: encryptedString)
//                    let decrypted = try _cypher.decrypt(_encrypted)
//                    if let decryptedText = String(bytes: decrypted, encoding: .utf8), let data = NSData(base64Encoded: decryptedText, options: .ignoreUnknownCharacters) {
//                        return data as Data
//                    }
//                }
            }
            catch let error {
                print("Error encoding text: \(error)")
            }
        }
        
        return nil
    }
}
