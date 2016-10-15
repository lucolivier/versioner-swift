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
        
        case SLIF_FileNotFound
        case SLIF_FileNotOpen
        
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
            
        case .SLIF_FileNotFound: return             "File not found"
        case .SLIF_FileNotOpen: return              "File doesn't open"
            
        case .FR_FileClosed: return                 "File closed"
            //default: return "Unknow error"
        }
    }
    
    var err: ErrorType?
    var comp: String?
    
    var description: String {
        let error = (err != nil) ? err! : .NoError
        if comp == "" {
            return "\(FileManager.my) error: [\(error.hashValue)] \(self[error])"
        } else {
            return "\(FileManager.my) error: [\(error.hashValue)] \(self[error])\n\(comp)"
        }
    }
    
    func display(err: ErrorType, comp: String, quit: Bool) {
        print ("\(FileManager.my) \(description)")
        if quit { exit(Int32(err.hashValue)) }
    }
    
    func usage() {
        display(err: .PRM_UsageMissed, comp: CommandLine.arguments.description, quit: false)
        print ("Usage: \(FileManager.my) version-string(>=2chars) [root path]")
        exit(1)
    }
}

let error = ErrorHandler()

