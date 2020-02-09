# DashDashSwift

An unopinionated command line parser for Swift CLI projects.

## Installation

DashDashSwift is available as a Swift package. Here's [a quick guide from Apple](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) about integrating packages into your application.

(You could also just drag the contents of `Sources/DashDashSwift` into your project direcly, if you like.)


## Getting Started

You can use an instance of `CommandLineParser` to parse an array of arguments. Generally, you'd get these from an instance of `CommandLine`. 

From there, a parser has methods to extract strings, ints, doubles, bools and more.


## Examples


### The Bare Minimum

```swift
import DashDashSwift

// create a parser
var parser = CommandLineParser()

let name = parser.stringFor(key: "name", shortKey: "n", args: CommandLine.arguments) ?? "Anonymous"

let age = parser.intFor(key: "age", args: CommandLine.arguments) ?? 21

let height = parser.doubleFor(key: "height", shortKey:"h" args: CommandLine.arguments) ?? 180.0

```


### More Flair


```swift
import DashDashSwift

// create a parser, passing in a title and description.
// this will be printed when a user requests help
var parser = CommandLineParser(title: "Chotchkie", description: "Chotchkie is a command line program to control the amount of flair on your uniform.")


// optionally register the command line arguments to parse.
// you may also pass this value in to any of the parser's functions
parser.arguments = CommandLine.arguments

// optionally register your commands with the parser.
// this allows you to ask for `key` and get `shortKey` automatically,
// as well as printing a help message with all the commands automatically.
parser.register(key: "input", shortKey: "i", description: "The location where files should be read from.")
parser.register(key: "output",  shortKey: "o", description: "The location where files should be saved.")
parser.register(key: "size", shortKey: "s", description: "The desired file size, in bytes")
parser.register(key: "all", shortKey: "a", description: "Boolean. Whether or not all directories should be included.")

// parse! there are methods for strings, bools, directories, ints, and doubles
// all, naturally, return optional values
guard let input = parser.dirFor(key: "input") else {
    parser.printHelp()
    fatalError()
}

guard let output = parser.dirFor(key: "output") else { 
    parser.printHelp()
    fatalError()
}

if parser.boolFor(key: "all") {
    // ...
}

let size = parser.intFor(key: "size") ?? 1024

```

