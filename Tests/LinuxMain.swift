import XCTest

import FlagTests

var tests = [XCTestCaseEntry]()
tests += FlagTests.allTests()
XCTMain(tests)
