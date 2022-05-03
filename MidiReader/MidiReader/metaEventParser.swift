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
	private var m_TimeDelta:UInt32 = 0

	func parseMetaEvent(startIdx:inout Int, timeDelta:UInt32, data:Data) -> Event?
	{
		m_Data = data
		m_TimeDelta = timeDelta
		
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
			return nil
		}
		
		let event:Event? = parseAppropriateMetaEvent(startIdx:&startIdx, eventType:metaEventType)

		m_Data = nil
		
		return event
	}
	
	private func parseAppropriateMetaEvent(startIdx:inout Int, eventType:MetaEventDefinitions) -> Event?
	{
		var event:Event?
		
		switch(eventType) {
			case .SEQUENCE_NUMBER:
				event = parseSeqNumber(startIdx:&startIdx)
			case .TEXT_INFO:
				event = parseTextEvent(startIdx:&startIdx)
			case .COPYRIGHT:
				event = parseCopyright(startIdx:&startIdx)
			case .TEXT_SEQUENCE:
				event = parseTextSequence(startIdx:&startIdx)
			case .TEXT_INSTRUMENT:
				event = parseTextInstrument(startIdx:&startIdx)
			case .TEXT_LYRIC:
				event = parseTextLyric(startIdx:&startIdx)
			case .TEXT_MARKER:
				event = parseTextMarker(startIdx:&startIdx)
			case .TEXT_CUE_POINT:
				event = parseTextCuePoint(startIdx:&startIdx)
			case .MIDI_CHANNEL:
				event = parseMidiChannel(startIdx:&startIdx)
			case .PORT_SELECTION:
				event = parsePortSelection(startIdx:&startIdx)
			case .TEMPO:
				event = parseTempo(startIdx:&startIdx)
			case .SMPTE:
				event = parseSmpte(startIdx:&startIdx)
			case .TIME_SIGNATURE:
				event = parseTimeSignature(startIdx:&startIdx)
			case .MINI_TIME_SIGNATURE:
				event = parseMiniTimeSignature(startIdx:&startIdx)
			case .SPECIAL_SEQUENCE:
				event = parseSpecialSequence(startIdx:&startIdx)
			case .END_OF_TRACK://0xFF2F
				() //Already handled
			default:
				()
		}
		
		return event
	}
	
	//0xFF00 - Will be followed by 02 then the sequence number
	private func parseSeqNumber(startIdx:inout Int) -> Event?
	{
		return MetaEvent(eventTimeDelta: m_TimeDelta)
	}
	
	//All 0xFF2[0 - F]
	
	//0xFF20 -
	private func parseMidiChannel(startIdx:inout Int) -> Event?
	{
		let constByte:UInt8 = m_Data[startIdx]
		startIdx += 1

		//Via the spec - the full definition of the Channel Prefix metaevent is 0xFF2001
		//Our enum is only UInt16 since not all meta-events use 3 bytes, therefore, we need
		//to perform an extra validation here.
		guard(constByte == 0x01) else {return nil}
		
		let midiChannel:UInt8 = m_Data[startIdx]
		startIdx += 1
		
		Printer.printUInt8AsHex(X: midiChannel)
		
		return MetaEvent(eventTimeDelta: m_TimeDelta)
	}
	
	//0xFF21 - //Also has a 01 after the 21, and then a byte (0 - 127) Identifing the port number.
	private func parsePortSelection(startIdx:inout Int) -> Event?
	{
		let constByte:UInt8 = m_Data[startIdx]
		startIdx += 1

		//Via the spec - the full definition of the port selection metaevent is 0xFF2101
		//Our enum is only UInt16 since not all meta-events use 3 bytes, therefore, we need
		//to perform an extra validation here.
		guard(constByte == 0x01) else {return nil}
		
		let portNumber:UInt8 = m_Data[startIdx]
		startIdx += 1
		
		Printer.printUInt8AsHex(X: portNumber)
		
		return MetaEvent(eventTimeDelta: m_TimeDelta)
	}

	//All 0xFF5[0 - F]
	//0xFF51 -
	private func parseTempo(startIdx:inout Int) -> Event?
	{
		let constByte:UInt8 = m_Data[startIdx]
		startIdx += 1

		//Via the spec - the full definition of the tempo metaevent is 0xFF5103
		//Our enum is only UInt16 since not all meta-events use 3 bytes, therefore, we need
		//to perform an extra validation here.
		guard(constByte == 0x03) else {return nil}
		
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
		
		return MetaEvent(eventTimeDelta: m_TimeDelta)
	}
	
	//0xFF54 -
	private func parseSmpte(startIdx:inout Int) -> Event?
	{
		let constByte:UInt8 = m_Data[startIdx]
		startIdx += 1

		//Via the spec - the full definition of the SMPTE metaevent is 0xFF5405
		//Our enum is only UInt16 since not all meta-events use 3 bytes, therefore, we need
		//to perform an extra validation here.
		guard(constByte == 0x05) else {return nil}
		
		//hr
		let hours:UInt8 = m_Data[startIdx]
		startIdx += 1
		
		//mn
		let minutes:UInt8 = m_Data[startIdx]
		startIdx += 1
		
		//se
		let seconds:UInt8 = m_Data[startIdx]
		startIdx += 1
		
		//fr
		let milliseconds:UInt8 = m_Data[startIdx]
		startIdx += 1
		
		//ff
		let fractionalFrames:UInt8 = m_Data[startIdx]
		startIdx += 1

		Printer.printByteValuesAsHex(byte1: hours, byte2: minutes, byte3: seconds, byte4: milliseconds)
		Printer.printByteValuesAsHex(byte1: fractionalFrames)
		
		return MetaEvent(eventTimeDelta: m_TimeDelta)
	}
	
	//0xFF58 -
	private func parseTimeSignature(startIdx:inout Int) -> Event?
	{
		let constByte:UInt8 = m_Data[startIdx]
		startIdx += 1

		//Via the spec - the full definition of the time signature metaevent is 0xFF5804
		//Our enum is only UInt16 since not all meta-events use 3 bytes, therefore, we need
		//to perform an extra validation here.
		guard(constByte == 0x04) else {return nil}

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
		
		return MetaEvent(eventTimeDelta: m_TimeDelta)
	}
	
	//0xFF59 -
	private func parseMiniTimeSignature(startIdx:inout Int) -> Event?
	{
		let constByte:UInt8 = m_Data[startIdx]
		startIdx += 1

		//Via the spec - the full definition of the mini-time signature metaevent is 0xFF5902
		//Our enum is only UInt16 since not all meta-events use 3 bytes, therefore, we need
		//to perform an extra validation here.
		guard(constByte == 0x02) else {return nil}
		
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

		let trackKey:MusicalKey = Utils.valuesToMusicalKey(numShrpFlats:numberSharpsFlats, MajMin:MajorMinorKey)
		Printer.printMessage(msg: MusicalKey.musicalKeyToString(p: trackKey))
		
		return MetaEvent(eventTimeDelta: m_TimeDelta)
	}
	
	//Events with 0xFF7[0 - F]
	
	//0xFF7F -
	private func parseSpecialSequence(startIdx:inout Int) -> Event?
	{
		return MetaEvent(eventTimeDelta: m_TimeDelta)
	}
	
	//All meta-text events are 0xFF0[1 - F]
	//NOTE: In the text events, there is a size of the text + 1. It seems this is
	//a value of 0x00 for the string's null terminator. ie: '\0'
	//0xFF01, //Followed by LEN, TEXT. NOTE: The 0xFF01 - 0xFF0F are all reserved for text messages.
	private func parseTextEvent(startIdx:inout Int) -> Event?
	{
		return MetaEvent(eventTimeDelta: m_TimeDelta)
	}
	
	//0xFF02 -
	private func parseCopyright(startIdx:inout Int) -> Event?
	{
		return MetaEvent(eventTimeDelta: m_TimeDelta)
	}
	
	//0xFF03 -
	private func parseTextSequence(startIdx:inout Int) -> Event?
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
		
		return MetaEvent(eventTimeDelta: m_TimeDelta)
	}
	
	//0xFF04 -
	private func parseTextInstrument(startIdx:inout Int) -> Event?
	{
		return MetaEvent(eventTimeDelta: m_TimeDelta)
	}
	
	//0xFF05 -
	private func parseTextLyric(startIdx:inout Int) -> Event?
	{
		return MetaEvent(eventTimeDelta: m_TimeDelta)
	}
	
	//0xFF06 -
	private func parseTextMarker(startIdx:inout Int) -> Event?
	{
		return MetaEvent(eventTimeDelta: m_TimeDelta)
	}
	
	//0xFF07 -
	private func parseTextCuePoint(startIdx:inout Int) -> Event?
	{
		return MetaEvent(eventTimeDelta: m_TimeDelta)
	}
}
