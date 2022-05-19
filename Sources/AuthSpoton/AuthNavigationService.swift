//
//  AuthNavigationService.swift
//  AuthiOSDemo
//
//  Created by Jason Maderski on 5/17/22.
//

import Foundation
import AppAuth

public protocol AuthNavigationService {
    
    /**
     * Get the app link to redirect to after a successful authentication.
     */
    func getAuthenticatedLink() -> String
    
    /**
     * Set the app link to redirect to after a successful authentication.
     */
    func setAuthenticatedLink(successLink: String?)
    
    /**
     * Get the app link to redirect to after a successful end session.
     */
    func getEndSessionLink() -> String
    
    /**
     * Set the app link to redirect to after a successful end session.
     */
    func setEndSessionLink(successLink: String)
    
    /**
     * On the [AuthenticatedScreen], set some state values from the authorization code response.
     */
    func saveStateFromAuthCode(codeRes: OIDAuthorizationResponse?, err: Error)
}
