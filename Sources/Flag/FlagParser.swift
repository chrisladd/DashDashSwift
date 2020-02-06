//
//  FlagParser.swift
//  Grate
//
//  Created by Christopher Ladd on 1/11/20.
//  Copyright © 2020 Christopher Ladd. All rights reserved.
//

import Foundation

struct FlagParser {
    func unflaggedArgumentsFrom(_ args: [String]) -> [String] {
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
    
    func nextValueAfter(key: String, args:[String]) -> String? {
        guard let idx = args.firstIndex(of: key) else { return nil }
        guard idx < args.count - 1 else { return nil }
        let val = args[idx + 1]
        
        if let dashRange = val.firstIndex(of: "-") {
            guard dashRange > val.startIndex else { return  nil }
        }
        
        return val
    }
    
    func stringForKey(_ key: String, shortKey: String?, args: [String]) -> String? {
        if let val = nextValueAfter(key: "--" + key, args: args) {
            return val
        }
        
        guard let shortKey = shortKey else { return nil }
        if let val = nextValueAfter(key: "-" + shortKey, args: args) {
            return val
        }
        
        return nil
    }
    
    func boolForKey(_ key: String, shortKey: String?, args: [String]) -> Bool {
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
    
    func stringForFlag(_ flag: Flag, args: [String]) -> String? {
        return stringForKey(flag.key, shortKey: flag.shortKey, args: args)
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
    
    /**
     Similar to `stringForFlag`, but ensures paths end in a trailing `/`
     */
    func dirForFlag(_ flag: Flag, args: [String]) -> String? {
        guard let path = stringForFlag(flag, args: args) else { return nil }
        return dirWithPath(path)
    }
    
    func intForFlag(_ flag: Flag, args: [String]) -> Int? {
        guard let string = stringForFlag(flag, args: args) else { return nil }
        
        return Int(string)
    }
}
