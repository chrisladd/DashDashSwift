//
//  CommandLineFlag.swift
//
//  Created by Christopher Ladd on 1/11/20.
//  Copyright © 2020 Better Notes, LLC
//



import Foundation

struct CommandLineFlag {
    struct MessageSpacing {
        /**
        Indentation, from the beinning of the line for the `--key`
        */
        var leftIndent = 0
        
        /**
        Indentation, from the beinning of the line, for the `-s`hort key, if it exists
        */
        var shortKeyIndent = 0
        
        /**
         Indentation, from the beinning of the line, for the description
         */
        var descriptionIndent = 0
        
        /**
         The maximum allowed line length
         */
        var lineLength = 60
    }
    
    static func spacingFor(flags: [CommandLineFlag], lineLength: Int = 60) -> MessageSpacing {
        let leftIndent = 0
        let interFlagSpacing = 2
        let flagMessageSpacing = 2
        let dashDashWidth = 2
        let dashWidth = 1
        
        var spacing = MessageSpacing()
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
    
    
    let key: String
    let shortKey: String?
    let description: String?
    
    func message(spacing: MessageSpacing? = nil) -> String {
        let spacing = spacing ?? MessageSpacing()
        
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

        var currentLine = string
        if let description = description {
            // break up into words
            let tagger = NSLinguisticTagger(tagSchemes: [.tokenType], options: 0)
            tagger.string = description

            let range = NSRange(location: 0, length: description.utf16.count)
            if #available(OSX 10.13, *) {
                tagger.enumerateTags(in: range, unit: .word, scheme: .tokenType, options: []) { _, tokenRange, _ in
                    let word = (description as NSString).substring(with: tokenRange)
                    
                    let isSingleCharacter = word.count == 1
                    let isLineTooLong = currentLine.count + word.count > spacing.lineLength
                    
                    if isLineTooLong && !isSingleCharacter {
                        // drop trailing spaces, if they exist
                        if string.last == " " {
                            string.remove(at: string.index(before: string.endIndex))
                        }
                        
                        currentLine = String(repeating: " ", count: spacing.descriptionIndent)
                        string += "\n" + String(repeating: " ", count: spacing.descriptionIndent)
                    }
                    
                    string += word
                    currentLine += word

                }
            } else {
                string += description
            }
        }
        
        return string
    }
}
