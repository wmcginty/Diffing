import XCTest
@testable import Diffing

final class DiffingTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Diffing().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
