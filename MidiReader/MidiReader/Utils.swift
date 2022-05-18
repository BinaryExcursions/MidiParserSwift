//
//  Utils.swift
//  MidiReader
//
//  Created by Jeff Behrbaum on 4/26/22.
//

import Foundation

class Utils
{
	class func byteToChar(byte:UInt8) -> (Bool, Character?)
	{
		var b:Array<UInt8> = Array<UInt8>()
		b.append(byte)
		
		guard let s:String = String(bytes:b, encoding: .utf8) else {
			return (false, nil)
		}
		
		let c:Character = Character(s)
		
		return ((c.isLetter || c.isNumber), c)
	}
	
	class func into16Bit(byte1:UInt8, byte2:UInt8) -> UInt16
	{
		var X:UInt16 = 0

		var X1:UInt16 = UInt16(byte1)
		X1 = (X1 << 8)
		
		X = X1 + UInt16(byte2)
		//X = UInt32(  (byte1 << 24) + (byte2 << 16) + (byte3 << 8) + byte4 )
		
		Printer.printUInt16AsHex(X:X)
		Printer.printByteValuesAsHex(byte1:byte1, byte2:byte2, numBytes: 2)
		Printer.printByteValuesAsBinary(byte1:byte1, byte2:byte2, numBytes: 2)
		Printer.printByteValuesAsDecimal(byte1:byte1, byte2:byte2, numBytes: 2)

		return X
	}
	
	class func into32Bit(byte1:UInt8, byte2:UInt8, byte3:UInt8, byte4:UInt8) -> UInt32
	{
		var X:UInt32 = 0

		var X1:UInt32 = UInt32(byte1)
		X1 = (X1 << 24)
		
		var X2:UInt32 = UInt32(byte2)
		X2 = (X2 << 16)
		
		var X3:UInt32 = UInt32(byte3)
		X3 = (X3 << 8)

		X = X1 + X2 + X3 + UInt32(byte4)
		//X = UInt32(  (byte1 << 24) + (byte2 << 16) + (byte3 << 8) + byte4 )
		
		Printer.printUInt32AsHex(X:X)
		Printer.printByteValuesAsHex(byte1:byte1, byte2:byte2, byte3:byte3, byte4:byte4)
		Printer.printByteValuesAsBinary(byte1:byte1, byte2:byte2, byte3:byte3, byte4:byte4)
		Printer.printByteValuesAsDecimal(byte1:byte1, byte2:byte2, byte3:byte3, byte4:byte4)

		return X
	}
	
	//I think this really will only ever be a UInt32 - MAX!
	class func readVariableLengthValue(startIdx:inout Int, data:Data) -> UInt32
	{
		guard (startIdx > 0) && (startIdx < data.count)  else {return 0}
		
		var numberOfBytesRead:Int = 0 //We know we're going to read at least one byte

		var totalValue:UInt32 = 0
		var valueAtByteValue:UInt8 = 0
		
		repeat {
			valueAtByteValue = data[startIdx]
			
			//You MUST clear out the leading bit before adding it to our deltatime value! Just simply
			//ALWAYS doing it since it does no harm regardless if the leading bit is 0 or 1
			//but keeps the logic and readablity clean
			let deltaTimeValueToAdd = valueAtByteValue & MSB_REST_VALUE //Need to use a tmp variable so the loop predicate still works correctly

			totalValue <<= (numberOfBytesRead * 8)//First shift our stored value. 8 because it is the size of a byte
			totalValue += UInt32(deltaTimeValueToAdd)
			
			startIdx += 1
			numberOfBytesRead += 1
		}while ((valueAtByteValue & MSB_TEST_VALUE) == MSB_TEST_VALUE)
		
		return totalValue//(delta:UInt32(deltaTime), numBytesRead:numberOfBytesRead)
	}
	
	class func timeSignatureFromNumeratorDenominator(numerator:UInt8, denominator:UInt8) -> TimingInfo
	{
		let timing:TimingInfo = .COMMON

		//First get the denominator to a base 10 non-decimal value. if: Denominator may come is as 3
		//Which means 2^-3 - this is because it's supposed to denote 2/8 for example
		let D:UInt8 = 2^denominator
		
		guard(D>0 && ((D & (D-1)) == 0)) else {return .COMMON}

