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

func multiplyByDigit(lhs: BigInt, _ rhs: UInt32) -> BigInt {
    let nrNewDigits = lhs.digits.count + 1
    var newDigits = Array<UInt32>(count: nrNewDigits, repeatedValue: 0)

    var carryAndAccumulator: UInt64 = 0
    for i in 0 ..< nrNewDigits {
        carryAndAccumulator += (UInt64(lhs[i]) * UInt64(rhs))

        newDigits[i] = UInt32(carryAndAccumulator & 0xffffffff)

        carryAndAccumulator >>= 32
    }

    return BigInt(digits: newDigits)
}

public func multiplySchoolAlgorithmSlow(lhs: BigInt, _ rhs: BigInt, accumulator: BigInt = BigInt()) -> BigInt {
    var accumulator = accumulator
    let lhs_abs = abs(lhs)
    let rhs_abs = abs(rhs)

    let result_positive: Bool
    switch (lhs >= 0, rhs >= 0) {
    case (false, false):    result_positive = true
    case (false, true):     result_positive = false
    case (true, false):     result_positive = false
    case (true, true):      result_positive = true
    }

    for i in 0 ..< rhs.digits.count {
        accumulator = accumulator + (multiplyByDigit(lhs_abs, rhs_abs[i]) << (i*32))
    }

    return result_positive  ? accumulator : -accumulator
}

public func multiplySchoolAlgorithm(lhs: BigInt, _ rhs: BigInt) -> BigInt {
    let lhs_abs = abs(lhs).digits
    let rhs_abs = abs(rhs).digits

    // Reserve one extra digit for overflow.
    var accumulator = Array<UInt32>(count: lhs_abs.count + rhs_abs.count + 1, repeatedValue: 0)

    for rhs_index in 0 ..< rhs_abs.count {
        let rhs_digit = UInt64(rhs_abs[rhs_index])
        var carry: UInt64 = 0
        for lhs_index in 0 ..< lhs_abs.count {
            let lhs_digit = UInt64(lhs_abs[lhs_index])

            // Add the digit from the accumulator to the carry.
            // There is enough room to add the accumulator to the carry.
            // Example for 8 bit digits with 16 carry and product:
            //    (255 lhs digit * 255 rhs digit) + 255 carry + 255 accumulator => 65535
            carry += UInt64(accumulator[rhs_index + lhs_index])

            // Calculate the product of the two digits plus carry.
            // Hopfully this result in a fused multiply add.
            let product = lhs_digit * rhs_digit + carry

            // Now save the low bits from the product back into the accumulator.
            accumulator[rhs_index + lhs_index] = UInt32(product & 0xffffffff)

            // Set the next carry to the upper bits of the product.
            carry = product >> 32
        }

        // Save the overflow in the digit beyond the current most significant byte.
        accumulator[rhs_index + lhs_abs.count] = UInt32(carry & 0xffffffff)
    }

    let result_positive: Bool
    switch (lhs >= 0, rhs >= 0) {
    case (false, false):    result_positive = true
    case (false, true):     result_positive = false
    case (true, false):     result_positive = false
    case (true, true):      result_positive = true
    }

    return result_positive  ? BigInt(digits:accumulator) : -BigInt(digits:accumulator)
}


