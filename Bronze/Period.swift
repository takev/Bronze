//
//  Period.swift
//  Bronze
//
//  Created by Take Vos on 2016-04-27.
//  Copyright © 2016 Take Vos. All rights reserved.
//

import Foundation

struct Period {
    // Number if microseconds.
    let intrinsic: Int64

    var numberOfMilliseconds: Int64 {
        return intrinsic / 1000
    }

    static func seconds(seconds: Int) -> Period {
        return Period(intrinsic: Int64(seconds) * 1000000)
    }

    static func minutes(minutes: Int) -> Period {
        return Period(intrinsic: Int64(minutes) * 60000000)
    }

    static func zero() -> Period {
        return Period(intrinsic: 0)
    }
}

func clamp(a: Period, minimum: Period, maximum: Period) -> Period {
    return Period(intrinsic: clamp(a.intrinsic, minimum: minimum.intrinsic, maximum: maximum.intrinsic))
}