		if(numerator == 2) && (D == 2) {
			return .CUT
		}
		else if(numerator == 4) && (D == 4) {
			return .COMMON
		}
		
		if(numerator == 2){
			switch(D) {
				case 4:
					return .TWO_FOUR
				case 8:
					return .TWO_EIGHT
				case 16:
					return .TWO_SIXTEEN
				default:
					return .CUT
			}
		}
		else if(numerator == 3) {
			switch(D) {
				case 2:
					return .THREE_TWO
				case 4:
					return .THREE_FOUR
				case 8:
					return .THREE_EIGHT
				case 16:
					return .THREE_SIXTEEN
				default:
					return .COMMON
			}
		}
		else if(numerator == 4) {
			switch(D) {
				case 2:
					return .FOUR_TWO
				case 8:
					return .FOUR_EIGHT
				case 16:
					return .FOUR_SIXTEEN
				default:
					return .COMMON
			}
		}
		else if(numerator == 5) {
			switch(D) {
				case 2:
					return .FIVE_TWO
				case 4:
					return .FIVE_FOUR
				case 8:
					return .FIVE_EIGHT
				case 16:
					return .FIVE_SIXTEEN
				default:
					return .COMMON
			}
		}
		else if(numerator == 6) {
			switch(D) {
				case 2:
					return .SIX_TWO
				case 4:
					return .SIX_FOUR
				case 8:
					return .SIX_EIGHT
				case 16:
					return .SIX_SIXTEEN
				default:
					return .COMMON
			}
		}
		else if(numerator == 7) {
			switch(D) {
				case 2:
					return .SEVEN_TWO
				case 4:
					return .SEVEN_FOUR
				case 8:
					return .SEVEN_EIGHT
				case 16:
					return .SEVEN_SIXTEEN
				default:
					return .COMMON
			}
		}
		else if(numerator == 8) {
			switch(D) {
				case 2:
					return .EIGHT_TWO
				case 4:
					return .EIGHT_FOUR
				case 8:
					return .EIGHT_EIGHT
				case 16:
					return .EIGHT_SIXTEEN
				default:
					return .COMMON
			}
		}
		else if(numerator == 9) {
			switch(D) {
				case 2:
					return .NINE_TWO
				case 4:
					return .NINE_FOUR
				case 8:
					return .NINE_EIGHT
				case 16:
					return .NINE_SIXTEEN
				default:
					return .COMMON
			}
		}

		return timing
	}
	
	//IMPORTANT!!!!! Channel value of 0 is refered to as channel 1. Ie: it's zero index based like an array [1, 2, 3, 4...]
	//Channel value at index 0 is 1
	class func valueToChannelVoiceMessage(messageValue:UInt8) -> (msg:MidiMajorMessage, channel:UInt8)
	{
		let channelCtrl:UInt8 = 0x0F
		let chnl:UInt8 = messageValue & channelCtrl
		var voiceMsg:MidiMajorMessage = .NOTE_OFF
		
		if( (messageValue & MidiMajorMessage.NOTE_OFF.rawValue) == MidiMajorMessage.NOTE_OFF.rawValue) {
			voiceMsg = MidiMajorMessage.NOTE_OFF}
		else if( (messageValue & MidiMajorMessage.NOTE_ON.rawValue) == MidiMajorMessage.NOTE_ON.rawValue) {
			voiceMsg = MidiMajorMessage.NOTE_ON}
		else if( (messageValue & MidiMajorMessage.KEY_PRESSURE_AFTER_TOUCH.rawValue) == MidiMajorMessage.KEY_PRESSURE_AFTER_TOUCH.rawValue) {
			voiceMsg = MidiMajorMessage.KEY_PRESSURE_AFTER_TOUCH}
		else if( (messageValue & MidiMajorMessage.CONTROL_CHANGE.rawValue) == MidiMajorMessage.CONTROL_CHANGE.rawValue) {
			voiceMsg = MidiMajorMessage.CONTROL_CHANGE}
		else if( (messageValue & MidiMajorMessage.PROGRAM_CHANGE.rawValue) == MidiMajorMessage.PROGRAM_CHANGE.rawValue) {
			voiceMsg = MidiMajorMessage.PROGRAM_CHANGE}
		else if( (messageValue & MidiMajorMessage.CHANNEL_PRESSURE_AFTER_TOUCH.rawValue) == MidiMajorMessage.CHANNEL_PRESSURE_AFTER_TOUCH.rawValue) {
			voiceMsg = MidiMajorMessage.CHANNEL_PRESSURE_AFTER_TOUCH}
		else if( (messageValue & MidiMajorMessage.PITCH_WHEEL_CHANGE.rawValue) == MidiMajorMessage.PITCH_WHEEL_CHANGE.rawValue) {
			voiceMsg = MidiMajorMessage.PITCH_WHEEL_CHANGE}
		else {
			voiceMsg = MidiMajorMessage.UNDEFINED}

