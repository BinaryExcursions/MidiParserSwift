//
//  midiDataComponents.swift
//  MidiReader
//
//  Created by Jeff Behrbaum on 4/27/22.
//

import Foundation

let MIDI_HDR_VALUE:UInt32 = 0x4D546864 //This is MThd
let MIDI_HDR_LEN_VALUE:UInt32 = 0x6 //This seems to be the standard number according to the specs

class MidiRecordHeader
{
	private var m_Title:UInt32 = 0
	private var m_Length:UInt32 = 0
	private var m_TimeDivision:UInt16 = 0
	private var m_NumberOfTracks:UInt16 = 0
	private var m_MidiFileType:MidiType = .SIMULTANEOUS
		
	var Title:UInt32 {
		get{return m_Title}
		set{
			//DO NOT HARD-CODE THIS VALUE!!!!!  I MUST be set from the file or stream being read in.
			guard newValue == MIDI_HDR_VALUE else {return}
			
			m_Title = newValue
		}
	}
	
	var Length:UInt32 {
		get{return m_Length}
		set{
			guard newValue == MIDI_HDR_LEN_VALUE else {return}
			
			m_Length = newValue
		}
	}
		
	var TimeDivision:UInt16 {
		get{return m_TimeDivision}
		set{
			guard newValue > 0 else {return}
			
			m_TimeDivision = newValue
		}
	}
	
	var NumberOfTracks:UInt16 {
		get{return m_NumberOfTracks}
		set{
			guard newValue >= 1 else{return}
			m_NumberOfTracks = newValue
		}
	}
	
	var MidiFileType:MidiType {
		get{return m_MidiFileType}
		set{m_MidiFileType = newValue}
	}
	
	func numberToMidiType(num:UInt16) -> MidiType
	{
		switch(num)
		{
			case 0:
				return .SINGLE
			case 1:
				return .SIMULTANEOUS
			default:
				return .SEQUENTIAL
		}
	}
	
	func midiTypeToNumber(mt:MidiType) -> UInt16
	{
		switch(m_MidiFileType) {
			case .SINGLE:
				return 0x0000
			case .SIMULTANEOUS:
				return 0x0001
			case .SEQUENTIAL:
				return 0x0002
		}
	}
}
