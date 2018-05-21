//
//  Date.swift
//  EyeOfTheTiger
//
//  Created by Vladimir Khabarov on 17.04.2018.
//  Copyright © 2018 FTC. All rights reserved.
//

import Foundation

final class DateUtility
{
    static func dateFrom(_ post: Post) -> String
    {
        if let date = post.updated {
            return "edit in " + formatter.string(from: date)
        } else {
            return formatter.string(from: post.created)
        }
    }
    
    static func dateFrom(_ comment: Comment) -> String
    {
        if let date = comment.updated {
            return "edit in " + formatter.string(from: date)
        } else {
            return formatter.string(from: comment.created)
        }
    }

    static private let formatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.timeZone = .current
        return formatter
    }()
}
