//
//  Writable.swift
//  Buffer
//
//  Created by Dima Bart on 2018-04-26.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

public protocol Writable {
    func write<T>(value: T, at offset: Int)
    func write<T>(bytes: UnsafePointer<T>, count: Int, at offset: Int)
}

extension Writable {
    
    public func write<T>(value: T, at offset: Int = 0) {
        self.write(value: value, at: offset)
    }
    
    public func write(data: Data, at offset: Int = 0) {
        let count = data.count
        if count > 0 {
            data.withUnsafeBytes { pointer in
                self.write(bytes: pointer.baseAddress!.assumingMemoryBound(to: Byte.self), count: count, at: offset)
            }
        }
    }
    
    public func write(string: String, at offset: Int = 0) {
        let length = string.lengthOfBytes(using: .utf8)
        if length > 0 {
            string.withCString { cString in
                self.write(bytes: cString, count: length, at: offset)
            }
        }
    }
}
