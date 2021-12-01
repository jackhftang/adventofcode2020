import ../common

proc main(inputFilename: string) =
  var input = readFile(currentSourcePath.parentDir / inputFilename).strip.splitLines.map(parseInt)
  var cnt = 0
  var xs: seq[int]
  for ys in input.windowed(3):
    xs.add sum(ys)

  for i in 1..xs.high:
    if xs[i] > xs[i-1]:
      cnt += 1
  echo cnt

when isMainModule:
  main("day1_input.txt")
  # main("day1_sample1.txt")