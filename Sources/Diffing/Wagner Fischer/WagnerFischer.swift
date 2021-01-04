//
//  WagnerFischer.swift
//  
//
//  Created by William McGinty on 1/3/21.
//

import Foundation

struct WagnerFischer: Diffing {
    
    // MARK: - Subtype
    final class Context<T: Diffable> {
        
        // MARK: - Properties
        let old: [T]
        let new: [T]
        
        private lazy var changesMatrix: WagnerFischer.Matrix = generatedChangesMatrix()

        // MARK: - Initializer
        init(old: [T], new: [T]) {
            self.old = old
            self.new = new
        }
    }
    
    // MARK: - Initializer
    public init() { /* No op */ }
    
    func changes<T>(from old: [T], to new: [T]) -> [Change<T>] where T : Diffable {
        //
    }
}

// MARK: - Helper - Matrix Creation
private extension WagnerFischer.Context {
    
    func generatedChangesMatrix() -> WagnerFischer.Matrix {
        var editDistances = WagnerFischer.Matrix(rows: old.count + 1, columns: new.count + 1)
        
        for row in 1...old.count {
            for column in 1...new.count {
                
                let coordinate = WagnerFischer.Matrix.Coordinate(row: row, column: column)
                let update = changeCount(for: coordinate, in: editDistances,
                                         whenComponentsEqual: old[row - 1] == new[column - 1])
                editDistances.set(value: update, at: coordinate)
            }
        }
        
        return editDistances
    }
    
    func changeCount(for coordinate: WagnerFischer.Matrix.Coordinate,
                     in matrix: WagnerFischer.Matrix, whenComponentsEqual equal: Bool) -> Int {
        return equal
            ? matrix[coordinate.previousRow.previousColumn]
            : minimumChangeCount(neighboring: coordinate, in: matrix) + 1
    }
    
    func minimumChangeCount(neighboring coordinate: WagnerFischer.Matrix.Coordinate,
                                 in matrix: WagnerFischer.Matrix) -> Int {
        switch (coordinate.row, coordinate.column) {
        case let (row, col) where row > 0 && col > 0:
            return min(matrix[coordinate.previousRow], matrix[coordinate.previousColumn], matrix[coordinate.previousRow.previousColumn])
        case let (row, _) where row > 0: return matrix[coordinate.previousRow]
        case let (_, col) where col > 0: return matrix[coordinate.previousColumn]
        default: return 0
        }
    }
}

//// MARK: Interface
private extension WagnerFischer.Context {
    
    func generatedChanges() -> [Change<T>] {
        var edits: [Change<T>] = []
        var coordinate = changesMatrix.end

        while changesMatrix.value(for: coordinate) > 0 {
            if coordinate.row > 0 && coordinate.column > 0 && old[coordinate.row - 1] == new[coordinate.column - 1] {
                //The two elements are the same, no edit required. Move diagonally up the matrix and repeat.
                coordinate = coordinate.previousRow.previousColumn

            } else {

                switch minimumChangeCount(neighboring: coordinate, in: changesMatrix) {
                case changesMatrix[coordinate.previousRow] where coordinate.row > 0:
                    //It would be optimal to move UP the matrix (meaning a deletion)
                    coordinate = coordinate.previousRow
                    rangeAlteringEdits.append(deletionEdit(from: old, for: coordinate))

                case changesMatrix[coordinate.inPreviousColumn] where coordinate.column > 0:
                    //It would be optimal to move LEFT in the matrix (meaning an insertion)
                    coordinate = coordinate.previousColumn
                    rangeAlteringEdits.append(insertionEdit(into: new, for: coordinate))

                case _ where coordinate.row > 0 && coordinate.column > 0:
                    //It would be optimal to move DIAGONALLY UP the matrix (meaning a substitution)
                    coordinate = coordinate.previousRow.inPreviousColumn
                    edits.append(substitutionEdit(from: old, into: new, for: coordinate))

                default: continue
                }
            }
        }

        return edits + condensedRangeAlteringEdits(from: rangeAlteringEdits)
    }
}
//
//// MARK: Editor Creation
//private extension Transformer {
//    
//    static func deletionEdit(from source: T, for coordinate: Coordinate) -> AnyRangeAlteringEditor<T> {
//        guard let element = source[atOffset: coordinate.row], let index = source.index(atOffset: coordinate.row) else {
//                fatalError("Logic error - we have calculated a coordinate that should not exist")
//        }
//        
//        return AnyRangeAlteringEditor(editor: Deletion(source: source, deleted: element, atIndex: index))
//    }
//    
//    static func insertionEdit(into source: T, for coordinate: Coordinate) -> AnyRangeAlteringEditor<T> {
//        guard let element = source[atOffset: coordinate.column], let index = source.index(atOffset: coordinate.column) else {
//                fatalError("Logic error - we have calculated a coordinate that should not exist")
//        }
//        
//        return AnyRangeAlteringEditor(editor: Insertion(source: source, inserted: element, atIndex: index))
//    }
//    
//    static func substitutionEdit(from source: T, into destination: T, for coordinate: Coordinate) -> AnyEditor<T> {
//        guard let removed = source[atOffset: coordinate.row], let inserted = destination[atOffset: coordinate.column],
//            let index = source.index(atOffset: coordinate.row) else {
//                fatalError("Logic error - we have calculated a coordinate that should not exist")
//        }
//        
//        return AnyEditor(editor: Substitution(source: source, from: removed, to: inserted, atIndex: index))
//    }
//    
//    static func movementEdit(from lhs: AnyRangeAlteringEditor<T>, and rhs: AnyRangeAlteringEditor<T>) -> AnyEditor<T>? {
//        guard lhs.isAdditive != rhs.isAdditive && lhs.alteredElement == rhs.alteredElement else { return nil }
//        
//        let sourceOffset = !lhs.isAdditive ? lhs.alteredIndexOffset : rhs.alteredIndexOffset
//        let destOffset = lhs.isAdditive ? lhs.alteredIndexOffset : rhs.alteredIndexOffset
//
//        return AnyEditor(editor: Movement<T>(move: lhs.alteredElement, fromIndexOffset: sourceOffset, toIndexOffset: destOffset))
//    }
//}
//
//
//// MARK: Movement Processing
//private extension Transformer {
//    
//    static func condensedRangeAlteringEdits(from edits: [AnyRangeAlteringEditor<T>]) -> [AnyEditor<T>] {
//        var rangeAlteringEdits = [AnyEditor<T>]()
//        var (insertions, availableDeletions) = edits.bifilter { $0.isAdditive }
//        var unpairedInsertions = [AnyRangeAlteringEditor<T>]()
//
//        //Iterate over all of our additive (insertion) edits
//        insertionLoop: for insertion in insertions {
//            
//            //If an insertion and corresponding deletion are present - condense them into a move
//            for deletion in zip(availableDeletions.indices, availableDeletions) {
//                if let movement = movementEdit(from: insertion, and: deletion.1) {
//                    rangeAlteringEdits.append(movement)
//                    availableDeletions.remove(at: deletion.0)
//                    continue insertionLoop
//                }
//            }
//            
//            unpairedInsertions.append(insertion)
//        }
//        
//        return rangeAlteringEdits + unpairedInsertions.map(AnyEditor.init) + availableDeletions.map(AnyEditor.init)
//    }
//}
