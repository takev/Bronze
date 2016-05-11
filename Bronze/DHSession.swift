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

class DHSession {
    let group: DHGroup
    let myPrivateKey = BigInt(randomNrBits: 512)
    let myPublicKey: BigInt
    var sharedSecret: BigInt?

    init(group: DHGroup) {
        self.group = group
        myPublicKey = modularPower(group.generator, exponent: self.myPrivateKey, modulus: group.prime)
    }

    func setTheirPublicKey(theirPublicKey: BigInt) {
        sharedSecret = modularPower(theirPublicKey, exponent: self.myPrivateKey, modulus: group.prime)

    }

}