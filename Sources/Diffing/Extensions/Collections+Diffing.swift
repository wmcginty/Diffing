//
//  Collections+Diffing.swift
//  
//
//  Created by William McGinty on 12/31/20.
//

import Foundation

// MARK: - Collection + Indexed
extension Collection {
    
    func indexed() -> Zip2Sequence<Self.Indices, Self> {
        return zip(indices, self)
    }
}

// MARK: - Collection + Diffing
public extension Collection where Element: Diffable {
    
    func difference(to new: [Element], using algorithm: Diffing = Heckel()) -> Difference<Element> {
        return algorithm.difference(from: Array(self), to: new)
    }
}

// MARK: - Array + Diffing
public extension Array where Element: Diffable {
    
    func applying(difference: Difference<Element>) -> [Element] {
        return difference.applied(to: self)
    }
}
