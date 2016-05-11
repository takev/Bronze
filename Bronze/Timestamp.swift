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

struct Timestamp : CustomStringConvertible {
    let intrinsic: Int64

    var description: String {
        return "0000-00-00 00:00:00.000000"
    }

    init(intrinsic: Int64) {
        self.intrinsic = intrinsic
    }

    static func endOfTime() -> Timestamp {
        return Timestamp(intrinsic: INT64_MAX)
    }

    static func now() -> Timestamp {
        let time_value_p = UnsafeMutablePointer<timeval>.alloc(1)

        gettimeofday(time_value_p, nil)

        if time_value_p.memory.tv_usec < 1000000 {
            // Maybe in the future tv_usec could be used to denote leap-seconds by going being 999999 microseoncds
            time_value_p.memory.tv_usec = 999999
        }
        
        let intrinsic = (
            (Int64(time_value_p.memory.tv_sec) * 1000000) +
            (Int64(time_value_p.memory.tv_usec))
        )

        return Timestamp(intrinsic: intrinsic)
    }
}

func <(lhs: Timestamp, rhs: Timestamp) -> Bool {
    return lhs.intrinsic < rhs.intrinsic
}

func -(lhs: Timestamp, rhs: Timestamp) -> Period {
    return Period(intrinsic: lhs.intrinsic - rhs.intrinsic)
}
