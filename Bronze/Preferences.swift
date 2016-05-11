// Bronze - A standard library for Swift.
// Copyright (C) 2015  Take Vos
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

/// User preferences as application defaults, parsed from command line and parsed from a preferences file.
///

struct Preferences {
    var programName                                     = "<unknown>"
    var programUsage:       [String]                    = []
    var programDescription                              = ""
    var options:            [String: OptionType]        = [:]
    var shortOptions:       [String: OptionType]        = [:]
    var nonOptions:         [OptionType]                = []
    var groups                                          = Set<String>()
    var values:             [String: OptionValueType]   = [:]

    init() {
    }

    subscript(name: String) -> OptionValueType? {
        get {
            return values[name]
        }
        set(optionalValue) {
            guard let option = options[name] else {
                preconditionFailure("Option.\(name) does not exist")
            }
            guard let value = optionalValue else {
                preconditionFailure("Option.\(name) can not be assigned nil")
            }

            precondition(isSameType(option.defaultValue, value), "Option.\(name) wrong type")
            values[name] = optionalValue
        }
    }

    /// Add a option to the preferences.
    ///
    /// - parameter name:               The name of an option.
    /// - parameter description:        A description to show in the usage, or in a configuration file.
    /// - parameter defaultValue:       The default value if it is not defined on the command line or configuration file.
    ///                                 This also defines the type of the option.
    /// - parameter shortOption:        A single letter short option for on the command line.
    /// - parameter argumentName:       The name of the argument of an option, or nil if the option has no argument.
    /// - parameter inGroup:            The option is part of a group of options.
    /// - parameter nonOptionArgument:  The command line argument is not part of an option.
    mutating func addOption(
        name: String,
        description: String,
        defaultValue: OptionValueType,
        shortOption: String? = nil,
        argumentName: String? = nil,
        inGroup: Bool = false,
        isNonOptionArgument: Bool = false
    ) {
        let option = OptionType(
            name: name,
            description: description,
            defaultValue: defaultValue,
            shortOption: shortOption,
            argumentName: argumentName,
            inGroup: inGroup,
            isNonOptionArgument: isNonOptionArgument
        )

        options[name] = option
        if option.isNonOptionArgument {
            nonOptions.append(option)
        }
        if option.shortOption != nil {
            shortOptions[option.shortOption!] = option
        }
    }

    static func fullNameToTuple(fullName: String) -> (String?, String) {
        let groupAndName = fullName.split(".", maximum: 2)
        if groupAndName.count == 1 {
            return (nil, fullName)
        } else {
            return (groupAndName[0], groupAndName[1])
        }
    }

    func usage() -> String {
        var s = String()

        s += "Usage:\n"
        for usageString in programUsage {
            let usageLines = usageString.wrap(72 - 3 - programName.characters.count)

            for (i, usageLine) in usageLines.enumerate() {
                if (i == 0) {
                    s += "  \(programName) \(usageLine)\n"
                } else {
                    let spaces = " " * programName.characters.count
                    s += "  \(spaces) \(usageLine)\n"
                }
            }
        }

        s += "Description:\n"
        let programDescriptionLines = programDescription.wrap()
        for line in programDescriptionLines {
            s += line + "\n"
        }
        if programDescriptionLines.count > 0 {
            s += "\n"
        }

        s += "Options:\n"
        let sortedOptions = options.values.filter{ return !$0.isNonOptionArgument }.sort{ return $0.name < $1.name }
        for option in sortedOptions {
            s += option.usage()
        }

        s += "Non option arguments:\n"
        for option in nonOptions {
            s += option.usage()
        }

        s += "\n"
        return s
    }

