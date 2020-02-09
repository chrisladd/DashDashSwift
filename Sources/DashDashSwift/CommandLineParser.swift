//
//  CommandLineParser.swift
//
//  Created by Christopher Ladd on 1/11/20.
//  Copyright © 2020 Better Notes, LLC
//

import Foundation

public struct CommandLineParser {
    var flags = [String: CommandLineFlag]()
    var keys = [String]()
    var title: String?
    var description: String?
    
    /**
     You may set the current arguments from `CommandLine.arguments` for more convenient access.
     */
    public var arguments = [String]()
    
    public init() {
        register(key: "help", shortKey: "h", description: "Show this help message")
    }

    /**
     Initializes a parser with a title and a description.
     
     These will be used to print a helpful message to the console when the user adds the -h or --help flags.
     */
    public init(title: String?, description: String?) {
        self.init()
        self.title = title
        self.description = description
    }
    
    /**
     Registers a key, a short key, and a description.
     
     This is used to both allow you to query keys and short keys easily, as well as
     */
    public mutating func register(key: String, shortKey: String?, description: String?) {
        keys.append(key)
        flags[key] = CommandLineFlag(key: key, shortKey: shortKey, description: description)
    }
    
    /**
     Unregisters a single key
     */
    public mutating func unregister(key: String) {
        keys.removeAll { $0 == key }
        flags.removeValue(forKey: key)
    }
    
    /**
     Unregisters all keys
     */
    public mutating func unregisterAllKeys() {
        keys = [String]()
        flags = [String: CommandLineFlag]()
    }
    
    // MARK: Help
    
    /**
     A string to be printed to the console, representing the flags, in the order they were registered.
     */
    public func help() -> String {
        var help = ""
        
        if let title = title {
            help.append("\(title)\n")
        }
        
        if let description = description {
            help.append("\(description)\n\n")
        }
        
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
    
    /**
     Returns unflagged arguments from previously registered arguments
     */
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

    
    /**
     Returns a string, given a key, from an array of arguments.
     
     If a short key was previously registered, that will also be checked.
     */
    public func stringFor(key: String, args: [String]) -> String? {
        return stringFor(key: key, shortKey: nil, args: args)
    }
    
    /**
     Returns a string, given a key, from arguments previously registered.
     */
    public func stringFor(key: String, shortKey: String?) -> String? {
        return stringFor(key: key, shortKey: shortKey, args: arguments)
    }
    
    /**
     Returns a string, given a key, from arguments previously registered.
     
     If a short key was previously registered, that will also be checked.
     */
    public func stringFor(key: String) -> String? {
        return stringFor(key: key, shortKey: nil, args: arguments)
    }
    
    /**
     Returns a string, given a key, from arguments previously supplied.
     
     If no result is found, will look for an unnamed argument at `index`
     */
    public func stringFor(key: String, or index: Int) -> String? {
        if let result = stringFor(key: key) {
            return result
        }
        
        let unflaggedArgs = unflaggedArguments()
        
        if unflaggedArgs.count > index {
            return unflaggedArgs[index]
        }
        
        return nil
    }
    
    // MARK: Bools
    
    /**
     Returns a boolean given a flag's presence or absense. E.g. --help
     */
    public func boolForKey(_ key: String, shortKey: String?, args: [String]) -> Bool {
        if args.firstIndex(of: "--" + key) != nil {
            return true
        }
        
        // fetch our short key from a pre-supplied flag, if it exists
        guard let shortKey = shortKeyWith(key: key, shortKey: shortKey) else { return false }
        
        if args.firstIndex(of: "-" + shortKey) != nil {
            return true
        }

        return false
    }
    
    /**
    Returns a boolean given a flag's presence or absense. E.g. --help
    */
    public func boolForKey(_ key: String, args: [String]) -> Bool {
        return boolForKey(key, shortKey: nil, args: args)
    }
    
    /**
    Returns a boolean given a flag's presence or absense. E.g. --help
    */
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
     Returns the key's value as a string, but ensures paths end in a trailing `/`
     */
    public func dirFor(key: String, shortKey: String?, args: [String]) -> String? {
        guard let path = stringFor(key: key, shortKey: shortKey, args: args) else { return nil }
        return dirWithPath(path)
    }
    
    /**
    Returns the key's value as a string, but ensures paths end in a trailing `/`
    */
    public func dirFor(key: String, args: [String]) -> String? {
        return dirFor(key: key, shortKey: nil, args: args)
    }

    /**
    Returns the key's value as a string, but ensures paths end in a trailing `/`
    */
    public func dirFor(key: String) -> String? {
        return dirFor(key: key, shortKey: nil, args: arguments)
    }
    
    // MARK: Ints
    
    /**
     Returns the integer value of the key.
     
     E.g. --size 10 -> 10
     */
    public func intFor(key: String, shortKey: String?, args: [String]) -> Int? {
        guard let string = stringFor(key: key, shortKey: shortKey, args: args) else { return nil }
        return Int(string)
    }
    
    /**
     Returns the integer value of the key, as well as a short key.
     
     E.g. --size 10 -> 10
     */
    public func intFor(key: String, shortKey: String?) -> Int? {
        guard let string = stringFor(key: key, shortKey: shortKey) else { return nil }
        return Int(string)
    }
    

    /**
    Returns the integer value of the key.
    
    E.g. --size 10 -> 10
    */
    public func intFor(key: String, args: [String]) -> Int? {
        return intFor(key: key, shortKey: nil, args: args)
    }
    
    /**
    Returns the integer value of the key.
    
    E.g. --size 10 -> 10
    */
    public func intFor(key: String) -> Int? {
        return intFor(key: key, shortKey: nil, args: arguments)
    }
    
    // MARK: Doubles
    
    /**
    Returns the double value of the key.
    
    E.g. --size 10.7 -> 10.7
    */
    public func doubleFor(key: String, shortKey: String?, args: [String]) -> Double? {
        guard let string = stringFor(key: key, shortKey: shortKey, args: args) else { return nil }
        return Double(string)
    }
    
    /**
    Returns the double value of the key.
    
    E.g. --size 10.7 -> 10.7
    */
    public func doubleFor(key: String, shortKey: String?) -> Double? {
        guard let string = stringFor(key: key, shortKey: shortKey, args: arguments) else { return nil }
        return Double(string)
    }
    
    
    /**
    Returns the double value of the key.
    
    E.g. --size 10.7 -> 10.7
    */
    public func doubleFor(key: String, args: [String]) -> Double? {
        return doubleFor(key: key, shortKey: nil, args: args)
    }
    
    /**
    Returns the double value of the key.
    
    E.g. --size 10.7 -> 10.7
    */
    public func doubleFor(key: String) -> Double? {
        return doubleFor(key: key, shortKey: nil, args: arguments)
    }
    
    
    // MARK: - Utility
    
    /**
     Returns an array of arguments given a string, in the same format returned by `CommandLine.arguments`
     */
    public static func argsFrom(string: String) -> [String] {
        var args: [String] =  ["."]
        let components = string.split(separator: " ").map({ String($0) })
        args.append(contentsOf: components)
        return args
     }

    
    /**
    Returns the double value of the key.
    
    E.g. --size 10.7 -> 10.7
    */
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

    /**
    Returns the double value of the key.
    
    E.g. --size 10.7 -> 10.7
    */
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
