//
//  AuthService.swift
//  AuthiOSDemo
//
//  Created by Jason Maderski on 5/15/22.
//

import Foundation
import UIKit

/**
 * The [AuthService] offers functionality related to authentication with a SSO provider.
 */
protocol AuthService {
    /**
     * Launches a login screen, which opens a custom tab to the SSO Provider, so the user can login.
     * Uses the authorization code flow.
     * @param successLink the app link to redirect to after a successful authentication.
     * @see <a href="https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller">SFSafariViewController</a>
     */
    func launchLogin(presentingViewController: UIViewController, completion: @escaping AuthCompletionHandler) //FIXME: See if we should change use deeplinks like on Android
    
    /**
     * Launches a logout screen, which clears any auth-related data.
     * @param successLink the app link to redirect to after successfully ending the session.
     */
    func launchLogout(presentingViewController: UIViewController, completion: @escaping AuthCompletionHandler) //FIXME: See if we should change use deeplinks like on Android
    
    /**
     * If the user is authenticated, returns a [UserProfile]. Otherwise, returns null.
     */
    func getUserProfile() -> UserProfile?
    
    /**
     * If the user is authenticated, returns true. Otherwise, returns false.
     */
    func isAuthenticated() -> Bool
    
    /**
     * If the user is authenticated, returns a valid access token. Otherwise, returns null.
     */
    func getAccessToken() -> String?
}
