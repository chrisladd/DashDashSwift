//
//  Flag.swift
//  Grate
//
//  Created by Christopher Ladd on 1/11/20.
//  Copyright © 2020 Christopher Ladd. All rights reserved.
//

import Foundation

public struct Flag {
    public let key: String
    public let shortKey: String?
    public let description: String?
    
    public init(key: String, shortKey: String?, description: String?) {
        self.key = key
        self.shortKey = shortKey
        self.description = description
    }
    
    public func message() -> String {
        var string = ""
        string += "--" + key
        if let shortKey = shortKey {
            string += "\t -" + shortKey
        }
        
        if let description = description {
            string += "\t" + description
        }
        
        return string
    }
}
