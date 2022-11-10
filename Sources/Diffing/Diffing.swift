//
//  Diffing.swift
//  
//
//  Created by William McGinty on 1/3/21.
//

import Foundation

public protocol Diffing {
    func changes<T: Diffable>(from old: [T], to new: [T]) -> [Change<T>]
    func difference<T: Diffable>(from old: [T], to new: [T]) -> Difference<T>
}

public extension Diffing {
    
    func difference<T: Diffable>(from old: [T], to new: [T]) -> Difference<T> {
        return Difference<T>(changes(from: old, to: new), old: old, new: new)
    }
}

public enum Change<T: Diffable>: Equatable {
    case insert(value: T, index: Int)
    case delete(value: T, index: Int)
    case move(value: T, sourceIndex: Int, destinationIndex: Int)
    case update(old: T, new: T, index: Int)
    
    // MARK: - Interface
    public var isInsertion: Bool {
        switch self {
        case .insert: return true
        default: return false
        }
    }
    
    public var isDeletion: Bool {
        switch self {
        case .delete: return true
        default: return false
        }
    }
    
    public var isMove: Bool {
        switch self {
        case .move: return true
        default: return false
        }
    }
    
    public var isUpdate: Bool {
        switch self {
        case .update: return true
        default: return false
        }
    }
    
    // MARK: - CustomDebugStringConvertible
    public var debugDescription: String {
        switch self {
        case let .insert(value, index): return "Insert \(value) at index \(index)"
        case let .delete(value, index): return "Delete \(value) at index \(index)"
        case let .move(value, from, to): return "Move \(value) from index \(from) to index \(to)"
        case let .update(old, new, index): return "Update \(old) to \(new) at index \(index)"
        }
    }
}

public struct Difference<T: Diffable> {

    public typealias Element = Change<T>
    public typealias Index = Int
    
    // MARK: - Properties
    public let old: [T]
    public let new: [T]
    public let unsortedChanges: [Change<T>]
    public let sortedChanges: [Change<T>]
        
    // MARK: - Initializers
    public init(old: [T], new: [T], algorithm: Diffing) {
        self.init(algorithm.changes(from: old, to: new), old: old, new: new)
    }
    
    init(_ changes: [Change<T>], old: [T], new: [T]) {
        self.unsortedChanges = changes
        self.sortedChanges = Self.sortedChanges(from: changes, old: old, new: new)
        self.old = old
        self.new = new
    }
}

// MARK: - Interface
public extension Difference {
    
    func applied(to collection: [T]) -> [T] {
        return sortedChanges.reduce(into: collection) { result, change in
            switch change {
            case let .insert(value, index): result.insert(value, at: index)
            case let .delete(_, index): result.remove(at: index)
            case let .update(_, new, index): result[index] = new
            case let .move(value, fromIndex, toIndex):
                result.remove(at: fromIndex)
                result.insert(value, at: toIndex)
            }
        }
    }
}

// MARK: - Helper
private extension Difference {
        
    static func sortedChanges(from unsorted: [Change<T>], old: [T], new: [T]) -> [Change<T>] {
        var insertions: [Change<T>] = []
        var updates: [Change<T>] = []
        var indexedDeletions: [[Change<T>]] = Array(repeating: [], count: old.count)
        
        for change in unsorted {
            switch change {
            case .insert: insertions.append(change)
            case .update: updates.append(change)
            case let .delete(_, from): indexedDeletions[from].append(change)
            case let .move(value, from, to):
                insertions.append(.insert(value: value, index: to))
                indexedDeletions[from].append(.delete(value: value, index: from))
            }
        }
        
        // Return updates + sorted deletions + insertions
        return  updates + indexedDeletions.compactMap { $0.first }.reversed() + insertions
    }
}

// MARK: - Equatable
extension Difference: Equatable where T: Equatable { }
