//
//  AuthConfigProvider.swift
//  AuthiOSDemo
//
//  Created by Jason Maderski on 5/17/22.
//

import Foundation

public protocol AuthConfigProvider {
    func getAuthConfig() -> AuthConfig
}
