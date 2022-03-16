//
//  Utils.swift
//
//
//  Created by Yurii Zadoianchuk on 14/03/2022.
//

import Foundation

extension BERTLV {
    
    public enum Error: LocalizedError {
        
        case missingLength
        case missingType
        case wrongLongLength
        case typeLengthMismatch
        case valueTooShort
        case parsingError
        
    }

}

public struct BERTLV: CustomStringConvertible, Equatable {
    
    internal init(tag: UInt64, value: [UInt8], isConstructed: Bool) throws {
        self.tag = tag
        self.value = value
        self.isConstructed = isConstructed
        self.subTags = isConstructed ? try BERTLV.parse(bytes: value) : []
    }
    
    let tag: UInt64
    let value: [UInt8]
    
    let subTags: [BERTLV]
    let isConstructed: Bool
    
    public var description: String {
        "0x\(tag.hexString) -> 0x\(value.map(\.hexString))"
    }
    
    public static func parse(bytes: [UInt8]) throws -> [BERTLV] {
        var tags: [BERTLV] = []
        var bytes = bytes
        
        while bytes.count != 0 {
            let (type, typeLength, isConstructed) = try type(from: bytes)
            let (length, lengthLength) = try length(from: Array(bytes.dropFirst(typeLength)))
            let from: Int = typeLength + lengthLength
            let to: Int = from + Int(length)
            guard bytes.endIndex >= to else {
                throw Error.valueTooShort
            }
            let value: [UInt8] = Array(bytes[from..<to])
            let tag = try BERTLV(tag: type, value: value, isConstructed: isConstructed)
            tags.append(tag)
            bytes = Array(bytes.dropFirst(typeLength + lengthLength + Int(length)))
        }
        
        return tags
    }
    
    public static func type(
        from bytes: [UInt8]
    ) throws -> (
        type: UInt64,
        typeLength: Int,
        isConstructed: Bool
    ) {
        guard let first = bytes.first else {
            throw Error.missingType
        }
        
        var type: UInt64 = UInt64(first)
        let isConstructed = type & 0x20 == 0x20
        var typeLength: Int = 1
        
        // Type long form
        // Long form if bits 1-5 are set to 1
        if first & 0x1F == 0x1F {
            type = UInt64(first)
            for byte in bytes.dropFirst() {
                type <<= 8
                type |= UInt64(byte)
                typeLength += 1
                // Type continues
                // If bit 8 is set to 1 - type continues
                if byte & 0x80 == 0x80 {
                    continue
                } else {
                    break
                }
            }
        }
        
        return (type, typeLength, isConstructed)
    }
    
    public static func length(
        from bytes: [UInt8]
    ) throws -> (
        length: UInt64,
        lengthLength: Int
    ) {
        guard let first = bytes.first else {
            throw Error.missingLength
        }
        
        var length: UInt64
        let lengthLength: Int
        
        // Length long form
        if first & 0x80 == 0x80 {
            length = 0
            
            // Length length
            // Length of length is stored in second nibble
            // 1 is for the byte containing length length
            lengthLength = Int(first & 0x0F) + 1
            
            guard lengthLength <= bytes.dropFirst().endIndex else {
                throw Error.wrongLongLength
            }
            
            for byte in bytes.dropFirst()[1..<lengthLength] {
                length <<= 8
                length |= UInt64(byte)
            }
        } else {
            length = UInt64(first)
            lengthLength = 1
        }
        
        return (length, lengthLength)
    }
    
}
