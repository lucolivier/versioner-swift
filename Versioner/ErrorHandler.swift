//
//  ErrorHandling.swift
//      version: 0.01ß
//
//  Versioner
//
//  Created by Luc-Olivier on 10/15/16.
//  Copyright © 2016 Luc-Olivier. All rights reserved.
//

import Foundation

struct ErrorHandler {
    enum ErrorType: Error {
        case NoError
        case PRM_UsageMissed
        case PRM_VersionStrTooShort
        case PRM_RootPathNotFound
        case PRM_ConfFileNotFound
        
        case GEN_FileVoid
        case GEN_TagNotFound
        case GEN_TooMuchTags
        case GEN_FileNotFound
        
        case FH_OR_FileNotExist
        case FH_OR_FileNotOpen
        
        case FH_OW_CantCreateFile
        case FH_OW_FileNotOpen
        case FH_OW_NothingWritten
        
        case FH_SLIF_FileNotExist
        case FH_SLIF_FileNotFound
        case FH_SLIF_FileNotOpen
        
        case FR_FileNotOpen
        case FR_FileClosed
        
        case FW_FileClosed
        case FW_FileNotOpen
        
        case FH_DF_ErrRemStillExists
        case FH_DF_ErrRemNoLongerExists
     
        case FH_RF_FileNameUsed
        case FH_RF_ErrRenamingFile
        
        var Int: Int { return self.hashValue }
    }

    var literals : [Int: String] = [
        ErrorType.NoError.Int:                      "",
        ErrorType.PRM_UsageMissed.Int:              "Syntax error",
        ErrorType.PRM_VersionStrTooShort.Int:       "Version string too short (at least \(versionStrMinLength) chars)",
        ErrorType.PRM_RootPathNotFound.Int:         "Root path not found",
        ErrorType.PRM_ConfFileNotFound.Int:         "Configuration file not found at root project",
        
        ErrorType.GEN_FileVoid.Int:                 "File looks void",
        ErrorType.GEN_TagNotFound.Int:              "Version tag not found",
        ErrorType.GEN_TooMuchTags.Int:              "More than 1 tragged line found",
        ErrorType.GEN_FileNotFound.Int:             "File not found",
    
        ErrorType.FH_OR_FileNotExist.Int:           "File not exist",
        ErrorType.FH_OR_FileNotOpen.Int:            "File not oepn",
        
        ErrorType.FH_OW_CantCreateFile.Int:         "Can't create file",
        ErrorType.FH_OW_FileNotOpen.Int:            "File not open",
        ErrorType.FH_OW_NothingWritten.Int:         "Nothing has been written",
        
        ErrorType.FH_SLIF_FileNotExist.Int:         "File not exist",
        ErrorType.FH_SLIF_FileNotFound.Int:         "File not found",
        ErrorType.FH_SLIF_FileNotOpen.Int:          "File not open",
        
        //ErrorType.FR_FileNotFound.Int:            "File not found",
        ErrorType.FR_FileNotOpen.Int:               "File not open",
        ErrorType.FR_FileClosed.Int:                "File closed",
    
        ErrorType.FW_FileClosed.Int:                "File closed",
        ErrorType.FW_FileNotOpen.Int:               "File not open",
        
        ErrorType.FH_DF_ErrRemStillExists.Int:      "Error while removing file. File still exists",
        ErrorType.FH_DF_ErrRemNoLongerExists.Int:   "Error while removing file. File still exists",
        
        ErrorType.FH_RF_FileNameUsed.Int:           "File name already used",
        ErrorType.FH_RF_ErrRenamingFile.Int:        "Error while renaming file"
        

    ]
    
    // properties
    
    var error: ErrorType?
    var message: String?
    
    // convenient properties
    
    var description: String {
        let error = (self.error != nil) ? self.error! : .NoError
        if message == "" || message == nil {
            return "\(fm.my) error: [\(error.Int)] \(literals[error.Int]!)"
        } else {
            return "\(fm.my) error: [\(error.Int)] \(literals[error.Int]!)\n\(message)"
        }
    }
    var isSet: Bool { return error != nil ? true : false }
    
    // funcs
    
    mutating func set(err: ErrorType) { self.error = err }
    mutating func set(err: ErrorType, message: String?) { self.error = err ; self.message = message }
    mutating func set(err: ErrorType, catched: NSError) {
        self.error = err ; self.message = "\(catched.code): \(catched.domain)"
    }
    mutating func unset() { self.error = nil ; self.message = nil }
    
    func display(quit: Bool) {
        print ("\(fm.my) \(description)")
        if quit {
            let codeErr = self.error != nil ? self.error!.hashValue : 0
            exit(Int32(codeErr))
        }
    }
    mutating func display(add: String, quit: Bool) {
        if self.message != nil { self.message! += "\n\(add)" } else { self.message = add }
        display(quit: quit)
    }
    
    func display(err: ErrorType, message: String?, quit: Bool) {
        if message == "" || message == nil {
            print("\(fm.my) error: [\(err.Int)] \(literals[err.Int]!)")
        } else {
            print("\(fm.my) error: [\(err.Int)] \(literals[err.Int]!)\n\(message!)")
        }
        if quit { exit(Int32(err.hashValue)) }
    }
    func display(err: ErrorType, quit: Bool) { display(err: err, message: nil, quit: quit) }
    
    func usage() {
        display(err: .PRM_UsageMissed, message: CommandLine.arguments.description, quit: false)
        print ("Usage: \(fm.my) version-string(>=2chars) [root path]")
        exit(1)
    }
}

let error = ErrorHandler()

