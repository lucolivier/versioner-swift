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

let versionStrMinLength = 3

/* Preset */

let argAmt = CommandLine.arguments.count
if argAmt < 2 || argAmt > 3 { error.usage() }

let replString = CommandLine.arguments[1]
if replString.characters.count < versionStrMinLength { error.display(err: .PRM_VersionStrTooShort, message: nil, quit: true) }

var rootPath = ""
if argAmt == 3 {
    rootPath = CommandLine.arguments[2]
    if rootPath[rootPath.startIndex] != "/" {
        rootPath = fm.currentDir + "/" + rootPath
    }
    if rootPath[rootPath.index(before: rootPath.endIndex)] != "/" {
        rootPath += "/"
    }
    if !fm.directoryExists(rootPath) { error.display(err: .PRM_RootPathNotFound, message: nil, quit: true) }
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
        print ("------------")
        print("#fileName: \(fileName)")
        print("#selector: \(selector)")
        print("#needle: \(needle)")
        print("#filePath: \(filePath)")
    }

    var err = ErrorHandler()

    let file = FileHandler(path: filePath, err: &err)
    if file == nil { error.display(err: .FH_FileNotFound, message: filePath, quit: true) }
    
    var match = 0
    var linesAmt = 0
    var lines = [String]()
    

    if selector != "" {
        (match, linesAmt, lines) = file!.searchLinesInFile(
            selecter: {(line: String) -> String in
                if line.range(of: selector) != nil && line.range(of: needle) != nil {
                    return line
                }
                return ""
            })
    } else {
        (match, linesAmt, lines) = file!.searchLinesInFile(
          selecter: {(line: String) -> String in
            if line.range(of: needle) != nil {
                return line
            }
            return ""
        })
    }

    if err.isSet { err.display(add: filePath, quit: true) }

    if linesAmt == 0 { error.display(err: .GEN_FileVoid, message: filePath, quit: true) }
    if match == 0 { error.display(err: .GEN_TagNotFound, message: filePath, quit: true) }
    if match > 1 { error.display(err: .GEN_TooMuchTags, message: filePath, quit: true) }
    
    filesLinesAmt.append(linesAmt)
    
    if debug > 0 { print("linesAmt: \(linesAmt)") ; for line in lines { print(line) } }
}

/* Main */

for (fileName, selector, needle) in files {

}


