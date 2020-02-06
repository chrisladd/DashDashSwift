//
//  FlagParser.swift
//  Grate
//
//  Created by Christopher Ladd on 1/11/20.
//  Copyright © 2020 Christopher Ladd. All rights reserved.
//

import Foundation

public struct FlagParser {
    var flags = [String: Flag]()
    var keys = [String]()
    public var arguments = [String]()
    
    public init() {
        register(key: "help", shortKey: "h", description: "Show this help message")
    }
    
    /**
     Registers a key, a short key, and a description.
     
     This is used to both allow you to query keys and short keys easily, as well as
     */
    public mutating func register(key: String, shortKey: String?, description: String?) {
        keys.append(key)
        flags[key] = Flag(key: key, shortKey: shortKey, description: description)
    }
    
    // MARK: Help
    
    /**
     A string to be printed to the console, representing the flags, in the order they were registered.
     */
    public func help() -> String {
        var help = ""
        
        print("\nGrate helps slice up audio files into test buffers.\n")
        
        for key in keys {
            guard let flag = flags[key] else { continue }
            help.append(flag.message())
            help.append("\n")
        }
        
        return help
    }
    
    /**
     Prints a help message to the console
     */
    public func printHelp() {
        print(help())
    }
    
    /**
     Returns an array of arguments which were not prepended by flags.
     */
    public func unflaggedArgumentsFrom(_ args: [String]) -> [String] {
        var unflaggedArgs = [String]()
        
        var isLastArgFlag = false
        for (idx, arg) in args.enumerated() {
            guard idx > 0 else { continue } // first is the path
            // if this is a flag, mark it
            guard arg.starts(with: "-") == false else {
                isLastArgFlag = true
                continue
            }
            
            // if the last arg was a flag, this one is its value
            guard isLastArgFlag == false else {
                isLastArgFlag = false
                continue
            }
            
            // if we've gotten here, it's an argument
            unflaggedArgs.append(arg)
            
            isLastArgFlag = false
        }
        
        return unflaggedArgs
    }
    
    public func unflaggedArguments() -> [String] {
        return unflaggedArgumentsFrom(arguments)
    }
    
    // MARK: Strings
    
    /**
     Returns a string, given a key and an optional short key.
     
     If you've previously registered this key with the parser, the short key will be provided automatically.
     */
    public func stringFor(key: String, shortKey: String?, args: [String]) -> String? {
        if let val = nextValueAfter(key: "--" + key, args: args) {
            return val
        }

        // fetch our short key from a pre-supplied flag, if it exists
        guard let shortKey = shortKeyWith(key: key, shortKey: shortKey) else { return nil }
        
        if let val = nextValueAfter(key: "-" + shortKey, args: args) {
            return val
        }
        
        return nil
    }
    
    public func stringFor(key: String, args: [String]) -> String? {
        return stringFor(key: key, shortKey: nil, args: args)
    }
    
    public func stringFor(key: String) -> String? {
        return stringFor(key: key, shortKey: nil, args: arguments)
    }
    
    // MARK: Bools
    
    public func boolForKey(_ key: String, shortKey: String?, args: [String]) -> Bool {
        if args.firstIndex(of: "--" + key) != nil {
            return true
        }
        
        if let shortKey = shortKey {
            if args.firstIndex(of: "-" + shortKey) != nil {
                return true
            }
        }
        
        return false
    }
    
    public func boolForKey(_ key: String, args: [String]) -> Bool {
        return boolForKey(key, shortKey: nil, args: args)
    }
    
    public func boolForKey(_ key: String) -> Bool {
        return boolForKey(key, shortKey: nil, args: arguments)
    }
    
    
    public func dirWithPath(_ path: String) -> String {
        var dir = path
        if let last = path.last {
            if last != "/" {
                dir += "/"
            }
        }
        
        return dir
    }
    
    // MARK: Directories
    
    /**
     Similar to `stringForFlag`, but ensures paths end in a trailing `/`
     */
    public func dirFor(key: String, shortKey: String?, args: [String]) -> String? {
        guard let path = stringFor(key: key, shortKey: shortKey, args: args) else { return nil }
        return dirWithPath(path)
    }
    
    public func dirFor(key: String, args: [String]) -> String? {
        return dirFor(key: key, shortKey: nil, args: args)
    }

    /**
     If you've registered arguments and flags previously.
     */
    public func dirFor(key: String) -> String? {
        return dirFor(key: key, shortKey: nil, args: arguments)
    }
    
    // MARK: Ints
    
    public func intFor(key: String, shortKey: String?, args: [String]) -> Int? {
        guard let string = stringFor(key: key, shortKey: shortKey, args: args) else { return nil }
        return Int(string)
    }
    
    public func intFor(key: String, args: [String]) -> Int? {
        return intFor(key: key, shortKey: nil, args: args)
    }
    
    public func intFor(key: String) -> Int? {
        return intFor(key: key, shortKey: nil, args: arguments)
    }
    
    // MARK: Doubles
    
    public func doubleFor(key: String, shortKey: String?, args: [String]) -> Double? {
        guard let string = stringFor(key: key, shortKey: shortKey, args: args) else { return nil }
        return Double(string)
    }
    
    public func doubleFor(key: String, args: [String]) -> Double? {
        return doubleFor(key: key, shortKey: nil, args: args)
    }
    
    public func doubleFor(key: String) -> Double? {
        return doubleFor(key: key, shortKey: nil, args: arguments)
    }
    
    
    // MARK: - Utility
    
    func shortKeyWith(key: String, shortKey: String?) -> String? {
        // use the supplied key if it exists
        if let shortKey = shortKey {
            return shortKey
        }
        
        // fall back to a registered flag
        if let flag = flags[key] {
            return flag.shortKey
        }
        
        return nil
    }

    func nextValueAfter(key: String, args:[String]) -> String? {
        guard let idx = args.firstIndex(of: key) else { return nil }
        guard idx < args.count - 1 else { return nil }
        let val = args[idx + 1]
        
        if let dashRange = val.firstIndex(of: "-") {
            guard dashRange > val.startIndex else { return  nil }
        }
        
        return val
    }
    


}
