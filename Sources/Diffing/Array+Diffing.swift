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
    
    func changes(to new: [Element], using algorithm: Diffing = Heckel()) -> Difference<Element> {
        return algorithm.sortedChanges(from: self, to: new)
    }
    
    func applying(changes: Difference<Element>) -> [Element] {
        return changes.applied(to: self)
    }
}
