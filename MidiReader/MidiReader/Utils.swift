//
//  Utils.swift
//  MidiReader
//
//  Created by Jeff Behrbaum on 4/26/22.
//

import Foundation

class Utils
{
	class func byteToChar(byte:UInt8) -> (Bool, Character?)
	{
		var b:Array<UInt8> = Array<UInt8>()
		b.append(byte)
		
		guard let s:String = String(bytes:b, encoding: .utf8) else {
			return (false, nil)
		}
		
		let c:Character = Character(s)
		
		return ((c.isLetter || c.isNumber), c)
	}
	
	class func into16Bit(byte1:UInt8, byte2:UInt8) -> UInt16
	{
		var X:UInt16 = 0

		var X1:UInt16 = UInt16(byte1)
		X1 = (X1 << 8)
		
		X = X1 + UInt16(byte2)
		//X = UInt32(  (byte1 << 24) + (byte2 << 16) + (byte3 << 8) + byte4 )
		
		Printer.printUInt16AsHex(X:X)
		Printer.printByteValuesAsHex(byte1:byte1, byte2:byte2, numBytes: 2)
		Printer.printByteValuesAsBinary(byte1:byte1, byte2:byte2, numBytes: 2)
		Printer.printByteValuesAsDecimal(byte1:byte1, byte2:byte2, numBytes: 2)

		return X
	}
	
	class func into32Bit(byte1:UInt8, byte2:UInt8, byte3:UInt8, byte4:UInt8) -> UInt32
	{
		var X:UInt32 = 0

		var X1:UInt32 = UInt32(byte1)
		X1 = (X1 << 24)
		
		var X2:UInt32 = UInt32(byte2)
		X2 = (X2 << 16)
		
		var X3:UInt32 = UInt32(byte3)
		X3 = (X3 << 8)

		X = X1 + X2 + X3 + UInt32(byte4)
		//X = UInt32(  (byte1 << 24) + (byte2 << 16) + (byte3 << 8) + byte4 )
		
		Printer.printUInt32AsHex(X:X)
		Printer.printByteValuesAsHex(byte1:byte1, byte2:byte2, byte3:byte3, byte4:byte4)
		Printer.printByteValuesAsBinary(byte1:byte1, byte2:byte2, byte3:byte3, byte4:byte4)
		Printer.printByteValuesAsDecimal(byte1:byte1, byte2:byte2, byte3:byte3, byte4:byte4)

		return X
	}
	
	//We're just going be here.  I think this really should be a UInt32 - MAX!
	class func readVariableLengthValue(startIdx:inout Int, data:Data) -> UInt32
	{
		guard (startIdx > 0) && (startIdx < data.count)  else {return 0}
		
		var numberOfBytesRead:Int = 0 //We know we're going to read at least one byte

		var totalValue:UInt32 = 0
		var valueAtByteValue:UInt8 = 0
		
		repeat {
			valueAtByteValue = data[startIdx]
			
			//You MUST clear out the leading bit before adding it to our deltatime value! Just simply
			//ALWAYS doing it since it does no harm regardless if the leading bit is 0 or 1
			//but keeps the logic and readablity clean
			let deltaTimeValueToAdd = valueAtByteValue & MSB_REST_VALUE //Need to use a tmp variable so the loop predicate still works correctly

			totalValue <<= (numberOfBytesRead * 8)//First shift our stored value. 8 because it is the size of a byte
			totalValue += UInt32(deltaTimeValueToAdd)
			
			startIdx += 1
			numberOfBytesRead += 1
		}while ((valueAtByteValue & MSB_TEST_VALUE) == MSB_TEST_VALUE)
		
		return totalValue//(delta:UInt32(deltaTime), numBytesRead:numberOfBytesRead)
	}
}
