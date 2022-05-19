//
//  UserProfile.swift
//  AuthiOSDemo
//
//  Created by Jason Maderski on 5/16/22.
//

import Foundation

/**
 * A profile for an authenticated user.
 */
struct UserProfile {
    /**
    * Unique identifier for the user. Sourced from the subject claim.
    */
    let id: String
    
    /**
     * Full name of the user.
     */
    let name: String
    
    /**
     * Email of the user.
     */
    let email: String
}
