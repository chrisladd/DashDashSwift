//
//  String+MaxLineLength.swift
//  
//
//  Created by Christopher Ladd on 2/12/20.
//

import Foundation


extension String {
    func appending(input: String, lineLength: Int, indent: Int) -> String {
        var string = self
        let tagger = NSLinguisticTagger(tagSchemes: [.tokenType], options: 0)
        tagger.string = input

        var currentLine: String = String(string.components(separatedBy: "\n").last ?? "")
        
        if string.count == 0 || currentLine.count == 0 {
            currentLine = String(repeating: " ", count: indent)
            string += String(repeating: " ", count: indent)
        }
        
        let range = NSRange(location: 0, length: input.utf16.count)
        if #available(OSX 10.13, *) {
            tagger.enumerateTags(in: range, unit: .word, scheme: .tokenType, options: []) { _, tokenRange, _ in
                let word = (input as NSString).substring(with: tokenRange)
                
                let isSingleCharacter = word.count == 1
                let isLineTooLong = currentLine.count + word.count > lineLength
                let isNewline = word == "\n"
                
                if isLineTooLong && !isSingleCharacter {
                    // drop trailing spaces, if they exist
                    if string.last == " " {
                        string.remove(at: string.index(before: string.endIndex))
                    }
                    
                    currentLine = String(repeating: " ", count: indent)
                    string += "\n" + String(repeating: " ", count: indent)
                }
                
                string += word
                currentLine += word
                
                // pad newlines
                if isNewline {
                    currentLine = String(repeating: " ", count: indent)
                    string += String(repeating: " ", count: indent)
                }

            }
        } else {
            string += input
        }
        
        return string
    }
}
