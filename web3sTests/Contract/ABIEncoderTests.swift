//
//  ABIEncoderTests.swift
//  web3sTests
//
//  Created by Matt Marshall on 13/03/2018.
//  Copyright © 2018 Argent Labs Limited. All rights reserved.
//

import XCTest
import BigInt
@testable import web3swift

class ABIEncoderTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testEncodePositiveInt32() {
        var encoded: [UInt8]
        do {
            encoded = try ABIEncoder.encodeArgument(type: "int32", arg: "10000")
            XCTAssert(String(hexFromBytes: encoded) == "0x0000000000000000000000000000000000000000000000000000000000002710")
            encoded = try ABIEncoder.encodeArgument(type: "int32", arg: "25639")
            XCTAssert(String(hexFromBytes: encoded) == "0x0000000000000000000000000000000000000000000000000000000000006427")
        } catch let error {
            print(error.localizedDescription)    
            XCTFail()
        }
    }
 
    func testEncodeNegativeInt32() {
        
        do {
            let encoded = try ABIEncoder.encodeArgument(type: "int32", arg: "-25896")
            XCTAssert(String(hexFromBytes: encoded) == "0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff9ad8")
        } catch let error {
            print(error.localizedDescription)
            XCTFail()
        }
    }
    
    func testEncodeSmallString() {
        
        do {
            let encoded = try ABIEncoder.encodeArgument(type: "string", arg: "a response string (unsupported)")
            XCTAssert(String(hexFromBytes: encoded) == "0x000000000000000000000000000000000000000000000000000000000000001f6120726573706f6e736520737472696e672028756e737570706f727465642900")
        } catch let error {
            print(error.localizedDescription)
            XCTFail()
        }
    }
    
    func testEncodeLargeString() {
        
        do {
            let encoded = try ABIEncoder.encodeArgument(type: "string", arg: " hello world hello world hello world hello world  hello world hello world hello world hello world  hello world hello world hello world hello world hello world hello world hello world hello world")
            XCTAssert(String(hexFromBytes: encoded) == "0x00000000000000000000000000000000000000000000000000000000000000c22068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c64202068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c64202068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c64000000000000000000000000000000000000000000000000000000000000")
        } catch let error {
            print(error.localizedDescription)
            XCTFail()
        }
    }
    
    func testEncodeAddress() {
        
        do {
            let encoded = try ABIEncoder.encodeArgument(type: "address", arg: "0x407d73d8a49eeb85d32cf465507dd71d507100c1")
            XCTAssert(String(hexFromBytes: encoded) == "0x000000000000000000000000407d73d8a49eeb85d32cf465507dd71d507100c1")
        } catch let error {
            print(error.localizedDescription)
            XCTFail()
        }
    }
    
}
