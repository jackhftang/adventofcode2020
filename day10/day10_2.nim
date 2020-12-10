import ../common

const inputFilename = "day10_input.txt"
# const inputFilename = "day10_sample1.txt"
# const inputFilename = "day10_sample2.txt"
const inputFilePath = currentSourcePath.parentDir / inputFilename

# ----

proc ways(input: seq[int], i: int): int =
  var table {.global.}: Table[int, int] 
  if i == input.len-1:
    return 1

  if i in table:
    return table[i]

  for j in i+1..i+3:
    if j < input.len and input[j] <= input[i] + 3:
      result += ways(input, j)

  table[i] = result

proc main() =
  var input = readFile(inputFilePath).strip.split("\n").map(parseInt)
  input.add 0
  input.sort
  # input.add input[^1] + 3
  echo input
  echo ways(input, 0)

when isMainModule:
  main()