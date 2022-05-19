//
//  AuthConfig.swift
//  AuthiOSDemo
//
//  Created by Jason Maderski on 5/15/22.
//

import Foundation

public struct AuthConfig {
    private let authorizeUri: String
    private let tokenUri: String
    private let endSessionUri: String
    private let redirectUri: String
    let clientId: String
    let scopes: String
    
    init(
        authorizeUri: String,
        tokenUri: String,
        endSessionUri: String,
        redirectUri: String,
        clientId: String,
        scopes: String
    ) {
        self.authorizeUri = authorizeUri
        self.tokenUri = tokenUri
        self.endSessionUri = endSessionUri
        self.redirectUri = redirectUri
        self.clientId = clientId
        self.scopes = scopes
    }
    
    func getAuthorizeUri() -> URL {
        return URL(self.authorizeUri)
    }
    
    func getTokenUri() -> URL {
        return URL(self.tokenUri)
    }
    
    func getEndSessionUri() -> URL {
        return URL(self.endSessionUri)
    }
    
    func getRedirectUri() -> URL {
        return URL(self.redirectUri)
    }
}

extension URL {
    init(_ string: String) {
        self.init(string: "\(string)")!
    }
}
