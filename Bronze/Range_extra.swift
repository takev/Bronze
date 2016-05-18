//
//  Range_extra.swift
//  Bronze
//
//  Created by Take Vos on 2016-05-13.
//  Copyright © 2016 Take Vos. All rights reserved.
//

import Foundation

extension Range {
    var distance: Index.Distance {
        return self.startIndex.distanceTo(self.endIndex)
    }
}

