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


/// * Arguments are options if they begin with a hyphen delimiter (‘-’).
/// * Multiple options may follow a hyphen delimiter in a single token if the options do not take arguments.
///   Thus, ‘-abc’ is equivalent to ‘-a -b -c’.
/// * Option names are single alphanumeric characters (as for isalnum; see Classification of Characters).
/// * Certain options require an argument. For example, the ‘-o’ command of the ld command requires an
///   argument—an output file name.
/// * An option and its argument may or may not appear as separate tokens. (In other words, the whitespace
///   separating them is optional.) Thus, ‘-o foo’ and ‘-ofoo’ are equivalent.
/// * Options precede other non-option arguments.
/// * The argument ‘--’ terminates all options; any following arguments are treated as non-option arguments,
///   even if they begin with a hyphen.
/// * A token consisting of a single hyphen character is interpreted as an ordinary non-option argument.
///   By convention, it is used to specify input from or output to the standard input and output streams.
/// * Options may be supplied in any order, or appear multiple times. The interpretation is left up to the
///   particular application program.
/// * GNU adds long options to these conventions. Long options consist of ‘--’ followed by a name made of
///   alphanumeric characters and dashes. Option names are typically one to three words long, with hyphens
///   to separate words. Users can abbreviate the option names as long as the abbreviations are unique.
/// * To specify an argument for a long option, write ‘--name=value’. This syntax enables a long option
///   to accept an argument that is itself optional.
public func parseCommandLine(commandLine: [String], shortOptionsWithArguments: String) -> [CommandLineOptionType] {
    enum state_t {
    case OPTION
    case NON_OPTION
    case SHORT_OPTION_VALUE
    }

    var state = state_t.OPTION
    var result: [CommandLineOptionType] = []
    var short_option_name: String? = nil

    for argument in commandLine {
        switch state {
        case .OPTION:
            if argument == "--" {
                // End of options.
                state = .NON_OPTION

            } else if argument.hasPrefix("--") {
                // Long option.
                let argument_without_minus = argument.substringFromIndex(2)
                let name_value = argument_without_minus.split("=", maximum:2)

                switch name_value.count {
                case 1:     result.append(.OPTION(name_value[0]))
                case 2:     result.append(.OPTION_ARGUMENT(name_value[0], name_value[1]))
                default:    preconditionFailure("Only supposed to be 1 or 2 items")
                }

            } else if argument.hasPrefix("-") {
                // Short options. Walk through each option in the argument.
                var index = argument.startIndex.advancedBy(1)
                while index != argument.endIndex {
                    let c = String(argument[index])

                    // Check if the option has a required argument, which means this is the last option in
                    // this command line argument; the rest of the command line argument becomes the option argument.
                    // Or the option argument is in the next command line argument.
                    if shortOptionsWithArguments.containsString(c) {
                        let value = argument[index.advancedBy(1) ..< argument.endIndex]
                        if value == "" {
                            // The value should be in the next argument.
                            short_option_name = c
                            state = .SHORT_OPTION_VALUE

                        } else {
                            // The value was in the same argument.
                            result.append(.SHORT_OPTION_ARGUMENT(c, value))
                        }

                        // An short option with argument finishes the command line argument.
                        break

                    } else {
                        result.append(.SHORT_OPTION(c))
                    }

                    index = index.advancedBy(1)
                }

            } else {
                // Found a non-option argument.
                result.append(.NON_OPTION(argument))
                state = .NON_OPTION
            }

        case .SHORT_OPTION_VALUE:
            assert(short_option_name != nil, "option_name must be set when entering .OPTION_VALUE state")
            result.append(.SHORT_OPTION_ARGUMENT(short_option_name!, argument))

            short_option_name = nil
            state = .OPTION

        case .NON_OPTION:
            result.append(.NON_OPTION(argument))
        }
    }

    return result
}
