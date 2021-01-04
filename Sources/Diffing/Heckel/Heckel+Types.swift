//
//  Heckel+Types.swift
//  
//
//  Created by William McGinty on 1/3/21.
//

import Foundation

// MARK: - Heckel Subtypes
extension Heckel {
    
    enum Reference {
        final class Entry {
            public var oldCounter = 0
            public var newCounter = 0
            public var oldIndex = 0
            
            var uniquelyAppearsInBoth: Bool {
                return oldCounter == 1 && newCounter == 1
            }
        }

        case entry(Entry) /// A pointer to the line's symbol entry
        case indexInOther(Int) ///The line's number in the `other` file, either the original or new

        // MARK: - Interface
        var entry: Entry? {
            switch self {
            case let .entry(entry): return entry
            default: return nil
            }
        }

        var index: Int? {
            switch self {
            case let .indexInOther(index): return index
            default: return nil
            }
        }
    }
}
