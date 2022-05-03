//
//  defs.swift
//  MidiReader
//
//  Created by Jeff Behrbaum on 4/27/22.
//

import Foundation

typealias PrecussionKeyMap = (keyNum:UInt8, noteMapping:MidiNote, precussionName:MidiPrecussionMap)

enum MidiType {
	case SINGLE,
	SIMULTANEOUS,
	SEQUENTIAL
}

enum TimeingInfo {
	case COMMON,
	CUT,
	FOUR_FOUR,
	TWO_FOUR,
	THREE_FOUR
}

enum TrackEventType {
	case MIDI_EVENT,
	SYSEX_EVENT,
	SYSREALTIME_EVENT,
	META_EVENT
}

enum MetaEventDefinitions:UInt16, CaseIterable {
	case UNKNOWN = 0x0000,
	SEQUENCE_NUMBER = 0xFF00, //Will be followed by 02 then the sequence number
	TEXT_INFO = 0xFF01, //Followed by LEN, TEXT. NOTE: The 0xFF01 - 0xFF0F are all reserved for text messages.
	COPYRIGHT = 0xFF02,
	TEXT_SEQUENCE = 0xFF03,
	TEXT_INSTRUMENT = 0xFF04,
	TEXT_LYRIC = 0xFF05,
	TEXT_MARKER = 0xFF06,
	TEXT_CUE_POINT = 0xFF07,
	MIDI_CHANNEL = 0xFF20,
	PORT_SELECTION = 0xFF21, //Also has a 01 after the 21, and then a byte (0 - 127) Identifing the port number.
	END_OF_TRACK = 0xFF2F,
	TEMPO = 0xFF51,
	SMPTE = 0xFF54,
	TIME_SIGNATURE = 0xFF58,
	MINI_TIME_SIGNATURE = 0xFF59,
	SPECIAL_SEQUENCE = 0xFF7F
}

//Section 1.1 - Major Midi messages defined
enum MidiMajorMessage:UInt8 {
	case UNDEFINED = 0x00,

	//MidiChannel Voice/Mode Message - Commonly refered to as simply channel messages
	NOTE_OFF = 0x80,
	NOTE_ON = 0x90,
	KEY_PRESSURE_AFTER_TOUCH = 0xA0,
	CONTROL_CHANGE = 0xB0, //There is particular rules to follow to interpret this message
	PROGRAM_CHANGE = 0xC0,
	CHANNEL_PRESSURE_AFTER_TOUCH = 0xD0,
	PITCH_WHEEL_CHANGE = 0xE0,
	
	//Section 1.1 - Third messages defined: MidiSystemCommonMessages
	SYS_EXCLUSIVE = 0xF0,
	SONG_POSITION_POINTER = 0xF2,
	SONG_SELECT = 0xF3,
	TUNE_REQUEST = 0xF6,
	END_OF_EXCLUSIVE = 0xF7,
	
	//Section 1.1 - Last messages defined - MidiSystemRealTimeMessage
	TIMING_CLOCK = 0xF8,
	START_SEQUENCE = 0xFA,
	CONTINUE_AT_POINT_OF_SEQUENCE_STOP = 0xFB,
	STOP_SEQUENCE = 0xFC,
	ACTIVE_SENSING = 0xFE,
	RESET = 0xFF
}

//IF - your mode control message implements mode control - which is identified if the first of the two
//bytes following the status message has a value of 122, 123, 124, 125, 126, or 127 then you'll use both
//the control number in combination with the new value to be in one of the following control modes
enum MidiEventModeControlStates:UInt8 {
	case UNDEFINED,
	LOCAL_CONTROL_ON,
	LOCAL_CONTROL_OFF,
	ALL_NOTES_OFF,
	OMNI_MODE_OFF,
	OMNI_MODE_ON,
	MONO_MODE_ON,
	MONO_MODE_OFF
}

