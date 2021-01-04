//
//  Diffable.swift
//  
//
//  Created by William McGinty on 12/31/20.
//

import Foundation

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
