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

public func <<(lhs: UInt64, rhs: Int) -> UInt64 {
    return lhs << UInt64(rhs)
}

public func >>(lhs: UInt64, rhs: Int) -> UInt64 {
    return lhs >> UInt64(rhs)
}

public func <<(lhs: UInt32, rhs: Int) -> UInt32 {
    return lhs << UInt32(rhs)
}

public func >>(lhs: UInt32, rhs: Int) -> UInt32 {
    return lhs >> UInt32(rhs)
}

public func clamp(a: Int, minimum: Int, maximum: Int) -> Int {
    if a <= minimum {
        return minimum
    } else if a >= maximum {
        return maximum
    } else {
        return a
    }
}

public func clamp(a: Int64, minimum: Int64, maximum: Int64) -> Int64 {
    if a <= minimum {
        return minimum
    } else if a >= maximum {
        return maximum
    } else {
        return a
    }
}

public protocol PowerOfTwo {
    // Count the number bits that are set to '1'.
    var popcount: Int { get }

    // Return the index + 1 of the least significant bit that is set to '1'.
    // Return zero when no bits are set.
    var ffs: Int { get }

    // Return the number of bits needed to represent all numbers from 0 ..< self
    // Return zero when no bits are set.
    var clog2: Int { get }
}

public extension PowerOfTwo {
    public var isPowerOfTwo: Bool {
        return popcount == 1
    }

    public var exponentOfPowerOfTwo: Int {
        assert(isPowerOfTwo, "Must be a power of two to get the exponent.")
        return ffs - 1
    }
}

extension Int: PowerOfTwo {
    public var popcount: Int {
        precondition(self >= 0, "Popcount can only be done on positive numbers.")
        return UInt64(self).popcount
    }

    public var ffs: Int {
        precondition(self >= 0, "Not implemented.")
        return UInt64(self).ffs
    }

    public var clz: Int {
        precondition(self >= 0, "Not implemented.")
        return UInt64(self).clz
    }

    public var clog2: Int {
        return (sizeofValue(self) * 8) - UInt64(self - 1).clz
    }
}

extension UInt32: PowerOfTwo {
    public var popcount: Int {
        return Int(popcount_u32(self))
    }

    public var ffs: Int {
        return Int(ffs_u32(self))
    }

    public var clz: Int {
        return Int(clz_u32(self))
    }
    
    public var clog2: Int {
        return (sizeofValue(self) * 8) - (self - 1).clz
    }
}

extension UInt64: PowerOfTwo {
    public var popcount: Int {
        return Int(popcount_u64(self))
    }

    public var ffs: Int {
        return Int(ffs_u64(self))
    }
    
    public var clz: Int {
        return Int(clz_u64(self))
    }
    
    public var clog2: Int {
        return (sizeofValue(self) * 8) - (self - 1).clz
    }
}

public func shiftl_overflow(lhs: UInt64, _ rhs: Int) -> (UInt64, UInt64) {
    let result = shiftl_overflow_u64_2(lhs, UInt64(rhs))
    return (result.x, result.y)
}

public func shiftl_overflow(lhs: UInt64, _ rhs: Int, carry: UInt64) -> (UInt64, UInt64) {
    let result = shiftl_overflow_u64_3(lhs, UInt64(rhs), carry)
    return (result.x, result.y)
}

public func shiftr_overflow(lhs: UInt64, _ rhs: Int) -> (UInt64, UInt64) {
    let result = shiftr_overflow_u64_2(lhs, UInt64(rhs))
    return (result.x, result.y)
}

public func shiftr_overflow(lhs: UInt64, _ rhs: Int, carry: UInt64) -> (UInt64, UInt64) {
    let result = shiftr_overflow_u64_3(lhs, UInt64(rhs), carry)
    return (result.x, result.y)
}

public func shiftr_overflow_sign_extend(lhs: UInt64, _ rhs: Int) -> (UInt64, UInt64) {
    let result = shiftr_overflow_sign_extend_u64_2(lhs, UInt64(rhs))
    return (result.x, result.y)
}

public func mul_overflow(lhs: UInt64, _ rhs: UInt64) -> (UInt64, UInt64) {
    let result = mul_overflow_u64_2(lhs, rhs)
    return (result.x, result.y)
}

public func mul_overflow(lhs: UInt64, _ rhs: UInt64, carry: UInt64) -> (UInt64, UInt64) {
    let result = mul_overflow_u64_3(lhs, rhs, carry)
    return (result.x, result.y)
}

public func mul_overflow(lhs: UInt64, _ rhs: UInt64, carry: UInt64, accumulator: UInt64) -> (UInt64, UInt64) {
    let result = mul_overflow_u64_4(lhs, rhs, carry, accumulator)
    return (result.x, result.y)
}

public func add_overflow(lhs: UInt64, _ rhs: UInt64) -> (UInt64, UInt64) {
    let result = add_overflow_u64_2(lhs, rhs)
    return (result.x, result.y)
}

public func add_overflow(lhs: UInt64, _ rhs: UInt64, carry: UInt64) -> (UInt64, UInt64) {
    let result = add_overflow_u64_3(lhs, rhs, carry)
    return (result.x, result.y)
}


