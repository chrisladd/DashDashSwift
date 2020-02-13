# DashDashSwift

![DashDashSwift Logo](../assets/dashdashlogo.png?raw=true)

An unopinionated command line parser for Swift CLI projects. DashDashSwift gives straightforward, sophisticated key-value access to command line arguments.

## Installation

DashDashSwift is available as a Swift package. Here's [a quick guide from Apple](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) about integrating packages into your application.

(You could also just drag the contents of `Sources/DashDashSwift` into your project direcly, if you like.)


## Getting Started

You can use an instance of `CommandLineParser` to parse an array of arguments. Generally, you'd get these from an instance of `CommandLine`, but the `args(from:)` function can produce these from a plain string. 

From there, a parser has methods to extract strings, ints, doubles, bools and more.

```swift
// example --name Chris --age 8
var parser = CommandLineParser()
parser.arguments = CommandLine.arguments
let name = parser.string(forKey: "name") // -> Optional("Chris")
let age = parser.int(forKey: "age")      // -> Optional(8)
```

The parser expects multi-character flags to be prefixed with `--`, and allows single-character boolean flags to be grouped together eith a single `-`. For example:

```swift
let command = `-rf --path ./input.json -o ./output.json`
var parser = CommandLineParser()
parser.arguments = CommandLineParser.args(from: command)

let inputPath = parser.string(forKey: "path") // -> Optional("./input.json")
let outputPath = parser.string(forKey: "o")   // -> Optional("./output.json")

let isRecursive = parser.bool(forKey: "r")    // -> true
let isForced = parser.bool(forKey: "f")       // -> true
```


## Examples


### The Bare Minimum

```swift
import DashDashSwift

// create a parser
var parser = CommandLineParser()

let name = parser.string(forKey: "name", shortKey: "n", args: CommandLine.arguments) ?? "Anonymous"

let age = parser.int(forKey: "age", args: CommandLine.arguments) ?? 21

let height = parser.double(forKey: "height", shortKey:"h" args: CommandLine.arguments) ?? 180.0

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
parser.register(key: "help", shortKey: "h", description: "Print this help message")

if (parser.bool(forKey: "h")) {
    parser.printHelp()
}

if parser.bool(forKey: "all") {
    // ...
}

let size = parser.int(forKey: "size") ?? 1024

// Be flexible! Allow users to pass in unnamed arguments, 
// and fall back to them by index. 
// 
// The below code allows
//    script ./path1 ./path2
// or
//    script -i ./path1 -o ./path2
// or
//    script --input ./path1 --output ./path2
//
let input = parser.stringFor(key: "input", or: 0)
let output = parser.stringFor(key: "output", or: 1)

if let input = input, let output = output {
   // ...
}

```

## Who made this?

Great question. [I'm Chris](http://www.chrisladd.net)—I make iOS apps like [ChordBank](https://www.chordbank.com) and [Better Notes](https://apps.apple.com/us/app/better-notes-lists-and-todos/id980887055), in addition to selected client dev and design work. In the process, I write lots and lots of command line utilities.

Do you have an interesting and well-financed iOS project you'd like help with? [Let's talk](http://www.chrisladd.net/contact/)!
