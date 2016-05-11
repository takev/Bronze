//
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

public func modularPower(_base: BigInt, exponent _exponent: BigInt, modulus: BigInt) -> BigInt {
    var base = _base
    var exponent = _exponent
    
    // I do not know what this means.
    //Assert :: (modulus - 1) * (modulus - 1) does not overflow base

    if modulus == 1 {
        return BigInt()
    }

    let (k, r) = reductionBarretFactors(modulus)

    var result = BigInt(1)

    base = reductionBarret(base, modulus: modulus, k: k, r: r)
    while exponent > 0 {
        if exponent.isOdd {
            // Barret reductin is a fast modulo.
            result = reductionBarret(result * base, modulus: modulus, k: k, r: r)
        }

        exponent = exponent >> 1
        base = reductionBarret(base * base, modulus: modulus, k: k, r: r)
    }
    return result
}
