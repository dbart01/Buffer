//
//  Buffer.Cursor.swift
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

extension Buffer {
    public class Cursor: CursorType {
        
        public let size: Int
        
        public private(set) var offset: Int
        
        fileprivate var buffer: Buffer
        
        // MARK: - Init -
        
        internal init(to buffer: Buffer, offset: Int, size: Int) {
            self.buffer = buffer
            self.size   = size
            self.offset = offset
        }
        
        // MARK: - CursorType -
        
        public func advanceOffset(by count: Int) {
            self.offset += count
        }
    }
}

extension Buffer {
    public class WritingCursor: Cursor, Writable {
        
        public func write<T>(value: T, at offset: Int) {
            self.buffer.write(value: value, at: self.offset + offset)
            self.advanceOffset(usingStride: T.self)
        }
        
        public func write<T>(bytes: UnsafePointer<T>, count: Int, at offset: Int) {
            self.buffer.write(bytes: bytes, count: count, at: self.offset + offset)
            self.advanceOffset(by: count)
        }
    }
}

extension Buffer {
    public class ReadingCursor: Cursor, Readable {
        
        public func read<T>(_ type: T.Type, at offset: Int) -> T {
            let value = self.buffer.read(type, at: self.offset + offset)
            self.advanceOffset(usingStride: T.self)
            return value
        }
        
        public func read<T>(pointerTo type: T.Type, size: Int, at offset: Int) -> UnsafePointer<T> {
            let value = self.buffer.read(pointerTo: type, size: size, at: self.offset + offset)
            self.advanceOffset(by: size)
            return value
        }
    }
}
