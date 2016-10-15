//
//  ErrorHandling.swift
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
        
        case GEN_FileVoid
        case GEN_TagNotFound
        case GEN_TooMuchTags
        
        case FH_FileNotFound
        
        case SLIF_FileNotFound
        case SLIF_FileNotOpen
        
        case FR_FileNotFound
        case FR_FileClosed
    }
    subscript(err: ErrorType) -> String {
        switch err {
        case .NoError: return                       ""
        case .PRM_UsageMissed: return               "Syntax error"
        case .PRM_VersionStrTooShort: return        "Version string too short (at least \(versionStrMinLength) chars)"
        case .PRM_RootPathNotFound: return          "Root path not found"
            
        case .GEN_FileVoid: return                  "File looks void"
        case .GEN_TagNotFound: return               "Version tag not found"
        case .GEN_TooMuchTags: return                "More than 1 tragged line found"
        
        case .FH_FileNotFound: return               "File not found"
            
        case .SLIF_FileNotFound: return             "File not found"
        case .SLIF_FileNotOpen: return              "File doesn't open"
        
        case .FR_FileNotFound: return               "File not found"
        case .FR_FileClosed: return                 "File closed"
            //default: return "Unknow error"
        }
    }
    
    // properties
    
    var error: ErrorType?
    var message: String?
    
    // convenient properties
    
    var description: String {
        let error = (self.error != nil) ? self.error! : .NoError
        if message == "" || message == nil {
            return "\(fm.my) error: [\(error.hashValue)] \(self[error])"
        } else {
            return "\(fm.my) error: [\(error.hashValue)] \(self[error])\n\(message)"
        }
    }
    var isSet: Bool { return error != nil ? true : false }
    
    // funcs
    
    mutating func set(err: ErrorType) { self.error = err }
    mutating func set(err: ErrorType, message: String?) { self.error = err ; self.message = message }
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
            print("\(fm.my) error: [\(err.hashValue)] \(self[err])")
        } else {
            print("\(fm.my) error: [\(err.hashValue)] \(self[err])\n\(message!)")
        }
        if quit { exit(Int32(err.hashValue)) }
    }
    
    func usage() {
        display(err: .PRM_UsageMissed, message: CommandLine.arguments.description, quit: false)
        print ("Usage: \(fm.my) version-string(>=2chars) [root path]")
        exit(1)
    }
}

let error = ErrorHandler()

