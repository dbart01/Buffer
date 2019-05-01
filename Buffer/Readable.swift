//
//  Readable.swift
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

public protocol Readable {
    func read<T>(_ type: T.Type, at offset: Int) -> T
    func read<T>(pointerTo type: T.Type, size: Int, at offset: Int) -> UnsafePointer<T>
}

extension Readable {
    public func read<T>(at offset: Int = 0) -> T {
        return self.read(T.self, at: offset)
    }
    
    public func read<T>(_ type: T.Type, at offset: Int = 0) -> T {
        return self.read(type, at: offset)
    }
    
    public func read<T>(_ type: T.Type, at offset: Int = 0, size: Int) -> T {
        let sourcePointer = self.read(pointerTo: UInt8.self, size: size, at: offset)

        var value: T?
        let pointer = UnsafeMutableRawPointer(mutating: &value)
        pointer.copyMemory(from: sourcePointer, byteCount: size)
        
        return pointer.assumingMemoryBound(to: T.self).pointee
    }
    
    public func read(dataWithSize size: Int, at offset: Int = 0) -> Data {
        let bytes = self.read(pointerTo: Byte.self, size: size, at: offset)
        return Data(bytes: bytes, count: size)
    }
    
    public func read(stringWithSize size: Int, at offset: Int = 0) -> String? {
        let bytes  = self.read(pointerTo: Byte.self, size: size, at: offset)
        let buffer = UnsafeBufferPointer(start: bytes, count: size)
        return String(bytes: buffer, encoding: .utf8)
    }
    
    public func read(unsafeStringWithSize size: Int, at offset: Int = 0) -> String? {
        let bytes = self.read(pointerTo: Byte.self, size: size, at: offset)
        return String(bytesNoCopy: UnsafeMutablePointer(mutating: bytes), length: size, encoding: .utf8, freeWhenDone: false)
    }
}
