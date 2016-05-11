//
//  LogLevel.swift
//  Bronze
//
//  Created by Take Vos on 2016-05-07.
//  Copyright © 2016 Take Vos. All rights reserved.
//

import Foundation

public enum LogPriority : CustomStringConvertible{
case Debug
case Notice
case Audit      // Information that must be logged to keep record off.
case Warning    // A warning is a minor error that may be corrected.
case Error      // A error is a problem that can not be corrected. The transaction needs to be terminated.
case Critical   // Fatal is an error that has/will cause errors in other parts of the system. The session needs to be terminated.
case Emergency  // An error serious enough to abort the application.
case Exit       // Normal application termination.

    public var description: String {
        switch self {
        case LogPriority.Debug:     return "DEBUG"
        case LogPriority.Notice:    return "NOTICE"
        case LogPriority.Audit:     return "AUDIT"
        case LogPriority.Warning:   return "WARNING"
        case LogPriority.Error:     return "ERROR"
        case LogPriority.Critical:  return "CRITICAL"
        case LogPriority.Emergency: return "EMERGENCY"
        case LogPriority.Exit:      return "EXIT"
        }
    }
}