//From Table 1.2
//These are the 2nd byte message identifier values - NOT the actual 3rd byte values
//https://midimusic.github.io/tech/midispec.html#BMA1_
//
// For iterations - example:
// for msg in MidiControllerMessage.allCases {...}
enum MidiControllerMessage:UInt8, CaseIterable {
	case BANK_SELECT = 0x00,
	MODULATION_WHEEL = 0x01,
	BREATH_CONTROL = 0x02,
	FOOT_CONTROL = 0x04,
	PORTAMENTO_TIME = 0x05,
	DATA_ENTRY = 0x06,
	CHANNEL_VOLUME = 0x07,
	BALANCE = 0x08,
	PAN = 0x0A,
	EXPRESSION_CONTROLLER = 0x0B,
	EFFECT_CTRL_1 = 0x0C,
	EFFECT_CTRL_2 = 0x0D,
	GEN_PURPOSE_CTRLR_1 = 0x10,
	GEN_PURPOSE_CTRLR_2 = 0x11,
	GEN_PURPOSE_CTRLR_3 = 0x12,
	GEN_PURPOSE_CTRLR_4 = 0x13,
	
	//There seems to be two values which apply to the same named messages
	BANK_SELECT_2nd = 0x20,
	MODULATION_WHEEL_2nd = 0x21,
	BREATH_CONTROL_2nd = 0x22,
	FOOT_CONTROL_2nd = 0x24,
	PORTAMENTO_TIME_2nd = 0x25,
	DATA_ENTRY_2nd = 0x26,
	CHANNEL_VOLUME_2nd = 0x27,
	BALANCE_2nd = 0x28,
	PAN_2nd = 0x2A,
	EXPRESSION_CONTROLLER_2nd = 0x2B,
	EFFECT_CTRL_1_2nd = 0x2C,
	EFFECT_CTRL_2_2nd = 0x2D,
	GEN_PURPOSE_CTRLR_1_2nd = 0x30,
	GEN_PURPOSE_CTRLR_2_2nd = 0x31,
	GEN_PURPOSE_CTRLR_3_2nd = 0x32,
	GEN_PURPOSE_CTRLR_4_2nd = 0x33,
	
	DAMPER_PEDAL_ON_OFF_SUSTAIN = 0x40,
	PORTAMENTO_ON_OFF = 0x41,
	SUSTENUTO_ON_OFF = 0x42,
	SOFT_PEDEL_ON_OFF = 0x43,
	LEGATO_FOOTSWITCH = 0x44,
	HOLD_2 = 0x45,
	SOUND_CTRLR_1 = 0x46,
	SOUND_CTRLR_2 = 0x47,
	SOUND_CTRLR_3 = 0x48,
	SOUND_CTRLR_4 = 0x49,
	SOUND_CTRLR_5 = 0x4A,
	SOUND_CTRLR_6 = 0x4B,
	SOUND_CTRLR_7 = 0x4C,
	SOUND_CTRLR_8 = 0x4D,
	SOUND_CTRLR_9 = 0x4E,
	SOUND_CTRLR_10 = 0x4F,

	GEN_PURPOSE_CTRLR_5 = 0x50,
	GEN_PURPOSE_CTRLR_6 = 0x51,
	GEN_PURPOSE_CTRLR_7 = 0x52,
	GEN_PURPOSE_CTRLR_8 = 0x53,
	PORTAMENTO_CTRL = 0x54,
	EFFECTS_1_DEPTH = 0x5B,
	EFFECTS_2_DEPTH = 0x5C,
	EFFECTS_3_DEPTH = 0x5D,
	EFFECTS_4_DEPTH = 0x5E,
	EFFECTS_5_DEPTH = 0x5F,
	
	DATA_ENTRY_ADD_1 = 0x60,
	DATA_ENTRY_SUB_1 = 0x61,
		  
	//Note: The 2 sets of parirings are probably going to use the 7 bits formatting to combine values
	NON_REG_PARAM_NUM_LSB = 0x62,
	NON_REG_PARAM_NUM_MSB = 0x63,
	
	REG_PARAM_NUM_LSB = 0x64,
	REG_PARAM_NUM_MSB = 0x65,
	
