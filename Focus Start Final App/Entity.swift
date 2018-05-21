//
//  Entity.swift
//  EyeOfTheTiger
//
//  Created by Vladimir Khabarov on 14.04.2018.
//  Copyright © 2018 FTC. All rights reserved.
//

import Foundation

struct Post: Codable {
    
    let id: String
    let text: String
    let created: Date
    let updated: Date?
}

struct Comment: Codable {
    
    let id: String
    let post_id: String
    let text: String
    let created: Date
    let updated: Date?
}
