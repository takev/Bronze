//
//  SequenceType_extra.swift
//  Bronze
//
//  Created by Take Vos on 2016-05-13.
//  Copyright © 2016 Take Vos. All rights reserved.
//

import Foundation

extension Indexable where Self._Element: Equatable {
    func longestRun(value: Self._Element) -> Range<Self.Index> {
        var currentRun = startIndex ..< startIndex
        var longestRun = currentRun

        for i in startIndex ..< endIndex {
            if self[i] == value {
                currentRun = currentRun.startIndex ... i

            } else {
                if longestRun.distance < currentRun.distance {
                    longestRun = currentRun
                }
                currentRun = i.advancedBy(1) ..< i.advancedBy(1)
            }
        }
        if longestRun.distance < currentRun.distance {
            longestRun = currentRun
        }

        return longestRun
    }
}