	ALL_SOUND_OFF = 0x78,
	RESET_ALL_CONTROLLERS = 0x79,
	LOCAL_CONTROLLER_ON_OFF = 0x7A,
	ALL_NOTES_OFF = 0x7B,
	OMNI_MODE_OFF = 0x7C,
	OMNI_MODE_OB = 0x7D,
	POLY_MODE_ON_OFF = 0x7E,
	POLY_MODE_ON = 0x7F
}

//From Table 1.3
//Piano Octave 0 - 10 each have all 12 notes.
//The user will need to determin if they want to
//evaluate the note as a sharp or flat based on the key
//as there are no values provided for flattened notes
enum MidiNote:UInt8, CaseIterable {
	case UNDEFINED = 0xFF,
	OCTAVE_ZERO_C = 0x0,
	OCTAVE_ZERO_C_SHRP = 0x1, //D_Flat
	OCTAVE_ZERO_D = 0x2,
	OCTAVE_ZERO_D_SHRP = 0x3, //E_FLAT
	OCTAVE_ZERO_E = 0x4,
	OCTAVE_ZERO_F = 0x5, //E_SHARP
	OCTAVE_ZERO_F_SHRP = 0x6, //G_FLAT
	OCTAVE_ZERO_G = 0x7,
	OCTAVE_ZERO_G_SHRP = 0x8, //A_FLAT
	OCTAVE_ZERO_A = 0x9,
	OCTAVE_ZERO_A_SHARP = 0xA, //B_FLAT
	OCTAVE_ZERO_B = 0xB, //C_FLAT

	OCTAVE_ONE_C = 0xC,
	OCTAVE_ONE_C_SHRP = 0xD,
	OCTAVE_ONE_D = 0xE,
	OCTAVE_ONE_D_SHRP = 0xF,
	OCTAVE_ONE_E = 0x10,
	OCTAVE_ONE_F = 0x11,
	OCTAVE_ONE_F_SHRP = 0x12,
	OCTAVE_ONE_G = 0x13,
	OCTAVE_ONE_G_SHRP = 0x14,
	OCTAVE_ONE_A = 0x15,
	OCTAVE_ONE_A_SHARP = 0x16,
	OCTAVE_ONE_B = 0x17,

	OCTAVE_TWO_C = 0x18,
	OCTAVE_TWO_C_SHRP = 0x19,
	OCTAVE_TWO_D = 0x1A,
	OCTAVE_TWO_D_SHRP = 0x1B,
	OCTAVE_TWO_E = 0x1C,
	OCTAVE_TWO_F = 0x1D,
	OCTAVE_TWO_F_SHRP = 0x1E,
	OCTAVE_TWO_G = 0x1F,
	OCTAVE_TWO_G_SHRP = 0x20,
	OCTAVE_TWO_A = 0x21,
	OCTAVE_TWO_A_SHARP = 0x22,
	OCTAVE_TWO_B = 0x23,

	OCTAVE_THREE_C = 0x24,
	OCTAVE_THREE_C_SHRP = 0x25,
	OCTAVE_THREE_D = 0x26,
	OCTAVE_THREE_D_SHRP = 0x27,
	OCTAVE_THREE_E = 0x28,
	OCTAVE_THREE_F = 0x29,
	OCTAVE_THREE_F_SHRP = 0x2A,
	OCTAVE_THREE_G = 0x2B,
	OCTAVE_THREE_G_SHRP = 0x2C,
	OCTAVE_THREE_A = 0x2D,
	OCTAVE_THREE_A_SHARP = 0x2E,
	OCTAVE_THREE_B = 0x2F,

	OCTAVE_FOUR_C = 0x30,
	OCTAVE_FOUR_C_SHRP = 0x31,
	OCTAVE_FOUR_D = 0x32,
	OCTAVE_FOUR_D_SHRP = 0x33,
	OCTAVE_FOUR_E = 0x34,
	OCTAVE_FOUR_F = 0x35,
	OCTAVE_FOUR_F_SHRP = 0x36,
	OCTAVE_FOUR_G = 0x37,
	OCTAVE_FOUR_G_SHRP = 0x38,
	OCTAVE_FOUR_A = 0x39,
	OCTAVE_FOUR_A_SHARP = 0x3A,
	OCTAVE_FOUR_B = 0x3B,

