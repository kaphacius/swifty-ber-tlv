//
//  Utils.swift
//
//
//  Created by Yurii Zadoianchuk on 14/03/2022.
//

import Foundation

extension BERTLV {
    
    public enum Error: LocalizedError {
        
        case failedToParseHexString
        case missingLength
        case missingType
        case wrongLongLength
        case valueTooShort
        
    }

}

public struct BERTLV: CustomStringConvertible, Equatable {
    
    internal init(
        tag: UInt64,
        value: [UInt8],
        isConstructed: Bool
    ) throws {
        self.tag = tag
        self.value = value
        self.isConstructed = isConstructed
        self.subTags = isConstructed ? try BERTLV.parse(bytes: value) : []
    }
    
    /// Padding byte initializer
    private init() {
        self.tag = .paddingByte
        self.value = []
        self.isConstructed = false
        self.subTags = []
    }
    
    internal static let paddingByte: BERTLV = .init()
    
    public let tag: UInt64
    public let value: [UInt8]
    
    public let subTags: [BERTLV]
    public let isConstructed: Bool
    
    public var bytes: [UInt8] {
        tag.bytes + lengthBytes + value
    }
    
    private var lengthBytes: [UInt8] {
        if value.count <= Int8.max {
            // Short form, firts up to 127 length
            return [UInt8(value.count)]
        } else {
            // Long form:
            // B1b8 is set to 1 to indicate long form.
            // B1b7-B1b1 contain the number of bytes indicating length.
            // B2 and following contain the actual length of the value.
            let realLengthBytes = UInt64(value.count).bytes
            let indicator: UInt8 = 0x80 | UInt8(realLengthBytes.count)
            return [indicator] + realLengthBytes
        }
    }
    
    public var description: String {
        "0x\(tag.hexString) -> 0x\(value.map(\.hexString))"
    }
    
}
