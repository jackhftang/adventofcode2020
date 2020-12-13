import ../common

const inputFilename = "day13_input.txt"
# const inputFilename = "day13_sample1.txt"
# const inputFilename = "day13_sample2.txt"
const inputFilePath = currentSourcePath.parentDir / inputFilename

# ----

proc main() =
  var input = readFile(inputFilePath).strip.split("\n")
  let m = input[0].parseInt
  let ts = input[1].split(",").filter(s => s != "x").map(parseInt)
  echo ts
  
  let ns = ts.map(t => (t,  t * ((m+t-1) div t)))
  echo ns
  let ns2 = ns.sorted((a,b) => a[1] - b[1])
  echo ns2
  echo (ns2[0][1] - m) * ns2[0][0]
  
proc main2() =
  var input = readFile(inputFilePath).strip.split("\n")
  let m = input[0].parseInt
  let ts = input[1].split(",").filter(s => s != "x").map(parseInt)
  let ns = ts.map(t => (t, t * ((m+t-1) div t) ))
  let ix = ns.map(x => x[1]).minIndex
  echo (ns[ix][1] - m) * ns[ix][0]

when isMainModule:
  main()
  main2()