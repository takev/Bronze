//
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

func shiftLeftByBits(lhs: BigInt, _ rhs: Int, carryAndAccumulator: UInt64 = 0) -> BigInt {
    var carryAndAccumulator = carryAndAccumulator;
    let shiftNrDigits = rhs >> 5
    let shiftNrBits = rhs & 0x1f

    var newDigits = Array<UInt32>(count: lhs.digits.count + shiftNrDigits + 1, repeatedValue: 0)

    for i in 0 ..< newDigits.count {
        if (i < shiftNrDigits) {
            newDigits[i] = 0
        } else {
            let j = i - shiftNrDigits

            // lhs-subscript automaticaly sign extends, so no need to worry about that.
            carryAndAccumulator |= (UInt64(lhs[j]) << UInt64(shiftNrBits))
            newDigits[i] = UInt32(carryAndAccumulator & 0xffffffff)
            carryAndAccumulator >>= 32
        }
    }

    return BigInt(digits: newDigits)
}

func shiftLeftByDigits(lhs: BigInt, _ rhs: Int) -> BigInt {
    return BigInt(digits: Array<UInt32>(count: rhs, repeatedValue: 0) + lhs.digits)
}

func shiftLeftByOneBit(lhs: BigInt, newBit: Bool = false) -> BigInt {
    // Sign extend with one extra digit to handle to potential overflow.
    var newDigits = lhs.digits + [lhs[lhs.digits.count]]

    var carryAndAccumulator: UInt64 = newBit ? 1 : 0
    for i in 0 ..< newDigits.count {
        carryAndAccumulator |= (UInt64(newDigits[i]) << 1)
        newDigits[i] = UInt32(carryAndAccumulator & 0xffffffff)
        carryAndAccumulator >>= 32
    }

    return BigInt(digits: newDigits)
}

func shiftRightByBits(lhs: BigInt, _ rhs: Int) -> BigInt {
    let shiftNrDigits = rhs >> 5
    let shiftNrBits = rhs & 0x1f

    var newDigits = Array<UInt32>(count: lhs.digits.count - shiftNrDigits + 1, repeatedValue: 0)

    // Fill in the carry by the sign of the lhs (take a digit beyond the number of digits available).
    var carryAndAccumulator: UInt64 = UInt64(lhs[lhs.digits.count]) << 32
    var i = newDigits.count - 1
    while i >= 0 {
        let j = i + shiftNrDigits

        carryAndAccumulator |= (UInt64(lhs[j]) << UInt64(32 - shiftNrBits))
        newDigits[i] = UInt32(carryAndAccumulator >> 32)
        carryAndAccumulator <<= 32

        i -= 1
    }

    return BigInt(digits: newDigits)
}

func shiftRightByDigits(lhs: BigInt, _ rhs: Int) -> BigInt {
    let nrDigitsToShift = min(rhs, lhs.digits.count)
    let newDigits = Array<UInt32>(lhs.digits[nrDigitsToShift ..< lhs.digits.count])

    if lhs.isPositive || newDigits.count > 0 {
        // If it is positive can simply discard digits.
        return BigInt(digits: newDigits)

    } else {
        // Return -1 if we shifted maximum to the right on a negative number.
        return BigInt(digits: [UInt32(0xffffffff)])
    }
}

func shiftRightByOneBit(lhs: BigInt) -> BigInt {
    var newDigits = lhs.digits

    // Fill in the carry by the sign of the lhs (take a digit beyond the number of digits available).
    var carryAndAccumulator: UInt64 = lhs < 0 ? 0x80000000_00000000 : 0
    for i in (0 ..< newDigits.count).reverse() {
        carryAndAccumulator |= (UInt64(newDigits[i]) << UInt64(32 - 1))
        newDigits[i] = UInt32(carryAndAccumulator >> 32)
        carryAndAccumulator <<= 32
    }

    return BigInt(digits: newDigits)
}

