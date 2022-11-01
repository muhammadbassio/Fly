//
//  File.swift
//  
//
//  Created by Muhammad on 04/04/2022.
//

import Foundation

open class APIManager {
	
	public var baseURL = ""                                     // the base URL for API endpoints
	public var mainHeaders:[String: String] = [:]
	private(set) public var networkManager: NetworkManager
	private(set) public var oAuthClient: OAuthClient?
	
	public init(manager: NetworkManager = NetworkManager.shared, client: OAuthClient? = nil) {
		networkManager = manager
		initConfiguration()
	}
	
	/// Override to implement your own init logic
	open func initConfiguration() {
		
	}
	
	public func request<T: Codable>(endPoint: APIEndPoint) async -> Result<T, NetworkError> {
		var headers = mainHeaders
		if let endpointHeaders = endPoint.headers {
			for (key, value) in endpointHeaders {
				headers[key] = value
			}
		}
		if endPoint.requiresAuthentication {
			guard let tokenType = oAuthClient?.token?.tokenType,
						let accessToken = oAuthClient?.token?.accessToken
			else { return Result.failure(NetworkError.authenticationRequired) }
			headers["Authorization"] = "\(tokenType) \(accessToken)"
		}
		var fullURL = "\(self.baseURL)\(endPoint.path)"
		if let queryParameters = endPoint.queryParameters {
			fullURL = "\(fullURL)?"
			for (key, value) in queryParameters {
				fullURL = "\(fullURL)\(key)=\(value)&"
			}
			fullURL = String(fullURL.dropLast())   
		}
		return await networkManager.request(fullURL: fullURL, method: endPoint.method, parameters: endPoint.parameters, headers: endPoint.headers, encoding: .json)
	}
}
