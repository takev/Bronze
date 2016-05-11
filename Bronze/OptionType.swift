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

struct OptionType {
    let name: String
    let description: String
    let defaultValue: OptionValueType
    let shortOption: String?
    let argumentName: String?
    let inGroup: Bool
    let isNonOptionArgument: Bool

    func usage() -> String {
        var s = String()
        var option_usage = "  "
        let wrapped_description = description.wrap(72 - 30)

        if isNonOptionArgument {
            precondition(argumentName != nil, "argumentName must be set if nonOptionArgument is set.")
            option_usage += "<" + argumentName! + ">"

        } else {
            // Prefix the short option in front of the long option.
            if shortOption != nil {
                option_usage += "-" + shortOption! + ", "
            }

            // Add the long option.
            if inGroup {
                option_usage += "--" + "<group>." + name
            } else {
                option_usage += "--" + name
            }

            // Add the optional argument name
            if argumentName != nil {
                option_usage += "=<" + argumentName! + ">"
            }
        }

        let spaces = " " * 30
        let append_spaces = " " * (30 - option_usage.characters.count)

        for (i, line) in wrapped_description.enumerate() {
            if (i == 0) {
                if (option_usage.characters.count < 28) {
                    s += "  \(option_usage)\(append_spaces) \(line)\n"
                } else {
                    s += "  \(option_usage)\n"
                    s += "  \(spaces) \(line)\n"
                }
            } else {
                s += "  \(spaces) \(line)\n"
            }
        }

        return s
    }
}
