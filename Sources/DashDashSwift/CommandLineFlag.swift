//
//  CommandLineFlag.swift
//
//  Created by Christopher Ladd on 1/11/20.
//  Copyright © 2020 Better Notes, LLC
//



import Foundation

struct CommandLineFlag {
    let key: String
    let shortKey: String?
    let description: String?
    
    func message() -> String {
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
