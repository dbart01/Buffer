//
//  Writable.swift
//  Buffer
//
//  Created by Dima Bart on 2018-04-26.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

public protocol Writable {
    func write<T>(at offset: Int, value: T)
    func write<T>(at offset: Int, bytes: UnsafePointer<T>, count: Int)
}

extension Writable {
    
    public func write<T>(at offset: Int = 0, value: T) {
        self.write(at: offset, value: value)
    }
    
    public func write(at offset: Int = 0, data: Data) {
        let count = data.count
        if count > 0 {
            _ = data.withUnsafeBytes { (bytes: UnsafePointer<Byte>) in
                self.write(at: offset, bytes: bytes, count: count)
            }
        }
    }
    
    public func write(at offset: Int = 0, string: String) {
        let length = string.lengthOfBytes(using: .utf8)
        if length > 0 {
            string.withCString { cString in
                self.write(at: offset, bytes: cString, count: length)
            }
        }
    }
}
