//
//  MessagePackTests.swift
//  BufferTests
//
//  Created by Dima Bart on 2018-05-10.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import XCTest
import Buffer

class MessagePackTests: XCTestCase {

    func test() {
        
        
    }
}

typealias Byte = UInt8

protocol Packable {
    func pack(in buffer: Buffer.WritingCursor)
}

struct Packet {
    var size:    Int
    var pointer: UnsafeMutablePointer<Byte>
    
    init(size: Int, pointer: UnsafeMutablePointer<Byte>) {
        self.size    = size
        self.pointer = pointer
    }
}

enum PackableType: Packable {
    case positivefixint // 0xxxxxxx    0x00 - 0x7f
    case negativefixint // 111xxxxx    0xe0 - 0xff
    case `nil`          // 11000000    0xc0
    case `false`        // 11000010    0xc2
    case `true`         // 11000011    0xc3
    case bin8(UInt8)    // 11000100    0xc4
    case bin16(UInt16)  // 11000101    0xc5
    case bin32(UInt32)  // 11000110    0xc6
    case ext8           // 11000111    0xc7
    case ext16          // 11001000    0xc8
    case ext32          // 11001001    0xc9
    case float32        // 11001010    0xca
    case float64        // 11001011    0xcb
    case uint8          // 11001100    0xcc
    case uint16         // 11001101    0xcd
    case uint32         // 11001110    0xce
    case uint64         // 11001111    0xcf
    case int8           // 11010000    0xd0
    case int16          // 11010001    0xd1
    case int32          // 11010010    0xd2
    case int64          // 11010011    0xd3
    case fixext1        // 11010100    0xd4
    case fixext2        // 11010101    0xd5
    case fixext4        // 11010110    0xd6
    case fixext8        // 11010111    0xd7
    case fixext16       // 11011000    0xd8
    case fixstr         // 101xxxxx    0xa0 - 0xbf
    case str8           // 11011001    0xd9
    case str16          // 11011010    0xda
    case str32          // 11011011    0xdb
    case fixarray       // 1001xxxx    0x90 - 0x9f
    case array16        // 11011100    0xdc
    case array32        // 11011101    0xdd
    case fixmap(UInt8)  // 1000xxxx    0x80 - 0x8f
    case map16(UInt16)  // 11011110    0xde
    case map32(UInt32)  // 11011111    0xdf
    
    init(_ dictionary: [String: Packable]) {
        let count = dictionary.count
        switch count {
        case 0...16:
            self = .fixmap(UInt8(count))
        case 16...0xFFFF:
            self = .map16(UInt16(count))
        case 0xFFFF...0xFFFFFFFF:
            self = .map32(UInt32(count))
        default:
            fatalError()
        }
    }
    
    func pack(in buffer: Buffer.WritingCursor) {
        switch self {
        case .positivefixint: break
        case .negativefixint: break
        case .nil: break
        case .false: break
        case .true: break
        case .bin8(let count): break
        case .bin16(let count): break
        case .bin32(let count): break
        case .ext8: break
        case .ext16: break
        case .ext32: break
        case .float32: break
        case .float64: break
        case .uint8: break
        case .uint16: break
        case .uint32: break
        case .uint64: break
        case .int8: break
        case .int16: break
        case .int32: break
        case .int64: break
        case .fixext1: break
        case .fixext2: break
        case .fixext4: break
        case .fixext8: break
        case .fixext16: break
        case .fixstr: break
        case .str8: break
        case .str16: break
        case .str32: break
        case .fixarray: break
        case .array16: break
        case .array32: break
        case .fixmap(let count):
            buffer.write(value: count)
        case .map16(let count):
            buffer.write(value: count)
        case .map32(let count):
            buffer.write(value: count)
        }
    }
}

enum Container {}
extension Container {
    struct Dictionary {
        static func packing(_ dictionary: [String: Packable]) {
            
        }
    }
}

extension Dictionary: Packable where Key == String, Value: Packable {
    
    func header() -> PackableType {
        
    }
    
    func pack(in buffer: Buffer.WritingCursor) {
        let type = PackableType(self)
        type.pack(in: buffer)
        
        
    }
}

//struct Map {
//
//    let header: MapHeader
//    let buffer: Data
//
//    init(dictionary: [String: Any]) {
//        self.header = MapHeader(rawValue: dictionary.count)!
//        dictionary.flatMap { key, value in
//
//        }
//    }
//}
//
//enum MapHeader: RawRepresentable {
//
//    typealias RawValue = Int
//
//    case map8(UInt8)
//    case map16(UInt16)
//    case map32(UInt32)
//
//    var rawValue: Int {
//        switch self {
//        case let .map8(count):  return Int(count)
//        case let .map16(count): return Int(count)
//        case let .map32(count): return Int(count)
//        }
//    }
//
//    init?(rawValue: RawValue) {
//        switch rawValue {
//        case 0...16:
//            self = .map8(UInt8(rawValue))
//        case 16...0xFFFF:
//            self = .map16(UInt16(rawValue))
//        case 0xFFFF...0xFFFFFFFF:
//            self = .map32(UInt32(rawValue))
//        default:
//            fatalError()
//        }
//    }
//}
