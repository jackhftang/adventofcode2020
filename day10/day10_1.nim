import ../common

const inputFilename = "day10_input.txt"
# const inputFilename = "day10_sample1.txt"
# const inputFilename = "day10_sample2.txt"
const inputFilePath = currentSourcePath.parentDir / inputFilename

# ----

proc main() =
  let input = readFile(inputFilePath).strip.split("\n").map(parseInt).sorted()
  echo input
  var ans = newSeq[int](input.len-1)
  for i in 1..input.high:
    ans[i-1] = input[i] - input[i-1]
  echo ans
  echo ans.count(1), ' ', ans.count(3)
  echo (ans.count(1)+1) * (ans.count(3)+1)

when isMainModule:
  main()