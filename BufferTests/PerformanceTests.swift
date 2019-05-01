//
//  PerformanceTests.swift
//  BufferTests
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

import XCTest
import Buffer

class PerformanceTests: XCTestCase {
    
    private let testCapacity  = 100_000
    private let arrayCapacity = 100
    
    // MARK: - Init -

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

    // MARK: - Writing -

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
    
    // MARK: - Reading -

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
