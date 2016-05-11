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

func additionGeneric(lhs: BigInt, _ optionalRhs: BigInt?, carry carryAndAccumulator: UInt64 = 0, invert: Bool = false, handleOverflow: Bool = true) -> BigInt {
    var carryAndAccumulator = carryAndAccumulator;

    let nrNewDigits: Int
    switch (optionalRhs, handleOverflow) {
    case (.None, false):                nrNewDigits = lhs.digits.count
    case (.None, true):                 nrNewDigits = lhs.digits.count + 1
    case (.Some(let rhs), false):       nrNewDigits = max(lhs.digits.count, rhs.digits.count)
    case (.Some(let rhs), true):        nrNewDigits = max(lhs.digits.count, rhs.digits.count) + 1
    }

    var newDigits = Array<UInt32>(count: nrNewDigits, repeatedValue: 0)

    for i in 0 ..< nrNewDigits {
        switch (optionalRhs, invert) {
        case (.None, false):
            carryAndAccumulator += UInt64(lhs[i])
        case (.None, true):
            carryAndAccumulator += UInt64(~lhs[i])
        case (.Some(let rhs), false):
            carryAndAccumulator += UInt64(lhs[i])
            carryAndAccumulator += UInt64(rhs[i])
        case (.Some(let rhs), true):
            carryAndAccumulator += UInt64(lhs[i])
            carryAndAccumulator += UInt64(~rhs[i])
        }

        newDigits[i] = UInt32(carryAndAccumulator & 0xffffffff)

        carryAndAccumulator >>= 32
    }

    return BigInt(digits: newDigits)
}
