//
//  CommandLineParser.swift
//
//  Created by Christopher Ladd on 1/11/20.
//  Copyright © 2020 Better Notes, LLC
//

import Foundation


public struct CommandLineParser {
    /// The maximum number of lines to be printed to the console.
    /// In practice, this is used to ensure that `--help` prints properly.
    public var maxLineLength = 60
    
    /// The indent, in characters, from the left edge of the terminal.
    public var leftIndent = 2
    
    /// You may set the current arguments from `CommandLine.arguments` for more convenient access.
    public var arguments = [String]()
    
    /// Initializes a parser with a title and a description.
    /// - Parameter title: a title
    /// - Parameter description: a description. Both the title and description will be printed with the `help()` message, and formatted to fit within the `maxLineLength`
    public init(title: String? = nil, description: String? = nil) {
        self.title = title
        self.description = description
    }
    
    var flags = [String: CommandLineFlag]()
    var keys = [String]()
    var title: String?
    var description: String?


    // MARK: - Registering Keys
    
    
    /// Registers a key and aliases like `shortKey` and `index` with the parser.
    ///
    /// This is used to both allow you to query keys and short keys easily, as well as print a helpful message for users with the `help()` and `printHelp()` functions.
    ///
    ///  - Parameter key: an arbitrary length key, to match with two dashes. Single-character keys will also match -o one dash.
    ///  - Parameter shortKey: a single-character key. If none is supplied, and `key` was previously registered, the corresponding `shortKey` will be automatically used
    /// - Parameter index: the index of an unflagged argument, to be used if no `key` or `shortKey` matches. E.g. you might allow the user to specify a path either with the flag `input`, or simply supply the path.
    /// - Parameter description: a description, to print in a table alongside your key in `help()`
    public mutating func register(key: String, shortKey: String? = nil, index: Int? = nil, description: String? = nil) {
        keys.append(key)
        flags[key] = CommandLineFlag(key: key, shortKey: shortKey, index: index, description: description)
    }
   
    /// Unregisters a single key
    /// - Parameter key: a key
    public mutating func unregister(key: String) {
        keys.removeAll { $0 == key }
        flags.removeValue(forKey: key)
    }
    
    /// Unregisters all keys from the parser
    public mutating func unregisterAllKeys() {
        keys = [String]()
        flags = [String: CommandLineFlag]()
    }
    
