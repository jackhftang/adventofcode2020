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
    let (r1,d1) = linearCongruence(d, b-r, m)
    r += r1 * d
    d *= d1
  
  echo r

proc main2() =
  var input = readFile(inputFilePath).strip.split("\n")
  var ns: seq[(int, int,int)]
  for i, n in toSeq(input[1].split(",")):
    if n != "x":
      ns.add (1, -i, parseInt n)
  let ans = linearCongruence(ns)  
  echo ans[0]

when isMainModule:
  main()
  main2()