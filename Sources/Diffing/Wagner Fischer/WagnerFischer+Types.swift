//
//  WagnerFischer+Types.swift
//  
//
//  Created by William McGinty on 1/3/21.
//

import Foundation

extension WagnerFischer {
    
    struct Matrix {
        
        // MARK: - Subtypes
        struct Coordinate {
            
            // MARK: - Properties
            let row: Int
            let column: Int
            
            // MARK: - Initializer
            init(row: Int, column: Int) {
                self.row = row
                self.column = column
            }
            
            // MARK: Interface
            var previousColumn: Coordinate {
                return Coordinate(row: row, column: max(0, column - 1))
            }
            
            var previousRow: Coordinate {
                return Coordinate(row: max(0, row - 1), column: column)
            }
        }
        
        // MARK: - Properties
        public private(set) var storage: [[Int]]
        public var end: Coordinate {
            return Coordinate(row: storage[0].count - 1, column: storage.count - 1)
        }
        
        // MARK: - Initializer
        init(rows: Int, columns: Int) {
            storage = [[Int]](repeating: [Int](repeating: 0, count: rows), count: columns)
            (0..<rows).forEach { storage[0][$0] = $0 }
            (0..<columns).forEach { storage[$0][0] = $0 }
        }
        
        // MARK: - Interface
        func value(for coordinate: Coordinate) -> Int {
            let column = min(coordinate.column, max(0, storage.count - 1))
            let row = min(coordinate.row, max(0, storage[0].count - 1))
            
            return storage[column][row]
        }
        
        mutating func set(value: Int, at coordinate: Coordinate) {
            storage[coordinate.column][coordinate.row] = value
        }
        
        subscript(coordinate: Coordinate) -> Int {
            return value(for: coordinate)
        }
    }
}


// MARK: CustomStringConvertible
extension WagnerFischer.Matrix: CustomStringConvertible {
    
    var description: String {
        let columnRange = 0..<(storage.first?.count ?? 1)
        let columnResult = columnRange.reduce("") { accum, row in
            let rowRange = 0..<storage.count
            let rowResult: String = rowRange.reduce("") {
                return $0 + "\(value(for: Coordinate(row: row, column: $1))) "
            }
            
            return accum + "\(rowResult)\n"
        }
        
        return columnResult
    }
}
