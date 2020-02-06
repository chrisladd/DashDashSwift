# DashDashSwift

An unopinionated command line parser for swift CLI projects.

## Usage

```
import DashDashSwift

// create a parser
var parser = CommandLineParser()

// optionally register the command line arguments to parse.
// you may also pass this value in to any of the parser's functions
parser.arguments = CommandLine.arguments

// optionally register your commands with the parser.
// this allows you to ask for `key` and get `shortKey` automatically,
// as well as printing a help message with all the commands automatically.
parser.register(key: "input", shortKey: "i", description: "The location where files should be read from.")

parser.register(key: "output",  shortKey: "o", description: "The location where files should be saved.")

```


