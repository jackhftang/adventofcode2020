import ../common

proc main(inputFilename: string) =
  var input = readFile(currentSourcePath.parentDir / inputFilename).strip.splitLines.map(parseInt)
  var cnt = 0
  for i in 1 .. input.high:
    if input[i] > input[i-1]:
      cnt += 1
  echo cnt

proc main2(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip
  var input = rawInput.splitLines.map(parseInt)
  echo input.windowed(2).toSeq.map(xs => int(xs[1] > xs[0])).sum

when isMainModule:
  main("day1_input.txt")
  main2("day1_input.txt")
  # main("day1_sample1.txt")