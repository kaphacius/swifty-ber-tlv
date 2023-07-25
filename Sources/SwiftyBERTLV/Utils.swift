//
//  Utils.swift
//  
//
//  Created by Yurii Zadoianchuk on 14/03/2022.
//

import Foundation

extension FixedWidthInteger {
    
    static var paddingByte: Self { 0x00 }
    
    public var hexString: String {
        let converted = String(self, radix: 16, uppercase: true)
        if converted.count % 2 == 0 {
            return converted
        } else {
            return "0".appending(converted)
        }
    }
    
    public var bytes: [UInt8] {
        guard self != .zero else {
            // If the value is zero - it can be represented as one byte with value zero
            return [0x00]
        }
        
        let totalBytes = self.bitWidth / UInt8.bitWidth
        let leadingZeroBytes: Int = (self.leadingZeroBitCount / UInt8.bitWidth)
        
        return stride(from: totalBytes - leadingZeroBytes - 1, through: 0, by: -1)
            .map { byteNumber in
                UInt8(truncatingIfNeeded: self >> (byteNumber * UInt8.bitWidth))
            }
    }
    
}

extension Array where Self.Element == UInt8 {
    
    public var hexString: String {
        map(\.hexString).joined()
    }
    
}

extension Array where Element == UInt8 {
    
    public init?(hexString: String) {
        let hexStringBytes = hexString
            .replacingOccurrences(of: " ", with: "")
            .split(by: 2)
            .map { UInt8($0, radix: 16) }
        
        let compactedHexStringBytes = hexStringBytes.compactMap { $0 }
        
        if hexStringBytes.count == compactedHexStringBytes.count {
            self = compactedHexStringBytes
        } else {
            return nil
        }
    }
    
}

extension Data {
    
    public init?(hexString: String) {
        if let bytes: [UInt8] = .init(hexString: hexString) {
            self = .init(bytes)
        } else {
            return nil
        }
    }
    
}

extension String {
    
    internal func split(by length: Int) -> [String] {
        var startIndex = self.startIndex
        var results = [String]()
        
        while startIndex < self.endIndex {
            let endIndex = self.index(startIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            results.append(String(self[startIndex..<endIndex]))
            startIndex = endIndex
        }
        
        return results
    }

}