	OCTAVE_FIVE_C = 0x3C,
	OCTAVE_FIVE_C_SHRP = 0x3D,
	OCTAVE_FIVE_D = 0x3E,
	OCTAVE_FIVE_D_SHRP = 0x3F,
	OCTAVE_FIVE_E = 0x40,
	OCTAVE_FIVE_F = 0x41,
	OCTAVE_FIVE_F_SHRP = 0x42,
	OCTAVE_FIVE_G = 0x43,
	OCTAVE_FIVE_G_SHRP = 0x44,
	OCTAVE_FIVE_A = 0x45,
	OCTAVE_FIVE_A_SHARP = 0x46,
	OCTAVE_FIVE_B = 0x47,
	
	OCTAVE_SIX_C = 0x48,
	OCTAVE_SIX_C_SHRP = 0x49,
	OCTAVE_SIX_D = 0x4A,
	OCTAVE_SIX_D_SHRP = 0x4B,
	OCTAVE_SIX_E = 0x4C,
	OCTAVE_SIX_F = 0x4D,
	OCTAVE_SIX_F_SHRP = 0x4E,
	OCTAVE_SIX_G = 0x4F,
	OCTAVE_SIX_G_SHRP = 0x50,
	OCTAVE_SIX_A = 0x51,
	OCTAVE_SIX_A_SHARP = 0x52,
	OCTAVE_SIX_B = 0x53,
	
	OCTAVE_SEVEN_C = 0x54,
	OCTAVE_SEVEN_C_SHRP = 0x55,
	OCTAVE_SEVEN_D = 0x56,
	OCTAVE_SEVEN_D_SHRP = 0x57,
	OCTAVE_SEVEN_E = 0x58,
	OCTAVE_SEVEN_F = 0x59,
	OCTAVE_SEVEN_F_SHRP = 0x5A,
	OCTAVE_SEVEN_G = 0x5B,
	OCTAVE_SEVEN_G_SHRP = 0x5C,
	OCTAVE_SEVEN_A = 0x5D,
	OCTAVE_SEVEN_A_SHARP = 0x5E,
	OCTAVE_SEVEN_B = 0x5F,

	OCTAVE_EIGHT_C = 0x60,
	OCTAVE_EIGHT_C_SHRP = 0x61,
	OCTAVE_EIGHT_D = 0x62,
	OCTAVE_EIGHT_D_SHRP = 0x63,
	OCTAVE_EIGHT_E = 0x64,
	OCTAVE_EIGHT_F = 0x65,
	OCTAVE_EIGHT_F_SHRP = 0x66,
	OCTAVE_EIGHT_G = 0x67,
	OCTAVE_EIGHT_G_SHRP = 0x68,
	OCTAVE_EIGHT_A = 0x69,
	OCTAVE_EIGHT_A_SHARP = 0x6A,
	OCTAVE_EIGHT_B = 0x6B,
	
	OCTAVE_NINE_C = 0x6C,
	OCTAVE_NINE_C_SHRP = 0x6D,
	OCTAVE_NINE_D = 0x6E,
	OCTAVE_NINE_D_SHRP = 0x6F,
	OCTAVE_NINE_E = 0x70,
	OCTAVE_NINE_F = 0x71,
	OCTAVE_NINE_F_SHRP = 0x72,
	OCTAVE_NINE_G = 0x73,
	OCTAVE_NINE_G_SHRP = 0x74,
	OCTAVE_NINE_A = 0x75,
	OCTAVE_NINE_A_SHARP = 0x76,
	OCTAVE_NINE_B = 0x77,
	
	OCTAVE_TEN_C = 0x78,
	OCTAVE_TEN_C_SHRP = 0x79,
	OCTAVE_TEN_D = 0x7A,
	OCTAVE_TEN_D_SHRP = 0x7B,
	OCTAVE_TEN_E = 0x7C,
	OCTAVE_TEN_F = 0x7D,
	OCTAVE_TEN_F_SHRP = 0x7E,
	OCTAVE_TEN_G = 0x7F //Last piano key
}

