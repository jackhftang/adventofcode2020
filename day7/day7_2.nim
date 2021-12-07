import ../common

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.split(",").map(parseInt)
  echo arange(0, max(input)).map(y => input.map(x => abs(x-y)*(abs(x-y)+1) div 2).sum).min

when isMainModule:
  # main("day7_sample1.txt")
  main("day7_input.txt")  
