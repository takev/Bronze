//
//  integer_intrinsics.m
//  Bronze
//
//  Created by Take Vos on 2016-01-02.
//  Copyright © 2016 Take Vos. All rights reserved.
//

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


