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

let midiReader:MidiReader = MidiReader()

guard midiReader.openMidiFile(fileName:filePath) != false else {
	exit(0)
}

var midiHeader:MidiHeader = MidiHeader()
var lastIdxRead = midiReader.readHeader(hdr: midiHeader) + 1

while(lastIdxRead > 0) {
	lastIdxRead = midiReader.readTrack(startIndex:lastIdxRead)
}