		return (voiceMsg, chnl)
	}

	class func valueToGeneralFamily(familyValue:UInt8) -> MidiInstrumentGeneralFamily
	{
		switch(familyValue) {
			case 1...8:
				return .INST_FAMILY_PIANO
			case 9...16:
				return .INST_FAMILY_CHROMATIC_PRECUSSION
			case 17...24:
				return .INST_FAMILY_ORGAN
			case 25...32:
				return .INST_FAMILY_GUITAR
			case 33...40:
				return .INST_FAMILY_BASS
			case 41...48:
				return .INST_FAMILY_STRINGS
			case 49...56:
				return .INST_FAMILY_ENSENBLE
			case 57...64:
				return .INST_FAMILY_BRASS
			case 65...72:
				return .INST_FAMILY_REED
			case 73...80:
				return .INST_FAMILY_PIPE
			case 81...88:
				return .INST_FAMILY_SYNTH_LEAD
			case 89...96:
				return .INST_FAMILY_SYNTH_PAD
			case 97...104:
				return .INST_FAMILY_SYNTH_EFFECTS
			case 105...112:
				return .INST_FAMILY_ETHNIC
			case 113...120:
				return .INST_FAMILY_PERCUSSIVE
			case 121...128:
				return .INST_FAMILY_SOUND_EFFECTS
			default:
				return .INST_FAMILY_PIANO
		}//End switch
	}
	
