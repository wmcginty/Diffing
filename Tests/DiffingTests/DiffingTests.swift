import XCTest
@testable import Diffing

final class DiffingTests: XCTestCase {
    
    func testSimpleInsertion() {
        let old = [1, 2, 3, 4, 5]
        let new = [1, 2, 3, 4, 5, 6]
        
        let changes = old.changes(to: new)
        XCTAssertEqual(changes.sortedChanges, [.insert(value: 6, index: 5)])
        XCTAssertEqual(old.applying(changes: changes), new)
    }
    
    func testSimpleDeletion() {
        let old = [1, 2, 3, 4, 5]
        let new = [1, 2, 4, 5]
        
        let changes = old.changes(to: new)
        XCTAssertEqual(changes.sortedChanges, [.delete(value: 3, index: 2)])
        XCTAssertEqual(old.applying(changes: changes), new)
    }
    
    func testSimpleMove() {
        let old = [1, 2, 3, 4, 5]
        let new = [2, 1, 3, 4, 5]
        
        let changes = old.changes(to: new)
        XCTAssertEqual(changes.unsortedChanges, [.move(value: 2, sourceIndex: 1, destinationIndex: 0),
                                                 .move(value: 1, sourceIndex: 0, destinationIndex: 1)])
        
        let diff = new.difference(from: old).inferringMoves()
        print(changes.sortedChanges)
        print(diff)
        XCTAssertEqual(old.applying(changes: changes), new)
    }
}
