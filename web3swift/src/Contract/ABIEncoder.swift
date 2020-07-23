//
//  ABIEncoder.swift
//  web3swift
//
//  Created by Matt Marshall on 16/03/2018.
//  Copyright © 2018 Argent Labs Limited. All rights reserved.
//

import Foundation
import BigInt

public class ABIEncoder {
    public struct EncodedValue {
        let encoded: [UInt8]
        let isDynamic: Bool
        let staticLength: Int
        
        var hexString: String { String(hexFromBytes: encoded) }
    }
    
    static func encode(_ value: Data,
                       forType type: ABIRawType,
                       padded: Bool = true,
                       size: Int = 1) throws -> EncodedValue {
        return try encode(value.web3.hexString, forType: type, padded: padded, size: size)
    }
    
    static func encode(_ value: String,
                       forType type: ABIRawType,
                       padded: Bool = true,
                       size: Int = 1) throws -> EncodedValue {
        let encoded: [UInt8] = try encode(value, forType: type, padded: padded, size: size)

        let staticLength: Int
        if type.isDynamic {
            staticLength = 32
        } else {
            staticLength = 32 * size
        }
        
        return EncodedValue(encoded: encoded,
                            isDynamic: type.isDynamic,
                            staticLength: staticLength)
    }
    
    private static func encode(_ value: String,
                       forType type: ABIRawType,
                       padded: Bool = true,
                       size: Int = 1) throws -> [UInt8] {
        var encoded: [UInt8] = [UInt8]()
        
        switch type {
        case .FixedUInt(_):
            guard let int = value.web3.isNumeric ? BigUInt(value) : BigUInt(hex: value) else {
                throw ABIError.invalidValue
            }
            let bytes = int.web3.bytes // should be <= 32 bytes
            guard bytes.count <= 32 else {
                throw ABIError.invalidValue
            }
            if padded {
                encoded = [UInt8](repeating: 0x00, count: 32 - bytes.count) + bytes
            } else {
                encoded = bytes
            }
        case .FixedInt(_):
            guard let int = value.web3.isNumeric ? BigInt(value) : BigInt(hex: value) else {
                throw ABIError.invalidType
            }
            
            let bytes = int.web3.bytes // should be <= 32 bytes
            guard bytes.count <= 32 else {
                throw ABIError.invalidValue
            }
            
            if int < 0 {
                encoded = [UInt8](repeating: 0xff, count: 32 - bytes.count) + bytes
            } else {
                encoded = [UInt8](repeating: 0, count: 32 - bytes.count) + bytes
            }
            
            if !padded {
                encoded = bytes
            }
        case .FixedBool:
            encoded = try encode(value == "true" ? "1":"0", forType: ABIRawType.FixedUInt(8))
        case .FixedAddress:
            guard let bytes = value.web3.bytesFromHex else { throw ABIError.invalidValue } // Must be 20 bytes
            if padded  {
                encoded = [UInt8](repeating: 0x00, count: 32 - bytes.count) + bytes
            } else {
                encoded = bytes
            }
        case .DynamicString:
            let bytes = value.web3.bytes
            let len = try encode(String(bytes.count), forType: ABIRawType.FixedUInt(256)).encoded
            let pack = (bytes.count - (bytes.count % 32)) / 32 + 1
            encoded = len + bytes
            if padded {
                encoded += [UInt8](repeating: 0x00, count: pack * 32 - bytes.count)
            }
        case .DynamicBytes:
            // Bytes are hex encoded
            guard let bytes = value.web3.bytesFromHex else { throw ABIError.invalidValue }
            let len = try encode(String(bytes.count), forType: ABIRawType.FixedUInt(256)).encoded
            let pack: Int
            if bytes.count == 0 {
                pack = 0
            } else {
                pack = (bytes.count - (bytes.count % 32)) / 32 + 1
            }
            
            encoded = len + bytes
            if padded {
                encoded += [UInt8](repeating: 0x00, count: pack * 32 - bytes.count)
            }
        case .FixedBytes(_):
            // Bytes are hex encoded
            guard let bytes = value.web3.bytesFromHex else { throw ABIError.invalidValue }
            encoded = bytes
            if padded {
                encoded += [UInt8](repeating: 0x00, count: 32 - bytes.count)
            }
        case .DynamicArray(let type):
            let unitSize = type.size * 2
            let stringValue = value.web3.noHexPrefix
            let size = stringValue.count / unitSize

            let padUnits = type.isPaddedInDynamic
            var bytes = [UInt8]()
            for i in (0..<size) {
                let start =  stringValue.index(stringValue.startIndex, offsetBy: i * unitSize)
                let end = stringValue.index(start, offsetBy: unitSize)
                let unitValue = String(stringValue[start..<end])
                let unitBytes = try encode(unitValue, forType: type, padded: padUnits).encoded
                bytes.append(contentsOf: unitBytes)
            }
            let len = try encode(String(size), forType: ABIRawType.FixedUInt(256)).encoded
            
            let pack: Int
            if bytes.count == 0 {
                pack = 0
            } else {
                pack = (bytes.count - (bytes.count % 32)) / 32 + 1
            }
            
            encoded = len + bytes + [UInt8](repeating: 0x00, count: pack * 32 - bytes.count)
        case .FixedArray(_, _):
            throw ABIError.notCurrentlySupported
        }
    
        return encoded
    }
    
    static func signature(name: String, types: [ABIRawType]) throws -> [UInt8] {
        let typeNames = types.map { $0.rawValue }
        let signature = name + "(" + typeNames.joined(separator: ",") + ")"
        guard let data = signature.data(using: .utf8) else { throw ABIError.invalidSignature }
        return data.web3.keccak256.web3.bytes
    }
    
    static func methodId(name: String, types: [ABIRawType]) throws -> [UInt8] {
        let signature = try Self.signature(name: name, types: types)
        return Array(signature.prefix(4))
    }
}


