import ../common

proc main(inputFilename: string) =
  var input = readFile(currentSourcePath.parentDir / inputFilename).strip.splitLines.map(parseInt)
  var cnt = 0
  for i in 1 .. input.high:
    if input[i] > input[i-1]:
      cnt += 1
  echo cnt

when isMainModule:
  main("day1_input.txt")
  # main("day1_sample1.txt")