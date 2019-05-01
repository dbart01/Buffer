//
//  Writable.swift
//  Buffer
//
//  The MIT License (MIT)
//
//  Copyright © 2019 Dima Bart
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
