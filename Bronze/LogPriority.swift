// Bronze - A standard library for Swift.
// Copyright (C) 2015-2016  Take Vos
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
