//: Playground - noun: a place where people can play

import Cocoa

var str = "version: '2.4.5'"

if let r1 = str.range(of: "version:") {
    let r1end = r1.upperBound
    
    let sub = str.substring(from: r1end)

    if let range = sub.range(of: "[0-9.]{1,10}", options: .regularExpression) {
        sub.substring(with: range)
    }
}