//From Appendix 1.4 table 1
enum MidiInstrumentGeneralFamily:UInt8 {
	case INST_FAMILY_PIANO,
		  INST_FAMILY_CHROMATIC_PRECUSSION,
		  INST_FAMILY_ORGAN,
		  INST_FAMILY_GUITAR,
		  INST_FAMILY_BASS,
		  INST_FAMILY_STRINGS,
		  INST_FAMILY_ENSENBLE,
		  INST_FAMILY_BRASS,
		  INST_FAMILY_REED,
		  INST_FAMILY_PIPE,
		  INST_FAMILY_SYNTH_LEAD,
		  INST_FAMILY_SYNTH_PAD,
		  INST_FAMILY_SYNTH_EFFECTS,
		  INST_FAMILY_ETHNIC,
		  INST_FAMILY_PERCUSSIVE,
		  INST_FAMILY_SOUND_EFFECTS
}

//From Appendix 1.4 table 2
//This is essentially, additional/extra sound information for a given synth sound
enum MidiInstrumentPatch:UInt16, CaseIterable {
	case ACOUSTIC_GRAND_PIANO,
	BRIGHT_ACOUSTIC_PIANO,
	ELECTRIC_GRAND_PIANO,
	HONKY_TONK_PIANO,
	ELECTRIC_PIANO_1_RHODES_PIANO,
	ELECTRIC_PIANO_2_CHORUSED_PIANO,
	HARPSICHORD,
	CLAVINET,
	CELESTA,
	GLOCKENSPIEL,
	MUSIC_BOX,
	VIBRAPHONE,
	MARIMBA,
	XYLOPHONE,
	TUBULAR_BELLS,
	DULCIMER_SANTUR,
	DRAWBAR_ORGAN_HAMMOND,
	PERCUSSIVE_ORGAN,
	ROCK_ORGAN,
	CHURCH_ORGAN,
	REED_ORGAN,
	ACCORDION_FRENCH,
	HARMONICA,
	TANGO_ACCORDION_BAND_NEON,
	ACOUSTIC_GUITAR_NYLON,
	ACOUSTIC_GUITAR_STEEL,
	ELECTRIC_GUITAR_JAZZ,
	ELECTRIC_GUITAR_CLEAN,
	ELECTRIC_GUITAR_MUTED,
	OVERDRIVEN_GUITAR,
	DISTORTION_GUITAR,
	GUITAR_HARMONICS,
	ACOUSTIC_BASS,
	ELECTRIC_BASS_FINGERED,
	ELECTRIC_BASS_PICKED,
	FRETLESS_BASS,
	SLAP_BASS_1,
	SLAP_BASS_2,
	SYNTH_BASS_1,
	SYNTH_BASS_2,
	VIOLIN,
	VIOLA,
	CELLO,
	CONTRABASS,
	TREMOLO_STRINGS,
	PIZZICATO_STRINGS,
	ORCHESTRAL_HARP,
	TIMPANI,
	STRING_ENSEMBLE_1_STRINGS,
	STRING_ENSEMBLE_2_SLOW_STRINGS,
	SYNTHSTRINGS_1,
	SYNTHSTRINGS_2,
	CHOIR_AAHS,
	VOICE_OOHS,
	SYNTH_VOICE,
	ORCHESTRA_HIT,
	TRUMPET,
	TROMBONE,
	TUBA,
	MUTED_TRUMPET,
	FRENCH_HORN,
	BRASS_SECTION,
	SYNTHBRASS_1,
	SYNTHBRASS_2,
	SOPRANO_SAX,
	ALTO_SAX,
	TENOR_SAX,
	BARITONE_SAX,
	OBOE,
	ENGLISH_HORN,
	BASSOON,
	CLARINET,
	PICCOLO,
	FLUTE,
	RECORDER,
	PAN_FLUTE,
	BLOWN_BOTTLE,
	SHAKUHACHI,
	WHISTLE,
	OCARINA,
	LEAD_1_SQUARE_WAVE,
	LEAD_2_SAWTOOTH_WAVE,
	LEAD_3_CALLIOPE,
	LEAD_4_CHIFFER,
	LEAD_5_CHARANG,
	LEAD_6_VOICE_SOLO,
	LEAD_7_FIFTHS,
	LEAD_8_BASS_LEAD,
	PAD_1_NEW_AGE_FANTASIA,
	PAD_2_WARM,
	PAD_3_POLYSYNTH,
	PAD_4_CHOIR_SPACE_VOICE,
	PAD_5_BOWED_GLASS,
	PAD_6_METALLIC_PRO,
	PAD_7_HALO,
	PAD_8_SWEEP,
	FX_1_RAIN,
	FX_2_SOUNDTRACK,
	FX_3_CRYSTAL,
	FX_4_ATMOSPHERE,
	FX_5_BRIGHTNESS,
	FX_6_GOBLINS,
	FX_7_ECHOES_DROPS,
	FX_8_SCI_FI_STAR_THEME,
	SITAR,
	BANJO,
	SHAMISEN,
	KOTO,
	KALIMBA,
	BAG_PIPE,
	FIDDLE,
	SHANAI,
	TINKLE_BELL,
	AGOGO,
	STEEL_DRUMS,
	WOODBLOCK,
	TAIKO_DRUM,
	MELODIC_TOM,
	SYNTH_DRUM,
	REVERSE_CYMBAL,
	GUITAR_FRET_NOISE,
	BREATH_NOISE,
	SEASHORE,
	BIRD_TWEET,
	TELEPHONE_RING,
	HELICOPTER,
	APPLAUSE,
	GUNSHOT
}

