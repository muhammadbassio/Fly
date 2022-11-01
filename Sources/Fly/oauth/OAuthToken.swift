//
//  OAuthToken.swift
//  Tuner
//
//  Created by Muhammad on 31/10/2022.
//

import Foundation

public struct OAuthToken: Codable {
	var tokenType: String?
	var accessToken: String?
	var refreshToken: String?
	var idToken: String?
	var expiresIn: UInt?
	var accessTokenExpiry: Date?
	
	enum CodingKeys: String, CodingKey {
		case tokenType = "token_type"
		case accessToken = "access_token"
		case refreshToken = "refresh_token"
		case idToken = "id_token"
		case expiresIn = "expires_in"
		case accessTokenExpiry = "expiry_date"
	}
}
