//
//  Utils.swift
//  
//
//  Created by Yurii Zadoianchuk on 14/03/2022.
//

import Foundation

internal typealias Byte = UInt8
internal typealias Bytes = [Byte]
internal let bitsInByte = Byte.bitWidth

extension UInt8 {
    
    internal var hexString: String {
        String(format: "%02X", self)
    }
    
}

extension UInt64 {
    
    internal var hexString: String {
        String(format: "%02X", self)
    }
    
    internal var byteLength: Int {
        8 - (self.leadingZeroBitCount / 8)
    }
    
}
