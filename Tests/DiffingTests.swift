import XCTest
@testable import Diffing

final class DiffingTests: XCTestCase {
    
    func testSimpleInsertion() {
        let old = [1, 2, 3, 4, 5]
        let new = [1, 2, 3, 4, 5, 6]
        
        let difference = old.difference(to: new)
        XCTAssertEqual(difference.sortedChanges, [.insert(value: 6, index: 5)])
        XCTAssertEqual(old.applying(difference: difference), new)
    }
    
    func testSimpleDeletion() {
        let old = [1, 2, 3, 4, 5]
        let new = [1, 2, 4, 5]
        
        let difference = old.difference(to: new)
        XCTAssertEqual(difference.sortedChanges, [.delete(value: 3, index: 2)])
        XCTAssertEqual(old.applying(difference: difference), new)
    }
    
    func testSimpleMove() {
        let old = [1, 2, 3, 4, 5]
        let new = [2, 1, 3, 4, 5]
        
        let difference = old.difference(to: new)
        XCTAssertEqual(difference.unsortedChanges, [.move(value: 2, sourceIndex: 1, destinationIndex: 0),
                                                    .move(value: 1, sourceIndex: 0, destinationIndex: 1)])
        XCTAssertEqual(old.applying(difference: difference), new)
    }
}
