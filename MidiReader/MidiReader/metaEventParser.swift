//
//  metaEventParser.swift
//  MidiReader
//
//  Created by Jeff Behrbaum on 4/29/22.
//

import Foundation

class MetaEventParser
{
	private var m_Data:Data!

	func parseMetaEvent(startIdx:inout Int, data:Data)
	{
		m_Data = data
		
		let metaSimpleID:UInt16 = Utils.into16Bit(byte1: m_Data[startIdx], byte2: m_Data[startIdx + 1])
		startIdx += 2
		
		var metaEventType:MetaEventDefinitions = .UNKNOWN
		for evtID in MetaEventDefinitions.allCases {
			if(evtID.rawValue == metaSimpleID){
				metaEventType = evtID
				break
			}
		}
		
		guard(metaEventType != .UNKNOWN) else {
			m_Data = nil //Just for cleanliness. It's reset each time the function is called, but still good practice.
			return
		}
		
		parseAppropriateMetaEvent(startIdx:&startIdx, eventType:metaEventType)

		m_Data = nil
	}
	
	private func parseAppropriateMetaEvent(startIdx:inout Int, eventType:MetaEventDefinitions)
	{
		switch(eventType) {
			case .SEQUENCE_NUMBER:
				parseSeqNumber(startIdx:&startIdx)
			case .TEXT_INFO:
				parseTextEvent(startIdx:&startIdx)
			case .COPYRIGHT:
				parseCopyright(startIdx:&startIdx)
			case .TEXT_SEQUENCE:
				parseTextSequence(startIdx:&startIdx)
			case .TEXT_INSTRUMENT:
				parseTextInstrument(startIdx:&startIdx)
			case .TEXT_LYRIC:
				parseTextLyric(startIdx:&startIdx)
			case .TEXT_MARKER:
				parseTextMarker(startIdx:&startIdx)
			case .TEXT_CUE_POINT:
				parseTextCuePoint(startIdx:&startIdx)
			case .MIDI_CHANNEL:
				parseMidiChannel(startIdx:&startIdx)
			case .PORT_SELECTION:
				parsePortSelection(startIdx:&startIdx)
			case .TEMPO:
				parseTempo(startIdx:&startIdx)
			case .SMPTE:
				parseSmpte(startIdx:&startIdx)
			case .TIME_SIGNATURE:
				parseTimeSignature(startIdx:&startIdx)
			case .MINI_TIME_SIGNATURE:
				parseMiniTimeSignature(startIdx:&startIdx)
			case .SPECIAL_SEQUENCE:
				parseSpecialSequence(startIdx:&startIdx)
			case .END_OF_TRACK://0xFF2F
				() //Already handled
			default:
				()
		}
	}
	
	//0xFF00 - Will be followed by 02 then the sequence number
	private func parseSeqNumber(startIdx:inout Int)
	{
		
	}
	
	//All 0xFF2[0 - F]
	
	//0xFF20 -
	private func parseMidiChannel(startIdx:inout Int)
	{
		
	}
	
	//0xFF21 - //Also has a 01 after the 21, and then a byte (0 - 127) Identifing the port number.
	private func parsePortSelection(startIdx:inout Int)
	{
		let constByte:UInt8 = m_Data[startIdx]
		startIdx += 1

		//Via the spec - the full definition of the time signature metaevent is 0xFF2101
		//Our enum is only UInt16 since not all meta-events use 3 bytes, therefore, we need
		//to perform an extra validation here.
		guard(constByte == 0x01) else {return}
		
		let portNumber:UInt8 = m_Data[startIdx]
		startIdx += 1
		
		Printer.printUInt8AsHex(X: portNumber)
	}

	//All 0xFF5[0 - F]
	//0xFF51 -
	private func parseTempo(startIdx:inout Int)
	{
		let constByte:UInt8 = m_Data[startIdx]
		startIdx += 1

		//Via the spec - the full definition of the time signature metaevent is 0xFF5103
		//Our enum is only UInt16 since not all meta-events use 3 bytes, therefore, we need
		//to perform an extra validation here.
		guard(constByte == 0x03) else {return}
		
		//This will ultimately be used to store the 24 bit tempo
		var tempoValue:UInt32 = 0x00000000
		
		var MSB:UInt32 = UInt32(m_Data[startIdx])
		MSB = (MSB << 16)
		startIdx += 1
		
		var MID_VAL:UInt32 = UInt32(m_Data[startIdx])
		MID_VAL = (MID_VAL << 8)
		startIdx += 1
		
		tempoValue = MSB + MID_VAL + UInt32(m_Data[startIdx])
		startIdx += 1

		Printer.printUInt32AsHex(X: tempoValue)
	}
	
	//0xFF54 -
	private func parseSmpte(startIdx:inout Int)
	{
		
	}
	
