//
//  NetworkEnums.swift
//  
//
//  Created by Muhammad on 04/04/2022.
//

import Foundation

public enum HTTPMethod: String {
	case get = "GET"
	case post = "POST"
	case put = "PUT"
	case patch = "PATCH"
	case delete = "DELETE"
}

public enum ParameterEncoding: String {
	case json = "application/json"
	case xwwwform = "application/x-www-form-urlencoded"
}
