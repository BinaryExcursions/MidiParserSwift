//
//  midiTrackComponent.swift
//  MidiReader
//
//  Created by Jeff Behrbaum on 4/27/22.
//

import Foundation

let MIDI_TRK_VALUE:UInt32 = 0x4D54726B //This is MTrk

class MidiEventNote
{
	private var m_Key:MidiNote = .OCTAVE_ZERO_C
	private var precussioinNote:PrecussionKeyMap?
	private var m_Velocity:UInt8 = 0
	private var m_StartTime:UInt32 = 0
	private var m_Duration:UInt32 = 0
}

class MidiEvent
{
	private var m_Instrument:String?
	private var m_EventType:TrackEventType = .MIDI_EVENT
	private var m_DeltaTime:UInt32 = 0 //This is actaully variable length - BUT 4 bytes should cover even the largest values
	
	//The event is the data which takes place immediately after the deltatime is reached
	//ie: Delta time = 1 second, in exactly 1 second, the event will occur.
	var EventType:TrackEventType {
		get{return m_EventType}
		set{m_EventType = newValue}
	}
	
	var DeltaTime:UInt32 {
		get{return m_DeltaTime}
		set{m_DeltaTime = newValue}
	}
}

class MidiTrack
{
	//--Holders until I know more about these variables
	private var m_ChunkType:Int = 0 //I think this is actually the MTrk
	private var m_ChunkLength:Int = 0 //I think this is the nummber of bytes in the record chunk
	private lazy var m_TrackEvents:Array<MidiEvent> = Array<MidiEvent>()
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


	
}