	class func valueToInstrumentPatch(patchValue:UInt16) -> MidiInstrumentPatch
	{
		switch(patchValue) {
			case 1:
				return .ACOUSTIC_GRAND_PIANO
			case 2:
				return .BRIGHT_ACOUSTIC_PIANO
			case 3:
				return .ELECTRIC_GRAND_PIANO
			case 4:
				return .HONKY_TONK_PIANO
			case 5:
				return .ELECTRIC_PIANO_1_RHODES_PIANO
			case 6:
				return .ELECTRIC_PIANO_2_CHORUSED_PIANO
			case 7:
				return .HARPSICHORD
			case 8:
				return .CLAVINET
			case 9:
				return .CELESTA
			case 10:
				return .GLOCKENSPIEL
			case 11:
				return .MUSIC_BOX
			case 12:
				return .VIBRAPHONE
			case 13:
				return .MARIMBA
			case 14:
				return .XYLOPHONE
			case 15:
				return .TUBULAR_BELLS
			case 16:
				return .DULCIMER_SANTUR
			case 17:
				return .DRAWBAR_ORGAN_HAMMOND
			case 18:
				return .PERCUSSIVE_ORGAN
			case 19:
				return .ROCK_ORGAN
			case 20:
				return .CHURCH_ORGAN
			case 21:
				return .REED_ORGAN
			case 22:
				return .ACCORDION_FRENCH
			case 23:
				return .HARMONICA
			case 24:
				return .TANGO_ACCORDION_BAND_NEON
			case 25:
				return .ACOUSTIC_GUITAR_NYLON
			case 26:
				return .ACOUSTIC_GUITAR_STEEL
			case 27:
				return .ELECTRIC_GUITAR_JAZZ
			case 28:
				return .ELECTRIC_GUITAR_CLEAN
			case 29:
				return .ELECTRIC_GUITAR_MUTED
			case 30:
				return .OVERDRIVEN_GUITAR
			case 31:
				return .DISTORTION_GUITAR
			case 32:
				return .GUITAR_HARMONICS
			case 33:
				return .ACOUSTIC_BASS
			case 34:
				return .ELECTRIC_BASS_FINGERED
			case 35:
				return .ELECTRIC_BASS_PICKED
			case 36:
				return .FRETLESS_BASS
			case 37:
				return .SLAP_BASS_1
			case 38:
				return .SLAP_BASS_2
			case 39:
				return .SYNTH_BASS_1
			case 40:
				return .SYNTH_BASS_2
			case 41:
				return .VIOLIN
			case 42:
				return .VIOLA
			case 43:
				return .CELLO
			case 44:
				return .CONTRABASS
			case 45:
				return .TREMOLO_STRINGS
			case 46:
				return .PIZZICATO_STRINGS
			case 47:
				return .ORCHESTRAL_HARP
			case 48:
				return .TIMPANI
			case 49:
				return .STRING_ENSEMBLE_1_STRINGS
			case 50:
				return .STRING_ENSEMBLE_2_SLOW_STRINGS
			case 51:
				return .SYNTHSTRINGS_1
			case 52:
				return .SYNTHSTRINGS_2
			case 53:
				return .CHOIR_AAHS
			case 54:
				return .VOICE_OOHS
			case 55:
				return .SYNTH_VOICE
			case 56:
				return .ORCHESTRA_HIT
			case 57:
				return .TRUMPET
			case 58:
				return .TROMBONE
			case 59:
				return .TUBA
			case 60:
				return .MUTED_TRUMPET
			case 61:
				return .FRENCH_HORN
			case 62:
				return .BRASS_SECTION
			case 63:
				return .SYNTHBRASS_1
			case 64:
				return .SYNTHBRASS_2
			case 65:
				return .SOPRANO_SAX
			case 66:
				return .ALTO_SAX
			case 67:
				return .TENOR_SAX
			case 68:
				return .BARITONE_SAX
			case 69:
				return .OBOE
			case 70:
				return .ENGLISH_HORN
			case 71:
				return .BASSOON
			case 72:
				return .CLARINET
			case 73:
				return .PICCOLO
			case 74:
				return .FLUTE
			case 75:
				return .RECORDER
			case 76:
				return .PAN_FLUTE
			case 77:
				return .BLOWN_BOTTLE
			case 78:
				return .SHAKUHACHI
			case 79:
				return .WHISTLE
			case 80:
				return .OCARINA
			case 81:
				return .LEAD_1_SQUARE_WAVE
			case 82:
				return .LEAD_2_SAWTOOTH_WAVE
			case 83:
				return .LEAD_3_CALLIOPE
			case 84:
				return .LEAD_4_CHIFFER
			case 85:
				return .LEAD_5_CHARANG
			case 86:
				return .LEAD_6_VOICE_SOLO
			case 87:
				return .LEAD_7_FIFTHS
			case 88:
				return .LEAD_8_BASS_LEAD
			case 89:
				return .PAD_1_NEW_AGE_FANTASIA
			case 90:
				return .PAD_2_WARM
			case 91:
				return .PAD_3_POLYSYNTH
			case 92:
				return .PAD_4_CHOIR_SPACE_VOICE
			case 93:
				return .PAD_5_BOWED_GLASS
			case 94:
				return .PAD_6_METALLIC_PRO
			case 95:
				return .PAD_7_HALO
			case 96:
				return .PAD_8_SWEEP
			case 97:
				return .FX_1_RAIN
			case 98:
				return .FX_2_SOUNDTRACK
			case 99:
				return .FX_3_CRYSTAL
			case 100:
				return .FX_4_ATMOSPHERE
			case 101:
				return .FX_5_BRIGHTNESS
			case 102:
				return .FX_6_GOBLINS
			case 103:
				return .FX_7_ECHOES_DROPS
			case 104:
				return .FX_8_SCI_FI_STAR_THEME
			case 105:
				return .SITAR
			case 106:
				return .BANJO
			case 107:
				return .SHAMISEN
			case 108:
				return .KOTO
			case 109:
				return .KALIMBA
			case 110:
				return .BAG_PIPE
			case 111:
				return .FIDDLE
			case 112:
				return .SHANAI
			case 113:
				return .TINKLE_BELL
			case 114:
				return .AGOGO
			case 115:
				return .STEEL_DRUMS
			case 116:
				return .WOODBLOCK
			case 117:
				return .TAIKO_DRUM
			case 118:
				return .MELODIC_TOM
			case 119:
				return .SYNTH_DRUM
			case 120:
				return .REVERSE_CYMBAL
			case 121:
				return .GUITAR_FRET_NOISE
			case 122:
				return .BREATH_NOISE
			case 123:
				return .SEASHORE
			case 124:
				return .BIRD_TWEET
			case 125:
				return .TELEPHONE_RING
			case 126:
				return .HELICOPTER
			case 127:
				return .APPLAUSE
			case 128:
				return .GUNSHOT
			default:
				return .ACOUSTIC_GRAND_PIANO
		}//End switch
	}
	
