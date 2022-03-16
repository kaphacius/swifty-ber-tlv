import XCTest
@testable import SwiftyBERTLV

final class SwiftyBERTLVTests: XCTestCase {
    
    func testParseEmptyBytes() throws {
        let data: [UInt8] = []
        
        let sut = try BERTLV.parse(bytes: data)
        
        XCTAssertTrue(sut.isEmpty)
    }
    
    func testParsePrimitiveTag() throws {
        let data: Bytes = [0xC1, 0x01, 0x01]
        
        let sut = try BERTLV.parse(bytes: data)
        
        XCTAssertEqual(sut.count, 1)
        
        let sutTag = try XCTUnwrap(sut.first)
        
        XCTAssertEqual(sutTag.tag, 0xC1)
        XCTAssertEqual(sutTag.isConstructed, false)
        XCTAssertEqual(sutTag.value.count, 1)
        XCTAssertEqual(sutTag.value, [0x01])
    }
    
    func testParseNoLength() throws {
        let data: Bytes = [0xC1]
        
        XCTAssertThrowsError(
            try BERTLV.parse(bytes: data),
            "",
            { error in
                guard case BERTLV.Error.missingLength = error else {
                    XCTFail()
                    return
                }
            }
        )
    }
    
    func testParseNoType() throws {
        
        let data: [UInt8] = []
        
        XCTAssertThrowsError(
            try BERTLV.type(from: data),
            "",
            { error in
                guard case BERTLV.Error.missingType = error else {
                    XCTFail()
                    return
                }
            }
        )
    }
    
    func testParseZeroLengthPrimitiveTag() throws {
        let data: Bytes = [0xC1, 0x00]
        
        let sut = try BERTLV.parse(bytes: data)
        
        XCTAssertEqual(sut.count, 1)
        
        let sutTag = try XCTUnwrap(sut.first)
        
        XCTAssertEqual(sutTag.tag, 0xC1)
        XCTAssertEqual(sutTag.isConstructed, false)
        XCTAssertEqual(sutTag.value.count, 0)
    }
    
    func testParseConstructedTag() throws {
        let data: Bytes = [0xE1, 0x03, 0x5A, 0x01, 0xFF]
        
        let sut = try BERTLV.parse(bytes: data)
        
        XCTAssertEqual(sut.count, 1)
        
        let sutTag = try XCTUnwrap(sut.first)
        
        XCTAssertEqual(sutTag.tag, 0xE1)
        XCTAssertEqual(sutTag.isConstructed, true)
        XCTAssertEqual(sutTag.value.count, 3)
        
        let subTag = try XCTUnwrap(BERTLV.parse(bytes: sutTag.value).first)
        
        XCTAssertEqual(subTag.tag, 0x5A)
        XCTAssertEqual(subTag.isConstructed, false)
        XCTAssertEqual(subTag.value.count, 1)
        XCTAssertEqual(subTag.value, [0xFF])
    }
    
    func testValueTooShort() throws {
        let data: Bytes = [0xE1, 0x03, 0xFF, 0xFF]
        
        XCTAssertThrowsError(
            try BERTLV.parse(bytes: data),
            "",
            { error in
                guard case BERTLV.Error.valueTooShort = error else {
                    XCTFail()
                    return
                }
            }
        )
    }
    
    func testParseLongLengthTag() throws {
        let data: Bytes = [
            0x4F,
            0x84, 0x00, 0x00, 0x00, 0x03,
            0xAA, 0xBB, 0xCC
        ]
        
        let sut = try BERTLV.parse(bytes: data)
        
        XCTAssertEqual(sut.count, 1)
        
        let sutTag = try XCTUnwrap(sut.first)
        
        XCTAssertEqual(sutTag.tag, 0x4F)
        XCTAssertEqual(sutTag.isConstructed, false)
        XCTAssertEqual(sutTag.value.count, 3)
    }
    
    func testParseLongLengthZeroLengthTag() throws {
        let data: Bytes = [
            0x4F,
            0x84, 0x00, 0x00, 0x00, 0x00
        ]
        
        let sut = try BERTLV.parse(bytes: data)
        
        XCTAssertEqual(sut.count, 1)
        
        let sutTag = try XCTUnwrap(sut.first)
        
        XCTAssertEqual(sutTag.tag, 0x4F)
        XCTAssertEqual(sutTag.isConstructed, false)
        XCTAssertEqual(sutTag.value.count, 0)
    }
    
    func testParseLongFormTypeTag() throws {
        let data: Bytes = [
            0xDF, 0xDF, 0xDF, 0x33,
            0x81, 0x00
        ]
        
        let sut = try BERTLV.parse(bytes: data)
        
        XCTAssertEqual(sut.count, 1)
        
        let sutTag = try XCTUnwrap(sut.first)
        
        XCTAssertEqual(sutTag.tag, 0xDFDFDF33)
        XCTAssertEqual(sutTag.isConstructed, false)
        XCTAssertEqual(sutTag.value.count, 0)
    }
    
    func testParseConstructedSubtags() throws {
        let data: Bytes = [0xE1, 0x03, 0x5A, 0x01, 0xFF]
        
        let sut = try BERTLV.parse(bytes: data)
        
        XCTAssertEqual(sut.count, 1)
        
        let sutTag = try XCTUnwrap(sut.first)
        
        XCTAssertEqual(sutTag.tag, 0xE1)
        XCTAssertEqual(sutTag.isConstructed, true)
        XCTAssertEqual(sutTag.value.count, 3)
        
        let subTag = try XCTUnwrap(sutTag.subTags.first)
        
        XCTAssertEqual(subTag.tag, 0x5A)
        XCTAssertEqual(subTag.isConstructed, false)
        XCTAssertEqual(subTag.value.count, 1)
        XCTAssertEqual(subTag.value, [0xFF])
    }
    
    func testNoParsePrimitiveSubtags() throws {
        let data: Bytes = [0x50, 0x03, 0x5A, 0x01, 0xFF]
        
        let sut = try BERTLV.parse(bytes: data)
        
        XCTAssertEqual(sut.count, 1)
        
        let sutTag = try XCTUnwrap(sut.first)
        
        XCTAssertEqual(sutTag.tag, 0x50)
        XCTAssertFalse(sutTag.isConstructed)
        XCTAssertEqual(sutTag.value.count, 3)
        XCTAssertTrue(sutTag.subTags.isEmpty)
    }
    
}
