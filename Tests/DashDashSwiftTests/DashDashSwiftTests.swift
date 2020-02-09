
import XCTest
@testable import DashDashSwift

class FlagTests: XCTestCase {
    var parser = CommandLineParser()

    func argsFrom(string: String) -> [String] {
        var args: [String] =  ["."]
        let components = string.split(separator: " ").map({ String($0) })
        args.append(contentsOf: components)
        return args
     }
    
    override func tearDown() {
        
    }
    
    override func setUp() {
        parser.arguments = []
        parser.unregisterAllKeys()
    }
    
    // MARK: Strings
    
    func testStringParsing() {
        parser.arguments = argsFrom(string: "--name Scruffy")
        let value = parser.stringFor(key: "name")
        XCTAssertEqual(value, "Scruffy")
    }
    
    func testShortStringParsing() {
        parser.arguments = argsFrom(string: "-n Scruffy")
        let value = parser.stringFor(key: "name", shortKey: "n")
        XCTAssertEqual(value, "Scruffy")
    }
    
    func testRegisteredShortStringParsing() {
        parser.register(key: "name", shortKey: "n", description: nil)
        
        parser.arguments = argsFrom(string: "-n Scruffy")
        let value = parser.stringFor(key: "name")
        XCTAssertEqual(value, "Scruffy")
    }

    // MARK: Ints
    
    func testIntParsing() {
        parser.arguments = argsFrom(string: "-n Scruffy --age 7")
        XCTAssertEqual(7, parser.intFor(key: "age"))
    }

    func testShortIntParsing() {
        parser.arguments = argsFrom(string: "-n Scruffy -a 7")
        XCTAssertEqual(7, parser.intFor(key: "age", shortKey: "a"))
    }
    
    func testShortIntParsingWithSuppliedArguments() {
        XCTAssertEqual(7, parser.intFor(key: "age", shortKey: "a", args: argsFrom(string: "-n Scruffy -a 7")))
    }

    // MARK: Doubles
    
    func testDoubleParsing() {
        parser.arguments = argsFrom(string: "-n Scruffy --age 7.0")
        XCTAssertEqual(7.0, parser.doubleFor(key: "age"))
    }

    func testShortDoubleParsing() {
        parser.arguments = argsFrom(string: "-n Scruffy -a 7")
        XCTAssertEqual(7.0, parser.doubleFor(key: "age", shortKey: "a"))
    }
    
    
    // MARK: Unflagged Arguments
    
    func testUnflaggedArguments() {
        parser.arguments = argsFrom(string: "./input_path ./output_path")
        XCTAssertEqual(parser.unflaggedArguments().count, 2)
        
        XCTAssertEqual(parser.unflaggedArguments()[0], "./input_path")
        XCTAssertEqual(parser.unflaggedArguments()[1], "./output_path")
    }
    
    func testMixedUnflaggedArguments() {
        parser.arguments = argsFrom(string: "--name Scruffy ./input_path -a 7 ./output_path --size 0.5")
        XCTAssertEqual(parser.unflaggedArguments().count, 2)
        
        XCTAssertEqual(parser.unflaggedArguments()[0], "./input_path")
        XCTAssertEqual(parser.unflaggedArguments()[1], "./output_path")
    }
    
    // MARK: Bools
    
    func testBools() {
        XCTAssertTrue(parser.boolForKey("f", args: argsFrom(string: "--path . --r --f")))
        XCTAssertTrue(parser.boolForKey("r", args: argsFrom(string: "--path . --r --f")))
        
        XCTAssertFalse(parser.boolForKey("f", args: argsFrom(string: "--path . ")))
        XCTAssertFalse(parser.boolForKey("r", args: argsFrom(string: "--path . ")))
    }

    
    func testShortBools() {
        parser.register(key: "force", shortKey: "f", description: nil)
        parser.register(key: "recursive", shortKey: "r", description: nil)
        
        XCTAssertTrue(parser.boolForKey("force", args: argsFrom(string: "--path . -r -f")))
        XCTAssertTrue(parser.boolForKey("recursive", args: argsFrom(string: "--path . -r -f")))
        
        XCTAssertFalse(parser.boolForKey("force", args: argsFrom(string: "--path . ")))
        XCTAssertFalse(parser.boolForKey("recursive", args: argsFrom(string: "--path . ")))
    }

    

}
