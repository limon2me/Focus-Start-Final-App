//
//  File.swift
//  EyeOfTheTiger
//
//  Created by Denis Morozov on 12.04.18.
//  Copyright © 2018 FTC. All rights reserved.
//

import Foundation

class User
{
	static let shared: User = User(id: "123", name: "name")

	let id: String
	let name: String

	init(id: String, name: String)
	{
		self.id = id
		self.name = name
	}
}
