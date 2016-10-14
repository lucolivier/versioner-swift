//
//  tools.swift
//  Versioner
//
//  Created by Luc-Olivier on 9/29/16.
//  Copyright © 2016 Luc-Olivier. All rights reserved.
//

import Foundation


func basename() -> String {
    return (CommandLine.arguments[0] as NSString).lastPathComponent
}

func currentDir() -> String {
    let fileManager = FileManager.default
    return fileManager.currentDirectoryPath
}

enum PathType { case isDirectory, isFile, notExists }

func checkPath(_ path: String) -> PathType {
    let fileManager = FileManager.default
    var isDir: ObjCBool = false
    fileManager.fileExists(atPath: path, isDirectory: &isDir)
    if (isDir.boolValue) { return .isDirectory }
    if (fileManager.fileExists(atPath: path)) { return .isFile }
    return .notExists
}

func directoryExists(_ path: String) -> Bool {
    return (checkPath(path) == .isDirectory) ? true : false
}
func fileExists(_ path: String) -> Bool {
    return (checkPath(path) == .isFile) ? true : false
}

func searchInFile(path: String, selecter: (_ line: String)-> String) -> Int {
    guard let file = File(path: path) else { return 1 }
    guard file.open() else { return 2 }
    var counter = 0
    while true {
        if let line = file.nextLine() {
            if selecter(line) != "" {
                counter += 1
                print(line)
            }
        } else {
            file.close()
            break
        }
    }
    if (counter == 0) { return 3 }
    if (counter > 1) { return 4 }
    return 0
}

class File {
    var filepath: String!
    
    // constants
    let delimiter = "\n"
    let encoding = String.Encoding.utf8
    let chunkSize = 4096
    
    // convenient vars
    var hook: FileHandle!
    let encodedDelimiter: Data
    var buffer: Data
    var eof: Bool = false
    
    init?(path: String) {
        guard fileExists(path) else { return nil }
        self.filepath = path
        self.encodedDelimiter =  "\n".data(using: encoding)!
        self.buffer = Data(capacity: chunkSize)
    }
    
    deinit { self.close() }
    
    func open() -> Bool {
        self.hook = FileHandle(forReadingAtPath: self.filepath)
        return hook != nil ? true : false
    }
    
    func close() {
        hook?.closeFile()
        hook = nil
    }
    
    func nextLine() -> String? {
        precondition(hook != nil, "Closed file")
        
        if eof { return nil }
        
        while !eof {
            // get the range of next delimiter occurence
            if let range = buffer.range(of: encodedDelimiter) {
                // Convert complete line from buffer
                let line = String(data: buffer.subdata(in: 0..<range.lowerBound), encoding: self.encoding)
                // Remove line from buffer
                buffer.removeSubrange(0..<range.upperBound)
                //
                return line
            }
            // get the next chunk into the buffer
            let interBuffer = hook.readData(ofLength: self.chunkSize)
            if interBuffer.count > 0 {
                buffer.append(interBuffer)
            } else {
                // eof or reading issue
                eof = true
                // let see if buffer countain last line
                if buffer.count > 0 {
                    let line = String(data: buffer as Data, encoding: encoding)
                    buffer.count = 0
                    return line
                }
            }
        }
        return nil
    }
    
}

