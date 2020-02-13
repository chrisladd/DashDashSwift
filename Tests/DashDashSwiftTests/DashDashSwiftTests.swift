
import XCTest
@testable import DashDashSwift

class FlagTests: XCTestCase {
    var parser = CommandLineParser()

    override func setUp() {
        parser = CommandLineParser()
        parser.maxLineLength = 60
    }
    
    // MARK: Strings
    
    func testStringParsing() {
        parser.arguments = CommandLineParser.args(from: "--name Scruffy")
        let value = parser.string(forKey : "name")
        XCTAssertEqual(value, "Scruffy")
    }
    
    func testOneCharacterNameParsing() {
        parser.arguments = CommandLineParser.args(from: "-n Scruffy")
        let value = parser.string(forKey : "n")
        XCTAssertEqual(value, "Scruffy")
    }
    
    func testShortStringParsing() {
        parser.arguments = CommandLineParser.args(from: "-n Scruffy")
        let value = parser.string(forKey: "name", shortKey: "n")
        XCTAssertEqual(value, "Scruffy")
    }
    
    func testRegisteredShortStringParsing() {
        parser.register(key: "name", shortKey: "n", description: nil)
        
        parser.arguments = CommandLineParser.args(from: "-n Scruffy")
        let value = parser.string(forKey : "name")
        XCTAssertEqual(value, "Scruffy")
    }
    
    func testAllStringVariationsProduceSameResults() {
        parser.register(key: "name", shortKey: "n", description: nil)
        let args = CommandLineParser.args(from: "-n Scruffy")
        parser.arguments = args
        
        XCTAssertEqual(parser.string(forKey: "n"), "Scruffy")
        XCTAssertEqual(parser.string(forKey: "name"), "Scruffy")
        XCTAssertEqual(parser.string(forKey: "n", args: args), "Scruffy")
        XCTAssertEqual(parser.string(forKey: "name", args: args), "Scruffy")
        XCTAssertEqual(parser.string(forKey: "name", shortKey: "n"), "Scruffy")
        XCTAssertEqual(parser.string(forKey: "name", shortKey: "n", args: args), "Scruffy")
    }

    // MARK: Ints
    
    func testIntParsing() {
        parser.arguments = CommandLineParser.args(from: "-n Scruffy --age 7")
        XCTAssertEqual(7, parser.int(forKey: "age"))
    }

    func testShortIntParsing() {
        parser.arguments = CommandLineParser.args(from: "-n Scruffy -a 7")
        XCTAssertEqual(7, parser.int(forKey: "age", shortKey: "a"))
    }
    
    func testShortIntParsingWithSuppliedArguments() {
        XCTAssertEqual(7, parser.int(forKey: "age", shortKey: "a", args: CommandLineParser.args(from: "-n Scruffy -a 7")))
    }

    func testAllIntVariationsProduceSameResults() {
        parser.register(key: "age", shortKey: "a", description: nil)
        let args = CommandLineParser.args(from: "-a 17")
        parser.arguments = args
        
        XCTAssertEqual(parser.int(forKey: "a"), 17)
        XCTAssertEqual(parser.int(forKey: "age"), 17)
        XCTAssertEqual(parser.int(forKey: "a", args: args), 17)
        XCTAssertEqual(parser.int(forKey: "age", args: args), 17)
        XCTAssertEqual(parser.int(forKey: "age", shortKey: "a"), 17)
        XCTAssertEqual(parser.int(forKey: "age", shortKey: "a", args: args), 17)
    }
    
    // MARK: Doubles
    
    func testDoubleParsing() {
        parser.arguments = CommandLineParser.args(from: "-n Scruffy --age 7.0")
        XCTAssertEqual(7.0, parser.double(forKey: "age"))
    }

    func testShortDoubleParsing() {
        parser.arguments = CommandLineParser.args(from: "-n Scruffy -a 7")
        
        XCTAssertEqual(7.0, parser.double(forKey: "age", shortKey: "a"))
    }
    
    func testAllDoubleVariationsProduceSameResults() {
        parser.register(key: "age", shortKey: "a", description: nil)
        let args = CommandLineParser.args(from: "-a 17")
        parser.arguments = args
        
        XCTAssertEqual(parser.double(forKey: "a"), 17.0)
        XCTAssertEqual(parser.double(forKey: "age"), 17.0)
        XCTAssertEqual(parser.double(forKey: "a", args: args), 17.0)
        XCTAssertEqual(parser.double(forKey: "age", args: args), 17.0)
        XCTAssertEqual(parser.double(forKey: "age", shortKey: "a"), 17.0)
        XCTAssertEqual(parser.double(forKey: "age", shortKey: "a", args: args), 17.0)
    }
    
    // MARK: Unflagged Arguments
    
    func testUnflaggedArguments() {
        parser.arguments = CommandLineParser.args(from: "./input_path ./output_path")
        XCTAssertEqual(parser.unflaggedArguments().count, 2)
        
        XCTAssertEqual(parser.unflaggedArguments()[0], "./input_path")
        XCTAssertEqual(parser.unflaggedArguments()[1], "./output_path")
    }
    
    func testMixedUnflaggedArguments() {
        parser.arguments = CommandLineParser.args(from: "--name Scruffy ./input_path -a 7 ./output_path --size 0.5")
        XCTAssertEqual(parser.unflaggedArguments().count, 2)
        
        XCTAssertEqual(parser.unflaggedArguments()[0], "./input_path")
        XCTAssertEqual(parser.unflaggedArguments()[1], "./output_path")
    }
    