    func interpretCommandLineOption(commandLineOption: CommandLineOptionType, nonOptionIndex: Int) throws -> (OptionType, String?, String?) {
        switch commandLineOption {
        case .OPTION(let fullName):
            let (optionalGroupName, optionName) = Preferences.fullNameToTuple(fullName)

            guard let option = options[optionName] else {
                throw PreferencesError.UNKNOWN_OPTION("--\(fullName)")
            }

            if let groupName = optionalGroupName {
                return (option, groupName, nil)
            } else {
                return (option, nil, nil)
            }

        case .OPTION_ARGUMENT(let fullName, let argumentString):
            let (optionalGroupName, optionName) = Preferences.fullNameToTuple(fullName)

            guard let option = options[optionName] else {
                throw PreferencesError.UNKNOWN_OPTION("--\(fullName)=\(argumentString)")
            }

            if let groupName = optionalGroupName {
                return (option, groupName, argumentString)
            } else {
                return (option, nil, argumentString)
            }

        case .SHORT_OPTION(let shortName):
            guard let option = shortOptions[shortName] else {
                throw PreferencesError.UNKNOWN_OPTION("-\(shortName)")
            }

            return (option, nil, nil)

        case .SHORT_OPTION_ARGUMENT(let shortName, let argumentString):
            guard let option = shortOptions[shortName] else {
                throw PreferencesError.UNKNOWN_OPTION("-\(shortName) \(argumentString)")
            }

            return (option, nil, argumentString)

        case .NON_OPTION(let argumentString):
            if nonOptionIndex >= nonOptions.count {
                throw PreferencesError.UNKNOWN_OPTION("#\(nonOptionIndex + 1) \(argumentString)")
            }

            let option = nonOptions[nonOptionIndex]
            return (option, nil, argumentString)
        }
    }

    func parseOptionArgument(fullOptionName: String, previousOptionArgument: OptionValueType, optionalArgumentString: String?) throws -> OptionValueType {
        // Parse an optional argument
        switch previousOptionArgument {
        case .BOOLEAN(let previousValue):
            if let argumentString = optionalArgumentString {
                if argumentString.lowercaseString == "false" || argumentString.lowercaseString == "0" {
                    return .BOOLEAN(false)
                } else if argumentString.lowercaseString == "true" || argumentString.lowercaseString == "1" {
                    return .BOOLEAN(true)
                } else {
                    throw PreferencesError.BAD_ARGUMENT("Could not parse option '\(fullOptionName)' boolean argument '\(argumentString)'.")
                }

            } else {
                return .BOOLEAN(!previousValue)
            }

        case .STRING(_):
            guard let argumentString = optionalArgumentString else {
                throw PreferencesError.BAD_ARGUMENT("option '\(fullOptionName)' requires a string argument.")
            }

            return .STRING(argumentString)

        case .INTEGER(let previousValue):
            if let argumentString = optionalArgumentString {
                if let value = Int(argumentString) {
                    return .INTEGER(value)
                } else {
                    throw PreferencesError.BAD_ARGUMENT("Could not parse option '\(fullOptionName)' integer argument '\(argumentString)'.")
                }

            } else {
                return .INTEGER(previousValue + 1)
            }

        case .REAL(_):
            if let argumentString = optionalArgumentString {
                if let value = Double(argumentString) {
                    return .REAL(value)
                } else {
                    throw PreferencesError.BAD_ARGUMENT("Could not parse option '\(fullOptionName)' float argument '\(argumentString)'.")
                }

            } else {
                throw PreferencesError.BAD_ARGUMENT("option '\(fullOptionName)' requires a float argument.")
            }
        }
    }


    /// Parse the command line.
    /// First string on the command line is the program name.
    ///
    mutating func parsePreferencesFromCommandLine(commandLine: [String]) throws {
        let shortOptionsWithArguments = shortOptions.values.filter{$0.argumentName != nil}.map{$0.shortOption!}.reduce("",combine:+)

        let commandLineWithoutProgram = Array<String>(commandLine[1 ..< commandLine.count])
        let parsedOptions = parseCommandLine(commandLineWithoutProgram, shortOptionsWithArguments:shortOptionsWithArguments)

        var nonOptionIndex : Int = 0
        for parsedOption in parsedOptions {
            let (option, optionalGroupName, optionalArgumentString) = try interpretCommandLineOption(parsedOption, nonOptionIndex: nonOptionIndex)

            if option.isNonOptionArgument {
                nonOptionIndex += 1
            }

            var fullOptionName: String
            if let groupName = optionalGroupName {
                groups.insert(groupName)
                fullOptionName = "\(groupName).\(option.name)"
            } else {
                fullOptionName = option.name
            }

            // Get the previous argument.
            var previousOptionArgument: OptionValueType
            if let value = values[fullOptionName] {
                previousOptionArgument = value
            } else {
                previousOptionArgument = option.defaultValue
            }

            let optionValue = try parseOptionArgument(fullOptionName, previousOptionArgument: previousOptionArgument, optionalArgumentString: optionalArgumentString)

            values[fullOptionName] = optionValue
        }

    }

}

var defaultPreferences = Preferences()
/*defaultPreferences.addOption("help",
    description:"This usage information.",
    defaultValue: .BOOLEAN(false),
    shortOption:"h"
)*/



