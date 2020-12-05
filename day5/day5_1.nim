import ../common

const inputFilename = "input.txt"
# const inputFilename = "sample1.txt"
# const inputFilename = "sample2.txt"
const inputFilePath = currentSourcePath.parentDir / inputFilename

# ----

proc parse(s: string): int =
  var r = 0
  for i in 0..s.high:
    if s[i] in "FL": r = 2*r 
    elif s[i] in "BR": r = 2*r + 1
    else: abort(fmt"unknown {s[i]}")

  return r

proc main() =
  let input = readFile(inputFilePath).strip.splitLines.map(parse)
  echo input
  echo input.max()

when isMainModule:
  main()