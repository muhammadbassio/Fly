//
//  OAuthError.swift
//  Tuner
//
//  Created by Muhammad on 31/10/2022.
//

import Foundation

public enum OAuthError: Error {
	case authenticationFailed(error: Error)
	case invalidRedirectURL
	case redirectURLMismatch
	case codeExtractionFailed
	case invalidRefreshToken
}
