//
//  main.swift
//  Versioner
//
//  Created by Luc-Olivier on 9/27/16.
//  Copyright © 2016 Luc-Olivier. All rights reserved.
//

import Foundation

let debug = 1

/* Static Params */

let files = [
    ("src/js/config/config.js","", "version:"),
    ("config.xml", "pokedesk", "version=")
]

/* Funcs */

func usage() {
    print ("Usage: \(basename()) version-number [root path]")
    exit(1)
}

func errExit(_ message: String) {
    print ("\(basename()) error: \(message)")
    exit(2)
}

/* Preset */

let argAmt = CommandLine.arguments.count
if (argAmt < 2 || argAmt > 3) { usage() }
let replString = CommandLine.arguments[1]
var rootPath = ""
if (argAmt == 3) {
    rootPath = CommandLine.arguments[2]
    if (rootPath[rootPath.startIndex] != "/") {
        rootPath = currentDir() + "/" + rootPath
    }
    if (rootPath[rootPath.index(before: rootPath.endIndex)] != "/") {
        rootPath += "/"
    }
    if (!directoryExists(rootPath)) { errExit("Root path not found \(rootPath)") }
}
if debug > 0 {
    print("#replString: \(replString)")
    print("#rootPath:   \(rootPath)")
}

/* Checkup */
var filesLinesAmt = [Int]()

for (fileName, selector, needle) in files {
    let filePath=rootPath+fileName
    if debug > 0 {
        print("#fileName: \(fileName)")
        print("#selector: \(selector)")
        print("#needle: \(needle)")
        print("#filePath: \(filePath)")
    }

    if debug > 0 { print ("------------") }
    var result = 0
    var linesAmt = 0
    var lines = [String]()
    if (selector != "") {
        (result, linesAmt, lines) = searchLinesInFile(path: filePath,
            selecter: {(line: String) -> String in
                if (line.range(of: selector) != nil) && (line.range(of: needle) != nil) {
                    return line
                }
                return ""
            })
    } else {
        (result, linesAmt, lines) = searchLinesInFile(path: filePath,
          selecter: {(line: String) -> String in
            if (line.range(of: needle) != nil) {
                return line
            }
            return ""
        })
    }
    if result == -1 { errExit("File not found! >\(filePath)") }
    if result == 2 { errExit("File doesn't open! >\(filePath)") }
    if linesAmt == 0 { errExit("File looks void! >\(filePath)") }
    if result == 0 { errExit("Version tag not found! >\(filePath)") }
    if result > 1 { errExit("More than 1 line found! >\(filePath)") }
    
    filesLinesAmt.append(linesAmt)
    
    if debug > 0 { print("linesAmt: \(linesAmt)") ; for line in lines { print(line) } }
}

/* Main */

for (fileName, selector, needle) in files {

}


