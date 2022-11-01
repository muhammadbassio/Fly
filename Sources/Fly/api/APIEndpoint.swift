//
//  APIEndPoint.swift
//  
//
//  Created by Muhammad on 04/04/2022.
//

import Foundation

public struct APIEndPoint {
	public var path: String
	public var method: HTTPMethod
	public var queryParameters: [String: Any]?
	public var requiresAuthentication: Bool
	public var headers: [String: String]?
	public var parameters: [String: Any]?
	
	public init(path: String,
							method: HTTPMethod = .get,
							queryParameters: [String: Any]? = nil,
							requiresAuthentication: Bool = false,
							headers: [String: String]? = nil,
							parameters: [String: Any]? = nil) {
		self.path = path
		self.method = method
		self.queryParameters = queryParameters
		self.requiresAuthentication = requiresAuthentication
		self.headers = headers
		self.parameters = parameters
	}
}
