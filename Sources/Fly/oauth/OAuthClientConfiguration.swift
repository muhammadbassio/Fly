//
//  OAuthClientConfiguration.swift
//  Tuner
//
//  Created by Muhammad on 31/10/2022.
//

import Foundation

public struct OAuthClientConfiguration {
	
	/// The client id.
	public var clientId: String
	
	/// The client secret, usually only needed for code grant (ex: Google).
	public var clientSecret: String
	
	/// The scope currently in use.
	public var scope: String
	
	/// The URL to authorize against.
	public var authURL: String
	
	/// The URL string where we can exchange a code for a token.
	public var tokenURL: String
	
	/// The redirect URL string to use.
	public var redirectURL: String
	
	/// The response type expected from an authorize call, e.g. "code" for Google.
	public var responseType: String
	
	/// The scheme used for redirect.
	public var scheme: String
	
	/// Other OAuth2 parameters.
	public var parameters: [String:String]
	
	public init(clientId: String = "",
							clientSecret: String = "",
							scope: String = "",
							authURL: String = "",
							tokenURL: String = "",
							redirectURL: String = "",
							responseType: String = "code",
							scheme: String = "",
							parameters: [String : String] = [:]) {
		self.clientId = clientId
		self.clientSecret = clientSecret
		self.scope = scope
		self.authURL = authURL
		self.tokenURL = tokenURL
		self.redirectURL = redirectURL
		self.responseType = responseType
		self.scheme = scheme
		self.parameters = parameters
	}
	
}
