//
//  NetworkError.swift
//  
//
//  Created by Muhammad on 04/04/2022.
//

import Foundation

public enum NetworkError: Error {
	case authenticationRequired
	case invalidURL
	case invalidStatusCode(code: Int)
	case invalidResponse
	case parameterEncodingFailure(error: Error)
	case nilDataResponse
	case jsonDecodingFailure(error: Error)
	case other(error: Error)
}
