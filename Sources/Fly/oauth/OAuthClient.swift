//
//  OAuthClient.swift
//  Tuner
//
//  Created by Muhammad on 31/10/2022.
//

import Foundation
import AuthenticationServices

open class OAuthClient {
	
	/// The OAuth2 client configuration.
	public var configuration: OAuthClientConfiguration
	
	/// The OAuth2 fetched access token.
	public var token: OAuthToken?
	
	public var keyValueStorage: KeyValueStorage
	public var networkManager: NetworkManager = NetworkManager.shared
	
	public var authenticator: ASWebAuthenticationSession? = nil
	
	public var clientIsLoadingToken: (() -> Void) = {}
	public var clientDidFinishLoadingToken: (() -> Void) = {}
	public var clientDidFailLoadingToken: ((_ error:Error) -> Void) = { error in
		
	}
	
	public init(config:OAuthClientConfiguration, storage: KeyValueStorage) {
		configuration = config
		keyValueStorage = storage
		token = nil
		loadToken()
	}
	
	open func loadToken() {
		guard configuration.clientId != "",
					let accessToken = keyValueStorage.value(key: "\(configuration.clientId).accessToken.accessToken"),
					let type = keyValueStorage.value(key: "\(configuration.clientId).accessToken.tokenType"),
					let refreshToken = keyValueStorage.value(key: "\(configuration.clientId).accessToken.refreshToken")
		else { return }
		token = OAuthToken()
		token?.accessToken = accessToken
		token?.tokenType = type
		token?.refreshToken = refreshToken
		
		if let idToken = keyValueStorage.value(key: "\(configuration.clientId).accessToken.idToken") {
			token?.idToken = idToken
		}
		if let intervalString = keyValueStorage.value(key: "\(configuration.clientId).accessToken.accessTokenExpiry"),
			 let timeInterval = Double(intervalString) {
			let accessTokenExpiry = Date(timeIntervalSinceReferenceDate: timeInterval)
			self.token?.accessTokenExpiry = accessTokenExpiry
			if accessTokenExpiry.timeIntervalSince(Date()) < 0 {
				Task {
					await refreshAccessToken()
				}
			}
		}
		
	}
	
	@discardableResult open func saveToken() -> Bool {
		guard configuration.clientId != "" else { return false }
		guard let accessToken = self.token?.accessToken, let type = self.token?.tokenType, let refreshToken = self.token?.refreshToken else { return false }
		keyValueStorage.save(value: accessToken, for: "\(configuration.clientId).accessToken.accessToken")
		keyValueStorage.save(value: type, for: "\(configuration.clientId).accessToken.tokenType")
		keyValueStorage.save(value: refreshToken, for: "\(configuration.clientId).accessToken.refreshToken")
		if let idToken = self.token?.idToken {
			keyValueStorage.save(value: idToken, for: "\(configuration.clientId).accessToken.idToken")
		}
		if let accessTokenExpiry = self.token?.accessTokenExpiry {
			let timeInterval = accessTokenExpiry.timeIntervalSinceReferenceDate
			keyValueStorage.save(value: "\(timeInterval)", for: "\(configuration.clientId).accessToken.accessTokenExpiry")
		}
		return true
	}
	
	open func clearToken() {
		guard configuration.clientId != "" else { return }
		keyValueStorage.detele(key: "\(configuration.clientId).accessToken.accessToken")
		keyValueStorage.detele(key: "\(configuration.clientId).accessToken.tokenType")
		keyValueStorage.detele(key: "\(configuration.clientId).accessToken.refreshToken")
		keyValueStorage.detele(key: "\(configuration.clientId).accessToken.idToken")
		keyValueStorage.detele(key: "\(configuration.clientId).accessToken.accessTokenExpiry")
	}
	
