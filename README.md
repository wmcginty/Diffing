# Diffing

![CI Status](https://github.com/wmcginty/Diffing/actions/workflows/main.yml/badge.svg)
[![Version](https://img.shields.io/cocoapods/v/Diffing.svg?style=flat)](http://cocoapods.org/pods/Diffing)
[![Platform](https://img.shields.io/cocoapods/p/Diffing.svg?style=flat)](http://cocoapods.org/pods/Diffing)

Diffing is a small framework that is desgined to make identifying the differences, or edits, between any two collections as quick and simple as possible. An implementation of Paul Heckel's algorithm, `Diffing` uses a series of five passes over two collections to identify the differences between a given `source` and `destination` collection and output them in a way that is both easy to understand, and easy to apply to UI elements like `UITableview` and `UICollectionView`.

For example, given the following two collections: 

```swift
let old = [1, 2, 3, 4, 5]
let new = [1, 2, 3, 4, 5, 6]
```

A simple extension on `Collection` can be invoked to determine the differences:

```swift
let difference = old.difference(to: new)
difference.sortedChanges // [.insert(value: 6, index: 5)]
```

In addition, the set of changes in `difference` can also be applied to any arbitrary collection. Applying this set of changes to `old` in this case, will always produce `new`.

```swift
let equals = old.applying(difference: difference) == new // true
```

## Inspiration

Diffing is heavily inspired by similar frameworks like the incredible [IGListKit](https://github.com/Instagram/IGListKit). The original algorithm published by Paul Heckel is available [here](https://dl.acm.org/doi/10.1145/359460.359467).


## Requirements

Requires iOS 10.0, tvOS 10.0, macOS 10.12


## Installation

### Cocoapods

Diffing is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'Diffing'
```

### Carthage

Add the following to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile):

```
github "wmcginty/Diffing"
```

Run `carthage update` and follow the steps as described in Carthage's [README](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application).

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/wmcginty/Diffing.git", from: "0.4.0")
]
```
