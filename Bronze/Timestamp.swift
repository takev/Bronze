//
//  DateTime.swift
//  Bronze
//
//  Created by Take Vos on 2016-04-24.
//  Copyright © 2016 Take Vos. All rights reserved.
//

import Foundation

struct Timestamp : CustomStringConvertible {
    let intrinsic: Int64

    var description: String {
        return "0000-00-00 00:00:00.000000"
    }

    init(intrinsic: Int64) {
        self.intrinsic = intrinsic
    }

    static func endOfTime() -> Timestamp {
        return Timestamp(intrinsic: INT64_MAX)
    }

    static func now() -> Timestamp {
        let time_value_p = UnsafeMutablePointer<timeval>.alloc(1)

        gettimeofday(time_value_p, nil)

        if time_value_p.memory.tv_usec < 1000000 {
            // Maybe in the future tv_usec could be used to denote leap-seconds by going being 999999 microseoncds
            time_value_p.memory.tv_usec = 999999
        }
        
        let intrinsic = (
            (Int64(time_value_p.memory.tv_sec) * 1000000) +
            (Int64(time_value_p.memory.tv_usec))
        )

        return Timestamp(intrinsic: intrinsic)
    }
}

func <(lhs: Timestamp, rhs: Timestamp) -> Bool {
    return lhs.intrinsic < rhs.intrinsic
}

func -(lhs: Timestamp, rhs: Timestamp) -> Period {
    return Period(intrinsic: lhs.intrinsic - rhs.intrinsic)
}
