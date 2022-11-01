//
//  File.swift
//  
//
//  Created by Muhammad on 04/04/2022.
//

import Foundation

open class NetworkManager {
	public static var shared = NetworkManager(session: .shared)
	
	var session: URLSession
	
	public init(configuration: URLSessionConfiguration) {
		session = URLSession(configuration: configuration)
	}
	
	public init(session: URLSession) {
		self.session = session
	}
	
	public func request<T:Codable>(fullURL: String,
																	 method: HTTPMethod = .get,
																	 parameters: [String: Any]? = nil,
																	 headers: [String: String]? = nil,
																 encoding: ParameterEncoding = .json) async -> Result<T,NetworkError> {
		guard let escapedURL = fullURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return .failure(NetworkError.invalidURL) }
		guard let url = URL(string: escapedURL) else { return .failure(NetworkError.invalidURL) }
		var request = URLRequest(url: url)
		request.httpMethod = method.rawValue
		if let parameters = parameters {
			switch encoding {
			case .json:
				do {
					request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
				} catch (let error) {
					return .failure(NetworkError.parameterEncodingFailure(error: error))
				}
			case .xwwwform:
				let parameterArray = parameters.map { (arg) -> String in
					let (key, value) = arg
					return "\(key)=\("\(value)".percentEscapedString)"
				}
				request.httpBody = parameterArray.joined(separator: "&").data(using: .utf8)
			}
			request.setValue(encoding.rawValue, forHTTPHeaderField: "Content-Type")
			request.setValue("application/json", forHTTPHeaderField: "Accept")
		}
		if let headers = headers {
			for (key, value) in headers {
				request.setValue(value, forHTTPHeaderField: key)
			}
		}
		do {
			let (data, _) = try await session.data(for: request)
			let decodedResponse = try JSONDecoder().decode(T.self, from: data)
			return .success(decodedResponse)
		} catch (let error) {
			return .failure(NetworkError.other(error: error))
		}
	}
	
}
