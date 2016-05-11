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