    // MARK: Bools
    
    func testBools() {
        XCTAssertTrue(parser.bool(forKey: "f", args: CommandLineParser.args(from: "--path . --r --f")))
        XCTAssertTrue(parser.bool(forKey: "r", args: CommandLineParser.args(from: "--path . --r --f")))
        
        XCTAssertFalse(parser.bool(forKey: "f", args: CommandLineParser.args(from: "--path . ")))
        XCTAssertFalse(parser.bool(forKey: "r", args: CommandLineParser.args(from: "--path . ")))
    }

    func testShortBools() {
        parser.register(key: "force", shortKey: "f", description: nil)
        parser.register(key: "recursive", shortKey: "r", description: nil)
        
        XCTAssertTrue(parser.bool(forKey: "force", args: CommandLineParser.args(from: "--path . -r -f")))
        XCTAssertTrue(parser.bool(forKey: "recursive", args: CommandLineParser.args(from: "--path . -r -f")))
        
        XCTAssertFalse(parser.bool(forKey: "force", args: CommandLineParser.args(from: "--path . ")))
        XCTAssertFalse(parser.bool(forKey: "recursive", args: CommandLineParser.args(from: "--path . ")))
    }

    func testCombinedFlags() {
        XCTAssertTrue(parser.bool(forKey: "f", args: CommandLineParser.args(from: "--path . -rf")))
        XCTAssertTrue(parser.bool(forKey: "r", args: CommandLineParser.args(from: "--path . -rf")))
    }

    func testAllBoolVariationsProduceSameResults() {
        parser.register(key: "isOfAge", shortKey: "a", description: nil)
        let args = CommandLineParser.args(from: "-ajr")
        parser.arguments = args
        
        XCTAssertEqual(parser.bool(forKey: "a"), true)
        XCTAssertEqual(parser.bool(forKey: "isOfAge"), true)
        XCTAssertEqual(parser.bool(forKey: "a", args: args), true)
        XCTAssertEqual(parser.bool(forKey: "isOfAge", args: args), true)
        XCTAssertEqual(parser.bool(forKey: "isOfAge", shortKey: "a"), true)
        XCTAssertEqual(parser.bool(forKey: "isOfAge", shortKey: "a", args: args), true)
    }

    
    // MARK: Help
    
    func testDescriptionIndentation() {
        parser = CommandLineParser(title: "DashDashSwift", description: """
For a year and a half, the GNU shell was "just about done". The author made repeated promises to deliver what he had done, and never kept them.

Finally I could no longer believe he would ever deliver anything.

So Foundation staff member Brian Fox is now implementing an imitation of the Bourne shell.  Once it is done, we will extend it with the features of the Korn shell, thus coming to Berkeley's aid.
""")
        
        let expHelp = """
  DashDashSwift

  For a year and a half, the GNU shell was "just about done".
  The author made repeated promises to deliver what he had
  done, and never kept them.
  
  Finally I could no longer believe he would ever deliver
  anything.
  
  So Foundation staff member Brian Fox is now implementing
  an imitation of the Bourne shell.  Once it is done, we
  will extend it with the features of the Korn shell, thus
  coming to Berkeley's aid.


"""

        XCTAssertEqual(parser.help(), expHelp)
        
        print("\n")
        parser.printHelp()
        print("\n")
    }
    
    func testHelpIndentation() {
        parser.register(key: "force", shortKey: "f", description: "whether to force the issue")
        parser.register(key: "recursive", shortKey: "r", description: "whether to force all the other issues")
        
        let expHelp = """
  --force      -f  whether to force the issue
  --recursive  -r  whether to force all the other issues

"""

        XCTAssertEqual(parser.help(), expHelp)
    }
    
    func testHelpLineBreaks() {
        parser.register(key: "force", shortKey: "f", description: "By such deductions the law of gravitation is rendered probable, that every particle attracts every other particle with a force which varies inversely as the square of the distance. The law thus suggested is assumed to be universally true.")
        
        let expHelp = """
  --force  -f  By such deductions the law of gravitation is
               rendered probable, that every particle
               attracts every other particle with a force
               which varies inversely as the square of the
               distance. The law thus suggested is assumed
               to be universally true.

"""

        XCTAssertEqual(parser.help(), expHelp)
    }
    
    func testParserMaxWidth() {
        parser.register(key: "force", shortKey: "f", description: "By such deductions the law of gravitation is rendered probable, that every particle attracts every other particle with a force which varies inversely as the square of the distance. The law thus suggested is assumed to be universally true.")
        
        let expHelp = """
  --force  -f  By such deductions the law of gravitation is
               rendered probable, that every particle
               attracts every other particle with a force
               which varies inversely as the square of the
               distance. The law thus suggested is assumed
               to be universally true.

"""

        XCTAssertEqual(parser.help(), expHelp)
        
        parser.maxLineLength = 120
        
         let expHelp2 = """
  --force  -f  By such deductions the law of gravitation is rendered probable, that every particle attracts every other
               particle with a force which varies inversely as the square of the distance. The law thus suggested is
               assumed to be universally true.

"""

        XCTAssertEqual(parser.help(), expHelp2)
    }
    
}

