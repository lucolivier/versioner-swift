//
//  FileManager.swift
//  Versioner
//
//  Created by Luc-Olivier on 10/15/16.
//  Copyright © 2016 Luc-Olivier. All rights reserved.
//

import Foundation

extension FileManager {
    
    // convenient properties
    
    var currentDir: String {
        return FileManager.default.currentDirectoryPath
    }
    var my: String {
        return basename(CommandLine.arguments[0])
    }
    
    // funcs
    
    func basename(_ path: String) -> String {
        return (path as NSString).lastPathComponent
    }
    
    enum PathType { case isDirectory, isFile, notExists }
    func checkPath(_ path: String) -> PathType {
        let fileManager = FileManager.default
        var isDir: ObjCBool = false
        fileManager.fileExists(atPath: path, isDirectory: &isDir)
        if isDir.boolValue { return .isDirectory }
        if fileManager.fileExists(atPath: path) { return .isFile }
        return .notExists
    }
    func directoryExists(_ path: String) -> Bool {
        return (checkPath(path) == .isDirectory) ? true : false
    }
    func fileExists(_ path: String) -> Bool {
        return (checkPath(path) == .isFile) ? true : false
    }
    
}

let fm = FileManager()

