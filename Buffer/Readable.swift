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
    func read(at offset: Int, size: Int) -> Data
}

extension Readable {
    public func read<T>(at offset: Int = 0) -> T {
        return self.read(T.self, at: offset)
    }
    
    public func read<T>(_ type: T.Type, at offset: Int = 0) -> T {
        return self.read(type, at: offset)
    }
    
    public func read(at offset: Int = 0, size: Int) -> Data {
        return self.read(at: offset, size: size)
    }
    
    public func read(at offset: Int = 0, size: Int) -> String? {
        let data = self.read(at: offset, size: size)
        return String(data: data, encoding: .utf8)
    }
}
