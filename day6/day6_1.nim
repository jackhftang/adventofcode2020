import ../common

const inputFilename = "input.txt"
# const inputFilename = "sample1.txt"
# const inputFilename = "sample2.txt"
const inputFilePath = currentSourcePath.parentDir / inputFilename

# ----

proc main() =
  let input = readFile(inputFilePath).strip.split("\n\n").mapIt(it.replace("\n"))
  echo input
  var t: CountTable[char]
  for x in input:
    let t2 = x.toHashSet()
    for k in t2:
      t.inc(k)
  echo t
  var cnt = 0
  for k, v in t:
    cnt += v
  echo cnt
  

when isMainModule:
  main()