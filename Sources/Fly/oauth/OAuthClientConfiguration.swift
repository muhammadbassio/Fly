//
//  OAuthClientConfiguration.swift
//  Tuner
//
//  Created by Muhammad on 31/10/2022.
//

import Foundation

public struct OAuthClientConfiguration {
	/// The client id.
	var clientId: String = ""
	
	/// The client secret, usually only needed for code grant (ex: Google).
	var clientSecret: String = ""
	
	/// The scope currently in use.
	var scope: String = ""
	
	/// The URL to authorize against.
	var authURL: String = ""
	
	/// The URL string where we can exchange a code for a token.
	public var tokenURL: String = ""
	
	/// The redirect URL string to use.
	var redirectURL: String = ""
	
	/// The response type expected from an authorize call, e.g. "code" for Google.
	var responseType: String = "code"
	
	/// The scheme used for redirect.
	var scheme: String = ""
	
	/// Other OAuth2 parameters.
	var parameters: [String:String] = [:]
	
}
