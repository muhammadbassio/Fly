//
//  File.swift
//  
//
//  Created by Muhammad on 04/04/2022.
//

import Foundation

extension String {
	public var percentEscapedString: String {
		var characterSet = CharacterSet.alphanumerics
		characterSet.insert(charactersIn: "-._* ")
		return addingPercentEncoding(withAllowedCharacters: characterSet)?.replacingOccurrences(of: " ", with: "+") ?? self
	}
}
