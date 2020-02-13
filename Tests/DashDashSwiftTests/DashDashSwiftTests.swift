
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
        parser.arguments = CommandLineParser.argsFrom(string: "--name Scruffy")
        let value = parser.string(forKey : "name")
        XCTAssertEqual(value, "Scruffy")
    }
    
    func testOneCharacterNameParsing() {
        parser.arguments = CommandLineParser.argsFrom(string: "-n Scruffy")
        let value = parser.string(forKey : "n")
        XCTAssertEqual(value, "Scruffy")
    }
    
    func testShortStringParsing() {
        parser.arguments = CommandLineParser.argsFrom(string: "-n Scruffy")
        let value = parser.string(forKey: "name", shortKey: "n")
        XCTAssertEqual(value, "Scruffy")
    }
    
    func testRegisteredShortStringParsing() {
        parser.register(key: "name", shortKey: "n", description: nil)
        
        parser.arguments = CommandLineParser.argsFrom(string: "-n Scruffy")
        let value = parser.string(forKey : "name")
        XCTAssertEqual(value, "Scruffy")
    }

    // MARK: Ints
    
    func testIntParsing() {
        parser.arguments = CommandLineParser.argsFrom(string: "-n Scruffy --age 7")
        XCTAssertEqual(7, parser.int(forKey: "age"))
    }

    func testShortIntParsing() {
        parser.arguments = CommandLineParser.argsFrom(string: "-n Scruffy -a 7")
        XCTAssertEqual(7, parser.int(forKey: "age", shortKey: "a"))
    }
    
    func testShortIntParsingWithSuppliedArguments() {
        XCTAssertEqual(7, parser.int(forKey: "age", shortKey: "a", args: CommandLineParser.argsFrom(string: "-n Scruffy -a 7")))
    }

    // MARK: Doubles
    
    func testDoubleParsing() {
        parser.arguments = CommandLineParser.argsFrom(string: "-n Scruffy --age 7.0")
        XCTAssertEqual(7.0, parser.double(forKey: "age"))
    }

    func testShortDoubleParsing() {
        parser.arguments = CommandLineParser.argsFrom(string: "-n Scruffy -a 7")
        
        XCTAssertEqual(7.0, parser.double(forKey: "age", shortKey: "a"))
    }
    
    
    // MARK: Unflagged Arguments
    
    func testUnflaggedArguments() {
        parser.arguments = CommandLineParser.argsFrom(string: "./input_path ./output_path")
        XCTAssertEqual(parser.unflaggedArguments().count, 2)
        
        XCTAssertEqual(parser.unflaggedArguments()[0], "./input_path")
        XCTAssertEqual(parser.unflaggedArguments()[1], "./output_path")
    }
    
    func testMixedUnflaggedArguments() {
        parser.arguments = CommandLineParser.argsFrom(string: "--name Scruffy ./input_path -a 7 ./output_path --size 0.5")
        XCTAssertEqual(parser.unflaggedArguments().count, 2)
        
        XCTAssertEqual(parser.unflaggedArguments()[0], "./input_path")
        XCTAssertEqual(parser.unflaggedArguments()[1], "./output_path")
    }
    
    // MARK: Bools
    
    func testBools() {
        XCTAssertTrue(parser.bool(forKey: "f", args: CommandLineParser.argsFrom(string: "--path . --r --f")))
        XCTAssertTrue(parser.bool(forKey: "r", args: CommandLineParser.argsFrom(string: "--path . --r --f")))
        
        XCTAssertFalse(parser.bool(forKey: "f", args: CommandLineParser.argsFrom(string: "--path . ")))
        XCTAssertFalse(parser.bool(forKey: "r", args: CommandLineParser.argsFrom(string: "--path . ")))
    }

    func testShortBools() {
        parser.register(key: "force", shortKey: "f", description: nil)
        parser.register(key: "recursive", shortKey: "r", description: nil)
        
        XCTAssertTrue(parser.bool(forKey: "force", args: CommandLineParser.argsFrom(string: "--path . -r -f")))
        XCTAssertTrue(parser.bool(forKey: "recursive", args: CommandLineParser.argsFrom(string: "--path . -r -f")))
        
        XCTAssertFalse(parser.bool(forKey: "force", args: CommandLineParser.argsFrom(string: "--path . ")))
        XCTAssertFalse(parser.bool(forKey: "recursive", args: CommandLineParser.argsFrom(string: "--path . ")))
    }


    func testCombinedFlags() {
        XCTAssertTrue(parser.bool(forKey: "f", args: CommandLineParser.argsFrom(string: "--path . -rf")))
        XCTAssertTrue(parser.bool(forKey: "r", args: CommandLineParser.argsFrom(string: "--path . -rf")))

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

