//
//  DiffingTypes.swift
//  
//
//  Created by William McGinty on 12/31/20.
//

import Foundation

// MARK: - Diffable
public protocol Diffable: Equatable {
    associatedtype ID: Hashable
    var diffID: ID { get }
}

public extension Diffable where Self: Hashable {
    var diffID: Int { return hashValue }
}

extension String: Diffable { }

extension Int: Diffable {}
extension Int8: Diffable {}
extension Int16: Diffable {}
extension Int32: Diffable {}
extension Int64: Diffable {}

extension Double: Diffable {}
extension Float: Diffable {}

// MARK: - Diffing Subtypes
extension Diffing {
    
    enum Reference {
        final class Entry {
            public var oldCounter = 0 // OC
            public var newCounter = 0 // NC
            public var oldIndex = 0 // OLNO
            
            var uniquelyAppearsInBoth: Bool {
                return oldCounter == 1 && newCounter == 1
            }
        }

        case entry(Entry)
        case index(Int)

        // MARK: - Interface
        var entry: Entry? {
            switch self {
            case let .entry(entry): return entry
            default: return nil
            }
        }

        var index: Int? {
            switch self {
            case let .index(index): return index
            default: return nil
            }
        }
    }
}

public extension Diffing {
    
    enum Change<T: Diffable>: Equatable {
        case insert(value: T, index: Int)
        case delete(value: T, index: Int)
        case move(value: T, fromIndex: Int, toIndex: Int)
        case update(value: T, index: Int)

        // MARK: - CustomDebugStringConvertible
        var debugDescription: String {
            switch self {
            case let .insert(value, index): return "Insert \(value) at index \(index)"
            case let .delete(value, index): return "Delete \(value) at index \(index)"
            case let .move(value, fromIndex, toIndex): return "Move \(value) from index \(fromIndex) to index \(toIndex)"
            case let .update(value, index): return "Update \(value) at index \(index)"
            }
        }
    }
}

