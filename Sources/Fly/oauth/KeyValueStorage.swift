//
//  KeyValueStorage.swift
//  Tuner
//
//  Created by Muhammad on 31/10/2022.
//

import Foundation

// Protocol used to save, load and delete (key, value) data
public protocol KeyValueStorage {
	func save(value: Any, for key: String)
	func value(key: String) -> Any
	@discardableResult func detele(key: String) -> Bool
}