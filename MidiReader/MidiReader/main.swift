//
//  main.swift
//  MidiReader
//
//  Created by Jeff Behrbaum on 4/26/22.
//

//File info from:
//https://midimusic.github.io/tech/midispec.html

import Foundation

Printer.printIsActive = false
 
let PATH:String = "/Users/president/Desktop/FooSimple.mid"
Printer.printMessage(msg:"File Name: \(PATH)\n--------------\n")

var filePath = PATH//+ (readLine() ?? "-")

let midiRecord:MidiRecord = MidiRecord()
let midiReader:MidiReader = MidiReader()

guard midiReader.openMidiFile(fileName:filePath) != false else {exit(0)}

var midiHeader:MidiRecordHeader = MidiRecordHeader()
var lastIdxRead = midiReader.readMidiRecordHeader(hdr: &midiHeader) + 1

midiRecord.Header = midiHeader
let trackInfo:MidiTrack? = nil

 repeat {
	let trackInfo:MidiTrack? = midiReader.readTrack(startIndex:&lastIdxRead)

	if let track = trackInfo {
		midiRecord.appendTrack(track: track)
	}
}while(trackInfo != nil)
