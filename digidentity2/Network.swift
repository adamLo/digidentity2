//
//  Network.swift
//  digidentity2
//
//  Created by Adam Lovastyik on 14/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import Foundation
import UIKit

typealias JSONObject = [String: Any]
typealias JSONArray = [JSONObject]

typealias FetchCompletion = ((_ inserted: Int, _ updated: Int, _ error: Error?) -> ())
typealias OperationCompletion = ((_ success: Bool, _ error: Error?) -> ())

class Network : NSObject, URLSessionDelegate {
    
    static let shared = Network()
    
    var session: NetworkSessionProtocol?
    var activityDelegate: NetworkActivityProtocol?
    var persistence: PersistenceProtocol?
    
    struct Configuration {
        
        static let baseURL = URL(string: "https://marlove.net/e/mock/v1")!
        
        static let certificateName = "certificate"
        static let certificateExt = "crt"
        static let authorization = "fa018047063f916d370cb0e07ae66b85"
        
        static let item = "item"
        static let items = "items"
        
        static let paramSinceId = "since_id"
        static let paramMaxId = "max_id"
    }
    
    typealias ErrorData = (code: Int, message: String)
    struct Errors {
        
        static let domain = "API"
        
        static let emptyData: ErrorData = (code: -1111, message: NSLocalizedString("Empty data received", comment: "Error message when empty data received from the api"))
        static let sessionNotConfigured: ErrorData = (code: -2222, message: NSLocalizedString("Session not configured", comment: "Error message when session not configured"))
        static let persistenceNotConfigured: ErrorData = (code: -3333, message: NSLocalizedString("Persistence not cnofigured", comment: "Error message when persistencer layer not configured"))
        static let encodeError: ErrorData = (code: -4444, message: NSLocalizedString("Failed to encode data for upload", comment: "Error message when failed to encode data for upload"))
        static let uploadError: ErrorData = (code: -5555, message: NSLocalizedString("Failed to upload image", comment: "Error message when failed to upload data"))
        static let deleteError: ErrorData = (code: -6666, message: NSLocalizedString("Failed to delete item", comment: "Error message when failed to delete item"))
    }
    
    // MARK: - Public functions
    
    func fetchItems(since startId: String? = nil, before endId: String? = nil, completion: FetchCompletion?) {
        
        guard let _session = session else {
            completion?(0, 0, NSError(domain: Errors.domain, code: Errors.sessionNotConfigured.code, userInfo: [NSLocalizedDescriptionKey: Errors.sessionNotConfigured.message]))
            return
        }
        
        guard let _persistence = persistence else {
            completion?(0, 0, NSError(domain: Errors.domain, code: Errors.persistenceNotConfigured.code, userInfo: [NSLocalizedDescriptionKey: Errors.persistenceNotConfigured.message]))
            return
        }
        
        var url = Configuration.baseURL.appendingPathComponent(Configuration.items)
        if let _start = startId {
            url = url.appendQueryItem(with: Configuration.paramSinceId, value: _start)
        }
        if let _end = endId {
            url = url.appendQueryItem(with: Configuration.paramMaxId, value: _end)
        }
        
        var request = URLRequest(url: url)
        request.configure(method: .get, authorization: Configuration.authorization)
        
        _session.startDataTask(with: request) { (data, response, error) in
            
            DispatchQueue.main.async {
                self.activityDelegate?.showNetworkActivityIndicator()
            }
            
            var inserted = 0
            var updated = 0
            var _error: Error? = error
            
            if let _data = data, !_data.isEmpty {
                
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: _data, options: []) as? JSONArray {
                        
                        let (processInsert, processUpdate, processError) = _persistence.process(items: jsonArray)
                        
                        _error = processError
                        inserted = processInsert
                        updated = processUpdate
                    }
                }
                catch let error2 {
                    _error = error2
                }
            }
            else if _error == nil {
                _error = NSError(domain: Errors.domain, code: Errors.emptyData.code, userInfo: [NSLocalizedDescriptionKey: Errors.emptyData.message])
            }
            
