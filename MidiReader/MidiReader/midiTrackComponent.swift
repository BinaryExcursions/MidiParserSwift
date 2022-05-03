//
//  midiTrackComponent.swift
//  MidiReader
//
//  Created by Jeff Behrbaum on 4/27/22.
//

import Foundation

let META_EVENT_IDENFIFIER:UInt8 = 0xFF
let MIDI_TRK_VALUE:UInt32 = 0x4D54726B //This is MTrk

class MidiTrack
{
	//--Holders until I know more about these variables
	private var m_ChunkType:Int = 0 //I think this is actually the MTrk
	private var m_ChunkLength:Int = 0 //I think this is the nummber of bytes in the record chunk
	private lazy var m_TrackEvents:Array<Event> = Array<Event>()
	//--End holders segment
	
	private var m_TrackIndex:Int = -1 //Will this be 0 based????? To be determined
	private var m_TrackBlockTitle:UInt32 = 0
	
	//The first track of type 1 file will need to contain tempo information
	//Remember, 4/4 at 120 bpm is always assumed if not present.
	private var m_TempoMapInfo:(t:TimeingInfo, tempo:UInt8)?// = (.FOUR_FOUR, 120) //Here for defaults, but still ONLY in the first track unless it changes at some point
	
	var TrackIndex:Int {
		get{return m_TrackIndex}
		set{
			guard newValue > 0 else {return}
			m_TrackIndex = newValue
		}
	}
	
	var TrackBlockTitle:UInt32 {
		get{return m_TrackBlockTitle}
		set{
			//DO NOT HARD-CODE THIS VALUE!!!!!  I MUST be set from the file or stream being read in.
			guard newValue == MIDI_TRK_VALUE else{return}
			m_TrackBlockTitle = newValue
		}
	}
	
	func appendEvent(event:Event)
	{
		//Realistically, this is where you'd want to execute the information in the event
		//so to minimize any additional processing.
		guard processEvent(event:event) == true else {return}

		m_TrackEvents.append(event)
	}
	
	subscript(index:Int) -> Event? {
		guard (index >= 0) && (index < m_TrackEvents.count) else {return nil}
		
		return m_TrackEvents[index]
	}
	
	func processEvent(event:Event) -> Bool
	{
		switch(event.eMidiType) {
			case .MIDI_EVENT:
				return processMidiEvent(event: event as! MidiChannelEvent)
			case .SYSEX_EVENT:
				return processSystemExclusionEvent(event:event as! SysExclusionEvent)
			case .META_EVENT:
				return processMetaEvent(event:event as! MetaEvent)
			case .SYSREALTIME_EVENT:
				return processSystemRealtimeEvent(event:event as! SysRealtimeEvent)
		}
	}
	
	private func processMidiEvent(event:MidiChannelEvent) -> Bool
	{
		var bRetStat:Bool = false
		
		switch(event.eventType)
		{
			case .NOTE_ON:
				bRetStat = processNoteOnOffEvent(event:event, noteOn:true)
			case .NOTE_OFF:
				bRetStat = processNoteOnOffEvent(event:event, noteOn:false)
			case .CONTROL_CHANGE:
				bRetStat = processControlChangeEvent(event: event)
			case .KEY_PRESSURE_AFTER_TOUCH:
				bRetStat = processKeyPressureAfterTouch(event: event)
			case .PROGRAM_CHANGE:
				bRetStat = processProgramChange(event: event)
			case .CHANNEL_PRESSURE_AFTER_TOUCH:
				bRetStat = processChannelPressureAfterTouch(event: event)
			case .PITCH_WHEEL_CHANGE:
				bRetStat = processPitchWheelChange(event: event)
			default:
				()
		}

		return bRetStat
	}
	
	private func processMetaEvent(event:MetaEvent) -> Bool
	{
		return true
	}
	
	private func processSystemExclusionEvent(event:SysExclusionEvent) -> Bool
	{
		return true
	}
	
	private func processSystemRealtimeEvent(event:SysRealtimeEvent) -> Bool
	{
		return true
	}
	
