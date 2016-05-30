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

func divisionSchoolAlgorithm(lhs: BigInt, _ rhs: BigInt) -> (BigInt, BigInt) {
    precondition(rhs != 0, "Divide by zero exception")
    precondition(lhs >= 0)
    precondition(rhs > 0)

    let result_positive: Bool
    switch (lhs >= 0, rhs >= 0) {
    case (false, false):    result_positive = true
    case (false, true):     result_positive = false
    case (true, false):     result_positive = false
    case (true, true):      result_positive = true
    }

    let abs_lhs = abs(lhs)
    let abs_rhs = abs(rhs)

    var quotient = BigInt()
    var remainder = BigInt()

    var i = abs_lhs.digits.count * 64 - 1
    while i >= 0 {
        remainder = shiftLeftByOneBit(remainder, newBit:abs_lhs.getBit(i))
        if remainder >= abs_rhs {
            remainder = remainder - abs_rhs
            quotient = quotient.setBit(i)
        }
        i -= 1
    }

    if result_positive {
        return (quotient, remainder)
    } else {
        return (-quotient, -remainder)
    }
}

/// Return the factors needed a barret reduction.
/// - parameter modulus: Modulus
/// - returns: (k, r)
func reductionBarretFactors(modulus: BigInt) -> (Int, BigInt) {
    // k needs to be twice the number of bits of the modulus,
    // otherwise r just becomes 1, and we need precission.
    let k = modulus.digits.count * 64 * 2

    // r = (2**k) / n
    let r = (BigInt(1) << k) / modulus
    return (k, r)
}

/// Return the x % modulus
/// x must be smaller than modulus**2
/// - parameter x: Value to reduce
/// - parameter modulus: Modulus
/// - parameter k: From reductionBattetFactors()
/// - parameter r: From reductionBattetFactors()
/// - returns: x % modulus
func reductionBarret(x: BigInt, modulus: BigInt, k: Int, r: BigInt) -> BigInt
{
    if x < modulus * modulus {
        let quotient = (x * r) >> k

        var remainder = x - (quotient * modulus)
        precondition(remainder > 0, "Remainder should be larger than 1.")

        var i = 0
        while remainder >= modulus {
            if i > 1 {
                preconditionFailure("r is too far off.")
            }

            remainder = remainder - modulus
            i += 1
        }

        return remainder

    } else {
        // Fallback slow method.
        Swift.print("Fallback barret-reduction")
        return x % modulus
    }
}

