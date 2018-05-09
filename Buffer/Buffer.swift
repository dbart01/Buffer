//
//  Buffer.swift
//  Buffer
//
//  Created by Dima Bart on 2018-04-25.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

public struct Buffer: Writable, Readable, Collection, MutableCollection, RandomAccessCollection, Equatable, CustomDebugStringConvertible, CustomStringConvertible {
    
    public typealias Element = Byte
    
    public let size: Int
    
    public let startIndex: Int
    public let endIndex:   Int
    
    private let store: UnsafeMutableRawPointer
    
    // ----------------------------------
    //  MARK: - Allocation -
    //
    private static func allocate(size: Int) -> UnsafeMutableRawPointer {
        return UnsafeMutableRawPointer.allocate(byteCount: size, alignment: 1)
    }
    
    // ----------------------------------
    //  MARK: - Init -
    //
    public init(size: Int, zero: Bool = true) {
        self.size  = size
        self.store = Buffer.allocate(size: size)
        
        self.startIndex = 0
        self.endIndex   = size
        
        if zero {
            self.store.initializeMemory(as: Byte.self, repeating: 0x00, count: size)
        }
    }
    
    public init(_ buffer: Buffer) {
        self.init(buffer.store, count: buffer.size)
    }
    
    public init(_ pointer: UnsafeRawPointer, count: Int) {
        self.size  = count
        self.store = Buffer.allocate(size: size)
        
        self.startIndex = 0
        self.endIndex   = count
        
        self.store.copyMemory(from: pointer, byteCount: count)
    }
    
    public init(_ array: Array<Byte>) {
        self.size  = array.count
        self.store = Buffer.allocate(size: size)

        self.startIndex = 0
        self.endIndex   = array.count

        if array.count > 0 {
            array.withUnsafeBytes {
                self.store.copyMemory(from: $0.baseAddress!, byteCount: array.count)
            }
        }
    }
    
    public init(_ data: Data) {
        self.size  = data.count
        self.store = Buffer.allocate(size: size)
        
        self.startIndex = 0
        self.endIndex   = data.count
        
        data.withUnsafeBytes { bytes in
            self.store.copyMemory(from: bytes, byteCount: data.count)
        }
    }
    
    public init<T>(_ collection: T) where T: Collection, T.Element == Element {
        self.init(Array(collection))
    }
    
    // ----------------------------------
    //  MARK: - Cursors -
    //
    public func cursorForWriting(at offset: Int) -> WritingCursor {
        self.assertWithinBounds(offset: offset, size: self.size - offset)
        return WritingCursor(to: self, offset: offset, size: self.size - offset)
    }
    
    public func write(at offset: Int = 0, block: (WritingCursor) -> Void) {
        block(self.cursorForWriting(at: offset))
    }
    
    public func cursorForReading(at offset: Int) -> ReadingCursor {
        self.assertWithinBounds(offset: offset, size: self.size - offset)
        return ReadingCursor(to: self, offset: offset, size: self.size - offset)
    }
    
    public func read(at offset: Int = 0, block: (ReadingCursor) -> Void) {
        block(self.cursorForReading(at: offset))
    }
    
    // ----------------------------------
    //  MARK: - Equatable -
    //
    public static func ==(lhs: Buffer, rhs: Buffer) -> Bool {
        if lhs.size == rhs.size {
            return memcmp(lhs.store, rhs.store, lhs.size) == 0
        }
        return false
    }
    
    // ----------------------------------
    //  MARK: - Description -
    //
    public var description: String {
        return self.debugDescription
    }
    
    public var debugDescription: String {
        return self.visualize(stride: self.size)
    }
    
    // ----------------------------------
    //  MARK: - Collection -
    //
    public func index(after i: Int) -> Int {
        return i + 1
    }
    
    // ----------------------------------
    //  MARK: - Subscript -
    //
    public subscript(index: Int) -> Byte {
        get {
            self.assertWithinBounds(offset: index, size: 1)
            return self.store.advanced(by: index).assumingMemoryBound(to: Byte.self).pointee
        }
        set(byte) {
            self.assertWithinBounds(offset: index, size: 1)
            self.store.advanced(by: index).initializeMemory(as: Byte.self, repeating: byte, count: 1)
        }
    }
    
    // ----------------------------------
    //  MARK: - Writable -
    //
    public func write<T>(at offset: Int, value: T) {
        self.assertWithinBounds(offset: offset, type: T.self)
        UnsafeMutableRawPointer(self.store).advanced(by: offset).initializeMemory(as: T.self, repeating: value, count: 1)
    }
    
    public func write(at offset: Int, data: Data) {
        let count = data.count
        self.assertWithinBounds(offset: offset, size: count)
        data.withUnsafeBytes { (bytes: UnsafePointer<Byte>) in
            _ = UnsafeMutableRawPointer(self.store).advanced(by: offset).initializeMemory(as: Byte.self, from: bytes, count: count)
        }
    }
    
    // ----------------------------------
    //  MARK: - Readable -
    //
    public func read<T>(_ type: T.Type, at offset: Int) -> T {
        self.assertWithinBounds(offset: offset, type: T.self)
        return self.store.advanced(by: offset).assumingMemoryBound(to: type).pointee
    }
    
    public func read(at offset: Int, size: Int) -> Data {
        self.assertWithinBounds(offset: offset, size: size)
        return Data(bytes: self.store.advanced(by: offset), count: size)
    }
    
    // ----------------------------------
    //  MARK: - Verify -
    //
    @inline(__always)
    private func assertWithinBounds<T>(offset: Int, type: T.Type) {
        self.assertWithinBounds(offset: offset, size: MemoryLayout<T>.stride)
    }
    
    @inline(__always)
    private func assertWithinBounds(offset: Int, size: Int) {
        precondition(size > 0, "Buffer access size cannot be negative - \(size).")
        precondition(offset + size <= self.size, "Buffer (\(self.size) bytes) access out-of-bounds [offset: \(offset), size: \(size)].")
    }
    
    // ----------------------------------
    //  MARK: - Visualize -
    //
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
