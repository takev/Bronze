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

public class LogDestinationStderr: LogDestination {
    public func print(message: String) {
        let message = message + "\n"

        guard let message_cstr = message.cStringUsingEncoding(NSUTF8StringEncoding) else {
            preconditionFailure("Message can not be converted to utf8 C string.")
        }

        write(2, message_cstr, message_cstr.count - 1)
    }
}
