import ../common

const inputFilename = "day14_input.txt"
# const inputFilename = "day14_sample1.txt"
# const inputFilename = "day14_sample2.txt"
const inputFilePath = currentSourcePath.parentDir / inputFilename

# ----

proc main() =
  var input = "0,5,4,1,10,14,7".split(",").map(parseInt)
  # var input = "0,3,6".split(",").map(parseInt)
  echo input 

  var pos: Table[int, seq[int]]
  var cnt = input.toCountTable
  for i, x in input:
    pos.mgetOrPut(x, @[]).add i

  while input.len < 30000000:
    let prev = input[^1]
    let n = 
      if cnt[prev] == 1: 0
      else: 
        let n2 = pos[prev][^1]
        let n3 = pos[prev][^2]
        n2 - n3

    cnt.inc n
    pos.mgetOrPut(n, @[]).add input.len
    input.add n

  echo input[^1]
  

when isMainModule:
  main()