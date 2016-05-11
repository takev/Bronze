//
//  BigInt_compare.swift
//  Bronze
//
//  Created by Take Vos on 2016-01-03.
//  Copyright © 2016 Take Vos. All rights reserved.
//

enum CompareResult {
case LeftGreaterThanRight
case LeftLessThanRight
case LeftEqualToRight
}

func compare(lhs: BigInt, _ rhs: BigInt) -> CompareResult {
    let abs_lhs = abs(lhs)
    let abs_rhs = abs(rhs)
    let positive: Bool

    switch (lhs.isPositive, rhs.isPositive) {
    case (false, false):    positive = false
    case (true, true):      positive = true
    case (false, true):     return CompareResult.LeftLessThanRight
    case (true, false):     return CompareResult.LeftGreaterThanRight
    }

    if abs_lhs.digits.count > abs_rhs.digits.count {
        return positive ? CompareResult.LeftGreaterThanRight : CompareResult.LeftLessThanRight
    } else if abs_lhs.digits.count < abs_rhs.digits.count {
        return positive ? CompareResult.LeftLessThanRight : CompareResult.LeftGreaterThanRight
    } else {
        var i = abs_lhs.digits.count - 1
        while i >= 0 {
            if (abs_lhs[i] > abs_rhs[i]) {
                return positive ? CompareResult.LeftGreaterThanRight : CompareResult.LeftLessThanRight
            } else if (abs_lhs[i] < abs_rhs[i]) {
                return positive ? CompareResult.LeftLessThanRight : CompareResult.LeftGreaterThanRight
            }
            // This digit is equal, continue
            i -= 1
        }
        // All digits are equal.
        return CompareResult.LeftEqualToRight
    }
}
