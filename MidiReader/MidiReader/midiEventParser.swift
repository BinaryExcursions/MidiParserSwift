//
//  midiCommonMessageParser.swift
//  MidiReader
//
//  Created by Jeff Behrbaum on 4/30/22.
//

import Foundation

class MidiEventParser
{
	private var m_Data:Data!
	private var m_TimeDelta:UInt32 = 0
	
	func parseMidiEvent(startIdx:inout Int, timeDelta:UInt32, data:Data) -> Event?
	{
		m_Data = data
		m_TimeDelta = timeDelta //Just don't want to pass this around to every method
		
		guard (startIdx > 0) && (startIdx < m_Data.count) else {return nil}
		
		let midiStatusByte:UInt8 = m_Data[startIdx]
		startIdx += 1
		
		let midiEvent:Event? = parseByteToMajorMidiMessage(messageValue: midiStatusByte, idx: &startIdx)
		
		return midiEvent
	}

	private func parseByteToMajorMidiMessage(messageValue:UInt8, idx:inout Int) -> Event?
	{
		let SYS_COMMON_MSG_CTRl:UInt8 = 0xF0
		let SYS_DATA_TYPE_CTRL:UInt8 = 0x08

		var evt:Event?
		
		if( (messageValue & SYS_COMMON_MSG_CTRl) == SYS_COMMON_MSG_CTRl) { //Looking at the high 4 bits of the byte
			//Looking at the lower 4 bits of the byte but more specifically the first bit - if set = Sys Realtime if not sys common.
			//ie: If the last 4 bits are > 8 (ie: 0xF8 - 0xFD) its a sys realtime, but if less than 8 (ie: 0xF0 - 0xF7) It's a sys common message
			let dataInfoVal:UInt8 = messageValue & SYS_DATA_TYPE_CTRL
			evt = (dataInfoVal == SYS_DATA_TYPE_CTRL) ? parseSystemRealTimeMessage(messageValue:messageValue, idx:&idx) : parseSystemExclusiveCommonMessage(messageValue: messageValue, idx:&idx)
		}
		else {
			evt = parseChannelMessageType(messageValue: messageValue, idx: &idx)
		}

		return evt
	}
	
	private func parseChannelMessageType(messageValue:UInt8, idx:inout Int) -> MidiChannelEvent?
	{
		let CHANNEL_Ctrl:UInt8 = 0x0F
		let chnl:UInt8 = messageValue & CHANNEL_Ctrl
		
		var byteRead:UInt8 = 0x0
		
		if( (messageValue & MidiMajorMessage.NOTE_OFF.rawValue) == messageValue) {
			byteRead = m_Data[idx] //Reading the key note
			idx += 1

			guard let musicalNote = MidiNote(rawValue: byteRead) else {return nil}
			
			byteRead = m_Data[idx] //Reading the Velocity
			idx += 1
			
			return MidiChannelEvent(eventTimeDelta:m_TimeDelta, channel:chnl, noteVelocity:byteRead, musicalNote:musicalNote, eventType:.NOTE_OFF)
		}
		else if( (messageValue & MidiMajorMessage.NOTE_ON.rawValue) == messageValue) {
			byteRead = m_Data[idx] //Reading the key note
			idx += 1

			guard let musicalNote = MidiNote(rawValue: byteRead) else {return nil}
			
			byteRead = m_Data[idx] //Reading the Velocity
			idx += 1
			
			return MidiChannelEvent(eventTimeDelta:m_TimeDelta, channel:chnl, noteVelocity:byteRead, musicalNote:musicalNote, eventType:.NOTE_ON)
		}
		else if( (messageValue & MidiMajorMessage.KEY_PRESSURE_AFTER_TOUCH.rawValue) == messageValue) {
			byteRead = m_Data[idx] //Reading the key note
			idx += 1

			guard let musicalNote = MidiNote(rawValue: byteRead) else {return nil}
			
			byteRead = m_Data[idx] //Reading the Pressure
			idx += 1
			
			return MidiChannelEvent(eventTimeDelta:m_TimeDelta, channel:chnl, pressure:byteRead, musicalNote:musicalNote, eventType:.KEY_PRESSURE_AFTER_TOUCH)
		}
		else if( (messageValue & MidiMajorMessage.CONTROL_CHANGE.rawValue) == messageValue) {
			let byte1 = m_Data[idx] //Reading the controller number
			idx += 1

			byteRead = m_Data[idx] //Reading the new control value
			idx += 1

			return MidiChannelEvent(eventTimeDelta:m_TimeDelta, channel:chnl, controllerNumber:byte1, controllerChangeValue:byteRead, eventType:.CONTROL_CHANGE)
		}
		else if( (messageValue & MidiMajorMessage.PROGRAM_CHANGE.rawValue) == messageValue) {
			byteRead = m_Data[idx] //Reading the new program number
			idx += 1
			
			return MidiChannelEvent(eventTimeDelta:m_TimeDelta, channel:chnl, programNumber:byteRead, eventType:.PROGRAM_CHANGE)
		}
		else if( (messageValue & MidiMajorMessage.CHANNEL_PRESSURE_AFTER_TOUCH.rawValue) == messageValue) {
			byteRead = m_Data[idx] //Reading the pressure value
			idx += 1
			
			return MidiChannelEvent(eventTimeDelta:m_TimeDelta, channel:chnl, pressure:byteRead, eventType:.CHANNEL_PRESSURE_AFTER_TOUCH)
		}
		else if( (messageValue & MidiMajorMessage.PITCH_WHEEL_CHANGE.rawValue) == messageValue) {
			var pitch:UInt16 = 0
			
			var lsb:UInt8 = m_Data[idx] //Reading the least significant bits value
			idx += 1

			var msb = m_Data[idx] //Reading the most significant bits value
			idx += 1
			
			lsb &= 0x7F //Be certain the leading bit is cleared or you could wind up with a full 16 bit value when you are only worried about 15 of them
			msb &= 0x7F //Be certain the leading bit is cleared or you could wind up with a full 16 bit value when you are only worried about 15 of them
			
			pitch = UInt16(msb)
			pitch <<= 8
			pitch += UInt16(lsb)

			return MidiChannelEvent(eventTimeDelta:m_TimeDelta, channel:chnl, pitchWheelChange:pitch, eventType:.PITCH_WHEEL_CHANGE)
		}

		return nil
	}

