import ../common

# const inputFilename = "sample.txt"
const inputFilename = "input.txt"
const input = staticRead(inputFilename).strip().split("\n")

# ----

proc isValid(s: string): bool =
  let xs = s.split(" ")
  let rng = xs[0].split("-").map(parseInt)
  let letter = xs[1][0]
  let pwd = xs[2]
  var cnt = 0
  if pwd[rng[0]-1] == letter: cnt.inc
  if pwd[rng[1]-1] == letter: cnt.inc
  return cnt == 1
    

proc main() =
  var cnt = 0
  for x in input:
    if isValid(x):
      cnt += 1
  echo cnt
  

when isMainModule:
  main()