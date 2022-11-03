//
//  KeyValueStorage.swift
//  Tuner
//
//  Created by Muhammad on 31/10/2022.
//

import Foundation

// Protocol used to save, load and delete (key, value) data
public protocol KeyValueStorage {
	@discardableResult func save(value: Any, for key: String) -> Bool
	func value(key: String) -> String?
	@discardableResult func detele(key: String) -> Bool
}
