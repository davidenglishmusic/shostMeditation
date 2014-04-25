require 'sinatra'
require_relative 'parseXML.rb'

get '/' do
  erb :index
end

get '/test' do
  fileForAnalysis = params.inspect.to_s.scan(/"(.*?)"/)[1].join.gsub('"[', '').gsub(']"', '')
  puts "*************** #{fileForAnalysis.to_s} **************"
  "#{fileForAnalysis}"
end

get '/result' do
  fileForAnalysis = params.inspect.to_s.scan(/"(.*?)"/)[1].join.gsub('"[', '').gsub(']"', '')
  @currentPiece = Score.new "#{fileForAnalysis}"
  @currentPieceName = @currentPiece.filename
  @pitchC = @currentPiece.getInstancesOfOnePitchFromAllParts("C")
  @pitchCsharp = @currentPiece.getInstancesOfOnePitchFromAllParts("Csharp") + @currentPiece.getInstancesOfOnePitchFromAllParts("Dflat")
  @pitchD = @currentPiece.getInstancesOfOnePitchFromAllParts("D")
  @pitchDsharp = @currentPiece.getInstancesOfOnePitchFromAllParts("Dsharp") + @currentPiece.getInstancesOfOnePitchFromAllParts("Eflat")
  @pitchE = @currentPiece.getInstancesOfOnePitchFromAllParts("E")
  @pitchF = @currentPiece.getInstancesOfOnePitchFromAllParts("F")
  @pitchFsharp = @currentPiece.getInstancesOfOnePitchFromAllParts("Fsharp") + @currentPiece.getInstancesOfOnePitchFromAllParts("Gflat")
  @pitchG = @currentPiece.getInstancesOfOnePitchFromAllParts("G")
  @pitchGsharp = @currentPiece.getInstancesOfOnePitchFromAllParts("Gsharp") + @currentPiece.getInstancesOfOnePitchFromAllParts("Aflat")
  @pitchA = @currentPiece.getInstancesOfOnePitchFromAllParts("A")
  @pitchAsharp = @currentPiece.getInstancesOfOnePitchFromAllParts("Asharp") + @currentPiece.getInstancesOfOnePitchFromAllParts("Bflat")
  @pitchB = @currentPiece.getInstancesOfOnePitchFromAllParts("B")

  @intervalm2 = @currentPiece.getInstancesOfOneDitoneFromAllParts("m2")
  @intervalM2 = @currentPiece.getInstancesOfOneDitoneFromAllParts("M2")
  @intervalm3 = @currentPiece.getInstancesOfOneDitoneFromAllParts("m3")
  @intervalM3 = @currentPiece.getInstancesOfOneDitoneFromAllParts("M3")
  @intervalP4 = @currentPiece.getInstancesOfOneDitoneFromAllParts("P4")
  @intervalTT = @currentPiece.getInstancesOfOneDitoneFromAllParts("TT")
  @intervalP5 = @currentPiece.getInstancesOfOneDitoneFromAllParts("P5")
  @intervalm6 = @currentPiece.getInstancesOfOneDitoneFromAllParts("m6")
  @intervalM6 = @currentPiece.getInstancesOfOneDitoneFromAllParts("M6")
  @intervalm7 = @currentPiece.getInstancesOfOneDitoneFromAllParts("m7")
  @intervalM7 = @currentPiece.getInstancesOfOneDitoneFromAllParts("M7")
  @intervalP8 = @currentPiece.getInstancesOfOneDitoneFromAllParts("P8")


  @duration1 = @currentPiece.getInstancesOfOneDurationFromAllParts("whole")
  @duration2 = @currentPiece.getInstancesOfOneDurationFromAllParts("half")
  @duration4 = @currentPiece.getInstancesOfOneDurationFromAllParts("quarter")
  @duration8 = @currentPiece.getInstancesOfOneDurationFromAllParts("eighth")
  @duration16 = @currentPiece.getInstancesOfOneDurationFromAllParts("16th")
  @duration32 = @currentPiece.getInstancesOfOneDurationFromAllParts("32nd")
  @duration64 = @currentPiece.getInstancesOfOneDurationFromAllParts("64th")

  @motiveVocal = @currentPiece.getInstancesOfMelodyFromSpecificPart([1, -3, -1], "P1")
  @motivePiano = @currentPiece.getInstancesOfMelodyFromSpecificPart([1, -3, -1], "P2")
  @motiveAll = @currentPiece.getInstancesOfMelodyFromAllParts([1, -3, -1])
  if @motiveAll > 0
    @motiveAll -= 1
  end

  erb :result
end