	class func valueToPrecussionPatch(precussionValue:UInt8) -> PrecussionKeyMap
	{
		switch(precussionValue) {
			case 35:
				return (precussionValue, .OCTAVE_ONE_B, .ACOUSTIC_BASS_DRUM)
			case 36:
				return (precussionValue, .OCTAVE_TWO_C, .BASS_DRUM_1)
			case 37:
				return (precussionValue, .OCTAVE_TWO_C_SHRP, .SIDE_STICK)
			case 38:
				return (precussionValue, .OCTAVE_TWO_D, .ACOUSTIC_SNARE)
			case 39:
				return (precussionValue, .OCTAVE_TWO_D_SHRP, .HAND_CLAP)
			case 40:
				return (precussionValue, .OCTAVE_TWO_E, .ELECTRIC_SNARE)
			case 41:
				return (precussionValue, .OCTAVE_TWO_F, .LOW_FLOOR_TOM)
			case 42:
				return (precussionValue, .OCTAVE_TWO_F_SHRP, .CLOSED_HI_HAT)
			case 43:
				return (precussionValue, .OCTAVE_TWO_G, .HIGH_FLOOR_TOM)
			case 44:
				return (precussionValue, .OCTAVE_TWO_G_SHRP, .PEDAL_HI_HAT)
			case 45:
				return (precussionValue, .OCTAVE_TWO_A, .LOW_TOM)
			case 46:
				return (precussionValue, .OCTAVE_TWO_A_SHARP, .OPEN_HI_HAT)
			case 47:
				return (precussionValue, .OCTAVE_TWO_B, .LOW_MID_TOM)
			case 48:
				return (precussionValue, .OCTAVE_THREE_C, .HI_MID_TOM)
			case 49:
				return (precussionValue, .OCTAVE_THREE_C_SHRP, .CRASH_CYMBAL_1)
			case 50:
				return (precussionValue, .OCTAVE_THREE_D, .HIGH_TOM)
			case 51:
				return (precussionValue, .OCTAVE_THREE_D_SHRP, .RIDE_CYMBAL_1)
			case 52:
				return (precussionValue, .OCTAVE_THREE_E, .CHINESE_CYMBAL)
			case 53:
				return (precussionValue, .OCTAVE_THREE_F, .RIDE_BELL)
			case 54:
				return (precussionValue, .OCTAVE_THREE_F_SHRP, .TAMBOURINE)
			case 55:
				return (precussionValue, .OCTAVE_THREE_G, .SPLASH_CYMBAL)
			case 56:
				return (precussionValue, .OCTAVE_THREE_G_SHRP, .COWBELL)
			case 57:
				return (precussionValue, .OCTAVE_THREE_A, .CRASH_CYMBAL_2)
			case 58:
				return (precussionValue, .OCTAVE_THREE_A_SHARP, .VIBRASLAP)
			case 59:
				return (precussionValue, .OCTAVE_THREE_B, .RIDE_CYMBAL_2)
			case 60:
				return (precussionValue, .OCTAVE_FOUR_C, .HI_BONGO)
			case 61:
				return (precussionValue, .OCTAVE_FOUR_C_SHRP, .LOW_BONGO)
			case 62:
				return (precussionValue, .OCTAVE_FOUR_D, .MUTE_HI_CONGA)
			case 63:
				return (precussionValue, .OCTAVE_FOUR_D_SHRP, .OPEN_HI_CONGA)
			case 64:
				return (precussionValue, .OCTAVE_FOUR_E, .LOW_CONGA)
			case 65:
				return (precussionValue, .OCTAVE_FOUR_F, .HIGH_TIMBALE)
			case 66:
				return (precussionValue, .OCTAVE_FOUR_F_SHRP, .LOW_TIMBALE)
			case 67:
				return (precussionValue, .OCTAVE_FOUR_G, .HIGH_AGOGO)
			case 68:
				return (precussionValue, .OCTAVE_FOUR_G_SHRP, .LOW_AGOGO)
			case 69:
				return (precussionValue, .OCTAVE_FOUR_A, .CABASA)
			case 70:
				return (precussionValue, .OCTAVE_FOUR_A_SHARP, .MARACAS)
			case 71:
				return (precussionValue, .OCTAVE_FOUR_B, .SHORT_WHISTLE)
			case 72:
				return (precussionValue, .OCTAVE_FIVE_C, .LONG_WHISTLE)
			case 73:
				return (precussionValue, .OCTAVE_FIVE_C_SHRP, .SHORT_GUIRO)
			case 74:
				return (precussionValue, .OCTAVE_FIVE_D, .LONG_GUIRO)
			case 75:
				return (precussionValue, .OCTAVE_FIVE_D_SHRP, .CLAVES)
			case 76:
				return (precussionValue, .OCTAVE_FIVE_E, .HI_WOOD_BLOCK)
			case 77:
				return (precussionValue, .OCTAVE_FIVE_F, .LOW_WOOD_BLOCK)
			case 78:
				return (precussionValue, .OCTAVE_FIVE_F_SHRP, .MUTE_CUICA)
			case 79:
				return (precussionValue, .OCTAVE_FIVE_G, .OPEN_CUICA)
			case 80:
				return (precussionValue, .OCTAVE_FIVE_G_SHRP, .MUTE_TRIANGLE)
			case 81:
				return (precussionValue, .OCTAVE_FIVE_A, .OPEN_TRIANGLE)
			default:
				return (35, .OCTAVE_ONE_B, .ACOUSTIC_BASS_DRUM)
		}//End Switch
	}
	
