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

proc tra(dy,dx: int): int =
  let m = input
  var x = 0
  var y = 0
  var cnt = 0
  while y < input.len:
    cnt += m[y][x]
    y = (y+dy) 
    x = (x+dx) mod input[0].len
  return cnt 

proc main() =
  echo tra(1,1) * tra(1,3) * tra(1,5) * tra(1,7) * tra(2,1)
  

when isMainModule:
  main()