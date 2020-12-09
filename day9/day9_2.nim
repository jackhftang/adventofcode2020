import ../common

const inputFilename = "day9_input.txt"
# const inputFilename = "day9_sample1.txt"
# const inputFilename = "day9_sample2.txt"
const inputFilePath = currentSourcePath.parentDir / inputFilename

# ----

proc main() =
  let input = readFile(inputFilePath).strip.split("\n").map(parseInt)
  let ss = input.unroll(0, (a,b) => a+b)
  echo ss

  var ans: seq[(int,int)]
  for i in 0..ss.high:
    for j in i+2..ss.high:
      if ss[j] - ss[i] == 22406676:
        ans.add (i,j-1)

  echo ans
  echo ans.mapIt(input[it[0]..it[1]].sum())
  echo ans.mapIt(input[it[0]..it[1]].max() + input[it[0]..it[1]].min())

when isMainModule:
  main()