//
//  FileManager.swift
//  Versioner
//
//  Created by Luc-Olivier on 10/15/16.
//  Copyright © 2016 Luc-Olivier. All rights reserved.
//

import Foundation

extension FileManager {
    static var currentDir: String {
        return FileManager.default.currentDirectoryPath
    }
    static var my: String {
        return basename(CommandLine.arguments[0])
    }
    static func basename(_ path: String) -> String {
        return (path as NSString).lastPathComponent
    }
    
    enum PathType { case isDirectory, isFile, notExists }
    static func checkPath(_ path: String) -> PathType {
        let fileManager = FileManager.default
        var isDir: ObjCBool = false
        fileManager.fileExists(atPath: path, isDirectory: &isDir)
        if isDir.boolValue { return .isDirectory }
        if fileManager.fileExists(atPath: path) { return .isFile }
        return .notExists
    }
    static func directoryExists(_ path: String) -> Bool {
        return (FileManager.checkPath(path) == .isDirectory) ? true : false
    }
    static func fileExists(_ path: String) -> Bool {
        return (FileManager.checkPath(path) == .isFile) ? true : false
    }
    
}

