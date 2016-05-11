//
//  DHSession.swift
//  Bronze
//
//  Created by Take Vos on 2016-04-18.
//  Copyright © 2016 Take Vos. All rights reserved.
//

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