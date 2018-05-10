//
//  BufferTests.swift
//  BufferTests
//
//  Created by Dima Bart on 2018-04-25.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import XCTest
import Buffer

class BufferTests: XCTestCase {
    
    // ----------------------------------
    //  MARK: - Init -
    //
    func testInitEmpty() {
        let buffer = Buffer(size: 64, zero: true)
        
        XCTAssertNotNil(buffer)
        XCTAssertEqual(buffer.size,       64)
        XCTAssertEqual(buffer.startIndex, 0)
        XCTAssertEqual(buffer.endIndex,   64)
        
        let data = buffer.read(dataWithSize: 64, at: 0)
        XCTAssertEqual(data, Data(count: 64))
    }
    
    func testInitFromBuffer() {
        let data    = Data(bytes: [0xAB, 0xCD, 0xEF, 0xED])
        let buffer1 = Buffer(data)
        let buffer2 = Buffer(buffer1)
        
        XCTAssertEqual(buffer1, buffer2)
        
        buffer2.write(value: 0xFEFEFEFE as UInt32, at: 0)
        
        XCTAssertNotEqual(buffer1, buffer2)
    }
    
    func testInitFromPointer() {
        let capacity = 4
        let pointer  = UnsafeMutablePointer<Byte>.allocate(capacity: capacity)
        pointer.advanced(by: 0).pointee = 0xAB
        pointer.advanced(by: 1).pointee = 0xCD
        pointer.advanced(by: 2).pointee = 0xEF
        pointer.advanced(by: 3).pointee = 0xED
        
        let buffer = Buffer(pointer, count: capacity)
        
        XCTAssertNotNil(buffer)
        XCTAssertEqual(buffer.size,       capacity)
        XCTAssertEqual(buffer.startIndex, 0)
        XCTAssertEqual(buffer.endIndex,   capacity)
        
        let data = buffer.read(dataWithSize: capacity)
        XCTAssertEqual(data, Data(bytes: [0xAB, 0xCD, 0xEF, 0xED]))
    }
    
    func testInitFromArray() {
        let bytes: [Byte] = [0xAB, 0xCD, 0xEF, 0xED]
        let buffer = Buffer(bytes)
        
        XCTAssertNotNil(buffer)
        XCTAssertEqual(buffer.size,       4)
        XCTAssertEqual(buffer.startIndex, 0)
        XCTAssertEqual(buffer.endIndex,   4)
        
        let data = buffer.read(dataWithSize: 4)
        XCTAssertEqual(data, Data(bytes: bytes))
    }
    
    func testInitFromData() {
        let bytes: [Byte] = [0xAB, 0xCD, 0xEF, 0xED]
        let input  = Data(bytes: bytes)
        let buffer = Buffer(input)
        
        XCTAssertNotNil(buffer)
        XCTAssertEqual(buffer.size,       4)
        XCTAssertEqual(buffer.startIndex, 0)
        XCTAssertEqual(buffer.endIndex,   4)
        
        let data = buffer.read(dataWithSize: 4)
        XCTAssertEqual(data, Data(bytes: bytes))
    }
    
    func testInitFromCollection() {
        let bytes: ArraySlice<UInt8> = [0xAB, 0xCD, 0xEF, 0xED][0..<4]
        let buffer = Buffer(bytes)
        
        XCTAssertNotNil(buffer)
        XCTAssertEqual(buffer.size,       4)
        XCTAssertEqual(buffer.startIndex, 0)
        XCTAssertEqual(buffer.endIndex,   4)
        
        let data = buffer.read(dataWithSize: 4)
        XCTAssertEqual(data, Data(bytes: bytes))
    }
    
    // ----------------------------------
    //  MARK: - Equality -
    //
    func testEqual() {
        let data    = Data(bytes: [0xAB, 0xCD, 0xEF, 0xED])
        let buffer1 = Buffer(data)
        let buffer2 = Buffer(data)
        
        XCTAssertEqual(buffer1, buffer2)
    }
    
    func testNotEqual() {
        let buffer1 = Buffer([0xAB, 0xCD, 0xEF, 0xED])
        let buffer2 = Buffer([0xAB, 0xCC, 0xEF, 0xEE])
        
        XCTAssertNotEqual(buffer1, buffer2)
        
        let buffer3 = Buffer([0xAB])
        
        XCTAssertNotEqual(buffer2, buffer3)
    }
    
    // ----------------------------------
    //  MARK: - Collection -
    //
    func testIteration() {
        let bytes  = [0xAB, 0xCD, 0xEF, 0xED] as [Byte]
        let buffer = Buffer(bytes)
        
        XCTAssertEqual(buffer.count, 4)
        for (index, byte) in buffer.enumerated() {
            XCTAssertEqual(byte, bytes[index])
        }
    }
    
