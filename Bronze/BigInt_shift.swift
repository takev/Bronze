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

func shiftLeftByBits(lhs: BigInt, _ rhs: Int, carry: UInt64 = 0) -> BigInt {
    var carry = carry;
    let shiftNrDigits = rhs >> 6
    let shiftNrBits = rhs & 0x3f

    var newDigits = Array<UInt64>(count: lhs.digits.count + shiftNrDigits + 1, repeatedValue: 0)

    for i in 0 ..< newDigits.count {
        if (i < shiftNrDigits) {
            newDigits[i] = 0
        } else {
            let j = i - shiftNrDigits

            // lhs-subscript automaticaly sign extends, so no need to worry about that.
            (newDigits[i], carry) = shiftl_overflow(lhs[j], shiftNrBits, carry: carry)
        }
    }

    return BigInt(digits: newDigits)
}

func shiftLeftByDigits(lhs: BigInt, _ rhs: Int) -> BigInt {
    return BigInt(digits: Array<UInt64>(count: rhs, repeatedValue: 0) + lhs.digits)
}

func shiftLeftByAtMostOneDigit(lhs: BigInt, _ rhs: Int, carry: UInt64 = 0) -> BigInt {
    var carry = carry;

    // Sign extend with one extra digit to handle to potential overflow.
    var newDigits = lhs.digits + [lhs[lhs.digits.count]]

    for i in 0 ..< newDigits.count {
        (newDigits[i], carry) = shiftl_overflow(lhs[i], rhs, carry: carry)
    }

    return BigInt(digits: newDigits)
}

func shiftLeftByOneBit(lhs: BigInt, newBit: Bool = false) -> BigInt {
    return shiftLeftByAtMostOneDigit(lhs, 1, carry: newBit ? 1 : 0)
}

func shiftRightByBits(lhs: BigInt, _ rhs: Int) -> BigInt {
    let shiftNrDigits = rhs >> 6
    let shiftNrBits = rhs & 0x3f

    var newDigits = Array<UInt64>(count: lhs.digits.count - shiftNrDigits + 1, repeatedValue: 0)

    // Fill in the carry by the sign of the lhs (take a digit beyond the number of digits available).
    var carry: UInt64 = lhs[lhs.digits.count]

    // Handle the first digit by sign extending.
    var i = newDigits.count - 1
    let j = i + shiftNrDigits
    (newDigits[i], carry) = shiftr_overflow_sign_extend(lhs[j], shiftNrBits)
    i -= 1

    while i >= 0 {
        let j = i + shiftNrDigits

        (newDigits[i], carry) = shiftr_overflow(lhs[j], shiftNrBits, carry: carry)

        i -= 1
    }

    return BigInt(digits: newDigits)
}

func shiftRightByDigits(lhs: BigInt, _ rhs: Int) -> BigInt {
    let nrDigitsToShift = min(rhs, lhs.digits.count)
    let newDigits = Array<UInt64>(lhs.digits[nrDigitsToShift ..< lhs.digits.count])

    if lhs.isPositive || newDigits.count > 0 {
        // If it is positive can simply discard digits.
        return BigInt(digits: newDigits)

    } else {
        // Return -1 if we shifted maximum to the right on a negative number.
        return BigInt(digits: [0xffffffff_ffffffff])
    }
}

func shiftRightByAtMostOneDigit(lhs: BigInt, _ rhs: Int) -> BigInt {
    if lhs.digits.count == 0 {
        return BigInt()

    } else {
        var newDigits = Array<UInt64>(count: lhs.digits.count, repeatedValue: 0)

        // Fill in the carry by the sign of the lhs (take a digit beyond the number of digits available).
        var carry: UInt64
        (newDigits[newDigits.count - 1], carry) = shiftr_overflow_sign_extend(lhs[newDigits.count - 1], rhs)
        for i in (0 ..< newDigits.count - 1).reverse() {
            (newDigits[i], carry) = shiftr_overflow(lhs[i], rhs, carry: carry)
        }

        return BigInt(digits: newDigits)
    }
}

func shiftRightByOneBit(lhs: BigInt) -> BigInt {
    return shiftRightByAtMostOneDigit(lhs, 1)
}

