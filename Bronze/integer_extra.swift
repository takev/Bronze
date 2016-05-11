//
//  integer_extra.swift
//  Bronze
//
//  Created by Take Vos on 2015-12-30.
//  Copyright © 2015 Take Vos. All rights reserved.
//

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
}

extension UInt32: PowerOfTwo {
    public var popcount: Int {
        return Int(popcount_u32(self))
    }

    public var ffs: Int {
        return Int(ffs_u32(self))
    }
}

extension UInt64: PowerOfTwo {
    public var popcount: Int {
        return Int(popcount_u64(self))
    }

    public var ffs: Int {
        return Int(ffs_u64(self))
    }
}

