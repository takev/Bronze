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


import XCTest
@testable import Bronze

class BigInt_tests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func BigIntStringFactor(text: String) -> BigInt {
        return try! BigInt(text)
    }
    
    func testIntInitialization() {
        XCTAssertEqual(BigInt(0).hexDescription, "0x0")
        XCTAssertEqual(BigInt(1).hexDescription, "0x0000000000000001")
        XCTAssertEqual(BigInt(-1).hexDescription, "0xffffffffffffffff")
        XCTAssertEqual(BigInt(0xffffffff).hexDescription, "0x00000000ffffffff")
        XCTAssertEqual(BigInt(0x1_ffffffff).hexDescription, "0x00000001ffffffff")
        XCTAssertEqual(BigInt(-0x1_ffffffff).hexDescription, "0xfffffffe00000001")
        XCTAssertEqual(BigInt(-0x80000000_00000000).hexDescription, "0x8000000000000000")
        XCTAssertEqual(BigInt(0x7fffffff_ffffffff).hexDescription, "0x7fffffffffffffff")
    }

    func testStringInitialization() {
        XCTAssertEqual(try! BigInt("0").hexDescription, "0x0")
        XCTAssertEqual(try! BigInt("1").hexDescription, "0x0000000000000001")
        XCTAssertEqual(try! BigInt("-1").hexDescription, "0xffffffffffffffff")
        XCTAssertEqual(try! BigInt("0xffffffff").hexDescription, "0x00000000ffffffff")
        XCTAssertEqual(try! BigInt("0x1_23456789").hexDescription, "0x0000000123456789")
        XCTAssertEqual(try! BigInt("0x1_ffffffff").hexDescription, "0x00000001ffffffff")
        XCTAssertEqual(try! BigInt("-0x1_ffffffff").hexDescription, "0xfffffffe00000001")
        XCTAssertEqual(try! BigInt("-0x80000000_00000000").hexDescription, "0x8000000000000000")
        XCTAssertEqual(try! BigInt("0x7fffffff_ffffffff").hexDescription, "0x7fffffffffffffff")
        XCTAssertEqual(try! BigInt("0x00000000_7fffffff_ffffffff").hexDescription, "0x7fffffffffffffff")
        XCTAssertEqual(try! BigInt("0x00000000_00000000_7fffffff_ffffffff").hexDescription, "0x7fffffffffffffff")
    }

    func testDecimalInitializationAndDecimalDescription() {
        XCTAssertEqual(try! BigInt("0").description, "0")
        XCTAssertEqual(try! BigInt("-0").description, "0")

        XCTAssertEqual(try! BigInt("1").description, "1")
        XCTAssertEqual(try! BigInt("10").description, "10")
        XCTAssertEqual(try! BigInt("100").description, "100")
        XCTAssertEqual(try! BigInt("1000").description, "1000")
        XCTAssertEqual(try! BigInt("10000").description, "10000")
        XCTAssertEqual(try! BigInt("100000").description, "100000")
        XCTAssertEqual(try! BigInt("1000000").description, "1000000")
        XCTAssertEqual(try! BigInt("10000000").description, "10000000")
        XCTAssertEqual(try! BigInt("100000000").description, "100000000")
        XCTAssertEqual(try! BigInt("1000000000").description, "1000000000")
        XCTAssertEqual(try! BigInt("10000000000").description, "10000000000")
        XCTAssertEqual(try! BigInt("100000000000").description, "100000000000")
        XCTAssertEqual(try! BigInt("1000000000000").description, "1000000000000")
        XCTAssertEqual(try! BigInt("10000000000000").description, "10000000000000")
        XCTAssertEqual(try! BigInt("100000000000000").description, "100000000000000")
        XCTAssertEqual(try! BigInt("1000000000000000").description, "1000000000000000")
        XCTAssertEqual(try! BigInt("10000000000000000").description, "10000000000000000")
        XCTAssertEqual(try! BigInt("100000000000000000").description, "100000000000000000")
        XCTAssertEqual(try! BigInt("1000000000000000000").description, "1000000000000000000")
        XCTAssertEqual(try! BigInt("10000000000000000000").description, "10000000000000000000")
        XCTAssertEqual(try! BigInt("100000000000000000000").description, "100000000000000000000")
        XCTAssertEqual(try! BigInt("1000000000000000000000").description, "1000000000000000000000")
        XCTAssertEqual(try! BigInt("10000000000000000000000").description, "10000000000000000000000")
        XCTAssertEqual(try! BigInt("100000000000000000000000").description, "100000000000000000000000")
        XCTAssertEqual(try! BigInt("1000000000000000000000000").description, "1000000000000000000000000")
        XCTAssertEqual(try! BigInt("10000000000000000000000000").description, "10000000000000000000000000")

        XCTAssertEqual(try! BigInt("12").description, "12")
        XCTAssertEqual(try! BigInt("123").description, "123")
        XCTAssertEqual(try! BigInt("1234").description, "1234")
        XCTAssertEqual(try! BigInt("12345").description, "12345")
        XCTAssertEqual(try! BigInt("123456").description, "123456")
        XCTAssertEqual(try! BigInt("1234567").description, "1234567")
        XCTAssertEqual(try! BigInt("12345678").description, "12345678")
        XCTAssertEqual(try! BigInt("123456789").description, "123456789")
        XCTAssertEqual(try! BigInt("1234567890").description, "1234567890")
        XCTAssertEqual(try! BigInt("12345678901").description, "12345678901")
        XCTAssertEqual(try! BigInt("123456789012").description, "123456789012")
        XCTAssertEqual(try! BigInt("1234567890123").description, "1234567890123")
        XCTAssertEqual(try! BigInt("12345678901234").description, "12345678901234")
        XCTAssertEqual(try! BigInt("123456789012345").description, "123456789012345")
        XCTAssertEqual(try! BigInt("1234567890123456").description, "1234567890123456")
        XCTAssertEqual(try! BigInt("12345678901234567").description, "12345678901234567")
        XCTAssertEqual(try! BigInt("123456789012345678").description, "123456789012345678")
        XCTAssertEqual(try! BigInt("1234567890123456789").description, "1234567890123456789")
        XCTAssertEqual(try! BigInt("12345678901234567890").description, "12345678901234567890")
        XCTAssertEqual(try! BigInt("123456789012345678901").description, "123456789012345678901")
        XCTAssertEqual(try! BigInt("1234567890123456789012").description, "1234567890123456789012")
        XCTAssertEqual(try! BigInt("12345678901234567890123").description, "12345678901234567890123")
        XCTAssertEqual(try! BigInt("123456789012345678901234").description, "123456789012345678901234")
        XCTAssertEqual(try! BigInt("1234567890123456789012345").description, "1234567890123456789012345")
        XCTAssertEqual(try! BigInt("12345678901234567890123456").description, "12345678901234567890123456")
        XCTAssertEqual(try! BigInt("123456789012345678901234567").description, "123456789012345678901234567")
        XCTAssertEqual(try! BigInt("1234567890123456789012345678").description, "1234567890123456789012345678")
        XCTAssertEqual(try! BigInt("12345678901234567890123456789").description, "12345678901234567890123456789")
        XCTAssertEqual(try! BigInt("123456789012345678901234567890").description, "123456789012345678901234567890")

        XCTAssertEqual(try! BigInt("-12").description, "-12")
        XCTAssertEqual(try! BigInt("-123").description, "-123")
        XCTAssertEqual(try! BigInt("-1234").description, "-1234")
        XCTAssertEqual(try! BigInt("-12345").description, "-12345")
        XCTAssertEqual(try! BigInt("-123456").description, "-123456")
        XCTAssertEqual(try! BigInt("-1234567").description, "-1234567")
        XCTAssertEqual(try! BigInt("-12345678").description, "-12345678")
        XCTAssertEqual(try! BigInt("-123456789").description, "-123456789")
        XCTAssertEqual(try! BigInt("-1234567890").description, "-1234567890")
        XCTAssertEqual(try! BigInt("-12345678901").description, "-12345678901")
        XCTAssertEqual(try! BigInt("-123456789012").description, "-123456789012")
        XCTAssertEqual(try! BigInt("-1234567890123").description, "-1234567890123")
        XCTAssertEqual(try! BigInt("-12345678901234").description, "-12345678901234")
        XCTAssertEqual(try! BigInt("-123456789012345").description, "-123456789012345")
        XCTAssertEqual(try! BigInt("-1234567890123456").description, "-1234567890123456")
        XCTAssertEqual(try! BigInt("-12345678901234567").description, "-12345678901234567")
        XCTAssertEqual(try! BigInt("-123456789012345678").description, "-123456789012345678")
        XCTAssertEqual(try! BigInt("-1234567890123456789").description, "-1234567890123456789")
        XCTAssertEqual(try! BigInt("-12345678901234567890").description, "-12345678901234567890")
        XCTAssertEqual(try! BigInt("-123456789012345678901").description, "-123456789012345678901")
        XCTAssertEqual(try! BigInt("-1234567890123456789012").description, "-1234567890123456789012")
        XCTAssertEqual(try! BigInt("-12345678901234567890123").description, "-12345678901234567890123")
        XCTAssertEqual(try! BigInt("-123456789012345678901234").description, "-123456789012345678901234")
        XCTAssertEqual(try! BigInt("-1234567890123456789012345").description, "-1234567890123456789012345")
        XCTAssertEqual(try! BigInt("-12345678901234567890123456").description, "-12345678901234567890123456")
        XCTAssertEqual(try! BigInt("-123456789012345678901234567").description, "-123456789012345678901234567")
        XCTAssertEqual(try! BigInt("-1234567890123456789012345678").description, "-1234567890123456789012345678")
        XCTAssertEqual(try! BigInt("-12345678901234567890123456789").description, "-12345678901234567890123456789")
        XCTAssertEqual(try! BigInt("-123456789012345678901234567890").description, "-123456789012345678901234567890")

        XCTAssertEqual(try! BigInt("-1").description, "-1")
    }

    func testRandomInitialization() {
        // This is a non-deterministic random test.
        // We do a lot of tests and see if on average each bit toggles.
        let NR_BITS = 4096
        let NR_TESTS = 100
        let BIT_COUNT_MIN = Int(Double(NR_TESTS) * 0.1)
        let BIT_COUNT_MAX = Int(Double(NR_TESTS) * 0.1)

        // Create a set of random numbers.
        var results: [BigInt] = []
        for _ in 0 ..< NR_TESTS {
            results.append(BigInt(randomNrBits: NR_BITS))
        }

        // All random numbers that are generated must be positive.
        for result in results {
            XCTAssert(result >= 0)
        }

        // Now count each '1' bit lsb to msb.
        var bitCounts: [Int] = []
        for bitNr in 0 ..< NR_BITS {
            var bitCount = 0
            for result in results {
                if result.getBit(bitNr) {
                    bitCount += 1
                }
            }
            bitCounts.append(bitCount)
        }

        // Check if each bitCount has a value between NR_TEST * 0.1 and NR_TEST * 0.9
        for bitCount in bitCounts {
            XCTAssert(bitCount < BIT_COUNT_MIN || bitCount > BIT_COUNT_MAX)
        }
    }

    func testShiftLeft() {
        XCTAssertEqual((BigInt(0) << 4).hexDescription, "0x0")
        XCTAssertEqual((BigInt(1) << 4).hexDescription, "0x0000000000000010")
        XCTAssertEqual((BigInt(-1) << 4).hexDescription, "0xfffffffffffffff0")
        XCTAssertEqual((BigInt(0xffffffff) << 4).hexDescription, "0x0000000ffffffff0")
        XCTAssertEqual((BigInt(0x1_ffffffff) << 4).hexDescription, "0x0000001ffffffff0")
        XCTAssertEqual((BigInt(-0x1_ffffffff) << 4).hexDescription, "0xffffffe000000010")
        XCTAssertEqual((BigInt(-0x80000000_00000000) << 4).hexDescription, "0xfffffffffffffff8_0000000000000000")
        XCTAssertEqual((BigInt(0x7fffffff_ffffffff) << 4).hexDescription, "0x0000000000000007_fffffffffffffff0")

        XCTAssertEqual((BigInt(0) << 36).hexDescription, "0x0")
        XCTAssertEqual((BigInt(1) << 36).hexDescription, "0x0000001000000000")
        XCTAssertEqual((BigInt(-1) << 36).hexDescription, "0xfffffff000000000")
        XCTAssertEqual((BigInt(0xffffffff) << 36).hexDescription, "0x000000000000000f_fffffff000000000")
        XCTAssertEqual((BigInt(0x1_ffffffff) << 36).hexDescription, "0x000000000000001f_fffffff000000000")
        XCTAssertEqual((BigInt(-0x1_ffffffff) << 36).hexDescription, "0xffffffffffffffe0_0000001000000000")
        XCTAssertEqual((BigInt(-0x80000000_00000000) << 36).hexDescription, "0xfffffff800000000_0000000000000000")
        XCTAssertEqual((BigInt(0x7fffffff_ffffffff) << 36).hexDescription, "0x00000007ffffffff_fffffff000000000")
    }

    func testShiftRight() {
        XCTAssertEqual((BigInt(0) >> 1).hexDescription, "0x0")
        XCTAssertEqual((BigInt(1) >> 1).hexDescription, "0x0")
        XCTAssertEqual((BigInt(-1) >> 1).hexDescription, "0xffffffffffffffff")
        XCTAssertEqual((BigInt(0xffffffff) >> 1).hexDescription, "0x000000007fffffff")
        XCTAssertEqual((BigInt(0x1_ffffffff) >> 1).hexDescription, "0x00000000ffffffff")
        XCTAssertEqual((BigInt(-0x1_ffffffff) >> 1).hexDescription, "0xffffffff00000000")
        XCTAssertEqual((BigInt(-0x80000000_00000000) >> 1).hexDescription, "0xc000000000000000")
        XCTAssertEqual((BigInt(0x7fffffff_ffffffff) >> 1).hexDescription, "0x3fffffffffffffff")

        XCTAssertEqual((BigInt(0) >> 4).hexDescription, "0x0")
        XCTAssertEqual((BigInt(1) >> 4).hexDescription, "0x0")
        XCTAssertEqual((BigInt(-1) >> 4).hexDescription, "0xffffffffffffffff")
        XCTAssertEqual((BigInt(0xffffffff) >> 4).hexDescription, "0x000000000fffffff")
        XCTAssertEqual((BigInt(0x1_ffffffff) >> 4).hexDescription, "0x000000001fffffff")
        XCTAssertEqual((BigInt(-0x1_ffffffff) >> 4).hexDescription, "0xffffffffe0000000")
        XCTAssertEqual((BigInt(-0x80000000_00000000) >> 4).hexDescription, "0xf800000000000000")
        XCTAssertEqual((BigInt(0x7fffffff_ffffffff) >> 4).hexDescription, "0x07ffffffffffffff")

        XCTAssertEqual((BigInt(0) >> 36).hexDescription, "0x0")
        XCTAssertEqual((BigInt(1) >> 36).hexDescription, "0x0")
        XCTAssertEqual((BigInt(-1) >> 36).hexDescription, "0xffffffffffffffff")
        XCTAssertEqual((BigInt(0xffffffff) >> 36).hexDescription, "0x0")
        XCTAssertEqual((BigInt(0x1_ffffffff) >> 36).hexDescription, "0x0")
        XCTAssertEqual((BigInt(-0x1_ffffffff) >> 36).hexDescription, "0xffffffffffffffff")
        XCTAssertEqual((BigInt(-0x80000000_00000000) >> 36).hexDescription, "0xfffffffff8000000")
        XCTAssertEqual((BigInt(0x7fffffff_ffffffff) >> 36).hexDescription, "0x0000000007ffffff")
    }

    func testMultiplication() {
        XCTAssertEqual((BigInt(0) * 0).description, "0")
        XCTAssertEqual((BigInt(0) * 1).description, "0")
        XCTAssertEqual((BigInt(1) * 1).description, "1")

        XCTAssertEqual((BigInt(1) * 10).description, "10")
        XCTAssertEqual((BigInt(10) * 1).description, "10")
        XCTAssertEqual((BigInt(-1) * 10).description, "-10")
        XCTAssertEqual((BigInt(-10) * 1).description, "-10")
        XCTAssertEqual((BigInt(1) * -10).description, "-10")
        XCTAssertEqual((BigInt(10) * -1).description, "-10")
        XCTAssertEqual((BigInt(-1) * -10).description, "10")
        XCTAssertEqual((BigInt(-10) * -1).description, "10")

        XCTAssertEqual((BigInt(1) * BigInt(10)).description, "10")
        XCTAssertEqual((BigInt(10) * BigInt(1)).description, "10")
        XCTAssertEqual((BigInt(-1) * BigInt(10)).description, "-10")
        XCTAssertEqual((BigInt(-10) * BigInt(1)).description, "-10")
        XCTAssertEqual((BigInt(1) * BigInt(-10)).description, "-10")
        XCTAssertEqual((BigInt(10) * BigInt(-1)).description, "-10")
        XCTAssertEqual((BigInt(-1) * BigInt(-10)).description, "10")
        XCTAssertEqual((BigInt(-10) * BigInt(-1)).description, "10")

        XCTAssertEqual((try! BigInt("12345678901234567890") * 2).description, "24691357802469135780")
        XCTAssertEqual((try! BigInt("12345678901234567890") * 4).description, "49382715604938271560")
        XCTAssertEqual((try! BigInt("12345678901234567890") * 8).description, "98765431209876543120")
        XCTAssertEqual((try! BigInt("12345678901234567890") * 16).description, "197530862419753086240")
        XCTAssertEqual((try! BigInt("12345678901234567890") * 32).description, "395061724839506172480")
        XCTAssertEqual((try! BigInt("12345678901234567890") * 64).description, "790123449679012344960")
        XCTAssertEqual((try! BigInt("12345678901234567890") * 128).description, "1580246899358024689920")
        XCTAssertEqual((try! BigInt("12345678901234567890") * 256).description, "3160493798716049379840")
        XCTAssertEqual((try! BigInt("12345678901234567890") * 2147483648).description, "26512143563859841556120862720")
        XCTAssertEqual((try! BigInt("12345678901234567890") * 4294967296).description, "53024287127719683112241725440")
        XCTAssertEqual((try! BigInt("12345678901234567890") * 8589934592).description, "106048574255439366224483450880")

        XCTAssertEqual((try! BigInt("-12345678901234567890") * 2).description, "-24691357802469135780")
        XCTAssertEqual((try! BigInt("-12345678901234567890") * 4).description, "-49382715604938271560")
        XCTAssertEqual((try! BigInt("-12345678901234567890") * 8).description, "-98765431209876543120")
        XCTAssertEqual((try! BigInt("-12345678901234567890") * 16).description, "-197530862419753086240")
        XCTAssertEqual((try! BigInt("-12345678901234567890") * 32).description, "-395061724839506172480")
        XCTAssertEqual((try! BigInt("-12345678901234567890") * 64).description, "-790123449679012344960")
        XCTAssertEqual((try! BigInt("-12345678901234567890") * 128).description, "-1580246899358024689920")
        XCTAssertEqual((try! BigInt("-12345678901234567890") * 256).description, "-3160493798716049379840")
        XCTAssertEqual((try! BigInt("-12345678901234567890") * 2147483648).description, "-26512143563859841556120862720")
        XCTAssertEqual((try! BigInt("-12345678901234567890") * 4294967296).description, "-53024287127719683112241725440")
        XCTAssertEqual((try! BigInt("-12345678901234567890") * 8589934592).description, "-106048574255439366224483450880")

        XCTAssertEqual((try! BigInt("12345678901234567890") * 3).description, "37037036703703703670")
        XCTAssertEqual((try! BigInt("12345678901234567890") * 5).description, "61728394506172839450")
        XCTAssertEqual((try! BigInt("12345678901234567890") * 9).description, "111111110111111111010")
        XCTAssertEqual((try! BigInt("12345678901234567890") * 17).description, "209876541320987654130")
        XCTAssertEqual((try! BigInt("12345678901234567890") * 33).description, "407407403740740740370")
        XCTAssertEqual((try! BigInt("12345678901234567890") * 65).description, "802469128580246912850")
        XCTAssertEqual((try! BigInt("12345678901234567890") * 129).description, "1592592578259259257810")
        XCTAssertEqual((try! BigInt("12345678901234567890") * 257).description, "3172839477617283947730")
        XCTAssertEqual((try! BigInt("12345678901234567890") * 2147483649).description, "26512143576205520457355430610")
        XCTAssertEqual((try! BigInt("12345678901234567890") * 4294967297).description, "53024287140065362013476293330")
        XCTAssertEqual((try! BigInt("12345678901234567890") * 8589934593).description, "106048574267785045125718018770")

        XCTAssertEqual((try! BigInt("1") * BigInt(0x100000000)).description, "4294967296")
    }

    func testDivision() {
        XCTAssertEqual((try! BigInt("4") / BigInt(2)).description, "2")
        XCTAssertEqual((try! BigInt("18446744073709551616") / BigInt(10)).description, "1844674407370955161")
    }

    func testModularPower() {
        XCTAssertEqual(modularPower(BigInt(3), exponent: BigInt(2), modulus: BigInt(10)).description, "9")
        XCTAssertEqual(modularPower(BigInt(3), exponent: BigInt(12345), modulus: BigInt(10)).description, "3")
        XCTAssertEqual(try! modularPower(BigInt(3), exponent: BigInt(12345), modulus: BigInt("36893488147422849766")).description, "24918863617337492911")

        XCTAssertEqual(try! modularPower(BigInt(2), exponent: BigInt("0x1f"), modulus: BigInt("0xFFFFFFFFFFFFFFFFC90FDAA22168C234C4C6628B80DC1CD129024E088A67CC74020BBEA63B139B22514A08798E3404DDEF9519B3CD3A431B302B0A6DF25F14374FE1356D6D51C245E485B576625E7EC6F44C42E9A637ED6B0BFF5CB6F406B7EDEE386BFB5A899FA5AE9F24117C4B1FE649286651ECE45B3DC2007CB8A163BF0598DA48361C55D39A69163FA8FD24CF5F83655D23DCA3AD961C62F356208552BB9ED529077096966D670C354E4ABC9804F1746C08CA237327FFFFFFFFFFFFFFFF")).description, "2147483648")

        XCTAssertEqual(try! modularPower(BigInt(2), exponent: BigInt("0x20"), modulus: BigInt("0xFFFFFFFFFFFFFFFFC90FDAA22168C234C4C6628B80DC1CD129024E088A67CC74020BBEA63B139B22514A08798E3404DDEF9519B3CD3A431B302B0A6DF25F14374FE1356D6D51C245E485B576625E7EC6F44C42E9A637ED6B0BFF5CB6F406B7EDEE386BFB5A899FA5AE9F24117C4B1FE649286651ECE45B3DC2007CB8A163BF0598DA48361C55D39A69163FA8FD24CF5F83655D23DCA3AD961C62F356208552BB9ED529077096966D670C354E4ABC9804F1746C08CA237327FFFFFFFFFFFFFFFF")).description, "4294967296")

        XCTAssertEqual(try! modularPower(BigInt(2), exponent: BigInt("0x123456789012345678901234567890"), modulus: BigInt("0xFFFFFFFFFFFFFFFFC90FDAA22168C234C4C6628B80DC1CD129024E088A67CC74020BBEA63B139B22514A08798E3404DDEF9519B3CD3A431B302B0A6DF25F14374FE1356D6D51C245E485B576625E7EC6F44C42E9A637ED6B0BFF5CB6F406B7EDEE386BFB5A899FA5AE9F24117C4B1FE649286651ECE45B3DC2007CB8A163BF0598DA48361C55D39A69163FA8FD24CF5F83655D23DCA3AD961C62F356208552BB9ED529077096966D670C354E4ABC9804F1746C08CA237327FFFFFFFFFFFFFFFF")).description, "2382520222103352709584526687930278051980125211999568276620527245391841002237103086655717377687700745979171468319836038597443166132103939456403029009374802199945677756130982355791093110688942270938705836413315505760592354754675109112626127150587584957323254460826287667114675972002665167638553362673525224719774242685840588531712489534896367548449286614815342560610539209463769667137569348715043966309599053088006556616133052662019451592674047544491011840110002437")
    }

}
