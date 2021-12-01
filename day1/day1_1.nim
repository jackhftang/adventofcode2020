import ../common

proc main(inputFilename: string) =
  var input = readFile(currentSourcePath.parentDir / inputFilename).strip.splitLines.map(parseInt)
  echo input


when isMainModule:
  # main("day1_input.txt")
  main("day1_sample1.txt")