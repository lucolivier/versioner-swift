//: Playground - noun: a place where people can play

import Cocoa

//var str = "version: '2.4.5'"
//var str = "version: '1.2.5A' •123••"
var str = "  version= 'zzz'"
var newVersion = "2.5.6◊"

if let nr = str.range(of: "version=") {
    let r = nr.upperBound..<str.endIndex
    if let vr = str.range(of: "[A-z0-9.-ß•◊√]{1,}", options: .regularExpression, range: r) {
        let str2 = str.replacingCharacters(in: vr, with: newVersion)
    }
}

