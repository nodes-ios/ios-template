//
//  File.swift
//
//
//  Created by Jakob Mygind on 09/12/2021.
//

import Foundation
import Tagged

public enum AccessTokenTag {}
public typealias AccessToken = Tagged<AccessTokenTag, String>

public enum RefreshTokenTag {}
public typealias RefreshToken = Tagged<RefreshTokenTag, String>

public struct RefreshTokenEnvelope: Codable, Equatable {
    init(token: RefreshToken, expiresAt: Date) {
        self.token = token
        self.expiresAt = expiresAt
    }

    public var token: RefreshToken
    public var expiresAt: Date
}

public struct APITokens: Codable, Equatable {
    init(
        token: AccessToken,
        refreshToken: RefreshTokenEnvelope
    ) {
        self.token = token
        self.refreshToken = refreshToken
    }

    public var token: AccessToken
    public var refreshToken: RefreshTokenEnvelope
}

extension APITokens {
    public static let mock = Self(
        token: "MockToken",
        refreshToken: .init(token: "MockRefreshToken", expiresAt: .distantFuture))
}

extension AccessToken {

    var expiry: Date {
        guard let jwt = JWT(accessToken: self) else { return Date.distantPast }
        return Date(timeIntervalSince1970: jwt.exp)
    }

    public func isValid(now: Date) -> Bool {
        expiry > now
    }
}
