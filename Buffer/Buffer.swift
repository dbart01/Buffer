//
//  Buffer.swift
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

public class Buffer: Writable, Readable, Collection, MutableCollection, RandomAccessCollection, Equatable, CustomDebugStringConvertible, CustomStringConvertible {
    
    public typealias Element = Byte
    
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return self.size
    }
    
    public private(set) var size: Int
    
    public private(set) var capacity: Int
    
    private var store: UnsafeMutableRawPointer
    
    // MARK: - Allocation -

    private static func allocate(size: Int) -> UnsafeMutableRawPointer {
        return UnsafeMutableRawPointer.allocate(byteCount: size, alignment: 1)
    }
    
    // MARK: - Init -

    public init(size: Int, zero: Bool = true) {
        self.size     = size
        self.capacity = size
        self.store    = Buffer.allocate(size: size)
        
        if zero {
            self.store.initializeMemory(as: Byte.self, repeating: 0x00, count: size)
        }
    }
    
    public init(_ pointer: UnsafeRawPointer, count: Int, capacity: Int) {
        assert(capacity >= count, "Buffer must be initialized with capacity large enough to contain the copied bytes.")
        
        self.size     = count
        self.capacity = capacity
        self.store    = Buffer.allocate(size: capacity)
        
        self.store.copyMemory(from: pointer, byteCount: count)
    }
    
    public convenience init(_ pointer: UnsafeRawPointer, count: Int) {
        self.init(pointer, count: count, capacity: count)
    }
    
    public convenience init(_ buffer: Buffer) {
        self.init(buffer.store, count: buffer.size)
    }
    
    public init(_ array: Array<Byte>) {
        self.size     = array.count
        self.capacity = self.size
        self.store    = Buffer.allocate(size: self.size)

        if array.count > 0 {
            array.withUnsafeBytes {
                self.store.copyMemory(from: $0.baseAddress!, byteCount: array.count)
            }
        }
    }
    
    public init(_ data: Data) {
        self.size     = data.count
        self.capacity = self.size
        self.store    = Buffer.allocate(size: self.size)
        
        self.write(data: data)
    }
    
    public convenience init<T>(_ collection: T) where T: Collection, T.Element == Element {
        self.init(Array(collection))
    }
    
    deinit {
        self.store.deallocate()
    }
    
    // MARK: - Cursors -

    public func cursorForWriting(at offset: Int) -> WritingCursor {
        self.assertWithinBounds(at: offset, size: self.size - offset)
        return WritingCursor(to: self, offset: offset, size: self.size - offset)
    }
    
    public func write(at offset: Int = 0, block: (WritingCursor) -> Void) {
        block(self.cursorForWriting(at: offset))
    }
    
    public func cursorForReading(at offset: Int) -> ReadingCursor {
        self.assertWithinBounds(at: offset, size: self.size - offset)
        return ReadingCursor(to: self, offset: offset, size: self.size - offset)
    }
    
    public func read(at offset: Int = 0, block: (ReadingCursor) -> Void) {
        block(self.cursorForReading(at: offset))
    }
    
    // MARK: - Equatable -

    public static func ==(lhs: Buffer, rhs: Buffer) -> Bool {
        if lhs.size == rhs.size {
            return memcmp(lhs.store, rhs.store, lhs.size) == 0
        }
        return false
    }
    
    // MARK: - Description -

    public var description: String {
        return self.debugDescription
    }
    
    public var debugDescription: String {
        return self.visualize(stride: self.size)
    }
    
    // MARK: - Collection -

    public func index(after i: Int) -> Int {
        return i + 1
    }
    
    // MARK: - Subscript -

    public subscript(index: Int) -> Byte {
        get {
            self.assertWithinBounds(at: index, size: 1)
            return self.store.advanced(by: index).assumingMemoryBound(to: Byte.self).pointee
        }
        set(byte) {
            self.assertWithinBounds(at: index, size: 1)
            self.store.advanced(by: index).initializeMemory(as: Byte.self, repeating: byte, count: 1)
        }
    }
    
    // MARK: - Inflation Strategy -
    
    private func inflatedCapacity(for overflow: Int, currentCapacity: Int) -> Int {
        return (currentCapacity + overflow) * 2
    }
    
    // MARK: - Inflate -

    private func inflate(for overflow: Int) {
        let inflatedCapacity = self.inflatedCapacity(for: overflow, currentCapacity: self.capacity)
        
        let store = Buffer.allocate(size: inflatedCapacity)
        store.copyMemory(from: self.store, byteCount: self.size)

        self.capacity = inflatedCapacity
        self.store    = store
    }
    
    private func inflateIfOverflowing(at offset: Int, insertionSize: Int) {
        let capacityOverflow = (offset + insertionSize) - self.capacity
        if capacityOverflow > 0 {
            self.inflate(for: capacityOverflow)
        }
        
        let sizeOverflow = (offset + insertionSize) - self.size
        if sizeOverflow > 0 {
            self.size += sizeOverflow
        }
    }
    
    private func inflateIfOverflowing<T>(at offset: Int, type: T.Type) {
        self.inflateIfOverflowing(at: offset, insertionSize: MemoryLayout<T>.stride)
    }
    
    // MARK: - Writable -

    public func write<T>(value: T, at offset: Int) {
        self.inflateIfOverflowing(at: offset, type: T.self)
        
        self.store.advanced(by: offset).initializeMemory(as: T.self, repeating: value, count: 1)
    }
    
    public func write<T>(bytes: UnsafePointer<T>, count: Int, at offset: Int) {
        self.inflateIfOverflowing(at: offset, insertionSize: count)
        
        self.store.advanced(by: offset).initializeMemory(as: T.self, from: bytes, count: count)
    }
    
    // MARK: - Readable -

    public func read<T>(_ type: T.Type, at offset: Int) -> T {
        self.assertWithinBounds(at: offset, type: T.self)
        return self.store.advanced(by: offset).assumingMemoryBound(to: type).pointee
    }
    
    public func read<T>(pointerTo type: T.Type, size: Int, at offset: Int) -> UnsafePointer<T> {
        self.assertWithinBounds(at: offset, size: size)
        return UnsafePointer(self.store.advanced(by: offset).assumingMemoryBound(to: T.self))
    }
    
    // MARK: - Assertions -

    @inline(__always)
    private func assertWithinBounds<T>(at offset: Int, type: T.Type) {
        self.assertWithinBounds(at: offset, size: MemoryLayout<T>.stride)
    }
    
    @inline(__always)
    private func assertWithinBounds(at offset: Int, size: Int) {
        assert(size > 0, "Buffer access size cannot be negative - \(size).")
        assert(offset + size <= self.size, "Buffer (\(self.size) bytes) access out-of-bounds [offset: \(offset), size: \(size)].")
    }
    
    // MARK: - Visualize -

    private func visualize(stride: Int, group: Int = 8) -> String {
        var hex: [String] = []
        for byte in self {
            let value = String(format: "%02X", byte)
            hex.append(value)
        }
        
        var output = ""
        let perRow = Swift.min(stride, group)
        let chunks = stride / perRow
        output += "------- Buffer --------"
        output += "\n"
        
        for chunk in 0..<chunks {
            let offset = chunk  * perRow
            let limit  = offset + perRow
            output += hex[offset..<limit].joined(separator: " ")
            output += "\n"
        }
        
        return output
    }
}
