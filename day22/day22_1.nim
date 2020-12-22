import ../common

const inputFilename = "day22_input.txt"
# const inputFilename = "day22_sample1.txt"
# const inputFilename = "day22_sample2.txt"
const inputFilePath = currentSourcePath.parentDir / inputFilename

# ----

proc main() =
  let input = readFile(inputFilePath).strip.split("\n\n").map(s => s.splitLines[1..^1].map(parseInt))
  var a,b : Deque[int]
  for x in input[0]: a.addLast x
  for x in input[1]: b.addLast x

  while a.len > 0 and b.len > 0:
    let a0 = a.popFirst()
    let b0 = b.popFirst()
    if a0 > b0:
      a.addLast a0
      a.addLast b0
    elif a0 < b0:
      b.addLast b0
      b.addLast a0
    else:
      abort()
  echo a
  echo b
  if a.len > 0:
    echo (a.toSeq * toSeq(1..a.len).reversed).sum
  elif b.len > 0:
    echo (b.toSeq * toSeq(1..b.len).reversed).sum

  

when isMainModule:
  main()