	private func processNoteOnOffEvent(event:MidiChannelEvent, noteOn:Bool) -> Bool
	{
		(noteOn == true) ? Printer.printMessage(msg: "Note On message") : Printer.printMessage(msg: "Note Off message")

		if let note = event.musicalNote {
			Printer.printUInt8AsHex(X: note.rawValue)
		}

		if let velocity = event.noteVelocity {
			Printer.printUInt8AsHex(X: velocity)
		}

		return true
	}

	private func processPitchWheelChange(event:MidiChannelEvent) -> Bool
	{
		if let wheelPitchChange:UInt16 = event.pitchWheelChange {
			Printer.printUInt16AsHex(X: wheelPitchChange)
		}
		
		return true
	}
	
	private func processChannelPressureAfterTouch(event:MidiChannelEvent) -> Bool
	{
		if let channelPressure = event.pressure {
			Printer.printUInt8AsHex(X: channelPressure)
		}
		
		return true
	}
	
	private func processProgramChange(event:MidiChannelEvent) -> Bool
	{
		if let programNumber = event.programNumber {
			Printer.printUInt8AsHex(X: programNumber)
		}

		return true
	}
	
	private func processKeyPressureAfterTouch(event:MidiChannelEvent) -> Bool
	{
		if let note = event.musicalNote {
			Printer.printUInt8AsHex(X: note.rawValue)
		}

		if let pressure = event.pressure {
			Printer.printUInt8AsHex(X: pressure)
		}

		return true
	}

	private func processControlChangeEvent(event:MidiChannelEvent) -> Bool
	{
		let MAX_CHANNEL:UInt8 = 0x0F //[0 - 15] for a total of 16 channels

		let MODE_LOCAL_CONTROL_CHK:UInt8 = 0x7A //122
		let MODE_ALL_NOTES_CHK:UInt8 = 0x7B //123
		let MODE_OMNI_MODE_ON:UInt8 = 0x7D //125
		let MODE_OMNI_MODE_OFF:UInt8 = 0x7C //124
		let MODE_MONO_MODE_ON:UInt8 = 0x7E //126
		let MODE_MONO_MODE_OFF:UInt8 = 0x7F //127

		var numberOfChannels:UInt8 = 0
		
		var ctrlModeState:MidiEventModeControlStates = .ALL_NOTES_OFF

		//Validate for those messages which have a channel - This will actually be most of them
		if let channel = event.channel {
			guard(channel <= MAX_CHANNEL) else {return false}
		}

		guard let changeValue = event.controllerChangeValue else {return false}

		switch(event.controllerNumber) {
			case MODE_LOCAL_CONTROL_CHK:
				ctrlModeState = (changeValue == 0) ? .LOCAL_CONTROL_OFF : .LOCAL_CONTROL_ON
			case MODE_ALL_NOTES_CHK:
				ctrlModeState = (changeValue == 0) ? .ALL_NOTES_OFF : .UNDEFINED
			case MODE_OMNI_MODE_ON:
				ctrlModeState = (changeValue == 0) ? .OMNI_MODE_ON : .UNDEFINED
			case MODE_OMNI_MODE_OFF:
				ctrlModeState = (changeValue == 0) ? .OMNI_MODE_OFF : .UNDEFINED
			case MODE_MONO_MODE_ON:
				ctrlModeState = .MONO_MODE_ON
				numberOfChannels = changeValue
			case MODE_MONO_MODE_OFF:
				ctrlModeState = .MONO_MODE_OFF
			default:
				return processStandardControlMessage(event:event)
		}

		Printer.printUInt8AsHex(X: numberOfChannels)
		Printer.printUInt8AsHex(X: ctrlModeState.rawValue)

		return true
	}
	
	private func processStandardControlMessage(event:MidiChannelEvent) -> Bool
	{
		guard let controlNumber:UInt8 = event.controllerNumber else {return false}
		guard let controlValue:UInt8 = event.controllerChangeValue else {return false}
		
		//Don't set this to an enum in the event struct during the initial processing of the message
		//since, depending on the control message type - the controllerNumber can have different meanings.
		let controlDevideID:MidiControllerMessage? = MidiControllerMessage(rawValue: controlNumber)
		
		guard controlDevideID != nil else {return false}
		
		Printer.printUInt8AsHex(X: controlValue)
		
		return true
	}
}
