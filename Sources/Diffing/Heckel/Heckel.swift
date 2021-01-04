//
//  Heckel.swift
//
//
//  Created by William McGinty on 12/31/20.
//

public struct Heckel {
    
    // MARK: - Initializer
    public init() { /* No op */ }
    
    final class Context<T: Diffable> {
        
        // MARK: - Properties
        let old: [T]
        let new: [T]
        
        private(set) lazy var analysis: Analysis = Analysis(old: old, new: new)
        
        // MARK: - Initializer
        init(old: [T], new: [T]) {
            self.old = old
            self.new = new
        }
    }
}

// MARK: - Heckel.Context.Analysis
extension Heckel.Context {
    
    struct Analysis {
        
        // MARK: - Properties
        private(set) var referenceTable: [T.ID: Heckel.Reference.Entry]
        private(set) var originalReferences: [Heckel.Reference]
        private(set) var newReferences: [Heckel.Reference]
        
        // MARK: - Initializer
        fileprivate init(old: [T], new: [T]) {
            referenceTable = [:]
            originalReferences = []
            newReferences = []
            
            analyzeDiff(from: old, to: new)
        }
        
        // MARK: - Interface
        private mutating func analyzeDiff(from old: [T], to new: [T]) {
            
            // Pass 1
            
            /* Each element of the `new` collection is read in sequence. An entry is created for the element is created if it does not already exist. The count of this element (by `diffID`) is incremented for each incidence. The `referenceTable` is updated with entry, and the entry is inserted into `newReference`. */
            
            for element in new {
                let diffID = element.diffID
                
                let entry = referenceTable[diffID] ?? Heckel.Reference.Entry()
                entry.newCounter += 1
                
                referenceTable[diffID] = entry
                newReferences.append(.entry(entry))
            }

            // Pass 2
            
            /* Each element of the `old` collection is read in sequence. An entry is created for the element is created if it does not already exist. The count of this element (by `diffID`) is incremented for each incidence. The `referenceTable` is updated with entry, and the entry is inserted into `originalReference`. */
            
            for (index, element) in old.indexed() {
                let diffID = element.diffID
                
                let entry = referenceTable[diffID] ?? Heckel.Reference.Entry()
                entry.oldCounter += 1
                entry.oldIndex = index
                
                referenceTable[diffID] = entry
                originalReferences.append(.entry(entry))
            }

            // Pass 3
            
            /* We rely on the first observation to begin diffing - if an element occurs only once in each collection, then it must be the same element (although it may have moved). We can use this observation to locate unaltered elements that can be exclude from any further treatment. To do this, we look for elements where:
                   
                `oldCounter` == `newCounter` == `1`
             
             For these elements, we alter `originalReference` and `newReference` to instead point to the index of the element in the other collection. */
            
            for (index, reference) in newReferences.indexed() {
                if let entry = reference.entry, entry.uniquelyAppearsInBoth {
                    newReferences[index] = .indexInOther(entry.oldIndex)
                    originalReferences[entry.oldIndex] = .indexInOther(index)
                }
            }

            // Pass 4
            
            /* We rely on the second observation to continue - if an element has been found to be unaltered, and the elements immediately adjacent to it in both collections are identical, then these elements must also be the same. This information can be used to find blocks of unchanged elements. */
            
            var i = 0
            while(i < newReferences.count - 1) {
                if let j = newReferences[i].index, j + 1 < originalReferences.count, newReferences[i + 1].entry != nil,
                   newReferences[i + 1].entry === originalReferences[j + 1].entry {
                    newReferences[i + 1] = .indexInOther(j + 1)
                    originalReferences[j + 1] = .indexInOther(i + 1)
                }
                
                i += 1
            }

            // Pass 5
            
            /* We again rely on the second observation to continue - if an element has been found to be unaltered, and the elements immediately adjacent to it in both collections are identical, then these elements must also be the same. This information can be used to find blocks of unchanged elements. This is nearly the same as Pass 4, except processed from back to front. */
            
            i = newReferences.count - 1
            while(i > 0) {
                if let j = newReferences[i].index, j - 1 >= 0, newReferences[i - 1].entry != nil,
                   newReferences[i - 1].entry === originalReferences[j - 1].entry {
                    newReferences[i - 1] = .indexInOther(j - 1)
                    originalReferences[j - 1] = .indexInOther(i - 1)
                }
                
                i -= 1
            }
        }
    }
}

// MARK: - Diffing
extension Heckel: Diffing {
    
    public func changes<T: Diffable>(from old: [T], to new: [T]) -> [Change<T>] {
        let context = Heckel.Context<T>(old: old, new: new)

        var changes: [Change<T>] = []
        var runningOffset = 0
        var deleteOffsets = Array(repeating: 0, count: old.count)
        
        // Deletions
        for (index, reference) in context.analysis.originalReferences.indexed() {
            /* At this point, we know that any elements in `originalReference` that contain an `entry`
             do not appear in the `new` collection - meaning they have been deleted. */
            
            deleteOffsets[index] = runningOffset
            
            if reference.entry != nil {
                changes.append(.delete(value: context.old[index], index: index))
                runningOffset += 1
            }
        }

        runningOffset = 0
        
        // Determine inserts, moves and updates
        for (index, reference) in context.analysis.newReferences.indexed() {
            
            switch reference {
            case .entry:
                runningOffset += 1
                changes.append(.insert(value: context.new[index], index: index))
                
            case .indexInOther(let otherIndex):
                if context.old[otherIndex] != context.new[index] {
                    changes.append(.update(value: context.new[index], index: index))
                }
                
                let deleteOffset = deleteOffsets[otherIndex]
                if (otherIndex - deleteOffset + runningOffset) != index {
                    changes.append(.move(value: context.new[index], sourceIndex: otherIndex, destinationIndex: index))
                }
            }
        }
        
        return changes
    }
}
