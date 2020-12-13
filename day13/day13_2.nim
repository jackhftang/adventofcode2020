import ../common

const inputFilename = "day13_input.txt"
# const inputFilename = "day13_sample1.txt"
# const inputFilename = "day13_sample2.txt"
const inputFilePath = currentSourcePath.parentDir / inputFilename

# ----

proc main() =
  var input = readFile(inputFilePath).strip.split("\n")
  var ns: seq[(int,int)]
  for i, n in toSeq(input[1].split(",")):
    if n != "x":
      let t = parseInt n
      ns.add (-i, t)
  echo ns

  var r = 0
  var d = 1
  for (b,m) in ns:
    let (r1,d1) = congrunence(d, b-r, m)
    r += r1 * d
    d *= d1
  
  echo r

when isMainModule:
  main()