    func testRandomAccess() {
        let bytes  = [0xAB, 0xCD, 0xEF, 0xED] as [Byte]
        let buffer = Buffer(bytes)
        
        XCTAssertEqual(buffer[0], 0xAB)
        XCTAssertEqual(buffer[1], 0xCD)
        XCTAssertEqual(buffer[2], 0xEF)
        XCTAssertEqual(buffer[3], 0xED)
    }
    
    func testRandomUpdate() {
        let bytes  = [0xAB, 0xCD, 0xEF, 0xED] as [Byte]
        let buffer = Buffer(bytes)
        
        buffer[0] = 0xDE
        buffer[1] = 0xAD
        buffer[2] = 0xBE
        buffer[3] = 0xEF
        
        let data = buffer.read(dataWithSize: 4)
        XCTAssertEqual(data, Data(bytes: [0xDE, 0xAD, 0xBE, 0xEF]))
    }
    
    // ----------------------------------
    //  MARK: - Write -
    //
    func testWriteType() {
        let buffer = Buffer([0xAB, 0xCD, 0xEF, 0xED])
        
        buffer.write(value: 0xDDCCBBAA as UInt32)
        
        let data = buffer.read(dataWithSize: 4)
        XCTAssertEqual(data, Data(bytes: [0xAA, 0xBB, 0xCC, 0xDD]))
    }
    
    func testWriteData() {
        let buffer = Buffer([0xAB, 0xCD, 0xEF, 0xED])
        
        let data = Data(bytes: [0xAA, 0xBB, 0xCC, 0xDD])
        buffer.write(data: data)
        
        let readData = buffer.read(dataWithSize: 4)
        XCTAssertEqual(readData, Data(bytes: [0xAA, 0xBB, 0xCC, 0xDD]))
    }
    
    func testWriteString() {
        let buffer = Buffer(size: 19)
        let string = "something important"
        
        buffer.write(string: string)
        
        let readData = buffer.read(dataWithSize: 19)
        XCTAssertEqual(readData, Data(bytes: [
            0x73, 0x6f, 0x6d, 0x65, 0x74, 0x68, 0x69, 0x6e, 0x67,
            0x20,
            0x69, 0x6d, 0x70, 0x6f, 0x72, 0x74, 0x61, 0x6e, 0x74,
        ]))
    }
    
    func testWriteStringSequence() {
        let buffer = Buffer(size: 38)
        let string = "something important"
        
        buffer.write {
            $0.write(string: string)
            $0.write(string: string)
        }
        
        let readData = buffer.read(dataWithSize: 38)
        XCTAssertEqual(readData, Data(bytes: [
            0x73, 0x6f, 0x6d, 0x65, 0x74, 0x68, 0x69, 0x6e, 0x67,
            0x20,
            0x69, 0x6d, 0x70, 0x6f, 0x72, 0x74, 0x61, 0x6e, 0x74,
            
            0x73, 0x6f, 0x6d, 0x65, 0x74, 0x68, 0x69, 0x6e, 0x67,
            0x20,
            0x69, 0x6d, 0x70, 0x6f, 0x72, 0x74, 0x61, 0x6e, 0x74,
        ]))
    }
    
    // ----------------------------------
    //  MARK: - Inflating -
    //
    func testWriteInflateType() {
        let buffer = Buffer([0xAA, 0xBB])
        
        buffer.write(value: 0xCC as UInt8, at: 2)
        
        XCTAssertEqual(buffer.size, 3)
        XCTAssertGreaterThanOrEqual(buffer.capacity, buffer.size)
        
        buffer.write(value: 0xDD as UInt8, at: 3)
        
        XCTAssertEqual(buffer.size, 4)
        XCTAssertGreaterThanOrEqual(buffer.capacity, buffer.size)
        
        XCTAssertEqual(buffer.read(dataWithSize: 4), Data(bytes: [0xAA, 0xBB, 0xCC, 0xDD]))
    }
    
    func testWriteInflateEmptyData() {
        let buffer = Buffer(size: 0)
        let data   = Data(bytes: [0xAA, 0xBB, 0xCC, 0xDD])
        
        buffer.write(data: data)
        
        XCTAssertEqual(buffer.size, 4)
        XCTAssertGreaterThanOrEqual(buffer.capacity, buffer.size)
        
        XCTAssertEqual(buffer.read(dataWithSize: 4), data)
    }
    
    func testWriteInflateAppendingData() {
        let buffer = Buffer([0xAA, 0xBB, 0xCC, 0xDD])
        let data   = Data(bytes: [0x01, 0x02, 0x03, 0x04])
        
        XCTAssertEqual(buffer.size,     4)
        XCTAssertEqual(buffer.capacity, 4)
        
        buffer.write(data: data, at: 4)
        
        XCTAssertEqual(buffer.size, 8)
        XCTAssertGreaterThanOrEqual(buffer.capacity, buffer.size)
        
        XCTAssertEqual(buffer.read(dataWithSize: 8), Data(bytes: [
            0xAA, 0xBB, 0xCC, 0xDD,
            0x01, 0x02, 0x03, 0x04,
        ]))
    }
    
