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
for (fileName, selector, niddle) in files {
    let filePath=rootPath+fileName
    if debug > 0 {
        print("#fileName: \(fileName)")
        print("#selector: \(selector)")
        print("#niddle: \(niddle)")
        print("#filePath: \(filePath)")
    }
    if (!fileExists(filePath)) { errExit("\(filePath) not found!") }
    
    print ("------------")
    if let file = File(path: filePath) {
        if file.open() {
            while true {
                if let line = file.nextLine() {
                    print(line)
                } else {
                    break
                }
            }
        }
    }
    
    if (selector != "") {
        
    } else {
        
    }
}




/*
 for argument in CommandLine.arguments {
 print(argument)
 }
 */
