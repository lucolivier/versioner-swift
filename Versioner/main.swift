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
for (fileName, selector, needle) in files {
    let filePath=rootPath+fileName
    if debug > 0 {
        print("#fileName: \(fileName)")
        print("#selector: \(selector)")
        print("#needle: \(needle)")
        print("#filePath: \(filePath)")
    }

    print ("------------")
    var result = 0
    if (selector != "") {
        result = searchInFile(path: filePath,
            selecter: {(line: String) -> String in
                if (line.range(of: selector) != nil) && (line.range(of: needle) != nil) {
                    return line
                }
                return ""
            })
    } else {
        result = searchInFile(path: filePath,
          selecter: {(line: String) -> String in
            if (line.range(of: needle) != nil) {
                return line
            }
            return ""
        })
    }
    switch result {
    case 1: errExit("\(filePath): not found!")
    case 2: errExit("\(filePath): does not open!")
    case 3: errExit("\(filePath): version tag not found")
    case 4: errExit("\(filePath): more than 1 line found")
    default: break
    }

}




/*
 for argument in CommandLine.arguments {
 print(argument)
 }
 */
