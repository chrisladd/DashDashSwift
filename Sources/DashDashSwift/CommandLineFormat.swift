//
//  File.swift
//  
//
//  Created by Christopher Ladd on 2/12/20.
//

import Foundation

struct CommandLineFormat {
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
    var lineLength = 70
}

