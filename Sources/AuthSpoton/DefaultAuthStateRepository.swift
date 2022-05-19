//
//  DefaultAuthStateRepository.swift
//  AuthiOSDemo
//
//  Created by Jason Maderski on 5/17/22.
//

import Foundation
import AppAuth

class DefaultAuthStateRepository: AuthStateRepository {
    
    private var authstate: OIDAuthState?
    private let authstatePreferenceKey = "AuthState"
    
    init() {}
    
    func get() -> OIDAuthState? {
        if let validAuthstate = authstate {
            return validAuthstate
        }
        
        if let decodedData  = UserDefaults.standard.object(forKey: authstatePreferenceKey) as? Data,
           let authInfo = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decodedData) as? OIDAuthState {
            authstate = authInfo
            return authstate
        } else {
            return nil
        }
    }
    
    func set(state: OIDAuthState) {
        self.authstate = state
        if #available(iOS 11.0, *) {
            if let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: state, requiringSecureCoding: false) {
                let userDefaults = UserDefaults.standard
                userDefaults.set(encodedData, forKey: authstatePreferenceKey)
            }
        } else {
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: state)
            let userDefaults = UserDefaults.standard
            userDefaults.set(encodedData, forKey: authstatePreferenceKey)
        }
    }
    
    func clear() {
        self.authstate = nil
        UserDefaults.standard.set(nil, forKey: authstatePreferenceKey)
    }
}
