//
//  Network.swift
//  digidentity2
//
//  Created by Adam Lovastyik on 14/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import Foundation

typealias JSONObject = [String: Any]
typealias JSONArray = [JSONObject]

class Network : NSObject, URLSessionDelegate {
    
    static let shared = Network()
    
    private lazy var session: URLSession = {
       
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        return session
    }()
    
    struct Configuration {
        
        static let baseURL = URL(string: "https://marlove.net/e/mock/v1")!
        
        static let certificateName = "certificate"
        static let certificateExt = "crt"
        static let authorization = "fa018047063f916d370cb0e07ae66b85"
        
        static let item = "item"
        static let items = "items"
    }
    
    // MARK: - Public functions
    
    func fetchItems(from startId: String? = nil, to endId: String? = nil, completion: ((_ success: Bool, _ error: Error?) -> ())?) {
        
        let url = Configuration.baseURL.appendingPathComponent(Configuration.items)
        var request = URLRequest(url: url)
        request.configure(method: .get, authorization: Configuration.authorization)
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            
            var success = false
            var _error: Error? = error
            
            if let _data = data, !_data.isEmpty {
                
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: _data, options: []) as? JSONArray {
                        
                        if !jsonArray.isEmpty {
                        
                            let context = Persistence.shared.createNewManagedObjectContext()
                            context.performAndWait {
                                
                                for jsonObject in jsonArray {
                                    
                                    if let identifier = jsonObject[Item.JSON.id] as? String, !identifier.isEmpty {

                                        var item: Item!
                                        if let _item = Item.find(by: identifier, in: context) {
                                            item = _item
                                        }
                                        else {
                                            item = Item.new(in: context)
                                        }
                                        item.update(with: jsonObject)
                                    }
                                }
                            }
                            
                            try context.save()
                        }
                        
                        success = true
                    }
                }
                catch let error2 {
                    _error = error2
                }
            }
            
            DispatchQueue.main.async {
                completion?(success, _error)
            }
        }
        
        dataTask.resume()
    }
    
    // MARK: - URLSession delegate for SSL pinning
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        if let serverTrust = challenge.protectionSpace.serverTrust, let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
        
            // FIXME: Remove this when
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
                let remoteCertificateData: NSData = SecCertificateCopyData(certificate)
                if let pathToCertificate = Bundle.main.path(forResource: Configuration.certificateName, ofType: Configuration.certificateExt), let localCertificateData: NSData = NSData(contentsOfFile: pathToCertificate) {

                    // Compare certificates
                    if isServerTRusted && remoteCertificateData.isEqual(to: localCertificateData as Data) {
                        let credential: URLCredential =  URLCredential(trust:serverTrust)
                        completionHandler(.useCredential, credential)
                    }
                }
            }
        }
        
        completionHandler(.cancelAuthenticationChallenge, nil)
    }

}


