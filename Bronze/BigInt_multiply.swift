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

func multiplyByDigit(lhs: BigInt, _ rhs: UInt64) -> BigInt {
    let nrNewDigits = lhs.digits.count + 1
    var newDigits = Array<UInt64>(count: nrNewDigits, repeatedValue: 0)

    var carry: UInt64 = 0
    for i in 0 ..< nrNewDigits {
        let result: UInt64
        (result, carry) = mul_overflow(lhs[i], rhs, carry: carry)
        newDigits[i] = result
    }

    return BigInt(digits: newDigits)
}

public func multiplySchoolAlgorithm(lhs: BigInt, _ rhs: BigInt) -> BigInt {
    let lhs_abs = abs(lhs).digits
    let rhs_abs = abs(rhs).digits

    // Reserve one extra digit for overflow.
    var accumulator = Array<UInt64>(count: lhs_abs.count + rhs_abs.count + 1, repeatedValue: 0)

    for rhs_index in 0 ..< rhs_abs.count {
        let rhs_digit = UInt64(rhs_abs[rhs_index])
        var carry: UInt64 = 0
        for lhs_index in 0 ..< lhs_abs.count {
            let lhs_digit = UInt64(lhs_abs[lhs_index])

            let result: UInt64
            let acc = accumulator[rhs_index + lhs_index]
            (result, carry) = mul_overflow(lhs_digit, rhs_digit, carry: carry, accumulator: acc)
            accumulator[rhs_index + lhs_index] = result
        }

        // Save the overflow in the digit beyond the current most significant byte.
        accumulator[rhs_index + lhs_abs.count] = carry
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


