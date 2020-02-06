import XCTest
@testable import DashDashSwift

final class FlagTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CommandLineFlag().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
