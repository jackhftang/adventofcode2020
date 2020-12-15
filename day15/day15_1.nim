import ../common

const inputFilename = "day14_input.txt"
# const inputFilename = "day14_sample1.txt"
# const inputFilename = "day14_sample2.txt"
const inputFilePath = currentSourcePath.parentDir / inputFilename

# ----

proc findr(xs: seq[int], x: int, start: int): int =
  var i = start
  while i > 0:
    i -= 1
    if xs[i] == x: return i
  return -1

proc main() =
  var input = "0,5,4,1,10,14,7".split(",").map(parseInt)
  echo input 
  while input.len < 2020:
    let prev = input[^1]
    # echo "cnt=", input.findr(prev, input.len), ' ', prev
    let n = 
      if input.count(prev) == 1: 0
      else: 
        let n2 = input.findr(prev, input.len) 
        let n3 = input.findr(prev, n2)
        n2 - n3
    input.add n
  echo input[^1]
  

when isMainModule:
  main()