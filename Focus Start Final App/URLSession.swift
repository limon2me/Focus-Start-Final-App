//
//  URLSession.swift
//  EyeOfTheTiger
//
//  Created by Denis Morozov on 12.04.18.
//  Copyright © 2018 FTC. All rights reserved.
//

import Foundation

public extension URLSession
{
	static let focusStartSession: URLSession = URLSession.makeFocusStartSession()

	static private func makeFocusStartSession() -> URLSession
	{
		let configuration = URLSessionConfiguration.default
		configuration.protocolClasses?.insert(FocusStartURLProtocol.self, at: 0)

		return URLSession(configuration: configuration)
	}
}
