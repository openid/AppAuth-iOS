//
//  ExternalUserAgentMock.swift
//  Example
//
//  Copyright © 2023 Akamai Technologies, Inc. All rights reserved.
//


import Foundation
import AppAuth

class OIDExternalUserAgentMock {
    var authResponse: OIDAuthorizationResponse?
    let appAuthMocks = AppAuthMocks()
    
    func getExternalUserAgentSession() -> OIDExternalUserAgentSession {
        let userAgentMock = ExternalUserAgentSessionMock()
        
        let session = OIDAuthorizationService.present(
            appAuthMocks.getAuthRequestMock()!,
            externalUserAgent: userAgentMock) { response, error in
                
                if let response = response {
                    self.authResponse = response
                }
            }
        
        return session
    }
}

// MARK: - OIDExternalUserAgentSessionMock -

protocol ExternalUserAgentSessionMockProtocol: OIDExternalUserAgent, URLSessionTaskDelegate {
    var urlSession: URLSession? { get set }
    var session: OIDExternalUserAgentSession? { get set }
}

class ExternalUserAgentSessionMock: NSObject, ExternalUserAgentSessionMockProtocol {
    
    var urlSession: URLSession?
    var session: OIDExternalUserAgentSession?
    
    func present(_ request: OIDExternalUserAgentRequest, session: OIDExternalUserAgentSession) -> Bool {
        self.session = session
        
        let requestUrl = request.externalUserAgentRequestURL()
        let URLRequest = URLRequest(url: requestUrl!)
        let config = URLSession.shared.configuration
        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        urlSession?.dataTask(with: URLRequest) { data, response, error in
            let httpResponse = response as! HTTPURLResponse
            let headers = httpResponse.allHeaderFields
            let location = headers["Location"]
            let url = URL(string: location as! String)
            session.resumeExternalUserAgentFlow(with: url!)
        }
        
        return true
    }
    
    func dismiss(animated: Bool, completion: @escaping () -> Void) {
        completion()
    }
}

extension ExternalUserAgentSessionMock: URLSessionDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        completionHandler(nil)
    }
}