    func testWriteInflateOverlappingData() {
        let buffer = Buffer([0xAA, 0xBB, 0xCC, 0xDD])
        let data   = Data(bytes: [0x01, 0x02, 0x03, 0x04])
        
        XCTAssertEqual(buffer.size,     4)
        XCTAssertEqual(buffer.capacity, 4)
        
        buffer.write(data: data, at: 2)
        
        XCTAssertEqual(buffer.size, 6)
        XCTAssertGreaterThanOrEqual(buffer.capacity, buffer.size)
        
        XCTAssertEqual(buffer.read(dataWithSize: 6), Data(bytes: [
            0xAA, 0xBB, 0x01, 0x02, 0x03, 0x04,
        ]))
    }
    
    // ----------------------------------
    //  MARK: - Read -
    //
    func testReadType() {
        let buffer = Buffer(size: 32)
        
        buffer.write(value: 1 as UInt8, at: 0)
        buffer.write(value: 2 as UInt8, at: 8)
        buffer.write(value: 3 as UInt8, at: 16)
        buffer.write(value: 4 as UInt8, at: 24)
        
        XCTAssertEqual(buffer.read(at: 0),  1 as UInt8)
        XCTAssertEqual(buffer.read(at: 8),  2 as UInt8)
        XCTAssertEqual(buffer.read(at: 16), 3 as UInt8)
        XCTAssertEqual(buffer.read(at: 24), 4 as UInt8)
        
        XCTAssertEqual(buffer.read(UInt8.self, at: 0),  1)
        XCTAssertEqual(buffer.read(UInt8.self, at: 8),  2)
        XCTAssertEqual(buffer.read(UInt8.self, at: 16), 3)
        XCTAssertEqual(buffer.read(UInt8.self, at: 24), 4)
    }
    
    func testReadData() {
        let buffer = Buffer([0xAB, 0xCD, 0xEF, 0xED])
        
        XCTAssertEqual(buffer.read(dataWithSize: 1, at: 0), Data(bytes: [0xAB]))
        XCTAssertEqual(buffer.read(dataWithSize: 1, at: 1), Data(bytes: [0xCD]))
        XCTAssertEqual(buffer.read(dataWithSize: 1, at: 2), Data(bytes: [0xEF]))
        XCTAssertEqual(buffer.read(dataWithSize: 1, at: 3), Data(bytes: [0xED]))
    }
    
    func testReadString() {
        let buffer = Buffer([
            0x73, 0x6f, 0x6d, 0x65, 0x74, 0x68, 0x69, 0x6e, 0x67,
            // 'something'
            0x20,
            // ' '
            0x69, 0x6d, 0x70, 0x6f, 0x72, 0x74, 0x61, 0x6e, 0x74,
            // 'important'
        ])
        
        let string = buffer.read(stringWithSize: 19)
        XCTAssertEqual(string, "something important")
    }
    
    func testReadUnsafeString() {
        let buffer = Buffer([
            0x73, 0x6f, 0x6d, 0x65, 0x74, 0x68, 0x69, 0x6e, 0x67,
            // 'something'
            0x20,
            // ' '
            0x69, 0x6d, 0x70, 0x6f, 0x72, 0x74, 0x61, 0x6e, 0x74,
            // 'important'
            ])
        
        let string = buffer.read(unsafeStringWithSize: 19)
        XCTAssertEqual(string, "something important")
    }
    
    // ----------------------------------
    //  MARK: - Description -
    //
    func testLongDescription() {
        let buffer = Buffer(size: 64)
        
        for i in 0..<64 {
            buffer[i] = Byte(i)
        }
        
        let description = buffer.description
        let expected    = """
        ------- Buffer --------
        00 01 02 03 04 05 06 07
        08 09 0A 0B 0C 0D 0E 0F
        10 11 12 13 14 15 16 17
        18 19 1A 1B 1C 1D 1E 1F
        20 21 22 23 24 25 26 27
        28 29 2A 2B 2C 2D 2E 2F
        30 31 32 33 34 35 36 37
        38 39 3A 3B 3C 3D 3E 3F

        """
        
        XCTAssertEqual(description, expected)
    }
    
    func testShortDescription() {
        let buffer      = Buffer([0x00, 0x01, 0x02, 0x03])
        let description = buffer.description
        let expected    = """
        ------- Buffer --------
        00 01 02 03

        """
        
        XCTAssertEqual(description, expected)
    }
}
