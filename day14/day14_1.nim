import ../common

const inputFilename = "day14_input.txt"
# const inputFilename = "day14_sample1.txt"
# const inputFilename = "day14_sample2.txt"
const inputFilePath = currentSourcePath.parentDir / inputFilename

# ----

proc main() =
  var input = readFile(inputFilePath).strip.split("\n")
  var maskOr = 0
  var maskAnd = 0
  var mem: Table[int, int]
  for line in input:
    if line.startsWith("mask"):
      let ss = line.split(" ")
      # extract 1
      maskOr = ss[2].replace("0", "X").replace("X", "0").parseBinInt
      # extract 0
      maskAnd = ss[2].replace("X", "1").parseBinInt
      echo "mask ", maskOr.toBin(36), " ", maskAnd.toBin(36)
    elif line.startsWIth("mem"):
      var x, y: int
      assert scanf(line, "mem[$i] = $i", x, y)
      mem[x] = (y and maskAnd) or maskOr
    else:
      abort(line)

  var ans = 0
  for k, v in mem: 
    ans += v
  
  echo ans

when isMainModule:
  main()