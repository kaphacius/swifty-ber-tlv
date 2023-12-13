//
//  Utils.swift
//
//
//  Created by Yurii Zadoianchuk on 14/03/2022.
//

import Foundation
    
public enum BERTLVError: Error {
    
    case failedToParseHexString
    case missingLength
    case missingType
    case wrongLongLength
    case valueTooShort
    case wrongPaddingByte(UInt8)
    
}

/// A structure represending data encoded according to ISO 7816 Annex D.1: BER-TLV data object
public struct BERTLV: CustomStringConvertible, Equatable {
    
    /// Category of the tag
    public enum Category: Equatable {
        
        /// Plain tag
        case plain
        
        /// Constructed tag, where value is a list of TLV
        case constructed(subtags: [BERTLV])
    }
    
    /// Tag
    public let tag: UInt64
    
    /// Value
    public let value: [UInt8]
    
    /// Category
    public let category: Category
    
    /// Original bytes encoding length
    public let lengthBytes: [UInt8]
    
    /// BERTLV as bytes
    public var bytes: [UInt8] {
        tag.bytes + lengthBytes + value
    }
    
    /// Human-readable description
    public var description: String {
        "0x\(tag.hexString) -> 0x\(value.map(\.hexString))"
    }
    
    internal static func paddingByte(_ value: UInt8) throws -> BERTLV {
        guard value.isPaddingByte else {
            throw BERTLVError.wrongPaddingByte(value)
        }
        
        return try .init(
            tag: UInt64(value),
            lengthBytes: [],
            value: [],
            isConstructed: false
        )
    }
    
    internal init(
        tag: UInt64,
        lengthBytes: [UInt8],
        value: [UInt8],
        isConstructed: Bool
    ) throws {
        self.tag = tag
        self.lengthBytes = lengthBytes
        self.value = value
        if isConstructed {
            self.category = .constructed(subtags: try BERTLV.parse(bytes: value))
        } else {
            self.category = .plain
        }
    }
    
    /// Padding byte initializer
    private init() {
        self.tag = UInt64(UInt8.paddingByte)
        self.lengthBytes = []
        self.value = []
        self.category = .plain
    }
    
}
