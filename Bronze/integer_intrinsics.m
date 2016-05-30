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

#import "integer_intrinsics.h"

int popcount_u64(uint64_t x) {
    return __builtin_popcountll((unsigned long long)x);
}

int popcount_u32(uint32_t x) {
    return __builtin_popcount((unsigned int)x);
}

int ffs_u64(uint64_t x) {
    return __builtin_ffsll((long long)x);
}

int ffs_u32(uint32_t x) {
    return __builtin_ffs((int)x);
}

int clz_u64(uint64_t x) {
    return __builtin_clzll((long long)x);
}

int clz_u32(uint32_t x) {
    return __builtin_clz((int)x);
}

uint64x2_t shiftl_overflow_u64_2(uint64_t a, uint64_t distance)
{
    __uint128_t _a = a;

    conv128_t result;
    result.u128 = _a << distance;
    return result.u64x2;
}

uint64x2_t shiftl_overflow_u64_3(uint64_t a, uint64_t distance, uint64_t carry)
{
    __uint128_t _a = a;
    __uint128_t _carry = carry;

    conv128_t result;
    result.u128 = (_a << distance) | _carry;
    return result.u64x2;
}

uint64x2_t shiftr_overflow_u64_2(uint64_t a, uint64_t distance)
{
    conv128_t _a;

    // Place the value in the most significant bits. So that
    // we can take the overflow from the least significant bits after the shift.
    _a.u64x2.x = 0;
    _a.u64x2.y = a;

    conv128_t shift_result;
    shift_result.u128 = _a.u128 >> distance;

    // The overflow and result are both in the wrong position.
    uint64x2_t result;
    result.x = shift_result.u64x2.y;
    result.y = shift_result.u64x2.x;
    return result;
}

uint64x2_t shiftr_overflow_sign_extend_u64_2(uint64_t a, uint64_t distance)
{
    conv128_t _a;

    // Place the value in the most significant bits. So that
    // we can take the overflow from the least significant bits after the shift.
    _a.u64x2.x = 0;
    _a.u64x2.y = a;

    // Shift as a signed integer to sign extend.
    conv128_t shift_result;
    shift_result.i128 = _a.i128 >> distance;

    // The overflow and result are both in the wrong position.
    uint64x2_t result;
    result.x = shift_result.u64x2.y;
    result.y = shift_result.u64x2.x;
    return result;
}

uint64x2_t shiftr_overflow_u64_3(uint64_t a, uint64_t distance, uint64_t carry)
{
    // Place the value in the most significant bits. So that
    // we can take the overflow from the least significant bits after the shift.
    conv128_t _a;
    _a.u64x2.x = 0;
    _a.u64x2.y = a;

    conv128_t _carry;
    _carry.u64x2.x = 0;
    _carry.u64x2.y = carry;

    conv128_t shift_result;
    shift_result.u128 = (_a.u128 >> distance) | _carry.u128;

    // The overflow and result are both in the wrong position.
    uint64x2_t result;
    result.x = shift_result.u64x2.y;
    result.y = shift_result.u64x2.x;
    return result;
}

uint64x2_t mul_overflow_u64_2(uint64_t a, uint64_t b)
{
    __uint128_t _a = a;
    __uint128_t _b = b;

    conv128_t result;
    result.u128 = _a * _b;
    return result.u64x2;
}

uint64x2_t mul_overflow_u64_3(uint64_t a, uint64_t b, uint64_t carry)
{
    __uint128_t _a = a;
    __uint128_t _b = b;
    __uint128_t _carry = carry;

    conv128_t result;
    result.u128 = (_a * _b) + _carry;
    return result.u64x2;
}

uint64x2_t mul_overflow_u64_4(uint64_t a, uint64_t b, uint64_t carry, uint64_t accumulator)
{
    __uint128_t _a = a;
    __uint128_t _b = b;
    __uint128_t _carry = carry;
    __uint128_t _accumulator = accumulator;

    conv128_t result;
    result.u128 = (_a * _b) + _carry + _accumulator;
    return result.u64x2;
}

uint64x2_t add_overflow_u64_2(uint64_t a, uint64_t b)
{
    __uint128_t _a = a;
    __uint128_t _b = b;

    conv128_t result;
    result.u128 = _a + _b;
    return result.u64x2;
}

uint64x2_t add_overflow_u64_3(uint64_t a, uint64_t b, uint64_t carry)
{
    __uint128_t _a = a;
    __uint128_t _b = b;
    __uint128_t _carry = carry;

    conv128_t result;
    result.u128 = _a + _b + _carry;
    return result.u64x2;
}


uint64_t rdrand_u64(void) {
    unsigned long long result;

    __builtin_ia32_rdrand64_step(&result);

    return result;
}

uint32_t rdrand_u32(void) {
    unsigned int result;

    __builtin_ia32_rdrand32_step(&result);

    return result;
}


