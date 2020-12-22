import ../common
import hashes

const inputFilename = "day22_input.txt"
# const inputFilename = "day22_sample1.txt"
# const inputFilename = "day22_sample2.txt"
const inputFilePath = currentSourcePath.parentDir / inputFilename

# ----

proc game(in1,in2: seq[int]): (int, Deque[int], Deque[int]) =
  echo fmt"game({in1}, {in2})"
  var conf1, conf2: HashSet[int]

  var a,b : Deque[int]
  for x in in1: a.addLast x
  for x in in2: b.addLast x
  while a.len > 0 and b.len > 0:
    var h1, h2: Hash = 0
    for x in a: h1 = h1 !& x
    for x in b: h2 = h2 !& x
    if h1 in conf1:
      return (1, a, b)
    conf1.incl h1
    if h2 in conf2:
      return (1, a, b)
    conf2.incl h2

    let a0 = a.popFirst()
    let b0 = b.popFirst()

    if a0 <= a.len and b0 <= b.len:
      # sub game 
      var n1,n2:seq[int]
      for i in 0..<a0: n1.add a[i]
      for i in 0..<b0: n2.add b[i]
      let (n, _, _) = game(n1,n2)
      if n == 1:
        a.addLast a0
        a.addLast b0  
      elif n == 2:
        b.addLast b0
        b.addLast a0  
      else:
        abort(n)
    elif a0 > b0:
      a.addLast a0
      a.addLast b0
    elif a0 < b0:
      b.addLast b0
      b.addLast a0
    else:
      abort()

  var n: int
  if a.len > 0: n = 1
  elif b.len > 0: n = 2
  else: abort(a.len, b.len)
  return (n, a, b)

proc main() =
  let input = readFile(inputFilePath).strip.split("\n\n").map(s => s.splitLines[1..^1].map(parseInt))
  let (n, a, b) = game(input[0], input[1])
  echo n
  echo a
  echo b
  if n == 1:
    echo (a.toSeq * toSeq(1..a.len).reversed).sum
  elif n == 2:
    echo (b.toSeq * toSeq(1..b.len).reversed).sum

  

when isMainModule:
  main()