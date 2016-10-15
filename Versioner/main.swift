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
if (argAmt < 2 || argAmt > 3) { Err.usage() }

let replString = CommandLine.arguments[1]
if replString.characters.count < versionStrMinLength { Err.display(err: .PRM_VersionStrTooShort, comp: "", quit: true) }

var rootPath = ""
if (argAmt == 3) {
    rootPath = CommandLine.arguments[2]
    if (rootPath[rootPath.startIndex] != "/") {
        rootPath = currentDir() + "/" + rootPath
    }
    if (rootPath[rootPath.index(before: rootPath.endIndex)] != "/") {
        rootPath += "/"
    }
    if (!directoryExists(rootPath)) { Err.display(err: .PRM_RootPathNotFound, comp: "", quit: true) }
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
    var err: Err.ErrorType?
    var match = 0
    var linesAmt = 0
    var lines = [String]()
    if (selector != "") {
        (err, match, linesAmt, lines) = searchLinesInFile(path: filePath,
            selecter: {(line: String) -> String in
                if (line.range(of: selector) != nil) && (line.range(of: needle) != nil) {
                    return line
                }
                return ""
            })
    } else {
        (err, match, linesAmt, lines) = searchLinesInFile(path: filePath,
          selecter: {(line: String) -> String in
            if (line.range(of: needle) != nil) {
                return line
            }
            return ""
        })
    }
    if err != nil { Err.display(err: err!, comp: filePath, quit: true) }

    if linesAmt == 0 { Err.display(err: .GEN_FileVoid, comp: filePath, quit: true) }
    if match == 0 { Err.display(err: .GEN_TagNotFound, comp: filePath, quit: true) }
    if match > 1 { Err.display(err: .GEN_TooMuchTags, comp: filePath, quit: true) }
    
    filesLinesAmt.append(linesAmt)
    
    if debug > 0 { print("linesAmt: \(linesAmt)") ; for line in lines { print(line) } }
}

/* Main */

for (fileName, selector, needle) in files {

}


