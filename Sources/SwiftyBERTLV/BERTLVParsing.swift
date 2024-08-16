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
            throw BERTLVError.failedToParseHexString
        }
        
        return try parse(bytes: bytes)
    }
    
    public static func parse(bytes: [UInt8]) throws -> [BERTLV] {
        var tags: [BERTLV] = []
        var bytes = bytes
        
        while bytes.count != 0 {
            if let first = bytes.first,
               first.isPaddingByte {
                // Padding byte
                // ISO 7816 Annex D.1: BER-TLV data object:
                // Before, between, or after TLV-coded data objects, '00' bytes without any meaning
                // may occur (for example, due to erased or modified TLV-coded data objects).
                try tags.append(.paddingByte(first))
                bytes = Array(bytes.dropFirst())
            } else {
                let (type, typeLength, isConstructed) = try type(from: bytes)
                let (length, lengthBytes) = try length(
                    from: Array(bytes.dropFirst(typeLength))
                )
                let lengthLength = lengthBytes.count
                let from: Int = typeLength + lengthLength
                let to: Int = from + length
                guard bytes.endIndex >= to else {
                    throw BERTLVError.valueTooShort
                }
                guard to >= from else {
                    throw BERTLVError.invalidTLV
                }
                let value: [UInt8] = Array(bytes[from..<to])
                let tag = try BERTLV(
                    tag: type,
                    lengthBytes: lengthBytes,
                    value: value,
                    isConstructed: isConstructed
                )
                tags.append(tag)
                bytes = Array(bytes.dropFirst(typeLength + lengthLength + length))
            }
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
            throw BERTLVError.missingType
        }
        
        var type: UInt64 = UInt64(first)
        let isConstructed = first.isConstructedTag
        var typeLength: Int = 1
        
        // Type long form
        if first.isLongFormTag {
            type = UInt64(first)
            for byte in bytes.dropFirst() {
                type <<= 8
                type |= UInt64(byte)
                typeLength += 1
                // Type continues
                // If bit 8 is set to 1 - type continues
                if byte.isLongFormLength {
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
        lengthBytes: [UInt8]
    ) {
        guard let first = bytes.first else {
            throw BERTLVError.missingLength
        }
        
        let lengthLength: Int
        var length: Int
        var lengthBytes: [UInt8] = [first]
        
        // Length is in long form if bit 8 is set to 1
        if first.isLongFormLength {
            length = 0
            
            // Length length
            // Length of length is stored in bits 7-1
            // Adding 1 is for the byte containing length length
            lengthLength = Int(first & 0x0F) + 1
            
            guard lengthLength <= bytes.dropFirst().endIndex else {
                throw BERTLVError.wrongLongLength
            }
            
            for byte in bytes.dropFirst()[1..<lengthLength] {
                length <<= 8
                length |= Int(byte)
                lengthBytes.append(byte)
            }
        } else {
            length = Int(first)
            lengthLength = 1
        }
        
        return (length, lengthBytes)
    }
    
    internal static func lengthBytes(for length: Int) -> [UInt8] {
        if length <= (UInt8.max ^ 0x80) {
            // If length can fit in 7 bits - short form length is used
            return [UInt8(length)]
        } else {
            // First byte is encoded as a long form indicator.
            // First bit is set to 1, indicating the lenth long form.
            // The bits 2-8 indicate the number of bytes that encode the length.
            
            // Find the number of bytes required.
            // Take leadingZeroBitCount, find number of unused full bytes.
            let uLength = UInt64(length)
            let unusedFullBytes = uLength.leadingZeroBitCount / UInt8.bitWidth
            // UInt64 is represented by 8 bytes.
            let bytesRequired = 0x08 - unusedFullBytes
            // Long form is indicated in the by setting bit 1 to 1.
            // Rest of the bits indicate the number of bytes that comprise the actual length.
            let first: UInt8 = 0x80 | UInt8(bytesRequired)
            
            var bytes: [UInt8] = []
            for i in 0..<bytesRequired {
                // Shift length right required amount of times
                let shifted = uLength >> (8 * i)
                // Get 8 highest bits and extract them
                let extracted = UInt8(shifted & 0xFF)
                bytes.insert(extracted, at: 0)
            }
            
            return [first] + bytes
        }
    }
    
}
