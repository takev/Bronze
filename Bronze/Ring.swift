//
//  Queue.swift
//  Bronze
//
//  Created by Take Vos on 2016-05-07.
//  Copyright © 2016 Take Vos. All rights reserved.
//

import Foundation

enum RingItemState {
case EMPTY
case COPYING
case OCCUPIED
case CLEARING
}

struct RingItem<T> {
    var state = RingItemState.EMPTY
    var item: T? = nil

    mutating func set(item: T) {
        precondition(self.state == RingItemState.EMPTY, "In wrong state during set()")

        self.state = RingItemState.COPYING
        OSMemoryBarrier()
        self.item = item
        OSMemoryBarrier()
        self.state = RingItemState.OCCUPIED
    }

    mutating func get() -> T {
        precondition(self.state == RingItemState.OCCUPIED, "In wrong state during get()")

        guard let item = self.item else {
            preconditionFailure("Item is empty during get")
        }

        self.state = RingItemState.CLEARING
        OSMemoryBarrier()
        self.item = nil
        OSMemoryBarrier()
        self.state = RingItemState.EMPTY

        return item
    }
}

// This class implements a ring buffer.
// A multiple consumer and multiple producer may be on different threads; no locking required.
public struct Ring<T> {
    var data: Array<RingItem<T>>
    var head: Int64 = 0
    var tail: Int64 = 0

    var nrItems: Int64 {
        return Int64(data.count)
    }

    init(nrItems: Int) {
        data = Array<RingItem<T>>(count: nrItems, repeatedValue: RingItem())
    }

    /// returns true when item was added to the ring; false when the ring is full.
    mutating func add(item: T) -> Bool {
        var oldHeadValue : Int64
        var newHeadValue : Int64

        repeat {
            oldHeadValue = head
            newHeadValue = oldHeadValue + 1

            // Even though tail may change, it will increase meaning we can go further.
            guard (oldHeadValue - tail) < nrItems else {
                return false
            }

            guard data[Int(oldHeadValue % nrItems)].state == RingItemState.EMPTY else {
                return false
            }

        } while !OSAtomicCompareAndSwap64Barrier(oldHeadValue, newHeadValue, &head)

        data[Int(oldHeadValue % nrItems)].set(item)
        return true
    }

    /// returns an item if there are items on the ring; nil when the ring is empty.
    mutating func remove() -> T? {
        var oldTailValue : Int64
        var newTailValue : Int64

        repeat {
            oldTailValue = tail
            newTailValue = oldTailValue + 1

            // Even though head may change, it will increase meaning we can go further.
            guard (head - oldTailValue) > 0 else {
                return nil
            }

            guard data[Int(oldTailValue % nrItems)].state == RingItemState.OCCUPIED else {
                return nil;
            }

        } while !OSAtomicCompareAndSwap64Barrier(oldTailValue, newTailValue, &tail)

        return data[Int(oldTailValue % nrItems)].get()
    }
}
