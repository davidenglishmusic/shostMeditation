require 'nokogiri'

class Score

  attr_accessor :filename

  def initialize filename
    @filename = filename
    @doc = getFile
  end

  def getFile
    f = File.open( (self.filename) )
    doc = Nokogiri::XML(f)
    f.close
    doc
  end

  def getNumberOfPartsAsArray
    result = []
    @doc.xpath("//score-part").each do |e|
      result.push(e.attribute("id").to_s)
    end
    result
  end

  def getPitchesAsArrayFromSpecificPart(partID)
    result = []
    @doc.xpath("//part[@id='#{partID}']//measure").each do |e|
      e.xpath("note").each do |f|
        if f.xpath("pitch//step").empty?
        else
          result.push(convertPitchXMLToString(f))
        end
      end
    end
    result
  end

  def cleanseAccidentalXML(accidentalCodeString)
    result = accidentalCodeString.scan(/>(.*)</).flatten.join
    if result == "natural"
      result = ""
    end
    result
  end

  def convertPitchToNumber(pitchName)
    if pitchName == "C"
      0
    elsif pitchName == "Csharp" || pitchName == "Dflat"
      1
    elsif pitchName == "D"
      2
    elsif pitchName == "Dsharp" || pitchName == "Eflat"
      3
    elsif pitchName == "E"
      4
    elsif pitchName == "F"
      5
    elsif pitchName == "Fsharp" || pitchName == "Gflat"
      6
    elsif pitchName == "G"
      7
    elsif pitchName == "Gsharp" || pitchName == "Aflat"
      8
    elsif pitchName == "A"
      9
    elsif pitchName == "Asharp" || pitchName == "Bflat"
      10
    else pitchName == "B"
      11
    end
  end

  def convertIntervalToNumber(interval)
    if interval == "P1"
      0
    elsif interval == "m2"
      1
    elsif interval == "M2"
      2
    elsif interval == "m3"
      3
    elsif interval == "M3"
      4
    elsif interval == "P4"
      5
    elsif interval == "TT"
      6
    elsif interval == "P5"
      7
    elsif interval == "m6"
      8
    elsif interval == "M6"
      9
    elsif interval == "m7"
      10
    elsif interval == "M7"
      11
    else interval == "P8"
      12
    end
  end

  def getInstancesOfOnePitchFromSpecificPart(pitch, partID)
    pitchesFromPiece = self.getPitchesAsArrayFromSpecificPart(partID)
    result = 0
    pitchesFromPiece.each do |e|
      if e == pitch
        result += 1
      end
    end
    result
  end

  def getInstancesOfOnePitchFromAllParts(pitch)
    (self.getNumberOfPartsAsArray).map{ |x| getInstancesOfOnePitchFromSpecificPart(pitch, x) }.inject{|sum,y| sum + y}
  end

  def getDurationsAsArrayFromSpecificPart(partID)
    result = []
    @doc.xpath("//part[@id='#{partID}']//measure").each do |e|
       e.xpath("note").each do |f|
         if f.xpath("pitch//step").empty?  
         else
             newDuration = f.xpath("type").to_s.scan(/>(.*)</).flatten.join
             result.push(newDuration)
         end
       end
    end
    result.flatten
  end

  def getInstancesOfOneDurationFromSpecificPart(durationLength, partID)
    partDurationArray = self.getDurationsAsArrayFromSpecificPart(partID)
    result = 0
    partDurationArray.each do |e|
      if e == durationLength
        result += 1
      end
    end
    result
  end

  def getInstancesOfOneDurationFromAllParts(durationLength)
    (self.getNumberOfPartsAsArray).map{ |x| getInstancesOfOneDurationFromSpecificPart(durationLength, x) }.inject{|sum,y| sum + y}
  end
  
  def getInstancesOfOneDitoneFromSpecificPart(inputInterval, partID)
    result = 0
    @doc.xpath("//part[@id='#{partID}']//measure").each do |e|
      e.xpath("note").each_cons(2) do |prev, curr|
        if curr.xpath("pitch//step").empty? || prev.xpath("pitch//step").empty?
        else
          if curr.attribute("default-x").to_s == prev.attribute("default-x").to_s || curr.attribute("default-x").to_s.to_i - prev.attribute("default-x").to_s.to_i <= 20
            firstPitchNumber = convertPitchToNumber(convertPitchXMLToString(curr))
            secondPitchNumber = convertPitchToNumber(convertPitchXMLToString(prev))
            intervalOfComparedPitches = getIntervalNumber(secondPitchNumber, firstPitchNumber)
            if convertIntervalToNumber(inputInterval) == intervalOfComparedPitches
              result += 1
            end
          end
        end
      end
    end
    result
  end

  def getInstancesOfOneDitoneFromAllParts(inputInterval)
    (self.getNumberOfPartsAsArray).map{ |x| getInstancesOfOneDitoneFromSpecificPart(inputInterval, x) }.inject{|sum,y| sum + y}
  end
  

  def convertPitchXMLToString(xmlElement)
    result = ""
    if xmlElement.xpath("accidental").empty? && xmlElement.css("alter").empty?
       result = xmlElement.xpath("pitch//step").to_s[6]
    elsif xmlElement.css("alter").to_s.length < 1       
       result = xmlElement.xpath("pitch//step").to_s[6] + cleanseAccidentalXML(xmlElement.css("accidental").to_s)
    else
       result = xmlElement.xpath("pitch//step").to_s[6] + addAccidentalForAlter(xmlElement)
    end
    result
  end

  def addAccidentalForAlter(xmlElement)
    alteration = xmlElement.css("alter").to_s.scan(/>(.*)</).flatten.join
    if alteration.to_i == -1
      "flat"
    else
      "sharp"
    end
  end

  def getFirstNoteAsXMLElement
    result = @doc.css("note").first
    result
  end

  def getSecondNoteAsXMLElement
    result = @doc.xpath("//note")
    result[1]
  end

  def getIntervalNumber(firstPitchNumber, secondPitchNumber)
    result = 0
    resultOfSubtraction = firstPitchNumber - secondPitchNumber
    if resultOfSubtraction >= 0
      result = resultOfSubtraction
    else
      result = resultOfSubtraction + 12
    end
    result
  end
  

  def getPitchAndOctaveAsArray(xmlElement)
    result = []
    result.push(convertPitchXMLToString(xmlElement))
    result.push(xmlElement.css("octave").to_s.scan(/>(.*)</).join.to_i)
    result    
  end

  def getDirectionalInterval(originPitchOctaveArray, destinationPitchOctaveArray)
    result = 0
    originPitchNumber = convertPitchToNumber(originPitchOctaveArray[0]) + (12 * originPitchOctaveArray[1])
    destinationPitchNumber = convertPitchToNumber(destinationPitchOctaveArray[0]) + (12 * destinationPitchOctaveArray[1])
    result = destinationPitchNumber - originPitchNumber
    result
  end

  def getNotesAsArraySortedByXCoorFromSpecificPart(partID)
    totalNumberOfNotes = getTotalNumberOfNotesIncludingRestsFromSpecificPart(partID)
    subresult = []
    totalNoteCounter = 1
    noteArrayPositionCounter = 0
    currentXCoor = 0
    currentXCoorArray = []
    currentNoteArray = []
    lastBar = 0
    @doc.xpath("//part[@id='#{partID}']//measure").each do |e|
      e.xpath("note").each do |f|
        if f.xpath("pitch//step").empty?
        else
          subresult.push([e.attribute("number").to_s.to_i, f.attribute("default-x").to_s.to_f, getPitchAndOctaveAsArray(f)])  
        end
      end
    end
    resortNoteArrayIntoXCoorSlots(subresult)
  end

  def resortNoteArrayIntoXCoorSlots(noteArray)
    if noteArray.empty?
      result = []
    else
      result = []
      currentXCoorSlot = []
      currentXCoorSlotCounter = 0
      currentNoteSlotCounter = 0
      currentNoteSlot = []
      currentMeasure = noteArray[0][0].to_i
      currentXCoorSlotValue = 0
      arrayLength = noteArray.length
      noteArray.each do |e|
        if e[0] == currentMeasure
          if e[1] - currentXCoorSlotValue <= 17
            currentNoteSlot.push(e[2])
          else
            currentXCoorSlot.push(currentNoteSlot)
            result.push(currentXCoorSlot)
            currentXCoorSlotCounter += 1
            currentXCoorSlot = []
            currentNoteSlot = []
            currentXCoorSlotValue = e[1]
            currentXCoorSlot.push(e[1])
            currentNoteSlot.push(e[2])
          end
        else
          currentMeasure += 1
          currentXCoorSlot.push(currentNoteSlot)
          result.push(currentXCoorSlot)
          currentXCoorSlot = []
          currentNoteSlot = []
          currentXCoorSlotValue = e[1]
          currentXCoorSlot.push(e[1])
          currentNoteSlot.push(e[2])       
        end
      end
      currentXCoorSlot.push(currentNoteSlot)
      result.push(currentXCoorSlot)
      result.shift
    end
    result
  end


  def getTotalNumberOfNotesIncludingRestsFromSpecificPart(partID)
    result = 0
    @doc.xpath("//part[@id='#{partID}']//note").each do |e|
      result += 1
    end
    result
  end

  def doIntervalsMatch(baseInterval, intervalToCompare)
    if baseInterval == intervalToCompare
      true
    else
      false
    end
  end

  def getInstancesOfMelodyFromSpecificPart(intervalsAsArray, partID)
    arrayOfNotesSortedByXCoor = getNotesAsArraySortedByXCoorFromSpecificPart(partID)
    numberOfXCoorColumnsToCompareAtOnce = intervalsAsArray.length + 1
    countOfIntervalsInMelody = intervalsAsArray.length - 1
    $result = 0
    intervalInArrayCounter = 0
    xCoorSlotOuterFunctionCounter = 0
    xCoorSlotCounter = 1
    noteCounter = 0
    arrayOfNotesSortedByXCoor.each_cons(numberOfXCoorColumnsToCompareAtOnce) do |e|
      arrayOfNotesSortedByXCoor[xCoorSlotOuterFunctionCounter][1].each do |f|
        getInstancesOfMelodyAcrossTheArray(f, arrayOfNotesSortedByXCoor, intervalsAsArray, intervalInArrayCounter, xCoorSlotCounter, countOfIntervalsInMelody)
      end
      xCoorSlotOuterFunctionCounter += 1
      xCoorSlotCounter += 1
    end
    $result
  end

  def getInstancesOfMelodyAcrossTheArray(startingPitch, arrayOfNotesSortedByXCoor, intervalsAsArray, intervalInArrayCounter, xCoorSlotCounter, countOfIntervalsInMelody)
    arrayOfNotesSortedByXCoor[xCoorSlotCounter][1].each do |g|
      originPitchOctaveArray = startingPitch
      destinationPitchOctaveArray = g
      if intervalInArrayCounter == countOfIntervalsInMelody
      end
      if getDirectionalInterval(originPitchOctaveArray, destinationPitchOctaveArray) == intervalsAsArray[intervalInArrayCounter] && intervalInArrayCounter == countOfIntervalsInMelody
         $result += 1
      elsif getDirectionalInterval(originPitchOctaveArray, destinationPitchOctaveArray) == intervalsAsArray[intervalInArrayCounter]
        intervalInArrayCounter += 1
        xCoorSlotCounter += 1
        getInstancesOfMelodyAcrossTheArray(g, arrayOfNotesSortedByXCoor, intervalsAsArray, intervalInArrayCounter, xCoorSlotCounter, countOfIntervalsInMelody)
      else
      end
      if intervalInArrayCounter > 0
        intervalInArrayCounter = -1
      end
    end
  end

  def getInstancesOfMelodyFromAllParts(intervalsAsArray)
    (self.getNumberOfPartsAsArray).map{ |x| getInstancesOfMelodyFromSpecificPart(intervalsAsArray, x) }.inject{|sum,y| sum + y}
  end
    	
end
