//
//  midiReader.swift
//  MidiReader
//
//  Created by Jeff Behrbaum on 4/26/22.
//

import Foundation

let MIDI_TYPE_MAX:UInt16 = 0x3
let END_OF_TRACK:UInt32 = 0xFF2F00
let MSB_TEST_VALUE:UInt8 = 0x80 //We need to see if the first bit is set - if it is, we read the next/following byte
let MSB_REST_VALUE:UInt8 = 0x7F //We & with this value to clear the leading bit of our 7 byte values

class MidiReader
{
	private var m_FileData:Data?

	func openMidiFile(fileName:String) -> Bool
	{
		var bRetStat:Bool = false
		
		let fm = FileManager()

		guard fm.isReadableFile(atPath:fileName) else {
			return bRetStat
		}
		
		guard let pathUrl:URL = URL(string:"file://" + fileName) else {
			return bRetStat
		}
		
		do {
			m_FileData = try Data(contentsOf: pathUrl)
			
			if(m_FileData != nil && m_FileData?.isEmpty == false) {
				bRetStat = true
			}
		}
		catch {
			print(error)
		}
		
		return bRetStat
	}

	//The return is the last index read. -1 is error
	func readHeader(hdr:MidiHeader) -> Int
	{
		guard let fileData = m_FileData else {
			return -1
		}
		
		hdr.Title = Utils.into32Bit(byte1: fileData[0], byte2: fileData[1], byte3: fileData[2], byte4: fileData[3])
		
		guard hdr.Title == MIDI_HDR_VALUE else {return 3}
		
		hdr.Length = Utils.into32Bit(byte1: fileData[4], byte2: fileData[5], byte3: fileData[6], byte4: fileData[7])
		
		guard hdr.Length == MIDI_HDR_LEN_VALUE else {return 7}
		
		let hdrType:UInt16 = Utils.into16Bit(byte1: fileData[8], byte2: fileData[9])

		guard hdrType <= MIDI_TYPE_MAX else {return 9}
		
		hdr.MidiFileType = hdr.numberToMidiType(num: hdrType)
		
		hdr.NumberOfTracks = Utils.into16Bit(byte1: fileData[10], byte2: fileData[11])
		
		guard hdr.NumberOfTracks > 0 else {return 11}
		
		hdr.TimeDivision = Utils.into16Bit(byte1: fileData[12], byte2: fileData[13])
		
		guard hdr.TimeDivision > 0 else {return 13}
		
		return 13
 	}
	
	func readTrack(startIndex:Int) -> Int
	{
		let HDR_SIZE:Int = 4  //4 bytes
		let EOT_SIZE:Int = 3 //3 bytes are used for the end of track marker
		let NUM_BYTES_TRACK_SIZE = 4 //4 bytes
		
		var idx:Int = startIndex
		
		
		guard let fileData = m_FileData else {
			return -1
		}

		//Read track header
		let hdr:UInt32 = Utils.into32Bit(byte1: fileData[idx], byte2: fileData[idx + 1], byte3: fileData[idx + 2], byte4: fileData[idx + 3])
		idx += HDR_SIZE
		Printer.printUInt32AsHex(X: hdr)

		guard hdr == MIDI_TRK_VALUE else {return idx}
		
		let trkChunkSize:UInt32 = Utils.into32Bit(byte1: fileData[idx], byte2: fileData[idx + 1], byte3: fileData[idx + 2], byte4: fileData[idx + 3])
		idx += NUM_BYTES_TRACK_SIZE
		Printer.printUInt32AsHex(X: trkChunkSize)

		let endIdx1:Int = startIndex + HDR_SIZE + NUM_BYTES_TRACK_SIZE + Int(trkChunkSize)  - EOT_SIZE
		guard (endIdx1 + 2) < fileData.count else {return idx}
		
		//Remember, we have NOT moved the read pointer, we did an index calculation.
		//Therefore, you must remember to increment the reader by EOT_SIZE before returning.
		//We're doing this here to make certain we have a valid record before reading and parsing the whole thing only to find out later it may be bad.
		let eot:UInt32 = Utils.into32Bit(byte1: 0x00, byte2: fileData[endIdx1], byte3: fileData[endIdx1 + 1], byte4: fileData[endIdx1 + 2])
		guard eot == END_OF_TRACK else {return idx}
		Printer.printUInt32AsHex(X: eot)
		
		//Remember, the delta time is a variable number of bytes with the maximum being
		//4 bytes - but will most likely ever only be 2 bytes. This is that 7 byte thing...
		let trackDeltaTimeOffset:(delta:UInt32, numBytesRead:Int) = readDeltaOffsetTime(startIdx:idx)
		guard trackDeltaTimeOffset.numBytesRead > 0 else {return idx} //Random value for now - just a place holder

		idx += trackDeltaTimeOffset.numBytesRead

		Printer.printMessage(msg:"Track Read")
		return -1
	}

	private func readDeltaOffsetTime(startIdx:Int) -> (delta:UInt32, numBytesRead:Int)
	{
		guard let fileData = m_FileData else {return (delta:0, numBytesRead:-1)}
		guard (startIdx > 0) && (startIdx < fileData.count)  else {return (delta:0, numBytesRead:-1)}
		
		var numberOfBytesRead:Int = 0 //We know we're going to read at least one byte
		
		var readIdx:Int = startIdx
		var deltaTime:UInt32 = 0
		var deltaTimeByteValue:UInt8 = 0
		
		repeat {
			deltaTimeByteValue = fileData[readIdx]
			
			//You MUST clear out the leading bit before adding it to our deltatime value! Just simply
			//ALWAYS doing it since it does no harm regardless if the leading bit is 0 or 1
			//but keeps the logic and readablity clean
			let deltaTimeValueToAdd = deltaTimeByteValue & MSB_REST_VALUE //Need to use a tmp variable so the loop predicate still works correctly

			deltaTime <<= (numberOfBytesRead * 8)//First shift our stored value. 8 because it is the size of a byte
			deltaTime += UInt32(deltaTimeValueToAdd)
			
			readIdx += 1
			numberOfBytesRead += 1
		}while ((deltaTimeByteValue & MSB_TEST_VALUE) == MSB_TEST_VALUE)
		
		return (delta:UInt32(deltaTime), numBytesRead:numberOfBytesRead)
	}
}
