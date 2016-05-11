//
//  integer_intrinsics.h
//  Bronze
//
//  Created by Take Vos on 2016-01-02.
//  Copyright © 2016 Take Vos. All rights reserved.
//

#ifndef integer_intrinsics_h
#define integer_intrinsics_h

#include <stdint.h>

int popcount_u64(uint64_t x);
int popcount_u32(uint32_t x);
int ffs_u64(uint64_t x);
int ffs_u32(uint32_t x);

uint64_t rdrand_u64(void);
uint32_t rdrand_u32(void);

#endif /* integer_intrinsics_h */