	open func authorize(provider: ASWebAuthenticationPresentationContextProviding) {
		var urltext = "\(self.configuration.authURL)?client_id=\(self.configuration.clientId)&redirect_uri=\(self.configuration.redirectURL)&prompt=consent&access_type=offline"
		if self.configuration.scope != "" {
			urltext = "\(urltext)&scope=\(self.configuration.scope)"
		}
		if self.configuration.responseType != "" {
			urltext = "\(urltext)&response_type=\(self.configuration.responseType)"
		}
		for (key, value) in self.configuration.parameters {
			urltext = "\(urltext)&\(key)=\(value)"
		}
		
		guard let escapedURL = urltext.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
					let authURL = URL(string: escapedURL) else { return }
		
		authenticator = ASWebAuthenticationSession(url: authURL, callbackURLScheme: configuration.scheme, completionHandler: { url, error in
			if let error = error {
				self.clientDidFailLoadingToken(OAuthError.authenticationFailed(error: error))
			} else if let url = url {
				Task {
					await self.handle(redirectURL:url)
				}
			}
		})
		authenticator?.presentationContextProvider = provider
		authenticator?.start()
		
	}
	
	open func handle(redirectURL: URL) async {
		// show loading
		self.clientIsLoadingToken()
		if self.configuration.redirectURL.isEmpty {
			self.clientDidFailLoadingToken(OAuthError.invalidRedirectURL)
			return
		}
		let components = URLComponents(url: redirectURL, resolvingAgainstBaseURL: true)
		guard let queryItems = components?.queryItems else {
			clientDidFailLoadingToken(OAuthError.codeExtractionFailed)
			return
		}
		let codeItems = queryItems.filter({ (item) -> Bool in
			if item.name == "code" {
				return true
			}
			return false
		})
		
		guard codeItems.count > 0 else {
			clientDidFailLoadingToken(OAuthError.codeExtractionFailed)
			return
		}
		
		guard let code = codeItems[0].value else {
			clientDidFailLoadingToken(OAuthError.codeExtractionFailed)
			return
		}
		
		let headers = ["Content-Type": "application/x-www-form-urlencoded", "Accept": "application/json"]
		let parameters = [
			"code": "\(code)",
			"client_id": "\(self.configuration.clientId)",
			"client_secret": "\(self.configuration.clientSecret)",
			"redirect_uri": "\(self.configuration.redirectURL)",
			"grant_type": "authorization_code",
			"access_type": "offline"
		]
		
		let response: Result<OAuthToken, NetworkError> = await networkManager.request(fullURL: self.configuration.tokenURL, method: .post, parameters: parameters, headers: headers, encoding: .xwwwform)
		switch(response) {
		case .success(let token):
			self.token = token
			if let expiresIn = token.expiresIn {
				self.token?.accessTokenExpiry = Date().addingTimeInterval(TimeInterval(expiresIn))
			}
			saveToken()
			clientDidFinishLoadingToken()
		case .failure(let error):
			clientDidFailLoadingToken(error)
		}
	}
	
	open func refreshAccessToken() async {
		if let tok = self.token?.refreshToken {
			let headers = ["Content-Type": "application/x-www-form-urlencoded"]
			let parameters = [
				"client_id": "\(self.configuration.clientId)",
				"client_secret": "\(self.configuration.clientSecret)",
				"redirect_uri": "\(self.configuration.redirectURL)",
				"refresh_token": "\(tok)",
				"grant_type": "refresh_token"
			]
			
			let response: Result<OAuthToken, NetworkError> = await networkManager.request(fullURL: self.configuration.tokenURL, method: .post, parameters: parameters, headers: headers)
			switch(response) {
			case .success(let token):
				self.token = token
				if let expiresIn = token.expiresIn {
					self.token?.accessTokenExpiry = Date().addingTimeInterval(TimeInterval(expiresIn))
				}
				saveToken()
				clientDidFinishLoadingToken()
				return
			case .failure(let error):
				clientDidFailLoadingToken(error)
				return
			}
		}
		else {
			clientDidFailLoadingToken(OAuthError.invalidRefreshToken)
		}
	}
	
	open func unauthorize() {
		self.token = nil
		self.clearToken()
	}
}
