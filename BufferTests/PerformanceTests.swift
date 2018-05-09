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
    
    private let testCapacity  = 1_000_000
    private let arrayCapacity = 1_000
    
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
        let data = Data(bytes: Array<Byte>(repeating: 0xFE, count: self.arrayCapacity))
        
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
        var buffer = Buffer(size: self.testCapacity)
        
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
                buffer.write(at: i, value: 0xFE as UInt8)
            }
        }
    }
    
    func testWriteDataUsingOffset() {
        let buffer = Buffer(size: self.testCapacity)
        let data   = Data([0xFE])
        
        measure {
            for i in 0..<self.testCapacity {
                buffer.write(at: i, data: data)
            }
        }
    }
    
    // ----------------------------------
    //  MARK: - Reading -
    //
    func testReadTypeUsingSubscript() {
        var buffer = Buffer(size: self.testCapacity)
        
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
        var buffer = Buffer(size: self.testCapacity)
        
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
        var buffer = Buffer(size: self.testCapacity)
        
        for i in 0..<self.testCapacity {
            buffer[i] = 0xFE
        }
        
        measure {
            for i in 0..<self.testCapacity {
                _ = buffer.read(at: i, size: 1)
            }
        }
    }
}
