//
//  midiCommonMessageParser.swift
//  MidiReader
//
//  Created by Jeff Behrbaum on 4/30/22.
//

import Foundation

class MidiCommonEventParser
{
	private var m_Data:Data!
	
	func parseMidiEvent(startIdx:inout Int, data:Data) -> protoEvent?
	{
		m_Data = data
		
		guard (startIdx > 0) && (startIdx < m_Data.count) else {return nil}
		
		let midiStatusByte:UInt8 = m_Data[startIdx]
		startIdx += 1
		
		let midiEvent:protoEvent? = parseByteToMajorMidiMessage(messageValue: midiStatusByte, idx: &startIdx)
		
		return midiEvent
	}

	func parseByteToMajorMidiMessage(messageValue:UInt8, idx:inout Int) -> protoEvent?
	{
		let SYS_COMMON_MSG_CTRl:UInt8 = 0xF0
		let SYS_DATA_TYPE_CTRL:UInt8 = 0x08

		var evt:protoEvent?

		var messageInfo:(msg:MidiMajorMessage, channel:UInt8?) = (.UNDEFINED, 0)

		if( (messageValue & SYS_COMMON_MSG_CTRl) == SYS_COMMON_MSG_CTRl) { //Looking at the high 4 bits of the byte
			let dataInfoVal:UInt8 = messageValue & SYS_DATA_TYPE_CTRL //Looking at the lower 4 bits of the byte
			messageInfo = (dataInfoVal == SYS_DATA_TYPE_CTRL) ? parseSystemRealTimeMessage(messageValue:messageValue) : parseSystemCommonMessage(messageValue: messageValue)
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
			
			return MidiChannelEvent(channel:chnl, noteVelocity:byteRead, musicalNote:musicalNote, eventType:.NOTE_OFF)
		}
		else if( (messageValue & MidiMajorMessage.NOTE_ON.rawValue) == messageValue) {
			byteRead = m_Data[idx] //Reading the key note
			idx += 1

			guard let musicalNote = MidiNote(rawValue: byteRead) else {return nil}
			
			byteRead = m_Data[idx] //Reading the Velocity
			idx += 1
			
			return MidiChannelEvent(channel:chnl, noteVelocity:byteRead, musicalNote:musicalNote, eventType:.NOTE_ON)
		}
		else if( (messageValue & MidiMajorMessage.KEY_PRESSURE_AFTER_TOUCH.rawValue) == messageValue) {
			byteRead = m_Data[idx] //Reading the key note
			idx += 1

			guard let musicalNote = MidiNote(rawValue: byteRead) else {return nil}
			
			byteRead = m_Data[idx] //Reading the Pressure
			idx += 1
			
			return MidiChannelEvent(channel:chnl, pressure:byteRead, musicalNote:musicalNote, eventType:.KEY_PRESSURE_AFTER_TOUCH)
		}
		else if( (messageValue & MidiMajorMessage.CONTROL_CHANGE.rawValue) == messageValue) {
			let byte1 = m_Data[idx] //Reading the controller number
			idx += 1

			byteRead = m_Data[idx] //Reading the new control value
			idx += 1
			
			return MidiChannelEvent(channel:chnl, controllerNumber:byte1, controllerChangeValue:byteRead, eventType:.CONTROL_CHANGE)
		}
		else if( (messageValue & MidiMajorMessage.PROGRAM_CHANGE.rawValue) == messageValue) {
			byteRead = m_Data[idx] //Reading the new program number
			idx += 1
			
			return MidiChannelEvent(channel:chnl, programNumber:byteRead, eventType:.PROGRAM_CHANGE)
		}
		else if( (messageValue & MidiMajorMessage.CHANNEL_PRESSURE_AFTER_TOUCH.rawValue) == messageValue) {
			byteRead = m_Data[idx] //Reading the pressure value
			idx += 1
			
			return MidiChannelEvent(channel:chnl, pressure:byteRead, eventType:.CHANNEL_PRESSURE_AFTER_TOUCH)
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

			return MidiChannelEvent(channel:chnl, pitchWheelChange:pitch, eventType:.PITCH_WHEEL_CHANGE)
		}

		return nil
	}

	private func parseSystemCommonMessage(messageValue:UInt8) -> (msg:MidiMajorMessage, channel:UInt8?)
	{
		let SYS_MSG_IDENTIFIER_CTRL:UInt8 = 0x0F//So we can evaluate the lower 4 bits to identify the specific message
		var messageInfo:(msg:MidiMajorMessage, channel:UInt8?) = (.UNDEFINED, nil)
		
		switch(messageValue & SYS_MSG_IDENTIFIER_CTRL) {
		case 0:
			messageInfo.msg = .SYS_EXCLUSIVE
		case 2:
			messageInfo.msg = .SONG_POSITION_POINTER
		case 3:
			messageInfo.msg = .SONG_SELECT
		case 6:
			messageInfo.msg = .TUNE_REQUEST
		case 7:
			messageInfo.msg = .END_OF_EXCLUSIVE
		case 1, 4, 5:
			messageInfo.msg = .UNDEFINED //As per the spec - these values are undefined System Common message tyeps
		default:
			messageInfo.msg = .UNDEFINED
		}

		return messageInfo
	}
	
	private func parseSystemRealTimeMessage(messageValue:UInt8) -> (msg:MidiMajorMessage, channel:UInt8?)
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

		return messageInfo
	}
}
