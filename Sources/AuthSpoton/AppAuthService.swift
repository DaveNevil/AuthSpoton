//
//  AppAuthService.swift
//  AuthiOSDemo
//
//  Created by Jason Maderski on 5/17/22.
//

import Foundation
import AppAuth
import JWTDecode
import SwiftCoroutine
import UIKit

enum AuthServiceError: Error {
    case claimKeyWithNoValue
    case invalidUserAgent
    case userTokenNotFound
    case unableToRetrieveToken
    case authResponseAccessTokenIsNil
    case authResponseRefreshTokenIsNil
    case authResponseIDTokenIsNill
    case unableToUpdateState
}

public typealias AuthCompletionHandler = (_ error: Error?) -> Void

public class AppAuthService : AuthService {
    private var session: AnyObject?
    private let authConfig: AuthConfig
    private let authStateRepository: AuthStateRepository
    private let serviceConfig: OIDServiceConfiguration
    
    private var userProfile: UserProfile? = nil
    
    public init(authConfig: AuthConfig, authStateRepository: AuthStateRepository) {
        self.serviceConfig = OIDServiceConfiguration(
            authorizationEndpoint: authConfig.getAuthorizeUri(),
            tokenEndpoint: authConfig.getTokenUri(),
            issuer: nil,
            registrationEndpoint: nil,
            endSessionEndpoint: authConfig.getEndSessionUri()
        )
        
        self.authStateRepository = authStateRepository
        self.authConfig = authConfig
    }
    
    public func launchLogin(presentingViewController: UIViewController, completion: @escaping AuthCompletionHandler) {
        DispatchQueue.main.startCoroutine {
            let authCodeRequest = OIDAuthorizationRequest(
                configuration: self.serviceConfig,
                clientId: self.authConfig.clientId,
                scopes: self.authConfig.scopes.components(separatedBy: " "),
                redirectURL: self.authConfig.getRedirectUri(),
                responseType: OIDResponseTypeCode,
                additionalParameters: nil
            )
            
            guard let userAgent = OIDExternalUserAgentIOS(presenting: presentingViewController) else {
                completion(AuthServiceError.invalidUserAgent)
                return
            }
            
            self.session = OIDAuthorizationService.present(
                authCodeRequest,
                externalUserAgent: userAgent) {[weak self] authorizationResponse, error in
                    if let result = authorizationResponse {
                        completion(nil)
                        print("Authorization response received successfully")
                        self?.saveStateFromAuthCode(authorizationResponse: result)
                    } else {
                        if let err = error, self?.isUserCancellationErrorCode(ex: err) != nil {
                            completion(error)
                            print("User cancelled the ASWebAuthenticationSession window")
                        } else {
                            print("Authorization Request Error")
                        }
                    }
                }
        }
    }
    
    /**
     * Set some state values from the authorization code response.
     */
    private func saveStateFromAuthCode(authorizationResponse: OIDAuthorizationResponse?) {
        DispatchQueue.main.startCoroutine {
            do {
                if authorizationResponse != nil {
                    try DispatchQueue.global().await {
                        let tokenResponse = try self.redeemCodeForTokens(
                            clientID: self.authConfig.clientId,
                            authResponse: authorizationResponse!
                        ).await()
                        
                        // Save the AuthState
                        let state = OIDAuthState(authorizationResponse: authorizationResponse!)
                        state.update(with: tokenResponse, error: AuthServiceError.unableToUpdateState)
                        self.authStateRepository.set(state: state)
                        print("STATE SAVED: \(state)")
                    }
                }
            } catch {
                // FIXME: Need to handle errors
                print("ERROR")
            }
        }
    }
    
