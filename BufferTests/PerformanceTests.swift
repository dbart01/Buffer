//
//  PerformanceTests.swift
//  BufferTests
//
//  Created by Dima Bart on 2018-05-03.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import XCTest
import Buffer

class PerformanceTests: XCTestCase {
    
    private let testCapacity  = 100_000
    private let arrayCapacity = 100
    
    // ----------------------------------
    //  MARK: - Init -
    //
    func testInitWithCapacity() {
        measure {
            for _ in 0..<self.testCapacity {
                _ = Buffer(size: 100)
            }
        }
    }
    
    func testInitWithBuffer() {
        let buffer = Buffer(size: 100, zero: true)
        
        measure {
            for _ in 0..<self.testCapacity {
                _ = Buffer(buffer)
            }
        }
    }
    
    func testInitWithData() {
        let data = Data(Array<Byte>(repeating: 0xFE, count: self.arrayCapacity))
        
        measure {
            for _ in 0..<self.testCapacity {
                _ = Buffer(data)
            }
        }
    }
    
    func testInitWithArray() {
        let collection = Array<Byte>(repeating: 0xFE, count: self.arrayCapacity)
        
        measure {
            for _ in 0..<self.testCapacity {
                _ = Buffer(collection)
            }
        }
    }
    
    func testInitWithCollection() {
        let collection = Array<Byte>(repeating: 0xFE, count: self.arrayCapacity)[0..<self.arrayCapacity]
        
        measure {
            for _ in 0..<self.testCapacity {
                _ = Buffer(collection)
            }
        }
    }

    // ----------------------------------
    //  MARK: - Writing -
    //
    func testWriteTypeUsingSubscript() {
        let buffer = Buffer(size: self.testCapacity)
        
        measure {
            for i in 0..<self.testCapacity {
                buffer[i] = 0xFE
            }
        }
    }
    
    func testWriteTypeUsingOffset() {
        let buffer = Buffer(size: self.testCapacity)
        
        measure {
            for i in 0..<self.testCapacity {
                buffer.write(value: 0xFE as UInt8, at: i)
            }
        }
    }
    
    func testWriteDataUsingOffset() {
        let buffer = Buffer(size: self.testCapacity)
        let data   = Data([0xFE])
        
        measure {
            for i in 0..<self.testCapacity {
                buffer.write(data: data, at: i)
            }
        }
    }
    
    // ----------------------------------
    //  MARK: - Reading -
    //
    func testReadTypeUsingSubscript() {
        let buffer = Buffer(size: self.testCapacity)
        
        for i in 0..<self.testCapacity {
            buffer[i] = 0xFE
        }
        
        measure {
            for i in 0..<self.testCapacity {
                _ = buffer[i]
            }
        }
    }
    
    func testReadTypeUsingOffset() {
        let buffer = Buffer(size: self.testCapacity)
        
        for i in 0..<self.testCapacity {
            buffer[i] = 0xFE
        }
        
        measure {
            for i in 0..<self.testCapacity {
                _ = buffer.read(Byte.self, at: i)
            }
        }
    }
    
    func testReadDataUsingOffset() {
        let buffer = Buffer(size: self.testCapacity)
        
        for i in 0..<self.testCapacity {
            buffer[i] = 0xFE
        }
        
        measure {
            for i in 0..<self.testCapacity {
                _ = buffer.read(dataWithSize: 1, at: i)
            }
        }
    }
    
    func testReadStringUsingOffset() {
        let buffer = Buffer(size: self.testCapacity)
        let string = "something important"
        let count  = string.count
        
        buffer.write {
            for _ in 0..<self.testCapacity / count {
                $0.write(string: string)
            }
        }
        
        measure {
            var i = 0
            while i < self.testCapacity {
                _ = buffer.read(stringWithSize: 19)
                i += count
            }
        }
    }
    
    func testReadUnsafeStringUsingOffset() {
        let buffer = Buffer(size: self.testCapacity)
        let string = "something important"
        let count  = string.count
        
        buffer.write {
            for _ in 0..<self.testCapacity / count {
                $0.write(string: string)
            }
        }
        
        measure {
            var i = 0
            while i < self.testCapacity {
                _ = buffer.read(unsafeStringWithSize: 19)
                i += count
            }
        }
    }
}
