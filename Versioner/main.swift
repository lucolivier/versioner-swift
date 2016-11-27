//
//  main.swift
//      version: 0.03ß
//
//  Versioner
//
//  Created by Luc-Olivier on 9/27/16.
//  Copyright © 2016 Luc-Olivier. All rights reserved.
//

import Foundation

let debug = 0

/* Static Params */

let myVersion = "0.04ß"
let versionStrMinLength = 3
let confFileName = "_versioner.conf"
let allowedChars = "A-z0-9.-ß•◊√_+"


/* Preset */

let argAmt = CommandLine.arguments.count
if argAmt < 2 || argAmt > 3 { error.usage() }

let replString = CommandLine.arguments[1]
if replString.characters.count < versionStrMinLength { error.display(err: .PRM_VersionStrTooShort, quit: true) }

let filteredReplString = replString.replacingOccurrences(of: "[\(allowedChars)]{1,}", with: "", options: .regularExpression)
if filteredReplString != "" { error.display(err: .PRM_VersionIllChars, quit: true) }

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


/* Check params file */

let fileConfPath = rootPath+confFileName
if !fm.fileExists(fileConfPath) { error.display(err: .PRM_CFNotFound, message: nil, quit: true) }

//var err = ErrorHandler()
let confFile = FileHandler(path: fileConfPath, err: &error)
if !confFile.open(.Read) { error.display(quit: true) }

var paramLines = [(String,String,String)]()

while true {
    if let line = confFile.readParamLine() {
        let splited = line.components(separatedBy: ",")
        if splited.count != 3 { error.display(err: .PRM_CFLineSyntaxError, quit: true) }
        paramLines.append((splited[0],splited[1],splited[2]))
        if debug > 0 { print ("#paramLine: \(line)") }
    } else {
        confFile.close()
        break
    }
}
if paramLines.count == 0 { error.display(err: .PRM_NoCFLines, quit: true) }

if debug > 0 { print(paramLines) }



/* Check files */

var filesLinesAmt = [Int]()

for (fileName, selector, needle) in paramLines {
    let filePath = rootPath + fileName
    if debug > 0 {
        print ("------------")
        print("#fileName: \(fileName)")
        print("#selector: \(selector)")
        print("#needle: \(needle)")
        print("#filePath: \(filePath)")
    }
    
    error.unset()
    let file = FileHandler(path: filePath, err: &error)
    if !file.open(.Read) { error.display(quit: true) }
    
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

    if error.isSet { error.display(add: filePath, quit: true) }

    if linesAmt == 0 { error.display(err: .GEN_FileVoid, message: filePath, quit: true) }
    if match == 0 { error.display(err: .GEN_TagNotFound, message: filePath, quit: true) }
    if match > 1 { error.display(err: .GEN_TooMuchTags, message: filePath, quit: true) }
    
    filesLinesAmt.append(linesAmt)
    if debug > 0 { print("#linesAmt: \(linesAmt)") ; for line in lines { print(line) } }
}

/* Main */

if debug == 0 { print ("\(fm.my) \(myVersion)") }
else { print ("------------") }


for (fileName, selector, needle) in paramLines {
    let filePath = rootPath + fileName
    let tempFilePath = filePath + "_tmp"
    
    error.unset()
    let file = FileHandler(path: filePath, err: &error)
    if !file.open(.Read) { error.display(quit: true) }
    
    let fileTmp = FileHandler(path: tempFilePath, err: &error)
    if !fileTmp.deleteFile() {
        if error.isSet { error.display(quit: true) }
    }
    if !fileTmp.open(.Write) { error.display(quit: true) }
    
    while true {
        if let line = file.read() {
            var newline = line
            if (selector != "" && line.range(of: selector) != nil && line.range(of: needle) != nil) || (selector == "" && line.range(of: needle) != nil) {
                
                if debug > 0 { print ("#line: \(line)") }
                
                if let nr = line.range(of: needle) {
                    let r = nr.upperBound..<line.endIndex
                    if let vr = line.range(of: "[\(allowedChars)]{1,}", options: .regularExpression, range: r) {
                        newline = line.replacingCharacters(in: vr, with: replString)
                        
                        if debug == 0 { print ("> \(fileName)") }
                        else { print ("#newLine: \(newline)") }
                    }
                }
                
            }
            
            if !fileTmp.write(line: newline) { error.display(quit: true) }
            
        } else {
            if error.isSet { error.display(quit: true) }
            file.close()
            break
        }
    }
    
    file.close()
    fileTmp.close()
    
    if !file.deleteFile() { error.display(quit: true) }
    if !fileTmp.renameFile(name: filePath) { error.display(quit: true) }
    
}



