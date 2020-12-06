import ../common

const inputFilename = "input.txt"
# const inputFilename = "sample1.txt"
# const inputFilename = "sample2.txt"
const inputFilePath = currentSourcePath.parentDir / inputFilename

# ----

proc combine(xs: seq[string]): seq[char] =
  for c in 'a'..'z':
    if xs.allIt(c in it):
      result.add(c)

proc main() =
  let input = readFile(inputFilePath).strip.split("\n\n").mapIt(combine(it.split("\n")))
  echo input

  var t: CountTable[char]
  for x in input:
    for c in x:
      t.inc(c)
  var cnt = 0
  for k,v in t:
    cnt += v
  echo cnt
  
when isMainModule:
  main()