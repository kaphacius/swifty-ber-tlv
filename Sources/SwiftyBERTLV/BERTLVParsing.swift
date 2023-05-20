//
//  BERTLVParsing.swift
//  
//
//  Created by Yurii Zadoianchuk on 20/05/2023.
//

import Foundation

extension BERTLV {
    
    public static func parse(hexString: String) throws -> [BERTLV] {
        guard let bytes = [UInt8](hexString: hexString) else {
            throw Error.failedToParseHexString
        }
        
        return try parse(bytes: bytes)
    }
    
    public static func parse(bytes: [UInt8]) throws -> [BERTLV] {
        var tags: [BERTLV] = []
        var bytes = bytes
        
        while bytes.count != 0 {
            let (type, typeLength, isConstructed) = try type(from: bytes)
            let (length, lengthLength) = try length(
                from: Array(bytes.dropFirst(typeLength))
            )
            let from: Int = typeLength + lengthLength
            let to: Int = from + length
            guard bytes.endIndex >= to else {
                throw Error.valueTooShort
            }
            let value: [UInt8] = Array(bytes[from..<to])
            let tag = try BERTLV(
                tag: type,
                value: value,
                isConstructed: isConstructed
            )
            tags.append(tag)
            bytes = Array(bytes.dropFirst(typeLength + lengthLength + length))
        }
        
        return tags
    }
    
    internal static func type(
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
    
    internal static func length(
        from bytes: [UInt8]
    ) throws -> (
        length: Int,
        lengthLength: Int
    ) {
        guard let first = bytes.first else {
            throw Error.missingLength
        }
        
        var length: Int
        let lengthLength: Int
        
        // Length long form
        if first & 0x80 == 0x80 {
            length = 0
            
            // Length length
            // Length of length is stored in bits 7-1
            // Adding 1 is for the byte containing length length
            lengthLength = Int(first & 0x0F) + 1
            
            guard lengthLength <= bytes.dropFirst().endIndex else {
                throw Error.wrongLongLength
            }
            
            for byte in bytes.dropFirst()[1..<lengthLength] {
                length <<= 8
                length |= Int(byte)
            }
        } else {
            length = Int(first)
            lengthLength = 1
        }
        
        return (length, lengthLength)
    }
    
}
