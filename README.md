# DashDashSwift

An unopinionated command line parser for Swift CLI projects. DashDashSwift gives straightforward, sophisticated key-value access to command line arguments.

## Installation

DashDashSwift is available as a Swift package. Here's [a quick guide from Apple](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) about integrating packages into your application.

(You could also just drag the contents of `Sources/DashDashSwift` into your project direcly, if you like.)


## Getting Started

You can use an instance of `CommandLineParser` to parse an array of arguments. Generally, you'd get these from an instance of `CommandLine`, but the `argsFrom(string:)` function can produce these from a plain string. 

From there, a parser has methods to extract strings, ints, doubles, bools and more.

```swift
var parser = CommandLineParser()
parser.arguments = CommandLine.arguments
let name = parser.stringFor(key: "name")
let age = parser.intFor(key: "age")
```

The parser expects multi-character flags to be prefixed with `--`, and allows single-character boolean flags to be grouped together eith a single `-`. For example:

```swift
let command = `-rf --path ./input.json -o ./output.json`
var parser = CommandLineParser()
parser.arguments = CommandLineParser.argsFrom(string: command)

let inputPath = parser.stringFor(key: "path") // -> Optional("./input.json")
let outputPath = parser.stringFor(key: "o") // -> Optional("./output.json")

let isRecursive = parser.boolFor(key: "r") // -> true
let isForced = parser.boolFor(key: "f") // -> true
```


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

## Who made this?

Great question. [I'm Chris](http://www.chrisladd.net)—I make iOS apps like [ChordBank](https://www.chordbank.com) and [Better Notes](https://apps.apple.com/us/app/better-notes-lists-and-todos/id980887055), in addition to selected client dev and design work. In the process, I write lots and lots of command line utilities.

Do you have an interesting and well-financed iOS project you'd like help with? [Let's talk](http://www.chrisladd.net/contact/)!
