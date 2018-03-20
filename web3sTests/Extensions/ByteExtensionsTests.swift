//
//  ByteExtensionsTests.swift
//  web3sTests
//
//  Created by Matt Marshall on 14/03/2018.
//  Copyright © 2018 Argent Labs Limited. All rights reserved.
//

import XCTest
import BigInt
@testable import web3swift

class ByteExtensionsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testBytesFromBigInt() {
        XCTAssert(BigInt(3251).bytes == [12, 179])
        XCTAssert(BigInt(434350411044).bytes == [101, 33, 77, 77, 36])
        XCTAssert(BigInt(-404).bytes == [254, 108])
    }
    
    func testBigIntFromTwosComplement() {
        let bytes: [UInt8] = [3, 0, 24, 124, 109]
        let data = Data(bytes)
        let bint = BigInt(twosComplement: data)
        
        XCTAssert(bint == 12886506605)
    }
    
    func testBytesFromData() {
        let bytes: [UInt8] = [255, 0, 123, 64]
        let data = Data(bytes: bytes)
        XCTAssert(data.bytes == bytes)
    }
    
    func testStrippingZeroesFromBytes() {
        let bytes: [UInt8] = [0, 0, 0, 24, 124, 109]
        let data = Data(bytes)
        
        let stripped = data.strippingZeroesFromBytes
        XCTAssert([24, 124, 109] == stripped.bytes)
    }
    
    func testStrippingZeroesFromBytesNone() {
        let bytes: [UInt8] = [3, 0, 24, 124, 109]
        let data = Data(bytes)
        
        let stripped = data.strippingZeroesFromBytes
        XCTAssert([3, 0, 24, 124, 109] == stripped.bytes)
    }
    
    func testBytesFromString() {
        let str = "hello world"
        XCTAssert(str.bytes == [104, 101, 108, 108, 111, 32, 119, 111, 114, 108, 100])
    }
    
    func testBytesFromHex() {
        let hex = "0x68656c6c6f20776f726c64"
        XCTAssert(hex.bytesFromHex! == [104, 101, 108, 108, 111, 32, 119, 111, 114, 108, 100])
    }
    
    func testHexFromBytes() {
        let bytes: [UInt8] = [104, 101, 108, 108, 111, 32, 119, 111, 114, 108, 100]
        let str = String(hexFromBytes: bytes)
        XCTAssert(str == "0x68656c6c6f20776f726c64")
    }
    
}

