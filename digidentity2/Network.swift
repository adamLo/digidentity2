//
//  Network.swift
//  digidentity2
//
//  Created by Adam Lovastyik on 14/03/2019.
//  Copyright © 2019 Lovastyik. All rights reserved.
//

import Foundation

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
    
    func fetchItems(from startId: String? = nil, to endId: String? = nil) {
        
        let url = Configuration.baseURL.appendingPathComponent(Configuration.items)
        var request = URLRequest(url: url)
        request.configure(method: .get, authorization: Configuration.authorization)
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            
            print("done")
        }
        
        dataTask.resume()
    }
    
    // MARK: - URLSession delegate for SSL pinning
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        let serverTrust = challenge.protectionSpace.serverTrust
        let certificate = SecTrustGetCertificateAtIndex(serverTrust!, 0)

        // Set SSL polocies for domain name check
        let policies = NSMutableArray()
        policies.add(SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString))
        SecTrustSetPolicies(serverTrust!, policies)

        // Evaluate server certifiacte
        var result:SecTrustResultType = SecTrustResultType(rawValue: 0)!
        SecTrustEvaluate(serverTrust!, &result)
        let isServerTRusted: Bool = (result == SecTrustResultType.unspecified || result == SecTrustResultType.proceed)

        // Get Local and Remote certificate Data
        let remoteCertificateData: NSData = SecCertificateCopyData(certificate!)
        let pathToCertificate = Bundle.main.path(forResource: Configuration.certificateName, ofType: Configuration.certificateExt)
        let localCertificateData: NSData = NSData(contentsOfFile: pathToCertificate!)!

        // Compare certificates
        if isServerTRusted && remoteCertificateData.isEqual(to: localCertificateData as Data) {
            let credential:URLCredential =  URLCredential(trust:serverTrust!)
            completionHandler(.useCredential,credential)
        }
        else {
            completionHandler(.cancelAuthenticationChallenge,nil)
        }
    }

}