            DispatchQueue.main.async {
                self.activityDelegate?.hideNetworkActivityIndicator()
                completion?(inserted, updated, _error)
            }
        }
    }
    
    func upload(image: UIImage, text: String, confidence: Double, completion: OperationCompletion?) {
        
        guard let _session = session else {
            completion?(false, NSError(domain: Errors.domain, code: Errors.sessionNotConfigured.code, userInfo: [NSLocalizedDescriptionKey: Errors.sessionNotConfigured.message]))
            return
        }
        
        guard let _persistence = persistence else {
            completion?(false, NSError(domain: Errors.domain, code: Errors.persistenceNotConfigured.code, userInfo: [NSLocalizedDescriptionKey: Errors.persistenceNotConfigured.message]))
            return
        }
        
        guard let jsonData = Item.uploadData(image: image, text: text, confidence: confidence) else {
            completion?(false, NSError(domain: Errors.domain, code: Errors.encodeError.code, userInfo: [NSLocalizedDescriptionKey: Errors.encodeError.message]))
            return
        }
        
        let url = Configuration.baseURL.appendingPathComponent(Configuration.item)
        var request = URLRequest(url: url)
        request.configure(method: .post, authorization: Configuration.authorization, data: jsonData)
        
        _session.startDataTask(with: request) { (data, response, error) in
            
            DispatchQueue.main.async {
                self.activityDelegate?.showNetworkActivityIndicator()
            }
            
            var success = false
            var _error: Error? = error
            
            if let _data = data, !_data.isEmpty {
                
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: _data, options: []) as? JSONObject {
                        
                        let (processInsert, processUpdate, processError) = _persistence.process(items: [jsonObject])
                        
                        _error = processError
                        success = processInsert > 0 || processUpdate > 0
                    }
                    else {
                        _error = NSError(domain: Errors.domain, code: Errors.uploadError.code, userInfo: [NSLocalizedDescriptionKey: Errors.uploadError.message])
                    }
                }
                catch let error2 {
                    _error = error2
                }
            }
            else if _error == nil {
                _error = NSError(domain: Errors.domain, code: Errors.emptyData.code, userInfo: [NSLocalizedDescriptionKey: Errors.emptyData.message])
            }
            
            DispatchQueue.main.async {
                self.activityDelegate?.hideNetworkActivityIndicator()
                completion?(success, _error)
            }
        }
    }
    
    func delete(itemId: String, completion: OperationCompletion?) {
        
        guard let _session = session else {
            completion?(false, NSError(domain: Errors.domain, code: Errors.sessionNotConfigured.code, userInfo: [NSLocalizedDescriptionKey: Errors.sessionNotConfigured.message]))
            return
        }
        
        guard let _persistence = persistence else {
            completion?(false, NSError(domain: Errors.domain, code: Errors.persistenceNotConfigured.code, userInfo: [NSLocalizedDescriptionKey: Errors.persistenceNotConfigured.message]))
            return
        }
        
        let url = Configuration.baseURL.appendingPathComponent(Configuration.item).appendingPathComponent(itemId)
        var request = URLRequest(url: url)
        request.configure(method: .delete, authorization: Configuration.authorization)
        
        _session.startDataTask(with: request) { (data, response, error) in
            
            DispatchQueue.main.async {
                self.activityDelegate?.showNetworkActivityIndicator()
            }
            
            var success = false
            var _error: Error? = error
            
            if error == nil, let _response = response as? HTTPURLResponse, _response.statusCode != 200 {
                _error = NSError(domain: Errors.domain, code: Errors.deleteError.code, userInfo: [NSLocalizedDescriptionKey: Errors.deleteError.message])
            }
            
            success = _error == nil
            
            // Delete regardless backend operation result as it may not be in sync with local cache (e.g. deleting an item thart has been already removed from the backend
            let _ = _persistence.delete(itemId: itemId)
            
            DispatchQueue.main.async {
                self.activityDelegate?.hideNetworkActivityIndicator()
                completion?(success, _error)
            }
        }
    }
    
    // MARK: - URLSession delegate for SSL pinning
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        if let serverTrust = challenge.protectionSpace.serverTrust {
        
            // FIXME: Remove this when remote certificate (or local?) is fixed so they match
            let credential: URLCredential =  URLCredential(trust:serverTrust)
            completionHandler(.useCredential, credential)
            return

            // Set SSL polocies for domain name check
            let policies = NSMutableArray()
            policies.add(SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString))
            SecTrustSetPolicies(serverTrust, policies)

            // Evaluate server certifiacte
            if var result: SecTrustResultType = SecTrustResultType(rawValue: 0) {
                SecTrustEvaluate(serverTrust, &result)
                let isServerTRusted: Bool = (result == SecTrustResultType.unspecified || result == SecTrustResultType.proceed)

                // Get Local and Remote certificate Data
                for certIndex in 0..<SecTrustGetCertificateCount(serverTrust) {
                    
                    if let certificate = SecTrustGetCertificateAtIndex(serverTrust, certIndex) {
                    
                        let remoteCertificateData: NSData = SecCertificateCopyData(certificate)
                        if let pathToCertificate = Bundle.main.path(forResource: Configuration.certificateName, ofType: Configuration.certificateExt), let localCertificateData: NSData = NSData(contentsOfFile: pathToCertificate) {
                            
                            // Compare certificates
                            // !!!: This is where SSL pinning fails: remote certificate doesn't match local
                            if isServerTRusted && remoteCertificateData.isEqual(to: localCertificateData as Data) {
                                let credential: URLCredential =  URLCredential(trust:serverTrust)
                                completionHandler(.useCredential, credential)
                                return
                            }
                        }
                    }
                }
            }
        }
        
        completionHandler(.cancelAuthenticationChallenge, nil)
    }

}


