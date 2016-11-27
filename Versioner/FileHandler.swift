//
//  FileHandler.swift
//      version: 0.02ß
//
//  Versioner
//
//  Created by Luc-Olivier on 10/15/16.
//  Copyright © 2016 Luc-Olivier. All rights reserved.
//

import Foundation

class FileHandler {
    
    // properties
    var filepath: String
    
    // internals
    var error: ErrorHandler
    var hookW: FileWriter?
    var hookR: FileReader?
    
    enum Mode { case Read; case Write }
    
    // inits
    
    init(path: String, err: inout ErrorHandler) {
        self.error = err
        self.filepath = path
    }
    
    // conveniences
    
    var exists: Bool { return fm.fileExists(filepath) }
    var isOpen: Bool { return (hookW != nil || hookR != nil) ? true : false }
    
    //  funcs

    func open(_ mode: Mode) -> Bool {
        self.error.unset()
        if mode == .Read && !self.exists {
            self.error.set(err: .FH_OR_FileNotExist)
            return false
        }
        if mode == .Read {
            hookR = FileReader(path: filepath, err: &self.error)
            if hookR == nil { return false }
        } else {
            hookW = FileWriter(path: filepath, err: &self.error)
            if hookW == nil { return false }
        }
        return true
    }
    
    func read() -> String? {
        self.error.unset()
        return hookR?.nextLine()
    }
    
    func readParamLine() -> String? {
        self.error.unset()
        var line: String?
        while true {
            line = hookR?.nextLine()
            if line != nil {
                line = line?.replacingOccurrences(of: "[\u{9} ]", with: "", options: .regularExpression)
                if line != nil && line != "" { break }
            } else {
                break
            }
        }
        return line
    }
    
    func write(line: String) -> Bool {
        self.error.unset()
        return hookW?.writeLine(line) == 0 ? false : true
    }
    
    func searchLinesInFile(selecter: (_ line: String)-> String) -> (Int, Int, [String]) {
        self.error.unset()
        if !self.exists {
            self.error.set(err: .FH_SLIF_FileNotExist)
            return (0,0,[])
        }
        guard let file = FileReader(path: filepath, err: &self.error) else {
            self.error.set(err: .FH_SLIF_FileNotFound)
            return (0,0,[])
        }
        if self.error.isSet {
            self.error.set(err: self.error.error!)
            return (0,0,[])
        }
        var match = 0
        var linesamt = 0
        var lines = [String]()
        while true {
            if let line = file.nextLine() {
                linesamt += 1
                if selecter(line) != "" {
                    match += 1
                    lines.append(line)
                }
            } else {
                file.close()
                break
            }
        }
        return (match, linesamt, lines)
    }

    func close() {
        if hookW != nil { hookW?.close() }
        hookW = nil
        if hookR != nil { hookR?.close() }
        hookR = nil
    }
    
    func deleteFile() -> Bool {
        self.error.unset()
        if self.exists {
            close()
            do {
                try fm.removeItem(atPath: filepath)
            } catch {
                if fm.fileExists(filepath) {
                self.error.set(err: .FH_DF_ErrRemStillExists, message: error.localizedDescription)
                    return false
                } else {
                  self.error.set(err: .FH_DF_ErrRemNoLongerExists, message: error.localizedDescription)
                    return true
                }
            }
        }
        return true
    }
    
    func renameFile(name: String) -> Bool {
        self.error.unset()
        if self.exists {
            self.close()
            if fm.fileExists(name) {
                self.error.set(err: .FH_RF_FileNameUsed)
                return false
            }
            do {
                try fm.moveItem(atPath: filepath, toPath: name)
            } catch {
                self.error.set(err: .FH_RF_ErrRenamingFile, message: error.localizedDescription)
                return false
            }
        }
        return true
    }
    
}

class FileWriter {
    // properties
    var filepath: String!
    
    // constants
    let delimiter = "\n"
    let encoding = String.Encoding.utf8
    
    // internals
    var err: ErrorHandler!
    var hook: FileHandle!
    
    init?(path: String, err: inout ErrorHandler) {
        //guard fm.fileExists(path) else { return nil }
        self.err = err
        self.err.unset()
        self.filepath = path
        if !self.open() {
            self.err.set(err: .FW_FileNotOpen)
        }
    }
    
    deinit { self.close() }
    
    func open() -> Bool {
        self.err.unset()
        if !fm.fileExists(self.filepath) {
            if !fm.createFile(atPath: self.filepath, contents: nil, attributes: nil) {
                self.err.set(err: .FH_OW_CantCreateFile)
                return false
            }
        }
        self.hook = FileHandle(forWritingAtPath: self.filepath)
        if hook == nil {
            self.err.set(err: .FH_OR_FileNotOpen)
        }
        return true
    }
    
    func close() {
        hook?.closeFile()
        hook = nil
    }
    
    func writeLine(_ line: String) -> Int {
        self.err.unset()
        if hook == nil { self.err.set(err: .FR_FileClosed) ; return 0 }
        
        let data = (line+delimiter).data(using: encoding)
        let startOffset = hook!.offsetInFile
        hook!.write(data!)
        let endOffset = hook!.offsetInFile
        if startOffset == endOffset {
            self.err.set(err: .FH_OW_NothingWritten)
            return 0
        }
        return endOffset.hashValue - startOffset.hashValue
    }
    
}

class FileReader {
    /* Parts thanks to Rene Rudnick https://gist.github.com/loc4l/4630db54d28ce1e11a58 */
    
    // properties
    var filepath: String!
    
    // constants
    let delimiter = "\n"
    let encoding = String.Encoding.utf8
    let chunkSize = 4096
    
    // internals
    var error: ErrorHandler!
    var hook: FileHandle!
    let encodedDelimiter: Data
    var buffer: Data
    var eof: Bool = false
    
    init?(path: String, err: inout ErrorHandler) {
        guard fm.fileExists(path) else { return nil }
        self.error = err
        self.filepath = path
        self.encodedDelimiter =  "\n".data(using: encoding)!
        self.buffer = Data(capacity: chunkSize)
        if !self.open() {
            self.error.set(err: .FR_FileNotOpen)
        }
    }
    
    deinit { self.close() }
    
    func open() -> Bool {
        self.error.unset()
        self.hook = FileHandle(forReadingAtPath: self.filepath)
        if hook == nil {
            self.error.set(err: .FH_OR_FileNotOpen)
        }
        return true
    }
    
    func close() {
        hook?.closeFile()
        hook = nil
    }
    
    func nextLine() -> String? {
        self.error.unset()
        if hook == nil { self.error.set(err: .FR_FileClosed) ; return nil }
        
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

