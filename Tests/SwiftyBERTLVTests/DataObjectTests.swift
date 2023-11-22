//
//  DataObjectTests.swift
//
//
//  Created by Yurii Zadoianchuk on 22/11/2023.
//

import XCTest
@testable import SwiftyBERTLV

final class DataObjectTests: XCTestCase {
    
    func testParseEmptyBytes() throws {
        let data: [UInt8] = []
        
        let sut = try DataObject.parse(bytes: data)
        
        XCTAssertTrue(sut.isEmpty)
    }
    
    func testParseSingleDOL() throws {
        let data: [UInt8] = [0xC1, 0x05]
        
        let sut = try DataObject.parse(bytes: data)
        
        XCTAssertEqual(sut.count, 1)
        
        let sutDataObject = try XCTUnwrap(sut.first)
        
        XCTAssertEqual(sutDataObject.tag, 0xC1)
        XCTAssertEqual(sutDataObject.length, 0x05)
    }
    
    func testParseLongLengthDataObject() throws {
        let data: [UInt8] = [
            0x4F,
            0x84, 0x00, 0x00, 0x00, 0x03
        ]
        
        let sut = try DataObject.parse(bytes: data)
        
        XCTAssertEqual(sut.count, 1)
        
        let sutTag = try XCTUnwrap(sut.first)
        
        XCTAssertEqual(sutTag.tag, 0x4F)
        XCTAssertEqual(sutTag.length, 3)
    }
    
}
