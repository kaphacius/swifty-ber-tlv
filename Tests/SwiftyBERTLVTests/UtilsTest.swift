//
//  UtilsTest.swift
//  
//
//  Created by Yurii Zadoianchuk on 17/12/2022.
//

import XCTest
@testable import SwiftyBERTLV

final class UtilsTest: XCTestCase {

    func testUIntHexStringRepresentation() {
        
        let uint8: UInt8 = 0xAB
        XCTAssertEqual("AB", uint8.hexString)
        
        let uint16: UInt16 = 0xABCD
        XCTAssertEqual("ABCD", uint16.hexString)

        let uint32: UInt32 = 0xABCDEF01
        XCTAssertEqual("ABCDEF01", uint32.hexString)

        let uint64: UInt64 = 0xABCDEF0123456789
        XCTAssertEqual("ABCDEF0123456789", uint64.hexString)

        let smallUInt8: UInt8 = 0x0A
        XCTAssertEqual("0A", smallUInt8.hexString)
        
        let smallUInt64: UInt64 = 0x00000000000000BB
        XCTAssertEqual("BB", smallUInt64.hexString)
        
        let otherUInt64: UInt64 = 0xAA000000000000BB
        XCTAssertEqual("AA000000000000BB", otherUInt64.hexString)
        
    }
    
    func testUInt8ArrayHexStringRepresentation() {
        
        let sut: [UInt8] = [0xAB, 0xCD, 0xEF]
        XCTAssertEqual("ABCDEF", sut.hexString)
        
    }
    
    func testStringSplit() {

        let input = "ABCDEF0123456789"
        
        let sut = input.split(by: 2)
        
        XCTAssertEqual(
            ["AB", "CD", "EF", "01", "23", "45", "67", "89"],
            sut
        )
        
    }
    
    func testArrayInitWithHexString() throws {
        
        let input = "ABCDEF0123456789"
        
        let sut: [UInt8] = try XCTUnwrap(.init(hexString: input))
        
        XCTAssertEqual(
            sut,
            [0xAB, 0xCD, 0xEF, 0x01, 0x23, 0x45, 0x67, 0x89]
        )
        
    }
    
    func testArrayInitWithInvalidHexString() throws {
        
        let input = "GBCDEF0123456789"
        
        XCTAssertNil([UInt8](hexString: input))
        
    }
    
    func testDataInitWithHexString() throws {
        
        let input = "ABCDEF0123456789"
        
        let sut: Data = try XCTUnwrap(.init(hexString: input))
        
        XCTAssertEqual(
            sut,
            Data([0xAB, 0xCD, 0xEF, 0x01, 0x23, 0x45, 0x67, 0x89])
        )
        
    }
    
    func testDataInitWithInvalidHexString() throws {
        
        let input = "GBCDEF0123456789"
        
        XCTAssertNil(Data(hexString: input))
        
    }
    
    func testIntegerToBytes() throws {
        let int1: UInt8 = 0xAA
        XCTAssertEqual(int1.bytes, [int1])
        
        let int2: UInt16 = 0xAABB
        XCTAssertEqual(int2.bytes, [0xAA, 0xBB])
        
        let int3: UInt32 = 0x00AA00BB
        XCTAssertEqual(int3.bytes, [0xAA, 0x00, 0xBB])
        
        let int4: UInt64 = 0x00000000000000FF
        XCTAssertEqual(int4.bytes, [0xFF])
    }
    
    func testIsLongFormTag() {
        let sut1: UInt8 = 0xDF
        XCTAssertTrue(sut1.isLongFormTag)
        
        let sut2: UInt8 = 0x1F
        XCTAssertTrue(sut2.isLongFormTag)
        
        let sut3: UInt8 = 0x1E
        XCTAssertFalse(sut3.isLongFormTag)
        
        let sut4: UInt8 = 0xF7
        XCTAssertFalse(sut4.isLongFormTag)
    }
    
    func testIsConstructedTag() {
        let sut1: UInt8 = 0x2F
        XCTAssertTrue(sut1.isConstructedTag)
        
        let sut2: UInt8 = 0xE0
        XCTAssertTrue(sut2.isConstructedTag)
        
        let sut3: UInt8 = 0xDF
        XCTAssertFalse(sut3.isConstructedTag)
        
        let sut4: UInt8 = 0x10
        XCTAssertFalse(sut4.isConstructedTag)
    }
    
    func testIsLongFormLength() {
        let sut1: UInt8 = 0x8F
        XCTAssertTrue(sut1.isLongFormLength)
        
        let sut2: UInt8 = 0xF0
        XCTAssertTrue(sut2.isLongFormLength)
        
        let sut3: UInt8 = 0x70
        XCTAssertFalse(sut3.isLongFormLength)
        
        let sut4: UInt8 = 0x0F
        XCTAssertFalse(sut4.isLongFormLength)
    }
    
    func testIsPaddingByte() {
        let sut1: UInt8 = 0xFF
        XCTAssertTrue(sut1.isPaddingByte)
        
        let sut2: UInt8 = 0x00
        XCTAssertTrue(sut2.isPaddingByte)
        
        let sut3: UInt8 = 0xAA
        XCTAssertFalse(sut3.isPaddingByte)
        
        let sut4: UInt8 = 0xBB
        XCTAssertFalse(sut4.isPaddingByte)
    }
    

}
