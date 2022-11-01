//
//  File.swift
//  
//
//  Created by Muhammad on 04/04/2022.
//

import Foundation

extension URLSession {
	func data(for request: URLRequest) async throws -> (Data, URLResponse) {
		if #available(macOS 12.0, iOS 15.0, *) {
			return try await self.data(for: request, delegate: nil)
		} else {
			return try await self.dataResponse(for: request)
		}
	}
	
	func dataResponse(for request: URLRequest) async throws -> (Data, URLResponse) {
		try await withCheckedThrowingContinuation { continuation in
			let task = self.dataTask(with: request) { data, response, error in
				guard let data = data, let response = response else {
					let error = error ?? URLError(.badServerResponse)
					return continuation.resume(throwing: error)
				}
				continuation.resume(returning: (data, response))
			}
			task.resume()
		}
	}
}
