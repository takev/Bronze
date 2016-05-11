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

enum CompareResult {
case LeftGreaterThanRight
case LeftLessThanRight
case LeftEqualToRight
}

func compare(lhs: BigInt, _ rhs: BigInt) -> CompareResult {
    let abs_lhs = abs(lhs)
    let abs_rhs = abs(rhs)
    let positive: Bool

    switch (lhs.isPositive, rhs.isPositive) {
    case (false, false):    positive = false
    case (true, true):      positive = true
    case (false, true):     return CompareResult.LeftLessThanRight
    case (true, false):     return CompareResult.LeftGreaterThanRight
    }

    if abs_lhs.digits.count > abs_rhs.digits.count {
        return positive ? CompareResult.LeftGreaterThanRight : CompareResult.LeftLessThanRight
    } else if abs_lhs.digits.count < abs_rhs.digits.count {
        return positive ? CompareResult.LeftLessThanRight : CompareResult.LeftGreaterThanRight
    } else {
        var i = abs_lhs.digits.count - 1
        while i >= 0 {
            if (abs_lhs[i] > abs_rhs[i]) {
                return positive ? CompareResult.LeftGreaterThanRight : CompareResult.LeftLessThanRight
            } else if (abs_lhs[i] < abs_rhs[i]) {
                return positive ? CompareResult.LeftLessThanRight : CompareResult.LeftGreaterThanRight
            }
            // This digit is equal, continue
            i -= 1
        }
        // All digits are equal.
        return CompareResult.LeftEqualToRight
    }
}
