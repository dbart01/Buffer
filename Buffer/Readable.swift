//
//  Readable.swift
//  Buffer
//
//  Created by Dima Bart on 2018-04-26.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

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
