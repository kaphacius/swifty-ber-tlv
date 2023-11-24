import XCTest
@testable import SwiftyBERTLV

final class SwiftyBERTLVTests: XCTestCase {
    
    func testParseEmptyBytes() throws {
        let data: [UInt8] = []
        
        let sut = try BERTLV.parse(bytes: data)
        
        XCTAssertTrue(sut.isEmpty)
    }
    
    func testParsePrimitiveTag() throws {
        let data: [UInt8] = [0xC1, 0x01, 0x01]
        
        let sut = try BERTLV.parse(bytes: data)
        
        XCTAssertEqual(sut.count, 1)
        
        let sutTag = try XCTUnwrap(sut.first)
        
        XCTAssertEqual(sutTag.tag, 0xC1)
        XCTAssertEqual(sutTag.value.count, 1)
        XCTAssertEqual(sutTag.value, [0x01])
        guard case .plain = sutTag.category else {
            XCTFail()
            return
        }
    }
    
    func testParseNoLength() throws {
        let data: [UInt8] = [0xC1]
        
        XCTAssertThrowsError(
            try BERTLV.parse(bytes: data),
            "",
            { error in
                guard case BERTLVError.missingLength = error else {
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
                guard case BERTLVError.missingType = error else {
                    XCTFail()
                    return
                }
            }
        )
    }
    
    func testParseZeroLengthPrimitiveTag() throws {
        let data: [UInt8] = [0xC1, 0x00]
        
        let sut = try BERTLV.parse(bytes: data)
        
        XCTAssertEqual(sut.count, 1)
        
        let sutTag = try XCTUnwrap(sut.first)
        
        XCTAssertEqual(sutTag.tag, 0xC1)
        XCTAssertEqual(sutTag.value.count, 0)
        guard case .plain = sutTag.category else {
            XCTFail()
            return
        }
    }
    
    func testParseConstructedTag() throws {
        let data: [UInt8] = [0xE1, 0x03, 0x5A, 0x01, 0xFF]
        
        let sut = try BERTLV.parse(bytes: data)
        
        XCTAssertEqual(sut.count, 1)
        
        let sutTag = try XCTUnwrap(sut.first)
        
        XCTAssertEqual(sutTag.tag, 0xE1)
        guard case let .constructed(subtags) = sutTag.category else {
            XCTFail()
            return
        }
        XCTAssertEqual(sutTag.value.count, 3)
        
        let subTag = try XCTUnwrap(subtags.first)
        
        XCTAssertEqual(subTag.tag, 0x5A)
        XCTAssertEqual(subTag.value.count, 1)
        XCTAssertEqual(subTag.value, [0xFF])
        guard case .plain = subTag.category else {
            XCTFail()
            return
        }
    }
    
    func testValueTooShort() throws {
        let data: [UInt8] = [0xE1, 0x03, 0xFF, 0xFF]
        
        XCTAssertThrowsError(
            try BERTLV.parse(bytes: data),
            "",
            { error in
                guard case BERTLVError.valueTooShort = error else {
                    XCTFail()
                    return
                }
            }
        )
    }
    
    func testParseLongLengthTag() throws {
        let data: [UInt8] = [
            0x4F,
            0x84, 0x00, 0x00, 0x00, 0x03,
            0xAA, 0xBB, 0xCC
        ]
        
        let sut = try BERTLV.parse(bytes: data)
        
        XCTAssertEqual(sut.count, 1)
        
        let sutTag = try XCTUnwrap(sut.first)
        
        XCTAssertEqual(sutTag.tag, 0x4F)
        XCTAssertEqual(sutTag.value.count, 3)
        guard case .plain = sutTag.category else {
            XCTFail()
            return
        }
    }
    
    func testParseLongLengthZeroLengthTag() throws {
        let data: [UInt8] = [
            0x4F,
            0x84, 0x00, 0x00, 0x00, 0x00
        ]
        
        let sut = try BERTLV.parse(bytes: data)
        
        XCTAssertEqual(sut.count, 1)
        
        let sutTag = try XCTUnwrap(sut.first)
        
        XCTAssertEqual(sutTag.tag, 0x4F)
        XCTAssertEqual(sutTag.value.count, 0)
        guard case .plain = sutTag.category else {
            XCTFail()
            return
        }
    }
    
    func testParseLongFormTypeTag() throws {
        let data: [UInt8] = [
            0xDF, 0xDF, 0xDF, 0x33,
            0x81, 0x00
        ]
        
        let sut = try BERTLV.parse(bytes: data)
        
        XCTAssertEqual(sut.count, 1)
        
        let sutTag = try XCTUnwrap(sut.first)
        
        XCTAssertEqual(sutTag.tag, 0xDFDFDF33)
        XCTAssertEqual(sutTag.value.count, 0)
        guard case .plain = sutTag.category else {
            XCTFail()
            return
        }
    }
    
    func testParseConstructedSubtags() throws {
        let data: [UInt8] = [0xE1, 0x03, 0x5A, 0x01, 0xFF]
        
        let sut = try BERTLV.parse(bytes: data)
        
        XCTAssertEqual(sut.count, 1)
        
        let sutTag = try XCTUnwrap(sut.first)
        
        XCTAssertEqual(sutTag.tag, 0xE1)
        guard case let .constructed(subtags) = sutTag.category else {
            XCTFail()
            return
        }
        XCTAssertEqual(sutTag.value.count, 3)
        
        let subTag = try XCTUnwrap(subtags.first)
        
        XCTAssertEqual(subTag.tag, 0x5A)
        XCTAssertEqual(subTag.value.count, 1)
        XCTAssertEqual(subTag.value, [0xFF])
        guard case .plain = subTag.category else {
            XCTFail()
            return
        }
    }
    
    func testNoParsePrimitiveSubtags() throws {
        let data: [UInt8] = [0x50, 0x03, 0x5A, 0x01, 0xFF]
        
        let sut = try BERTLV.parse(bytes: data)
        
        XCTAssertEqual(sut.count, 1)
        
        let sutTag = try XCTUnwrap(sut.first)
        
        XCTAssertEqual(sutTag.tag, 0x50)
        guard case .plain = sutTag.category else {
            XCTFail()
            return
        }
        XCTAssertEqual(sutTag.value.count, 3)
    }
    
    func testShortBytesRepresentation() throws {
        let data: [UInt8] = [0xC1, 0x01, 0x01]
        
        let tag = try BERTLV.parse(bytes: data)[0]
        
        let sut = tag.bytes
        XCTAssertEqual(sut, data)
    }
    
    func testLongTagTypeBytesRepresentation() throws {
        let data: [UInt8] = [0xDF, 0xBF, 0x05, 0x01, 0x01]
        
        let tag = try BERTLV.parse(bytes: data)[0]
        
        let sut = tag.bytes
        XCTAssertEqual(sut, data)
    }
    
    func testLongValueBytesRepresentation() throws {
        let data: [UInt8] = [0xC1, 0x81, 0x80] + Array(repeating: 0xFF, count: 128)
        
        let tag = try BERTLV.parse(bytes: data)[0]
        
        let sut = tag.bytes
        XCTAssertEqual(sut, data)
    }
    
    func testVeryLongValueBytesRepresentation() throws {
        let data: [UInt8] = [0xC1, 0x83, 0x07, 0xA1, 0x20] + Array(repeating: 0xFF, count: 500000)
        
        let tag = try BERTLV.parse(bytes: data)[0]
        
        let sut = tag.bytes
        XCTAssertEqual(sut, data)
    }
    
    func testParseZeroPadding() throws {
        let data: [UInt8] = [
            0x00,
            0xDF, 0xBF, 0x05, 0x01, 0x01,
            0x00,
            0x00,
            0xC1, 0x01, 0x00,
            0x00
        ]
        
        let suts = try BERTLV.parse(bytes: data)
        XCTAssertEqual(suts.count, 6)
        XCTAssertEqual(data, suts.flatMap(\.bytes))
    }
    
    func testParseFFPadding() throws {
        let data: [UInt8] = [
            0xFF,
            0xDF, 0xBF, 0x05, 0x01, 0x01,
            0xFF,
            0xFF,
            0xC1, 0x01, 0x00,
            0xFF
        ]
        
        let suts = try BERTLV.parse(bytes: data)
        XCTAssertEqual(suts.count, 6)
        XCTAssertEqual(data, suts.flatMap(\.bytes))
    }
    
    func testParseMixedPadding() throws {
        let data: [UInt8] = [
            0xFF,
            0xDF, 0xBF, 0x05, 0x01, 0x01,
            0xFF,
            0x00,
            0xC1, 0x01, 0x00,
            0x00,
            0xFF
        ]
        
        let suts = try BERTLV.parse(bytes: data)
        XCTAssertEqual(suts.count, 7)
        XCTAssertEqual(data, suts.flatMap(\.bytes))
    }
    
    func testLengthBytesShortForm() throws {
        let data: [UInt8] = [
            0xDF, 0xBF, 0x05, 0x01, 0x01,
        ]
        
        let parsed = try BERTLV.parse(bytes: data)
        let sut = try XCTUnwrap(parsed.first)
        XCTAssertEqual(parsed.count, 1)
        XCTAssertEqual(data, sut.bytes)
    }
    
    func testLengthBytesLongForm() throws {
        let data: [UInt8] = [
            0x4F,
            0x84, 0x00, 0x00, 0x00, 0x03,
            0xAA, 0xBB, 0xCC
        ]
        
        let parsed = try BERTLV.parse(bytes: data)
        let sut = try XCTUnwrap(parsed.first)
        XCTAssertEqual(parsed.count, 1)
        XCTAssertEqual(data, sut.bytes)
    }
    
}
