//
//  AuthStateRepository.swift
//  AuthiOSDemo
//
//  Created by Jason Maderski on 5/16/22.
//

import Foundation
import AppAuth

/**
 * Persistent data store for [AuthState].
 */
public protocol AuthStateRepository {
    func get() -> OIDAuthState?
    func set(state: OIDAuthState)
    func clear()
}
