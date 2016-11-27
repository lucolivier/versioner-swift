//: Playground - noun: a place where people can play

import Cocoa

let allowedChars = "A-z0-9.-ß•◊√_+"
let replString = "123654.321A"
let filteredReplString = replString.replacingOccurrences(of: "[\(allowedChars)]{1,}", with: "", options: .regularExpression)
