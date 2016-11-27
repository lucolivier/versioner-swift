//
//  ErrorHandling.swift
//      version: 0.04ß
//
//  Versioner
//
//  Created by Luc-Olivier on 10/15/16.
//  Copyright © 2016 Luc-Olivier. All rights reserved.
//

import Foundation

class ErrorHandler {
    enum ErrorType: String {
        case NoError                    = ""
        case PRM_UsageMissed            = "Syntax error"
        case PRM_VersionStrTooShort     = "Version string too short (at least #versionStrMinLength# chars)"
        case PRM_VersionIllChars        = "Illegal chars in string version (allowed '#allowedChars#')"
        case PRM_RootPathNotFound       = "Root path not found"
        case PRM_CFNotFound             = "Configuration file not found at root project"
        case PRM_NoCFLines              = "Nothing to do. No Configuration file lines found"
        case PRM_CFLineSyntaxError      = "Configuration file line syntax error"
        
        case GEN_FileVoid               = "File looks void"
        case GEN_TagNotFound            = "Version tag not found"
        case GEN_TooMuchTags            = "More than 1 tragged line found"
        case GEN_FileNotFound           = "File not found (1)"
        
        case FH_OR_FileNotExist         = "File not exist (1)"
        case FH_OR_FileNotOpen          = "File not open (1)"
        
        case FH_OW_CantCreateFile       = "Can't create file"
        case FH_OW_FileNotOpen          = "File not open"
        case FH_OW_NothingWritten       = "Nothing has been written"
        
        case FH_SLIF_FileNotExist       = "File not exist (2)"
        case FH_SLIF_FileNotFound       = "File not found (2)"
        case FH_SLIF_FileNotOpen        = "File not open (2)"
        
        case FR_FileNotOpen             = "File not open (3)"
        case FR_FileClosed              = "File closed (1)"
        
        case FW_FileClosed              = "File closed (2)"
        case FW_FileNotOpen             = "File not open (4)"
        
        case FH_DF_ErrRemStillExists    = "Error while removing file. File still exists"
        case FH_DF_ErrRemNoLongerExists = "Error while removing file. File no longer exists "
     
        case FH_RF_FileNameUsed         = "File name already used"
        case FH_RF_ErrRenamingFile      = "Error while renaming file"
        
        var Int: Int { return self.hashValue }
    }
    
    // properties
    
    var error: ErrorType?
    var message: String?
    
    // convenient properties
    
    var description: String {
        let error = (self.error != nil) ? self.error! : .NoError
        if message == "" || message == nil {
            return "\(fm.my) error: [\(error.Int)] \(self.parsedErrorString(self.error!))"
        } else {
            return "\(fm.my) error: [\(error.Int)] \(self.parsedErrorString(self.error!))\n\(message)"
        }
    }
    var isSet: Bool { return error != nil ? true : false }
    
    // funcs

    func parsedErrorString (_ error: ErrorType) -> String {
        switch error {
        case .PRM_VersionStrTooShort:
            return error.rawValue.replacingOccurrences(of: "#versionStrMinLength#", with: "\(versionStrMinLength)")
        case .PRM_VersionIllChars:
            return error.rawValue.replacingOccurrences(of: "#allowedChars#", with: "\(allowedChars)")
        default:
            return error.rawValue
        }
    }
    
    func set(err: ErrorType) { self.error = err }
    func set(err: ErrorType, message: String?) { self.error = err ; self.message = message }
    func set(err: ErrorType, catched: NSError) {
        self.error = err ; self.message = "\(catched.code): \(catched.domain)"
    }
    func unset() { self.error = nil ; self.message = nil }
    
    func display(quit: Bool) {
        print ("\(fm.my) \(description)")
        if quit {
            let codeErr = self.error != nil ? self.error!.hashValue : 0
            exit(Int32(codeErr))
        }
    }
    func display(add: String, quit: Bool) {
        if self.message != nil { self.message! += "\n\(add)" } else { self.message = add }
        display(quit: quit)
    }
    
    func display(err: ErrorType, message: String?, quit: Bool) {
        if message == "" || message == nil {
            print("\(fm.my) error: [\(err.Int)] \(self.parsedErrorString(err))")
        } else {
            print("\(fm.my) error: [\(err.Int)] \(self.parsedErrorString(err))\n\(message!)")
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

var error = ErrorHandler()

