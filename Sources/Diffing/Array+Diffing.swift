//
//  Array+Diffing.swift
//  
//
//  Created by William McGinty on 12/31/20.
//

import Foundation

public extension Array {
    
    func indexed() -> Zip2Sequence<Range<Array<Element>.Index>, [Element]> {
        return zip(indices, self)
    }
}

public extension Array where Element: Diffable {
    
    func changed(to new: [Element], sortedChanges: Bool = true) -> [Diffing.Change<Element>] {
        return sortedChanges ? Diffing.sortedChanges(from: self, to: new) : Diffing.changes(from: self, to: new)
    }
    
    func applying(changes: [Diffing.Change<Element>]) -> [Element] {
        return changes.reduce(into: self) { result, change in
            switch change {
            case let .insert(value, index): result.insert(value, at: index)
            case let .delete(_, index): result.remove(at: index)
            case let .update(value, index): result[index] = value
            case let .move(value, fromIndex, toIndex):
                result.remove(at: fromIndex)
                result.insert(value, at: toIndex)
            }
        }
    }
}
