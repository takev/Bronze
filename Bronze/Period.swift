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

struct Period {
    // Number if microseconds.
    let intrinsic: Int64

    var numberOfMilliseconds: Int64 {
        return intrinsic / 1000
    }

    static func seconds(seconds: Int) -> Period {
        return Period(intrinsic: Int64(seconds) * 1000000)
    }

    static func minutes(minutes: Int) -> Period {
        return Period(intrinsic: Int64(minutes) * 60000000)
    }

    static func zero() -> Period {
        return Period(intrinsic: 0)
    }
}

func clamp(a: Period, minimum: Period, maximum: Period) -> Period {
    return Period(intrinsic: clamp(a.intrinsic, minimum: minimum.intrinsic, maximum: maximum.intrinsic))
}
