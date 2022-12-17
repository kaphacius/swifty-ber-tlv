//
//  Utils.swift
//  
//
//  Created by Yurii Zadoianchuk on 14/03/2022.
//

import Foundation

extension UnsignedInteger {

    public var hexString: String {
        String(self, radix: 16, uppercase: true)
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
