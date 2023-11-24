//
//  File.swift
//  
//
//  Created by Yurii Zadoianchuk on 21/11/2023.
//

import Foundation

/// List of terminal/reader-related data objects (tags and lengths)
public typealias DOL = [DataObject]

public struct DataObject {
    
    /// Tag of the Data Object
    public let tag: UInt64
    
    /// Expected of the Data Object
    public let length: Int
    
    /// Parses DOL from a given hex string.
    /// - Parameter hexString: hexadecimal string to be parsed.
    /// - Returns: An array of parsed ``DataObject``.
    public static func parse(hexString: String) throws -> [DataObject] {
        guard let bytes = [UInt8](hexString: hexString) else {
            throw BERTLVError.failedToParseHexString
        }
        
        return try parse(bytes: bytes)
    }
    
    /// Parses DOL from a given hex string.
    /// - Parameter bytes: Byte array to be parsed.
    /// - Returns: An array of parsed ``DataObject``.
    public static func parse(bytes: [UInt8]) throws -> [DataObject] {
        var dataObjects: [DataObject] = []
        var bytes = bytes
        
        while bytes.count != 0 {
            let (type, typeLength, _) = try BERTLV.type(from: bytes)
            let (length, lengthBytes) = try BERTLV.length(
                from: Array(bytes.dropFirst(typeLength))
            )
            let lengthLength = lengthBytes.count
            bytes = Array(bytes.dropFirst(typeLength + lengthLength))
            
            dataObjects.append(.init(tag: type, length: length))
        }
        
        return dataObjects
    }
    
}
