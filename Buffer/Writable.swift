//
//  Writable.swift
//  Buffer
//
//  Created by Dima Bart on 2018-04-26.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

public protocol Writable {
    func write<T>(at offset: Int, value: T)
    func write(at offset: Int, data: Data)
}

extension Writable {
    
    public func write<T>(at offset: Int = 0, value: T) {
        self.write(at: offset, value: value)
    }
    
    public func write(at offset: Int = 0, data: Data) {
        self.write(at: offset, data: data)
    }
}