	private func parseSystemExclusiveCommonMessage(messageValue:UInt8, idx:inout Int) -> Event?
	{
		let SYS_MSG_IDENTIFIER_CTRL:UInt8 = 0x0F//So we can evaluate the lower 4 bits to identify the specific message
		
		var bytes:Array<UInt8>?
		var processMore:Bool = true
		
		var msgIdToProcess:UInt8 = messageValue
		
		repeat {
			//There's a high probable that you don't want to add the start and stop bytes to your byte array, but you may.  If you do
			//then you'll want to update the 0th and 7th case.
			switch(msgIdToProcess & SYS_MSG_IDENTIFIER_CTRL) {
				case 0://.SYS_EXCLUSIVE - Start
					bytes = Array<UInt8>() //Only once we know for certain we have the "start" of the exclusive message to we allocate our byte array
				
				//--NOTE: To the end user, you may want to do more with the system exclusive message so I left in the commented out cases
				//so you can see where you may want to provide more implementation specific to a particular manufacture's MIDI implementation
//				case 2://.SONG_POSITION_POINTER
//				case 3://.SONG_SELECT
//				case 6://.TUNE_REQUEST
				case 7://.END_OF_EXCLUSIVE --End message
					processMore = false
					idx -= 1 //We read the end of message - if we don't reset the counter here, the increment after the switch will get us our of sync
				case 1, 4, 5://.UNDEFINED
					()  //As per the spec - these values are undefined System Common message tyeps
				default:
					if(bytes != nil){bytes!.append(msgIdToProcess)}
			}
			
			idx += 1
			msgIdToProcess = m_Data[idx]
		} while(processMore == true)
		
		return SysExclusionEvent(eventTimeDelta: m_TimeDelta, exclusiveInfo: bytes ?? [])
	}
	
	private func parseSystemRealTimeMessage(messageValue:UInt8, idx:inout Int) -> Event?
	{
		let SYS_MSG_IDENTIFIER_CTRL:UInt8 = 0x07//So we can evaluate the lower 3 bits to identify the specific message
		var messageInfo:(msg:MidiMajorMessage, channel:UInt8?) = (.UNDEFINED, nil)
		
		switch(messageValue & SYS_MSG_IDENTIFIER_CTRL) {
		case 0:
			messageInfo.msg = .TIMING_CLOCK
		case 2:
			messageInfo.msg = .START_SEQUENCE
		case 3:
			messageInfo.msg = .CONTINUE_AT_POINT_OF_SEQUENCE_STOP
		case 4:
			messageInfo.msg = .STOP_SEQUENCE
		case 6:
			messageInfo.msg = .ACTIVE_SENSING
		case 7:
			messageInfo.msg = .RESET
		case 1, 5:
			messageInfo.msg = .UNDEFINED //As per the spec - these values are undefined System Common message tyeps
		default:
			messageInfo.msg = .UNDEFINED
		}
		
		if(messageInfo.msg == .UNDEFINED) {
			Printer.printMessage(msg: "The System Real-time event was read as undefined.")
		}
		
		return SysRealtimeEvent(eventTimeDelta: m_TimeDelta)
	}
}
