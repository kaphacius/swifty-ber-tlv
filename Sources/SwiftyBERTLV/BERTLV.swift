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
        lengthBytes: [UInt8],
        value: [UInt8],
        isConstructed: Bool
    ) throws {
        self.tag = tag
        self.lengthBytes = lengthBytes
        self.value = value
        self.isConstructed = isConstructed
        self.subTags = isConstructed ? try BERTLV.parse(bytes: value) : []
    }
    
    /// Padding byte initializer
    private init() {
        self.tag = .paddingByte
        self.lengthBytes = []
        self.value = []
        self.isConstructed = false
        self.subTags = []
    }
    
    internal static let paddingByte: BERTLV = .init()
    
    public let tag: UInt64
    public let value: [UInt8]
    
    public let subTags: [BERTLV]
    public let isConstructed: Bool
    public let lengthBytes: [UInt8]
    
    public var bytes: [UInt8] {
        tag.bytes + lengthBytes + value
    }
    
    public var description: String {
        "0x\(tag.hexString) -> 0x\(value.map(\.hexString))"
    }
    
}
