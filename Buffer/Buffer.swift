//
//  Buffer.swift
//  Buffer
//
//  Created by Dima Bart on 2018-04-25.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

public typealias Byte = UInt8

public struct Buffer: Collection, Equatable, CustomDebugStringConvertible, CustomStringConvertible {
    
    public typealias Element = Byte
    
    public let size: Int
    
    public let startIndex: Int
    public let endIndex:   Int
    
    private let store: UnsafeMutablePointer<Byte>
    
    // ----------------------------------
    //  MARK: - Allocation -
    //
    private static func allocate(size: Int) -> UnsafeMutablePointer<Byte> {
        return UnsafeMutablePointer<Byte>.allocate(capacity: size)
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
            self.store.initialize(repeating: 0x00, count: size)
        }
    }
    
    public init(_ buffer: Buffer) {
        self.size  = buffer.size
        self.store = Buffer.allocate(size: size)
        
        self.startIndex = 0
        self.endIndex   = buffer.size
        
        self.store.initialize(from: buffer.store, count: buffer.size)
    }
    
    public init<T>(_ collection: T) where T: Collection, T.Element == Element {
        let count  = collection.count
        self.size  = count
        self.store = Buffer.allocate(size: size)
        
        self.startIndex = 0
        self.endIndex   = count
        
        for (index, byte) in collection.enumerated() {
            self.store.advanced(by: index).initialize(to: byte)
        }
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
        return self.visualize(memory: self.store, stride: self.size)
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
            return self.store[index]
        }
        set(byte) {
            self.store.advanced(by: index).initialize(to: byte)
        }
    }
    
    // ----------------------------------
    //  MARK: - Write -
    //
    public mutating func write<T>(at offset: Int, value: T) {
        self.assertWithinBounds(offset: offset, type: T.self)
        self.store.advanced(by: offset).withMemoryRebound(to: T.self, capacity: 1) {
            $0.initialize(to: value)
        }
    }
    
    public mutating func write(at offset: Int, data: Data) {
        let count = data.count
        self.assertWithinBounds(offset: offset, size: count)
        data.withUnsafeBytes { (bytes: UnsafePointer<Byte>) in
            self.store.advanced(by: offset).initialize(from: bytes, count: count)
        }
    }
    
    // ----------------------------------
    //  MARK: - Read -
    //
    public func read<T>(at offset: Int) -> T {
        return self.read(T.self, at: offset)
    }
    
    public func read<T>(_ type: T.Type, at offset: Int) -> T {
        self.assertWithinBounds(offset: offset, type: T.self)
        return self.store.advanced(by: offset).withMemoryRebound(to: type, capacity: 1) { $0.pointee }
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
    private func visualize(memory: UnsafeMutablePointer<Byte>, stride: Int, group: Int = 8) -> String {
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
