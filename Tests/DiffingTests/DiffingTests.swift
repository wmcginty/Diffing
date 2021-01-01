import XCTest
@testable import Diffing

final class DiffingTests: XCTestCase {
    func testExample() {
        
        let old = [1, 2, 3, 4, 5]
        let new = [2, 1, 3, 4]
        
        let changes = old.changed(to: new, sortedChanges: false)
        print(changes.debugDescription)
        
        let diffed = old.applying(changes: changes)
        XCTAssertEqual(new, diffed)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