	class func valuesToMusicalKey(numShrpFlats:Int8, MajMin:UInt8) -> MusicalKey
	{
		var musicalKey:MusicalKey = .C_MAJ
		
		if(numShrpFlats == 0) {return (MajMin == 0) ? .C_MAJ : .A_MIN}
		
		//Is 4th since the circle of 5ths counter-clockwise is the circle of
		//4ths and these are the keys which contain flats instead of sharps.
		let is4th:Bool = (numShrpFlats < 0)
		
		switch(abs(numShrpFlats)) {
			case 1:
				if(is4th == false) {musicalKey = (MajMin == 0) ? .G_MAJ : .E_MIN}
				else {musicalKey = (MajMin == 0) ? .F_MAJ : .D_MIN}
			case 2:
				if(is4th == false) {musicalKey = (MajMin == 0) ? .D_MAJ : .B_MIN}
				else {musicalKey = (MajMin == 0) ? .BFLAT_MAJ : .G_MIN}
			case 3:
				if(is4th == false) {musicalKey = (MajMin == 0) ? .A_MAJ : .FSHRP_MIN}
				else {musicalKey = (MajMin == 0) ? .EFLAT_MAJ : .C_MIN}
			case 4:
				if(is4th == false) {musicalKey = (MajMin == 0) ? .E_MAJ : .CSHRP_MIN}
				else {musicalKey = (MajMin == 0) ? .AFLAT_MAJ : .F_MIN}
			case 5:
				if(is4th == false) {musicalKey = (MajMin == 0) ? .B_MAJ : .GSHRP_MIN}
				else {musicalKey = (MajMin == 0) ? .DFLAT_MAJ : .BFLAT_MIN}
			case 6:
				if(is4th == false) {musicalKey = (MajMin == 0) ? .FSHRP_MAJ : .DSHRP_MIN}
				else {musicalKey = (MajMin == 0) ? .GFLAT_MAJ : .EFLAT_MIN}
			case 7:
				if(is4th == false) {musicalKey = (MajMin == 0) ? .CSHRP_MAJ : .ASHRP_MIN}
				else {musicalKey = (MajMin == 0) ? .CFLAT_MAJ : .AFLAT_MIN}
			default:
				()
		}
		
		return musicalKey
	}
}
