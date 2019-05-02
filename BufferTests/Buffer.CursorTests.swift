//
//  Buffer.CursorTests.swift
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
@testable import Buffer

class Buffer_CursorTests: XCTestCase {
    
    // MARK: - Init -

    func testWritableCursorInit() {
        let buffer = Buffer([0xAB, 0xCD, 0xEF, 0xED])
        let cursor = Buffer.WritableCursor(to: buffer, offset: 1, size: 2)
        
        XCTAssertEqual(cursor.size,   2)
        XCTAssertEqual(cursor.offset, 1)
    }
    
    func testReadableCursorInit() {
        let buffer = Buffer([0xAB, 0xCD, 0xEF, 0xED])
        let cursor = Buffer.ReadableCursor(to: buffer, offset: 1, size: 2)
        
        XCTAssertEqual(cursor.size,   2)
        XCTAssertEqual(cursor.offset, 1)
    }
    
    // MARK: - WritableCursor -

    func testWriteTypesUsingBlock() {
        let buffer = Buffer(size: 7)
        
        let v1: UInt8  = 0x34
        let v2: UInt16 = 0x4545
        let v3: UInt32 = 0x56565656
        
        buffer.write {
            $0.write(value: v1)
            $0.write(value: v2)
            $0.write(value: v3)
        }
        
        XCTAssertEqual(buffer.read(UInt8.self,  at: 0), 0x34)
        XCTAssertEqual(buffer.read(UInt16.self, at: 1), 0x4545)
        XCTAssertEqual(buffer.read(UInt32.self, at: 3), 0x56565656)
    }
    
    func testWriteDataUsingBlock() {
        let buffer = Buffer(size: 7)
        let chunk1 = Data([0x34])
        let chunk2 = Data([0x45, 0x45])
        let chunk3 = Data([0x56, 0x56, 0x56, 0x56])
        
        buffer.write {
            $0.write(data: chunk1)
            $0.write(data: chunk2)
            $0.write(data: chunk3)
        }
        
        XCTAssertEqual(buffer[0], 0x34)
        XCTAssertEqual(buffer[1], 0x45)
        XCTAssertEqual(buffer[2], 0x45)
        XCTAssertEqual(buffer[3], 0x56)
        XCTAssertEqual(buffer[4], 0x56)
        XCTAssertEqual(buffer[5], 0x56)
        XCTAssertEqual(buffer[6], 0x56)
    }
    
    // MARK: - ReadableCursor -

    func testReadTypesUsingBlock() {
        let buffer = Buffer([0x34, 0x45, 0x45, 0x56, 0x56, 0x56, 0x56])
        
        buffer.read {
            XCTAssertEqual($0.read(UInt8.self),  0x34)
            XCTAssertEqual($0.read(UInt16.self), 0x4545)
            XCTAssertEqual($0.read(UInt32.self), 0x56565656)
        }
    }
    
    func testReadDataUsingBlock() {
        let buffer = Buffer([0x34, 0x45, 0x45, 0x56, 0x56, 0x56, 0x56])
        
        buffer.read {
            XCTAssertEqual($0.read(dataWithSize: 1), Data([0x34]))
            XCTAssertEqual($0.read(dataWithSize: 2), Data([0x45, 0x45]))
            XCTAssertEqual($0.read(dataWithSize: 4), Data([0x56, 0x56, 0x56, 0x56]))
        }
    }
}
