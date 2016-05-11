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

enum FormatState {
case IDLE
case FORMAT
}

extension String {
    init(sep:String, _ lines:String...) {
        self = ""
        for (idx, item) in lines.enumerate() {
            self += item
            if idx < lines.count-1 {
                self += sep
            }
        }
    }

    init(format: String, parameters:[Any]) {
        var parts: [String] = []
        var state = FormatState.IDLE

        var i = 0
        for c in format.characters {
            switch state {
            case FormatState.IDLE:
                if c == "%" {
                    state = FormatState.FORMAT
                } else {
                    parts.append(String(c))
                }

            case FormatState.FORMAT:
                if c == "%" {
                    parts.append("%")
                    state = FormatState.IDLE

                } else if c == "@" {
                    precondition(i < parameters.count, "Not enough parameters for format string")
                    let parameter = parameters[i]

                    switch parameter {
                    case is CustomStringConvertible:
                        let tmp = parameter as! CustomStringConvertible
                        parts.append(tmp.description)

                    case is String:
                        let tmp = parameter as! String
                        parts.append(tmp)

                    default:
                        preconditionFailure("Can not use %@ on parameter #" + (i + 1).description + ".")
                    }
                    
                    state = FormatState.IDLE
                    i += 1

                } else {
                    preconditionFailure("Unknown format character '" + String(c) + "'")
                }
            }
        }
        precondition(i == parameters.count, "Too many parameters for format string")

        self = parts.joinWithSeparator("")
    }

    init(format: String, _ parameters:Any...) {
        self.init(format: format, parameters: parameters)
    }


    /// Remove whitespace in front of the string.
    func lstrip() -> String {
        for i in self.startIndex ..< self.endIndex {
            if self[i] != " " && self[i] != "\t" && self[i] != "\n" {
                return self[i ..< self.endIndex]
            }
        }
        return ""
    }

    /// Remove whitespace in back of the string.
    func rstrip() -> String {
        for i in (self.startIndex ..< self.endIndex).reverse() {
            if self[i] != " " && self[i] != "\t" && self[i] != "\n" {
                return self[self.startIndex ... i]
            }
        }
        return ""
    }

    /// Remove whitespace before and after the string.
    func strip() -> String {
        return self.lstrip().rstrip()
    }

    /// Return a substring starting from index.
    /// - parameter index: Character index to the start of the substring.
    func substringFromIndex(from: Int) -> String {
        let fromIndex = self.startIndex.advancedBy(from)
        return self[fromIndex ..< endIndex]
    }

    /// Return a index where a needle is found.
    ///
    /// - parameter needle: A string to search for.
    /// - parameter from: Index to start the search from.
    /// - returns Index where needle is found in the string, or self.endIndex if not found.
    func find(needle: String, from: Index) -> Index {
        var i = from
        while i != endIndex {
            if self[i ..< endIndex].hasPrefix(needle) {
                return i
            }

            i = i.advancedBy(1)
        }
        return endIndex
    }

    /// Return a index where a needle is found.
    ///
    /// - parameter needle: A string to search for.
    /// - returns Index where needle is found in the string, or self.endIndex if not found.
    func find(needle: String) -> Index {
        return find(needle, from:startIndex)
    }

    /// Return a list of strings split by a string.
    ///
    /// When a maximum number of strings to return is set, the last
    /// string may contain the needle 0 or more times.
    ///
    /// - parameter needle: A string to split the string with.
    /// - parameter maximum: Maximum number strings to return
    func split(needle: String = " ", maximum: Int = -1) -> [String] {
        var result: [String] = []
        var previous_index = startIndex

        // First add the exception.
        if maximum == 0 {
            return []
        } else if maximum == 1 {
            return [self]
        }

        // find all the needles, and add substring on the left of the needle to the result.
        var index = find(needle)
        while index != endIndex {
            result.append(self[previous_index ..< index])
            previous_index = index.advancedBy(needle.characters.count)

            // We stop finding needles when we reach one less than the maximum.
            // After the break we add the rest of the string.
            if maximum != -1 && result.count >= maximum - 1 {
                break
            }

            index = find(needle, from:index)
        }

        // Add the last substring to the result.
        result.append(self[previous_index ..< endIndex])
        return result
    }

    /// Take three floating point numbers as string and return a float vector.
    func toDoubles(seperator: String=" ") -> [Double]? {
        var values : [Double] = []
        let components = self.componentsSeparatedByString(seperator)

        for component in components {
            let stripped_component = component.strip()

            guard let float_component = Double(stripped_component) else {
                return nil
            }

            values.append(float_component)
        }

        return values
    }

    /// Split a line up into multiple strings, each no longer than lineWidth.
    ///
    /// - parameter lineWidth: Length of the maximum line.
    /// - returns A set of lines no longer than the maximum line.
    func wrap(lineWidth: Int = 72) -> [String] {
        var current_line = String()
        var result: [String] = []

        let words = self.split()
        for word in words {
            if current_line.characters.count + 1 + word.characters.count < lineWidth {
                current_line += " " + word
            } else {
                result.append(current_line)
                current_line = word
            }
        }

        return result
    }
}

func *(lhs: String, rhs: Int) -> String {
    var result = String()
    
    for _ in 0 ..< rhs {
        result += lhs
    }

    return result
}
