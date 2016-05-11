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

import Foundation

public func +(lhs: BigInt, rhs: BigInt) -> BigInt {
    return additionGeneric(lhs, rhs)
}

public func +(lhs: BigInt, rhs: Int) -> BigInt {
    if rhs == 0 {
        return lhs
    } else if rhs > 0 {
        return additionGeneric(lhs, nil, carry: UInt64(rhs))
    } else {
        return lhs + BigInt(rhs)
    }
}

public func -(lhs: BigInt, rhs: BigInt) -> BigInt {
    return additionGeneric(lhs, rhs, carry: 1, invert: true, handleOverflow: false)
}

public func -(lhs: BigInt, rhs: Int) -> BigInt {
    return additionGeneric(lhs, BigInt(rhs), carry: 1, invert: true, handleOverflow: false)
}

public prefix func -(lhs: BigInt) -> BigInt {
    return additionGeneric(lhs, nil, carry: 1, invert: true, handleOverflow: false)
}

public prefix func ~(lhs: BigInt) -> BigInt {
    let newDigits = lhs.digits.map{return ~$0}
    return BigInt(digits: newDigits)
}

public func >>(lhs: BigInt, rhs: Int) -> BigInt {
    if rhs == 0 {
        return lhs

    } else if rhs == 1 {
        return shiftRightByOneBit(lhs)

    } else if rhs < 0 {
        return lhs << -rhs

    } else if (rhs % 32) == 0 {
        return shiftRightByDigits(lhs, rhs / 32)

    } else {
        return shiftRightByBits(lhs, rhs)
    }
}

public func <<(lhs: BigInt, rhs: Int) -> BigInt {
    if rhs == 0 {
        return lhs

    } else if rhs == 1 {
        return shiftLeftByOneBit(lhs)

    } else if rhs < 0 {
        return lhs >> -rhs

    } else if (rhs % 32) == 0 {
        return shiftLeftByDigits(lhs, rhs / 32)

    } else {
        return shiftLeftByBits(lhs, rhs)
    }
}

public func *(lhs: BigInt, rhs: Int) -> BigInt {
    if rhs == 0 {
        return BigInt()

    } else if rhs == 1 {
        return lhs

    } else if rhs > 0 && rhs.isPowerOfTwo {
        return lhs << rhs.exponentOfPowerOfTwo

    } else if rhs > 1 && rhs <= 2147483647 {
        return multiplyByDigit(lhs, UInt32(rhs))

    } else {
        return lhs * BigInt(rhs)
    }
}

public func *(lhs: BigInt, rhs: BigInt) -> BigInt {
    if rhs.digits.count == 0 {
        return BigInt()

    } else if rhs > 0 && rhs.digits.count == 1 {
        return lhs * Int(rhs.digits[0])

    } else if rhs >= 0 && rhs.isPowerOfTwo {
        return lhs << rhs.exponentOfPowerOfTwo

    } else {
        return multiplySchoolAlgorithm(lhs, rhs)
    }
}

public func /(lhs: BigInt, rhs: BigInt) -> BigInt {
    let (quotient, _) = divisionSchoolAlgorithm(lhs, rhs)
    return quotient
}

public func %(lhs: BigInt, rhs: BigInt) -> BigInt {
    let (_, remainder) = divisionSchoolAlgorithm(lhs, rhs)
    return remainder
}

public func >=(lhs: BigInt, rhs: BigInt) -> Bool {
    switch compare(lhs, rhs) {
    case .LeftEqualToRight:         return true
    case .LeftGreaterThanRight:     return true
    case .LeftLessThanRight:        return false
    }
}

public func <=(lhs: BigInt, rhs: BigInt) -> Bool {
    switch compare(lhs, rhs) {
    case .LeftEqualToRight:         return true
    case .LeftGreaterThanRight:     return false
    case .LeftLessThanRight:        return true
    }
}

public func <(lhs: BigInt, rhs: BigInt) -> Bool {
    switch compare(lhs, rhs) {
    case .LeftEqualToRight:         return false
    case .LeftGreaterThanRight:     return false
    case .LeftLessThanRight:        return true
    }
}

public func >(lhs: BigInt, rhs: BigInt) -> Bool {
    switch compare(lhs, rhs) {
    case .LeftEqualToRight:         return false
    case .LeftGreaterThanRight:     return true
    case .LeftLessThanRight:        return false
    }
}

public func ==(lhs: BigInt, rhs: BigInt) -> Bool {
    switch compare(lhs, rhs) {
    case .LeftEqualToRight:         return true
    case .LeftGreaterThanRight:     return false
    case .LeftLessThanRight:        return false
    }
}

public func !=(lhs: BigInt, rhs: BigInt) -> Bool {
    switch compare(lhs, rhs) {
    case .LeftEqualToRight:         return false
    case .LeftGreaterThanRight:     return true
    case .LeftLessThanRight:        return true
    }
}

public func %(lhs: BigInt, rhs: Int) -> BigInt {
    if lhs.digits.count == 0 {
        return BigInt()
    } else if rhs == 2 {
        return BigInt(Int(lhs.digits[0] & 1))
    } else if rhs.isPowerOfTwo && rhs > 0 && rhs <= 2147483647 {
        return BigInt(Int(lhs.digits[0] % UInt32(rhs)))
    } else {
        return lhs % BigInt(rhs)
    }
}

public func ==(lhs: BigInt, rhs: Int) -> Bool {
    if rhs == 0 {
        return lhs.digits.count == 0
    } else if rhs > 0 && rhs <= 2147483647 {
        return (lhs.digits.count == 1) && (lhs.digits[0] == UInt32(rhs))
    } else {
        return lhs == BigInt(rhs)
    }
}

public func !=(lhs: BigInt, rhs: Int) -> Bool {
    if rhs == 0 {
        return lhs.digits.count != 0
    } else {
        return lhs != BigInt(rhs)
    }
}

public func >=(lhs: BigInt, rhs: Int) -> Bool {
    if rhs == 0 {
        return lhs.isPositive
    } else {
        return lhs >= BigInt(rhs)
    }
}

public func <(lhs: BigInt, rhs: Int) -> Bool {
    if rhs == 0 {
        return lhs.isNegative
    } else {
        return lhs < BigInt(rhs)
    }
}

public func >(lhs: BigInt, rhs: Int) -> Bool {
    if rhs == 0 {
        return lhs.isPositive && (lhs.digits.count > 0)
    } else {
        return lhs < BigInt(rhs)
    }
}

public func abs(lhs: BigInt) -> BigInt {
    return lhs.abs
}