    public func launchLogout(presentingViewController: UIViewController, completion: @escaping AuthCompletionHandler) {
        DispatchQueue.main.startCoroutine {
            self.userProfile = nil
            
            guard let idToken = self.authStateRepository.get()?.lastTokenResponse?.idToken else {
                completion(AuthServiceError.userTokenNotFound)
                return
            }
            
            let logoutRequest = OIDEndSessionRequest(
                configuration: self.serviceConfig,
                idTokenHint: idToken,
                postLogoutRedirectURL: self.authConfig.getRedirectUri(),
                additionalParameters: nil
            )
            
            guard let userAgent = OIDExternalUserAgentIOS(presenting: presentingViewController) else {
                completion(AuthServiceError.invalidUserAgent)
                return
            }
            
            self.session = OIDAuthorizationService.present(
                logoutRequest,
                externalUserAgent: userAgent
            ) { [weak self] endSessionResponse, error in
                if endSessionResponse != nil {
                    self?.authStateRepository.clear()
                    completion(nil)
                    print("End Session Authorization response received successfully")
                } else {
                    if let err = error, self?.isUserCancellationErrorCode(ex: err) != nil {
                        print("User cancelled the ASWebAuthenticationSession window")
                    } else {
                        print("End Session Authorization Request Error")
                    }
                }
            }
        }
    }
    
    public func getUserProfile() -> UserProfile? {
        if userProfile != nil {
            return userProfile
        }
        
        guard let idToken = authStateRepository.get()?.lastTokenResponse?.idToken else { return nil }
        
        // FIXME: Need to catch error
        try? setProfile(idToken: idToken)
        
        return userProfile
    }
    
    public func isAuthenticated() -> Bool {
        return getUserProfile() != nil
    }
    
    public func getAccessToken() -> String? {
        let authState = self.authStateRepository.get()
        authState?.performAction(freshTokens: { (accessToken, idToken, error) in
            guard error == nil else {
                print("Failed to refresh token with Error: \(error!.localizedDescription)")
                return
            }

            if idToken != nil {
                // FIXME: Need to catch error
                try? self.setProfile(idToken: idToken!)
            }

            // FIXME: Need to get Access token from here some how
        })
        
        return nil
    }
    
    /*
     * Handle the authorization response, including the user closing the Chrome Custom Tab
     */
    private func redeemCodeForTokens(
        clientID: String,
        authResponse: OIDAuthorizationResponse) -> CoFuture<OIDTokenResponse> {

        let promise = CoPromise<OIDTokenResponse>()
        let request = authResponse.tokenExchangeRequest()

        OIDAuthorizationService.perform(
            request!,
            originalAuthorizationResponse: authResponse) { tokenResponse, ex in

            if tokenResponse != nil {

                print("Authorization code grant response received successfully")
                guard let accessToken = tokenResponse?.accessToken else {
                    return promise.fail(AuthServiceError.authResponseAccessTokenIsNil)
                }
                guard let refreshToken = tokenResponse?.refreshToken else {
                    return promise.fail(AuthServiceError.authResponseRefreshTokenIsNil)
                }
                guard let idToken = tokenResponse?.idToken else {
                    return promise.fail(AuthServiceError.authResponseIDTokenIsNill)
                }
                print("AccessToken: \(accessToken), RefreshToken: \(refreshToken), IDToken: \(idToken)" )
                
                promise.success(tokenResponse!)

            } else {
                promise.fail(AuthServiceError.unableToRetrieveToken)
            }
        }
        
        return promise
    }
    
    /*
     * We can check for specific error codes to handle the user cancelling the ASWebAuthenticationSession window
     */
    private func isUserCancellationErrorCode(ex: Error) -> Bool {
        
        let error = ex as NSError
        return error.domain == OIDGeneralErrorDomain && error.code == OIDErrorCode.userCanceledAuthorizationFlow.rawValue
    }
    
    private func setProfile(idToken: String) throws {
        let jwt = try decode(jwt: idToken)
        self.userProfile = UserProfile(
            id: try getClaimValue(decodedToken: jwt, key: "sub"),
            name: try getClaimValue(decodedToken: jwt, key: "name"),
            email: try getClaimValue(decodedToken: jwt, key: "email")
        )
    }
    
    private func getClaimValue(decodedToken: JWT?, key: String) throws -> String {
        return try decodedToken?.claim(name: key).string ?? { throw AuthServiceError.claimKeyWithNoValue }()
    }
}