    // MARK: Help
    
    
    /// A string to be printed to the console, representing the flags, in the order they were registered.
    ///
    /// Note that you are responsible for calling this method, and registering a `--help` and/or `-h` flag with your parser
    ///
    public func help() -> String {
        var help = ""
        let spacing = CommandLineFlag.spacingFor(flags: Array(flags.values), leftIndent: leftIndent, lineLength: maxLineLength)
        
        if let title = title {
            help = help.appending(input: title, lineLength: maxLineLength, indent: leftIndent)
            help.append("\n")
        }
        
        if let description = description {
            help += "\n"
            help = help.appending(input: description, lineLength: maxLineLength, indent: leftIndent)
            help += "\n\n"
        }
        
        for key in keys {
            guard let flag = flags[key] else { continue }
            help.append(flag.message(spacing: spacing))
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
    
    // MARK: Getting Values
    
    /// Returns an array of arguments which were not prepended by flags.
    ///  - Parameter args: an array of arguments.
    public func unflaggedArguments(from args: [String]) -> [String] {
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
    
    /// Returns an array of arguments which were not prepended by flags, drawing from the previously-registered `arguments`
    public func unflaggedArguments() -> [String] {
        return unflaggedArguments(from: arguments)
    }
    
    /*
     Returns a string, given a key and an optional short key.
     
     If you've previously registered this key with the parser, the short key will be provided automatically.
     */
    
    
    
    /// Returns a string for a given key, or nil if none is found.
    ///
    /// You may optionally pass in the index of an unflagged argument, which will be used if no `key` or `shortKey` matches
    ///
    ///  - Parameter key: an arbitrary length key, to match with two dashes. Single-character keys will also match -o one dash.
    ///  - Parameter shortKey: a single-character key. If none is supplied, and `key` was previously registered, the corresponding `shortKey` will be automatically used
    /// - Parameter index: the index of an unflagged argument, to be used if no `key` or `shortKey` matches. E.g. you might allow the user to specify a path either with the flag `input`, or simply supply the path.
    ///  - Parameter args: an array of arguments. If none is supplied, any arguments registered with the system will be used instead.
    public func string(forKey key: String, shortKey: String? = nil, index: Int? = nil, args: [String]? = nil) -> String? {
        let args = args ?? arguments
        
        if let val = nextValueAfter(key: "--" + key, args: args) {
            return val
        }

        // one-character flags can be used with a single trailing dash
        // otherwise, it's interpreted as combined flags.
        // e.g. -path -> 'p' 'a' 't' 'h'
        if key.count == 1 {
            if let val = nextValueAfter(key: "-" + key, args: args) {
                return val
            }
        }
        
        // fetch our short key from a pre-supplied flag, if it exists
        if let shortKey = shortKeyWith(key: key, shortKey: shortKey) {
            if let val = nextValueAfter(key: "-" + shortKey, args: args) {
                return val
            }
        }
        
        if let index = indexWith(key: key, index: index) {
            let unflaggedArgs = unflaggedArguments()
            
            if unflaggedArgs.count > index {
                return unflaggedArgs[index]
            }
        }
        
        return nil
    }
    
    /// Returns `true` if the key or short key is present, false otherwise.
    ///
    /// Keep in mind that single-character `shortKey` variables can be combined. So `-rf` would match return `true` for both `r` and `f`, but `false` for `rf`. `--rf` would return true for `rf` but false for both `r` and `f`.
    /// 
    ///  - Parameter key: an arbitrary length key, to match with two dashes. Single-character keys will also match -o one dash.
    ///  - Parameter shortKey: a single-character key. If none is supplied, and `key` was previously registered, the corresponding `shortKey` will be automatically used
    ///  - Parameter args: ar array of arguments. If none is supplied, any arguments registered with the system will be used instead.
    public func bool(forKey key: String, shortKey: String? = nil, args: [String]? = nil) -> Bool {
        let args = args ?? arguments
        
        if args.firstIndex(of: "--" + key) != nil {
            return true
        }

        if argsContainSingleDashed(key: key, args: args) {
            return true
        }
        
        // fetch our short key from a pre-supplied flag, if it exists
        guard let shortKey = shortKeyWith(key: key, shortKey: shortKey) else { return false }
        
        return argsContainSingleDashed(key: shortKey, args: args)
    }
    
    /// Returns a string with a trailing slash, or nil if none could be found.
    ///
    /// If no trailing slash is present in the value, one will be appended.

    /// - Parameter key: an arbitrary length key, to match with two dashes. Single-character keys will also match -o one dash.
    /// - Parameter shortKey: a single-character key. If none is supplied, and `key` was previously registered, the corresponding `shortKey` will be automatically used
    /// - Parameter args: ar array of arguments. If none is supplied, any arguments registered with the system will be used instead.
    ///
    public func dir(forKey key: String, shortKey: String? = nil, index: Int? = nil, args: [String]? = nil) -> String? {
        guard let path = string(forKey: key, shortKey: shortKey, index: index, args: args) else { return nil }
        return dirWithPath(path)
    }
    
    /// Returns an Int, or nil if none could be found
    ///
    /// - Parameter key: an arbitrary length key, to match with two dashes. Single-character keys will also match -o one dash.
    /// - Parameter shortKey: a single-character key. If none is supplied, and `key` was previously registered, the corresponding `shortKey` will be automatically used
    /// - Parameter args: ar array of arguments. If none is supplied, any arguments registered with the system will be used instead.
    public func int(forKey key: String, shortKey: String? = nil, index: Int? = nil, args: [String]? = nil) -> Int? {
        guard let string = string(forKey: key, shortKey: shortKey, index: index, args: args) else { return nil }
        return Int(string)
    }
    
    /// Returns a Double, or nil if none could be found
    ///
    /// - Parameter key: an arbitrary length key, to match with two dashes. Single-character keys will also match -o one dash.
    /// - Parameter shortKey: a single-character key. If none is supplied, and `key` was previously registered, the corresponding `shortKey` will be automatically used
    /// - Parameter args: ar array of arguments. If none is supplied, any arguments registered with the system will be used instead.
    public func double(forKey key: String, shortKey: String? = nil, index: Int? = nil, args: [String]? = nil) -> Double? {
        guard let string = string(forKey: key, shortKey: shortKey, index: index, args: args) else { return nil }
        return Double(string)
    }
    
    // MARK: - Utility
    
    /**
     - Returns: an array of arguments given a string, in the same format returned by `CommandLine.arguments`
     
     - Parameter string: a space-separated string. Note that the first argument will not be considered one of your flags.
     */
    public static func args(from string: String) -> [String] {
        var args: [String] =  ["."]
        let components = string.split(separator: " ").map({ String($0) })
        args.append(contentsOf: components)
        return args
     }

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
    
    func indexWith(key: String, index: Int?) -> Int? {
        // use the supplied key if it exists
        if let index = index {
            return index
        }
        
        // fall back to a registered flag
        if let flag = flags[key] {
            return flag.index
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

    func dirWithPath(_ path: String) -> String {
        var dir = path
        if let last = path.last {
            if last != "/" {
                dir += "/"
            }
        }
        
        return dir
    }

    func argsContainSingleDashed(key: String, args: [String]) -> Bool {
        // get the single-dashed groups from args
        for arg in args {
            guard !arg.starts(with: "--") else { continue }
            guard arg.starts(with: "-") else { continue }
            
            if arg.contains(key) {
                return true
            }
        }

        return false
    }

}
