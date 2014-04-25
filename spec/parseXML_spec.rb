require 'spec_helper'

describe Score do
  
  before :all do
    @score = Score.new "test.xml"
    @scoreBasic = Score.new "basic.xml"
    @scorePitches = Score.new "pitches.xml"
    @scoreDurations = Score.new "durations.xml"
    @scoreKeySignatureFlats = Score.new "keySignatureFlats.xml"
    @scoreKeySignatureSharps = Score.new "keySignatureSharps.xml"
    @scoreDitones = Score.new "ditones.xml"
    @scoreMotive = Score.new "shostakovichMotive.xml"
    @scoreStringQuartet8 = Score.new "StringQuartetNo8Mvmt1Excerpt.xml"
  end

  describe "#initialize" do
    it "returns a new Score object" do
      @score.should be_an_instance_of Score
    end
  end

  describe "#filename" do
    it "returns the filename" do
      @score.filename.should eql "test.xml"
    end
  end

  describe "#getFile" do
    it "returns the file as a Nokogiri::XML object" do
      result = @score.getFile.to_s
      result[39..160].should eql '<!DOCTYPE score-partwise PUBLIC "-//Recordare//DTD MusicXML 2.0 Partwise//EN" "http://www.musicxml.org/dtds/partwise.dtd">'
    end
  end

  describe "#getNumberOfPartsAsArray" do
    it "returns an array of the number of parts in the music" do
      @score.getNumberOfPartsAsArray.should eql ["P1", "P2"]
    end
  end

  describe "#getPitchesAsArrayFromSpecificPart" do
    it "returns an array of pitches from the part passed in as the argument" do
      @scoreBasic.getPitchesAsArrayFromSpecificPart("P1").should eql ["G", "B", "D", "G", "D"]
    end
  end

  describe "#cleanseAccidentalXML" do
    it "returns the accidental without the surrounding opening and closing tags" do
      @score.cleanseAccidentalXML("<accidental>sharp</accidental>").should eql "sharp"
    end
    it "returns an empty string as the accidental is a natural" do
      @score.cleanseAccidentalXML("<accidental>natural</accidental>").should eql ""
    end
  end

  describe "#convertIntervalToNumber" do
    it "converts an named interval ie. m3 to a number" do
      @score.convertIntervalToNumber("m3").should eql 3
    end
    it "converts an named interval ie. P8 to a number" do
      @score.convertIntervalToNumber("P8").should eql 12
    end
  end

  describe "#convertPitchToNumber" do
    it "converts a named pitch ie. Csharp to a number" do
      @score.convertPitchToNumber("Csharp").should eql (1)
    end
    it "converts a named pitch ie. A to a number" do
      @score.convertPitchToNumber("A").should eql (9)
    end
    it "should return a number" do
      @score.convertPitchToNumber("A").class.should eql Fixnum
    end
  end

  describe "#getInstancesOfOnePitchFromSpecificPart" do
    it "returns the number of instances of one pitch in a given part" do
      @scoreBasic.getInstancesOfOnePitchFromSpecificPart("G", "P1").should eql (2)
    end
    it "returns the number of instances of one pitch in a given part" do
      @scorePitches.getInstancesOfOnePitchFromSpecificPart("G", "P2").should eql (1)
    end 
  end
  
  describe "#getInstancesOfOnePitchFromAllParts" do
    it "returns the number of instances of one pitch from all parts" do
      @scorePitches.getInstancesOfOnePitchFromAllParts("C").should eql (2)
    end
  end

  describe "#getDurationsAsArrayFromSpecificPart" do
    it "returns an array of durations from a specific part" do
      @scoreBasic.getDurationsAsArrayFromSpecificPart("P1").should eql ["whole","whole","whole","whole","whole"]
    end
  end

  describe "#getInstancesOfOneDurationFromSpecificPart" do
    it "returns the number of instances of one duration in a given part" do
      @scoreDurations.getInstancesOfOneDurationFromSpecificPart("quarter", "P1").should eql 4
    end
  end

  describe "#getInstancesOfOneDurationFromAllParts" do
    it "returns the number of instances of one duration from all parts" do
      @scoreDurations.getInstancesOfOneDurationFromAllParts("quarter").should eql 8
    end
  end

  describe "#getInstancesOfOneDitoneFromSpecificPart" do
    it "returns the number of instances of one ditone in a given part" do
      @scoreDitones.getInstancesOfOneDitoneFromSpecificPart("P5", "P1").should eql 1
    end
  end

  describe "#getInstancesOfOneDitoneFromAllParts" do
    it "returns the number of instances of one ditone from all parts" do
      @scoreDitones.getInstancesOfOneDitoneFromAllParts("m2").should eql 2
    end
  end

 describe "convertPitchXMLToString" do
    it "should return a string ie. Gflat as a result of parsing the xml element in question" do
    xmlElement = @scoreBasic.convertPitchXMLToString(@scoreBasic.getFirstNoteAsXMLElement).should eql "G"
    end
  end

  describe "#addAccidentalForAlter" do
    it "should add an accidental according to an altered value" do
      @scoreKeySignatureFlats.addAccidentalForAlter(@scoreKeySignatureFlats.getFirstNoteAsXMLElement).should eql "flat"
    end
    it "should add an accidental according to an altered value" do
      @scoreKeySignatureSharps.addAccidentalForAlter(@scoreKeySignatureSharps.getFirstNoteAsXMLElement).should eql "sharp"
    end
  end

  describe "#getFirstNoteAsXMLElement" do
    it "returns the first note of the score as an XML Element" do
      @scoreBasic.getFirstNoteAsXMLElement.class.should eql Nokogiri::XML::Element
    end
  end

  describe "getSecondNoteAsXMLElement" do
    it "returns the second not of the score as an XML Element" do
      @scoreBasic.getSecondNoteAsXMLElement.class.should eql Nokogiri::XML::Element
    end
  end

  describe "#getIntervalNumber" do
    it "takes two number and returns their difference" do
      @score.getIntervalNumber(5,1).should eql 4
    end
    it "takes two number and returns the difference +12 if the result of the subtraction is negative" do
      @score.getIntervalNumber(3,8).should eql 7
    end
  end

  describe "#getPitchAndOctaveAsArray" do
    it "returns an array containing the pitch and its octave" do
      @scoreBasic.getPitchAndOctaveAsArray(@scoreBasic.getFirstNoteAsXMLElement).should eql ["G", 4]
    end
    it "returns an array containing the pitch and its octave" do
      @scoreKeySignatureFlats.getPitchAndOctaveAsArray(@scoreKeySignatureFlats.getFirstNoteAsXMLElement).should eql ["Bflat", 4]
    end
  end

  describe "#getDirectionalInterval" do
    it "returns the interval with either a positive or negative value representing the direction ie. C2 to Eflat2" do
      @score.getDirectionalInterval(["C", 2], ["Eflat", 2]).should eql 3
    end
    it "returns the interval with either a positive or negative value representing the direction ie. C2 to D3" do
      @score.getDirectionalInterval(["C", 2], ["D", 3]).should eql 14
    end
    it "returns the interval with either a positive or negative value representing the direction ie. Eflat2 to C2" do
      @score.getDirectionalInterval(["Eflat", 2], ["C", 2]).should eql -3
    end
    it "returns the interval with either a positive or negative value representing the direction ie. C4 to A2" do
      @score.getDirectionalInterval(["C", 4], ["A", 2]).should eql -15
    end
  end

  describe "#getNotesAsArraySortedByXCoorFromSpecificPart" do
    it "returns an array of notes sorted by x coordinates from a specific Part" do
      @scoreMotive.getNotesAsArraySortedByXCoorFromSpecificPart("P1").should eql [[ 80.33, [["D", 4]]], [ 134.16, [["Eflat", 4]]], [ 187.98, [["C", 4]]], [ 241.80, [["B", 3]]]]
    end
    it "returns an array of notes sorted by x coordinates from a specific Part" do
      @scoreBasic.getNotesAsArraySortedByXCoorFromSpecificPart("P1").should eql [[ 80.33, [["G", 4], ["B", 4], ["D", 5], ["G", 2], ["D", 3]]]]  
    end
    it "returns an array of notes sorted by x coordinates from a specific Part" do
      @scoreStringQuartet8.getNotesAsArraySortedByXCoorFromSpecificPart("P1").should eql [[43.57, [["G", 4]]], [15.0, [["Aflat", 4]]], [44.6, [["F", 4]]], [12.47, [["E", 4]]], [59.17, [["F", 4]]], [12.0, [["F", 4]]], [12.0, [["Eflat", 4]]], [16.8, [["Eflat", 4]]], [83.9, [["Eflat", 4]]], [116.98, [["Eflat", 4]]], [163.83, [["D", 5]]], [17.5, [["Eflat", 5]]], [63.01, [["C", 5]]], [26.37, [["B", 4]]], [26.37, [["B", 4]]], [17.5, [["B", 4]]], [17.5, [["B", 4]]], [63.01, [["C", 5]]], [91.46, [["G", 4]]], [30.7, [["Eflat", 4]]], [92.77, [["Eflat", 4]]], [30.7, [["Eflat", 4]]], [107.54, [["E", 4]]], [145.56, [["F", 4]]], [17.5, [["D", 4]]], [26.37, [["D", 4]]], [68.28, [["D", 4]]], [105.45, [["Eflat", 4]]], [17.5, [["C", 4]]], [26.37, [["C", 4]]], [70.01, [["D", 4]]], [83.9, [["Eflat", 4]]], [101.8, [["C", 4]]]]
    end
  end

  describe "#getTotalNumberOfNotesIncludingRestsFromSpecificPart" do
    it "returns a total of the number of notes and rests (note events) from a specific part" do
      @scoreMotive.getTotalNumberOfNotesIncludingRestsFromSpecificPart("P1").should eql (7)
    end
  end

  describe "#doIntervalsMatch" do
    it "returns true if the input intervals match or false if they do not" do
      @score.doIntervalsMatch(3, 3).should eql true
    end
    it "returns true if the input intervals match or false if they do not" do
      @score.doIntervalsMatch(3, -4).should eql false
    end
  end

  describe "#getInstancesOfMelodyFromSpecificPart" do
    it "returns the number of instances of a melody found in a specific part" do
      @scoreMotive.getInstancesOfMelodyFromSpecificPart([1,-3,-1], "P1").should eql 1
    end
    it "returns the number of instances of a melody found in a specific part" do
      @scoreMotive.getInstancesOfMelodyFromSpecificPart([1,-3,-1], "P2").should eql 4
    end
  end

end
