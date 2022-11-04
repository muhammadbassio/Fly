//
//  OAuthToken.swift
//  Tuner
//
//  Created by Muhammad on 31/10/2022.
//

import Foundation

public struct OAuthToken: Codable {
	
	public var tokenType: String?
	public var accessToken: String?
	public var refreshToken: String?
	public var idToken: String?
	public var expiresIn: UInt?
	public var accessTokenExpiry: Date?
	
	enum CodingKeys: String, CodingKey {
		case tokenType = "token_type"
		case accessToken = "access_token"
		case refreshToken = "refresh_token"
		case idToken = "id_token"
		case expiresIn = "expires_in"
		case accessTokenExpiry = "expiry_date"
	}
	
	public init() {
		
	}
	
}
