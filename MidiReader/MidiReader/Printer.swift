//
//  Printer.swift
//  MidiReader
//
//  Created by Jeff Behrbaum on 4/26/22.
//

import Foundation

class Printer
{
	static var printIsActive:Bool = true
	
	class func printMessage(msg:String, activePrintOverride:Bool = false)
	{
		if(printIsActive == false) {
			if(activePrintOverride == false) {return}
		}

		print(msg)
	}
	
	class func printUInt8AsHex(X:UInt8, activePrintOverride:Bool = false)
	{
		if(printIsActive == false) {
			if(activePrintOverride == false) {return}
		}
		
		let s:String = String(format: "%02X", X)
		print("The UInt8 \(X) is: 0x\(s)\n**********************\n")
	}
	
	class func printUInt32AsHex(X:UInt32, activePrintOverride:Bool = false)
	{
		if(printIsActive == false) {
			if(activePrintOverride == false) {return}
		}
			
		let s:String = String(format: "%02X", X)
		print("The UInt32 \(X) is: 0x\(s)\n**********************\n")
	}
	
	class func printUInt16AsHex(X:UInt16, activePrintOverride:Bool = false)
	{
		if(printIsActive == false) {
			if(activePrintOverride == false) {return}
		}
		
		let s:String = String(format: "%02X", X)
		print("The UInt16 \(X) is: 0x\(s)\n**********************\n")
	}
	
	class func printByteValuesAsHex(byte1:UInt8, byte2:UInt8 = 0, byte3:UInt8 = 0, byte4:UInt8 = 0, numBytes:Int = 4, activePrintOverride:Bool = false)
	{
		if(printIsActive == false) {
			if(activePrintOverride == false) {return}
		}
		
		var msg:String = "Bytes Hex: "
		
		let b1:String = String(format: "%02X", byte1)
		msg += b1
		
		if(numBytes >= 2){
			let b2:String = String(format: "%02X", byte2)
			msg += " - \(b2)"
		}
		
		if(numBytes >= 3) {
			let b3:String = String(format: "%02X", byte3)
			msg += " - \(b3)"
		}
		
		if(numBytes >= 4) {
			let b4:String = String(format: "%02X", byte4)
			msg += " - \(b4)"
		}
		
		print(msg)
	}
	
	class func printByteValuesAsDecimal(byte1:UInt8, byte2:UInt8 = 0, byte3:UInt8 = 0, byte4:UInt8 = 0, numBytes:Int = 4, activePrintOverride:Bool = false)
	{
		if(printIsActive == false) {
			if(activePrintOverride == false) {return}
		}
		
		var msg:String = "Bytes Dec: "

		let b1:String = String(byte1, radix: 10)
		msg += b1
		
		if(numBytes >= 2) {
			let b2:String = String(byte2, radix: 10)
			msg += " - \(b2)"
		}
		
		if(numBytes >= 3) {
			let b3:String = String(byte3, radix: 10)
			msg += " - \(b3)"
		}
		
		if(numBytes >= 4) {
			let b4:String = String(byte4, radix: 10)
			msg += " - \(b4)"
		}
				
		print(msg)
	}
	
	class func printByteValuesAsBinary(byte1:UInt8, byte2:UInt8 = 0, byte3:UInt8 = 0, byte4:UInt8 = 0, numBytes:Int = 4, activePrintOverride:Bool = false)
	{
		if(printIsActive == false) {
			if(activePrintOverride == false) {return}
		}
		
		var msg:String = "Bytes Bin: "

		let b1:String = String(byte1, radix: 2)
		msg += b1
		
		if(numBytes >= 2) {
			let b2:String = String(byte2, radix: 2)
			msg += " - \(b2)"
		}
		
		if(numBytes >= 3) {
			let b3:String = String(byte3, radix: 2)
			msg += " - \(b3)"
		}
		
		if(numBytes >= 4) {
			let b4:String = String(byte4, radix: 2)
			msg += " - \(b4)"
		}
		
		print(msg)
	}
}
