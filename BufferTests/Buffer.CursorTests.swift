//
//  Buffer.CursorTests.swift
//  BufferTests
//
//  Created by Dima Bart on 2018-04-27.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import XCTest
@testable import Buffer

class Buffer_CursorTests: XCTestCase {
    
    // ----------------------------------
    //  MARK: - Init -
    //
    func testInit() {
        let buffer = Buffer([0xAB, 0xCD, 0xEF, 0xED])
        let cursor = Buffer.Cursor(to: buffer, offset: 1, size: 2)
        
        XCTAssertEqual(cursor.size,   2)
        XCTAssertEqual(cursor.offset, 1)
    }
    
    // ----------------------------------
    //  MARK: - WritingCursor -
    //
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
    
    // ----------------------------------
    //  MARK: - ReadingCursor -
    //
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
