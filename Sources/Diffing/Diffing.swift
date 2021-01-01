//
//  Diffing.swift
//
//
//  Created by William McGinty on 12/31/20.
//

public struct Diffing {
    
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

// MARK: - Diffing Analysis
extension Diffing.Context {
    
    struct Analysis {
        
        // MARK: - Properties
        private(set) var referenceTable: [T.ID: Diffing.Reference.Entry]
        private(set) var originalReferences: [Diffing.Reference]
        private(set) var newReferences: [Diffing.Reference]
        
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
            for element in new {
                let diffID = element.diffID
                
                let entry = referenceTable[diffID] ?? Diffing.Reference.Entry()
                entry.newCounter += 1
                
                referenceTable[diffID] = entry
                newReferences.append(.entry(entry))
            }

            // Pass 2
            for (index, element) in old.indexed() {
                let diffID = element.diffID
                
                let entry = referenceTable[diffID] ?? Diffing.Reference.Entry()
                entry.oldCounter += 1
                entry.oldIndex = index
                
                referenceTable[diffID] = entry
                originalReferences.append(.entry(entry))
            }

            // Pass 3
            for (index, reference) in newReferences.indexed() {
                if let entry = reference.entry, entry.uniquelyAppearsInBoth {
                    newReferences[index] = .index(entry.oldIndex)
                    originalReferences[entry.oldIndex] = .index(index)
                }
            }

            // Pass 4
            var i = 0
            while(i < newReferences.count - 1) {
                if let j = newReferences[i].index, j + 1 < originalReferences.count, newReferences[i + 1].entry != nil,
                   newReferences[i + 1].entry === originalReferences[j + 1].entry {
                    newReferences[i + 1] = .index(j + 1)
                    originalReferences[j + 1] = .index(i + 1)
                }
                
                i += 1
            }

            // Pass 5
            i = newReferences.count - 1
            while(i > 0) {
                if let j = newReferences[i].index, j - 1 >= 0, newReferences[i - 1].entry != nil,
                   newReferences[i - 1].entry === originalReferences[j - 1].entry {
                    newReferences[i - 1] = .index(j - 1)
                    originalReferences[j - 1] = .index(i - 1)
                }
                
                i -= 1
            }
        }
    }
}

public extension Diffing {
    
    static func changes<T: Diffable>(from old: [T], to new: [T]) -> [Change<T>] {
        let context = Diffing.Context<T>(old: old, new: new)

        var changes: [Change<T>] = []
        var runningOffset = 0
        var deleteOffsets = Array(repeating: 0, count: old.count)
        
        // Determine deletions, incrementing offset to compensate for each delete
        for (j, reference) in context.analysis.originalReferences.indexed() {
            deleteOffsets[j] = runningOffset
            
            if reference.entry != nil {
                changes.append(.delete(value: context.old[j], index: j))
                runningOffset -= 1
            }
        }

        runningOffset = 0

        // Determine inserts, moves and updates
        for (i, reference) in context.analysis.newReferences.indexed() {
            
            if let j = reference.index {
                // Determine if the element has changed
                if context.new[i] != context.old[j] {
                    changes.append(.update(value: context.new[i], index: j))
                }

                // Determine if the move is needed
                let expectedOldIndex = j + runningOffset + deleteOffsets[j]
                if expectedOldIndex != i {
                    changes.append(.move(value: context.new[i], fromIndex: j, toIndex: i))
                    
                    if expectedOldIndex > i {
                        runningOffset += 1
                    }
                }

            } else {
                changes.append(.insert(value: context.new[i], index: i))
                runningOffset += 1
            }
        }

        return changes
    }
    
    static func sortedChanges<T: Diffable>(from old: [T], to new: [T]) -> [Change<T>] {
        let unsortedChanges = changes(from: old, to: new)
        
        var insertions: [Change<T>] = []
        var updates: [Change<T>] = []
        var indexedDeletions: [[Change<T>]] = Array(repeating: [], count: old.count)
        
        for change in unsortedChanges {
            switch change {
            case .insert: insertions.append(change)
            case .update: updates.append(change)
            case let .delete(_, from): indexedDeletions[from].append(change)
            case let .move(value, from, to):
                // Convert the move to an insert + delete pair
                insertions.append(.insert(value: value, index: to))
                indexedDeletions[from].append(.delete(value: value, index: from))
            }
        }
        
        // Return updates + sorted deletions + insertions
        return updates + indexedDeletions.compactMap { $0.first }.reversed() + insertions
    }
}