enum MidiPrecussionMap {
	case ACOUSTIC_BASS_DRUM,
	BASS_DRUM_1,
	SIDE_STICK,
	ACOUSTIC_SNARE,
	HAND_CLAP,
	ELECTRIC_SNARE,
	LOW_FLOOR_TOM,
	CLOSED_HI_HAT,
	HIGH_FLOOR_TOM,
	PEDAL_HI_HAT,
	LOW_TOM,
	OPEN_HI_HAT,
	LOW_MID_TOM,
	HI_MID_TOM,
	CRASH_CYMBAL_1,
	HIGH_TOM,
	RIDE_CYMBAL_1,
	CHINESE_CYMBAL,
	RIDE_BELL,
	TAMBOURINE,
	SPLASH_CYMBAL,
	COWBELL,
	CRASH_CYMBAL_2,
	VIBRASLAP,
	RIDE_CYMBAL_2,
	HI_BONGO,
	LOW_BONGO,
	MUTE_HI_CONGA,
	OPEN_HI_CONGA,
	LOW_CONGA,
	HIGH_TIMBALE,
	LOW_TIMBALE,
	HIGH_AGOGO,
	LOW_AGOGO,
	CABASA,
	MARACAS,
	SHORT_WHISTLE,
	LONG_WHISTLE,
	SHORT_GUIRO,
	LONG_GUIRO,
	CLAVES,
	HI_WOOD_BLOCK,
	LOW_WOOD_BLOCK,
	MUTE_CUICA,
	OPEN_CUICA,
	MUTE_TRIANGLE,
	OPEN_TRIANGLE
}

enum MusicalKey {
	//Circle of 5ths. Major and relative minor keys.
	case C_MAJ,
	A_MIN,
	G_MAJ,
	E_MIN,
	D_MAJ,
	B_MIN,
	A_MAJ,
	FSHRP_MIN,
	E_MAJ,
	CSHRP_MIN,
	B_MAJ,
	GSHRP_MIN,
	FSHRP_MAJ,
	DSHRP_MIN,
	CSHRP_MAJ,
	ASHRP_MIN,

	//Circle of 4ths. Major and relative minor keys
	F_MAJ,
	D_MIN,
	BFLAT_MAJ,
	G_MIN,
	EFLAT_MAJ,
	C_MIN,
	AFLAT_MAJ,
	F_MIN,
	DFLAT_MAJ,
	BFLAT_MIN,
	GFLAT_MAJ,
	EFLAT_MIN,
	CFLAT_MAJ,
	AFLAT_MIN
	
