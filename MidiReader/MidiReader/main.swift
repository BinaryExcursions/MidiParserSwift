//
//  main.swift
//  MidiReader
//
//  Created by Jeff Behrbaum on 4/26/22.
//

import Foundation

Printer.printIsActive = false
 
let PATH:String = "/Users/president/Desktop/FooSimple.mid"
Printer.printMessage(msg:"File Name: \(PATH)\n--------------\n")

var filePath = PATH//+ (readLine() ?? "-")

let midiRecord:MidiRecord = MidiRecord()
let midiReader:MidiReader = MidiReader()

guard midiReader.openMidiFile(fileName:filePath) != false else {exit(0)}

var midiHeader:MidiHeader = MidiHeader()
var lastIdxRead = midiReader.readHeader(hdr: midiHeader) + 1

midiRecord.Header = midiHeader

while(lastIdxRead > 0) {
	let trackInfo:(offsetIdx:Int, track:MidiTrack?) = midiReader.readTrack(startIndex:lastIdxRead)

	if let track = trackInfo.track {
		midiRecord.appendTrack(track: track)
	}
	
	lastIdxRead = trackInfo.offsetIdx
}
