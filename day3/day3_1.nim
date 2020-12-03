import ../common

# const inputFilename = "sample.txt"
const inputFilename = "input.txt"
const input = staticRead(inputFilename).strip().split("\n").map(line => line.map(
  proc(c: char): int = 
    if c == '#': 1 
    else: 0 
  )
)

# ----

proc main() =
  let m = input
  var x = 0
  var y = 0
  var cnt = 0
  while y < input.len:
    cnt += m[y][x]
    y = (y+1) 
    x = (x+3) mod input[0].len
  echo cnt
  

when isMainModule:
  main()