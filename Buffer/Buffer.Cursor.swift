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
        
        public func write<T>(at offset: Int, value: T) {
            self.buffer.write(at: self.offset + offset, value: value)
            self.advanceOffset(usingStride: T.self)
        }
        
        public func write(at offset: Int, data: Data) {
            self.buffer.write(at: self.offset + offset, data: data)
            self.advanceOffset(by: data.count)
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
        
        public func read(at offset: Int, size: Int) -> Data {
            let value = self.buffer.read(at: self.offset + offset, size: size)
            self.advanceOffset(by: size)
            return value
        }
    }
}
