//
//  Buffer.Cursor.swift
//  Buffer
//
//  Created by Dima Bart on 2018-04-26.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

extension Buffer {
    public class Cursor: CursorType {
        
        public let size: Int
        
        public private(set) var offset: Int
        
        fileprivate var buffer: Buffer
        
        // ----------------------------------
        //  MARK: - Init -
        //
        internal init(to buffer: Buffer, offset: Int, size: Int) {
            self.buffer = buffer
            self.size   = size
            self.offset = offset
        }
        
        // ----------------------------------
        //  MARK: - CursorType -
        //
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