	static func musicalKeyToString(p:MusicalKey?) -> String
	{
		guard let k = p else {return ""}
		
		var s:String = ""

		switch(k) {
			case MusicalKey.C_MAJ:
				s = "C-Maj"
			case MusicalKey.A_MIN:
				s = "A-min"
			case MusicalKey.G_MAJ:
				s = "G-Maj"
			case MusicalKey.E_MIN:
				s = "E-min"
			case MusicalKey.D_MAJ:
				s = "D-Maj"
			case MusicalKey.B_MIN:
				s = "B-min"
			case MusicalKey.A_MAJ:
				s = "A-Maj"
			case MusicalKey.FSHRP_MIN:
				s = "F#-min"
			case MusicalKey.E_MAJ:
				s = "E-Maj"
			case MusicalKey.CSHRP_MIN:
				s = "C#-min"
			case MusicalKey.B_MAJ:
				s = "B-Maj"
			case MusicalKey.GSHRP_MIN:
				s = "G#-min"
			case MusicalKey.FSHRP_MAJ:
				s = "F#-Maj"
			case MusicalKey.DSHRP_MIN:
				s = "D#-min"
			case MusicalKey.CSHRP_MAJ:
				s = "C#-Maj"
			case MusicalKey.ASHRP_MIN:
				s = "A#-min"

			/////////////////
			case MusicalKey.F_MAJ:
				s = "F-Maj"
			case MusicalKey.D_MIN:
				s = "D-min"
			case MusicalKey.BFLAT_MAJ:
				s = "Bb-Maj"
			case MusicalKey.G_MIN:
				s = "G-min"
			case MusicalKey.EFLAT_MAJ:
				s = "Eb-Maj"
			case MusicalKey.C_MIN:
				s = "C-min"
			case MusicalKey.AFLAT_MAJ:
				s = "Ab-Maj"
			case MusicalKey.F_MIN:
				s = "F-min"
			case MusicalKey.DFLAT_MAJ:
				s = "Db-Maj"
			case MusicalKey.BFLAT_MIN:
				s = "Bb-min"
			case MusicalKey.GFLAT_MAJ:
				s = "Gb-Maj"
			case MusicalKey.EFLAT_MIN:
				s = "Eb-min"
			case MusicalKey.CFLAT_MAJ:
				s = "Cb-Maj"
			case MusicalKey.AFLAT_MIN:
				s = "Ab-min"
		}

		return s
	}
}

protocol Event {
	var eMidiType:TrackEventType{get}
	var timeDelta:UInt32{get}
}

struct MidiChannelEvent: Event
{
	var eMidiType: TrackEventType {return .MIDI_EVENT}
	var timeDelta: UInt32 {return eventTimeDelta}

	var eventTimeDelta:UInt32
	var channel:UInt8?
	var pressure:UInt8?
	var noteVelocity:UInt8?
	var programNumber:UInt8?
	var musicalNote:MidiNote?
	var controllerNumber:UInt8?
	var controllerChangeValue:UInt8?
	
	//This is actually a 14 bit value
	var pitchWheelChange:UInt16?
	
	var eventType:MidiMajorMessage
}

struct MetaEvent: Event
{
	var timeDelta: UInt32 {return eventTimeDelta}
	var eMidiType: TrackEventType {return .META_EVENT}
	
	var eventTimeDelta:UInt32
}

struct SysExclusionEvent: Event
{
	var timeDelta: UInt32 {return eventTimeDelta}
	var eMidiType: TrackEventType {return .SYSEX_EVENT}
	
	var eventTimeDelta:UInt32
	
	var exclusiveInfo:Array<UInt8>

}

struct SysRealtimeEvent: Event {
	var timeDelta: UInt32 {return eventTimeDelta}
	var eMidiType: TrackEventType {return .SYSREALTIME_EVENT}
	
	var eventTimeDelta:UInt32
}

