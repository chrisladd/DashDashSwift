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
    
    func message(spacing: CommandLineFormat? = nil) -> String {
        let spacing = spacing ?? CommandLineFormat()
        
        var string = ""
        string += String(repeating: " ", count: spacing.leftIndent)
        string += "--" + key
        
        if string.count < spacing.shortKeyIndent {
            string += String(repeating: " ", count: spacing.shortKeyIndent - string.count)
        }

        if let shortKey = shortKey {
            string += "-" + shortKey
        }
        
        if string.count < spacing.descriptionIndent {
            string += String(repeating: " ", count: spacing.descriptionIndent - string.count)
        }

        if let description = description {
            string = string.appending(input: description, lineLength: spacing.lineLength, indent: spacing.descriptionIndent)
        }
        
        return string
    }
    
    /**
     Returns spacing required to render the array of flags, with configurable indents and lineLength
     */
    static func spacingFor(flags: [CommandLineFlag], leftIndent: Int = 2, lineLength: Int = 60) -> CommandLineFormat {
        let interFlagSpacing = 2
        let flagMessageSpacing = 2
        let dashDashWidth = 2
        let dashWidth = 1
        
        var spacing = CommandLineFormat()
        spacing.lineLength = lineLength
        spacing.leftIndent = leftIndent
        
        
        for flag in flags {
            let length = flag.key.count + leftIndent + interFlagSpacing + dashDashWidth
            spacing.shortKeyIndent = max(spacing.shortKeyIndent, length)
        }
        
        for flag in flags {
            let shortKeyLength: Int;
            if let shortKey = flag.shortKey {
                shortKeyLength = shortKey.count + dashWidth
            }
            else {
                shortKeyLength = 0
            }
            
            let length = spacing.shortKeyIndent + shortKeyLength + flagMessageSpacing
            spacing.descriptionIndent = max(spacing.descriptionIndent, length)
        }
        
        return spacing
    }
}
