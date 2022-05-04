//
//  midiRecord.swift
//  MidiReader
//
//  Created by Jeff Behrbaum on 4/29/22.
//

import Foundation

class MidiRecord
{
	private var m_midiHeader:MidiRecordHeader?
	private lazy var m_Tracks:Array<MidiTrack> = Array<MidiTrack>()
	
	var Header:MidiRecordHeader? {
		get{return m_midiHeader}
		set{m_midiHeader = newValue}
	}
	
	subscript(index: Int) -> MidiTrack?{
		get{
			guard( (index >= 0) && (index < m_Tracks.count) ) else {
				return nil
			}

			return m_Tracks[index]
		}
	}
	
	func appendTrack(track:MidiTrack)
	{
		m_Tracks.append(track)
	}
}