	//0xFF58 -
	private func parseTimeSignature(startIdx:inout Int)
	{
		let constByte:UInt8 = m_Data[startIdx]
		startIdx += 1

		//Via the spec - the full definition of the time signature metaevent is 0xFF5804
		//Our enum is only UInt16 since not all meta-events use 3 bytes, therefore, we need
		//to perform an extra validation here.
		guard(constByte == 0x04) else {return}

		let numerator:UInt8 = m_Data[startIdx]
		startIdx += 1
		
		//The denominator is a negative power of two. ie: 1^(-3) is really 1/3
		let denominator:UInt8 = m_Data[startIdx]
		startIdx += 1
		
		let midiClocksInMetronomeClick:UInt8 = m_Data[startIdx]
		startIdx += 1
		
		let numberNotated32ndNotes:UInt8 = m_Data[startIdx]
		startIdx += 1
		
		Printer.printByteValuesAsHex(byte1: numerator)
		Printer.printByteValuesAsHex(byte1: denominator)
		Printer.printByteValuesAsHex(byte1: midiClocksInMetronomeClick)
		Printer.printByteValuesAsHex(byte1: numberNotated32ndNotes)
	}
	
	//0xFF59 -
	private func parseMiniTimeSignature(startIdx:inout Int)
	{
		let constByte:UInt8 = m_Data[startIdx]
		startIdx += 1

		//Via the spec - the full definition of the time signature metaevent is 0xFF5902
		//Our enum is only UInt16 since not all meta-events use 3 bytes, therefore, we need
		//to perform an extra validation here.
		guard(constByte == 0x02) else {return}
		
		//We need this to be signed!
		//Negative represents the number of flats [-1 through -7]
		//Positive represents the number of sharps [1 through 7]
		//Zero reprsents C Major/A Minor
		let numberSharpsFlats:Int8 = Int8(m_Data[startIdx])
		startIdx += 1
		
		//0 = Major key
		//1 = Minor key
		let MajorMinorKey:UInt8 = m_Data[startIdx]
		startIdx += 1

		let trackKey:MusicalKey = valuesToMusicalKey(numShrpFlats:numberSharpsFlats, MajMin:MajorMinorKey)
		Printer.printMessage(msg: MusicalKey.musicalKeyToString(p: trackKey))
	}
	
	//Events with 0xFF7[0 - F]
	
	//0xFF7F -
	private func parseSpecialSequence(startIdx:inout Int)
	{
		
		
	}
	
	//All meta-text events are 0xFF0[1 - F]
	//NOTE: In the text events, there is a size of the text + 1. It seems this is
	//a value of 0x00 for the string's null terminator. ie: '\0'
	//0xFF01, //Followed by LEN, TEXT. NOTE: The 0xFF01 - 0xFF0F are all reserved for text messages.
	private func parseTextEvent(startIdx:inout Int)
	{
		
	}
	
	//0xFF02 -
	private func parseCopyright(startIdx:inout Int)
	{
		
	}
	
	//0xFF03 -
	private func parseTextSequence(startIdx:inout Int)
	{
		let textLen:UInt32 = Utils.readVariableLengthValue(startIdx:&startIdx, data:m_Data)
		
		var textInfo:String = ""
		var textData:Array<UInt8> = Array<UInt8>()
		
		for idx in 0..<Int(textLen) {
			textData.append(m_Data[idx + startIdx])
		}
		
		if let s = String(bytes: textData, encoding: .utf8) {
			textInfo = s
		}
		
		startIdx += Int(textLen)
		Printer.printMessage(msg: textInfo)
	}
	
	//0xFF04 -
	private func parseTextInstrument(startIdx:inout Int)
	{
		
	}
	
	//0xFF05 -
	private func parseTextLyric(startIdx:inout Int)
	{
		
	}
	
	//0xFF06 -
	private func parseTextMarker(startIdx:inout Int)
	{
		
	}
	
	//0xFF07 -
	private func parseTextCuePoint(startIdx:inout Int)
	{
		
	}
}


//	case UNKNOWN = 0x0000,
//	SEQUENCE_NUMBER = 0xFF00, //Will be followed by 02 then the sequence number

//	TEXT_INFO = 0xFF01, //Followed by LEN, TEXT. NOTE: The 0xFF01 - 0xFF0F are all reserved for text messages.
//	COPYRIGHT = 0xFF02,
//	TEXT_SEQUENCE = 0xFF03,
//	TEXT_INSTRUMENT = 0xFF04,
//	TEXT_LYRIC = 0xFF05,
//	TEXT_MARKER = 0xFF06,
//	TEXT_CUE_POINT = 0xFF07,


//	MIDI_CHANNEL = 0xFF20,
//	PORT_SELECTION = 0xFF21, //Also has a 01 after the 21, and then a byte (0 - 127) Identifing the port number.
//	END_OF_TRACK = 0xFF2F,


//	TEMPO = 0xFF51,
//	SMPTE = 0xFF54,
//	TIME_SIGNATURE = 0xFF58,
//	MINI_TIME_SIGNATURE = 0xFF59,
//	SPECIAL_SEQUENCE = 0xFF7F
