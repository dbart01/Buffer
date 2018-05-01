//
//  CursorType.swift
//  Buffer
//
//  Created by Dima Bart on 2018-04-27.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

public protocol CursorType {
    func advanceOffset(by count: Int)
}

extension CursorType {
    
    func advanceOffset<T>(usingStride type: T.Type) {
        self.advanceOffset(by: MemoryLayout<T>.stride)
    }
}
