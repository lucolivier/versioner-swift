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
if replString.characters.count < versionStrMinLength { error.display(err: .PRM_VersionStrTooShort, quit: true) }

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
    let filePath = rootPath + fileName
    if debug > 0 {
        print ("------------")
        print("#fileName: \(fileName)")
        print("#selector: \(selector)")
        print("#needle: \(needle)")
        print("#filePath: \(filePath)")
    }

    var err = ErrorHandler()

    let file = FileHandler(path: filePath, err: &err)
    if !file.open(.Read) { err.display(quit: true) }
    
    var match = 0
    var linesAmt = 0
    var lines = [String]()
    

    if selector != "" {
        (match, linesAmt, lines) = file.searchLinesInFile(
            selecter: {(line: String) -> String in
                if line.range(of: selector) != nil && line.range(of: needle) != nil {
                    return line
                }
                return ""
            })
    } else {
        (match, linesAmt, lines) = file.searchLinesInFile(
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
    if debug > 0 { print("#linesAmt: \(linesAmt)") ; for line in lines { print(line) } }
}

/* Main */

if debug > 0 { print ("------------") }

for (fileName, selector, needle) in files {
    let filePath = rootPath + fileName
    let tempFilePath = filePath + "_tmp"
    
    var err = ErrorHandler()
    
    let file = FileHandler(path: filePath, err: &err)
    if !file.open(.Read) { err.display(quit: true) }
    
    let fileTmp = FileHandler(path: tempFilePath, err: &err)
    if !fileTmp.deleteFile() {
        if err.isSet { err.display(quit: true) }
    }
    if !fileTmp.open(.Write) { err.display(quit: true) }
    
    while true {
        if let line = file.read() {
            var newline = line
            if (selector != "" && line.range(of: selector) != nil && line.range(of: needle) != nil) || (selector == "" && line.range(of: needle) != nil) {
                
                if debug > 0 { print ("#line: \(line)") }
                
                if let nr = line.range(of: needle) {
                    let r = nr.upperBound..<line.endIndex
                    if let vr = line.range(of: "[A-z0-9.-ß•◊√]{1,}", options: .regularExpression, range: r) {
                        newline = line.replacingCharacters(in: vr, with: replString)
                        
                        if debug > 0 { print ("#newLine: \(newline)") }
                    }
                }
                
            }
            
            if !fileTmp.write(line: newline) { err.display(quit: true) }
            
        } else {
            if err.isSet { err.display(quit: true) }
            file.close()
            break
        }
    }
    
    file.close()
    fileTmp.close()
    
    if !file.deleteFile() { err.display(quit: true) }
    if !fileTmp.renameFile(name: filePath) { err.display(quit: true) }
    
}



