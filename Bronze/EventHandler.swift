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


public class EventHandler {
    unowned var loop : EventLoop

    var optionalFileDescriptor: Int32? {
        return nil
    }

    var optionalTimeout: Timestamp? {
        return nil
    }

    init(loop: EventLoop) {
        self.loop = loop
    }

    var isReadable: Bool {
        return false
    }

    var isWritable: Bool {
        return false
    }

    func handleReadable() {
    }

    func handleWritable() {
    }

    func handleTimeout() {
    }

}
