//
//  Utils.swift
//  
//
//  Created by Yurii Zadoianchuk on 14/03/2022.
//

import Foundation

extension UInt8 {
    
    public var hexString: String {
        String(format: "%02X", self)
    }
    
}

extension UInt64 {
    
    public var hexString: String {
        String(format: "%02X", self)
    }
    
}
