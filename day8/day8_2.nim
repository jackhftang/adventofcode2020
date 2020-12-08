import ../common

const inputFilename = "day8_input.txt"
# const inputFilename = "day8_sample.txt"
const inputFilePath = currentSourcePath.parentDir / inputFilename

# ----
  
proc buildLoop(input: seq[(string, int)]): HashSet[int] =
  var t = initHashSet[int]()
  var first = true
  var i = 0

  while true:
    let inst = input[i]

    if i in t: 
      if first:
        first = false
        t.clear()
      else:
        break
    t.incl i

    case inst[0]:
    of "acc":
      i += 1
    of "jmp":
      i += inst[1]
    of "nop": 
      i += 1
    else: 
      abort(input)

  result = t 

proc buildPrev(xs: seq[(string, int)]): (seq[seq[int]], seq[seq[int]]) =
  var p = newSeqWith[seq[int]](xs.len+1, newSeq[int]())
  var n = newSeqWith[seq[int]](xs.len+1, newSeq[int]())
  for i in 0..xs.high:
    let inst = xs[i]
    case inst[0]:
    of "acc": 
      p[i+1].add i
    of "jmp":
      p[i + inst[1]].add i
      n[i+1].add i
    of "nop":
      p[i + 1].add i
      n[i + inst[1]].add i
    of "end":
      discard
    else:
      abort(inst)
  return (p,n)

proc findInst(input: seq[(string, int)], prev: seq[seq[int]], prevn: seq[seq[int]], loop: HashSet[int], i: int, change: int): int =
  let inst = input[i]
  if inst[0] in ["nop", "jmp"] and i in loop:
    return i
  for j in prev[i]:
    let x = findInst(input, prev, prevn, loop, j, change)
    if x != -1: return x

  if change > 0: 
    for j in prevn[i]:
      let x = findInst(input, prev, prevn, loop, j, change-1)
      if x != -1: return x

  return -1

proc main() =
  var input = readFile(inputFilePath).strip.split("\n").map(s => s.split(" ")).map(x => (x[0], parseInt(x[1])))
  echo input
  
  let loop = buildLoop(input)
  echo loop
  echo loop.len

  var prev = buildPrev(input)
  echo prev

  let ix = findInst(input, prev[0], prev[1], loop, input.len - 1, 1)
  echo ix, " ", input[ix]
  echo ix in loop
  input[ix] = ((if input[ix][0] == "nop": "jmp" else: "nop"), input[ix][1])
  echo input[ix]

  input.add ("end", 0)
  
  var t = initHashSet[int]()
  var i, acc = 0
  while true:
    let inst = input[i]
    echo i
    if i in t: 
      abort("loop", i)
    t.incl i
    case inst[0]:
    of "acc":
      acc += inst[1]
      i += 1
    of "jmp":
      i += inst[1]
    of "nop": 
      i += 1
    of "end":
      break
    else: 
      abort(input)
  
  echo "ans=", acc

proc execute(input: seq[(string, int)]): Option[int] =
  var t = initHashSet[int]()
  var i, acc = 0
  while true:
    let inst = input[i]
    if i in t: 
      return none[int]()
    t.incl i
    case inst[0]:
    of "acc":
      acc += inst[1]
      i += 1
    of "jmp":
      i += inst[1]
    of "nop": 
      i += 1
    of "end":
      break
    else: 
      abort(input)
  return some(acc)

proc main2() =
  var input = readFile(inputFilePath).strip.split("\n").map(s => s.split(" ")).map(x => (x[0], parseInt(x[1])))
  input.add ("end", 0)

  var i = 0
  while true:
    let inst = input[i]
    echo inst
    case inst[0]:
    of "acc":
      i += 1
    of "jmp":
      input[i] = ("nop", inst[1])
      let p = execute(input)
      if p.isSome():
        echo p.get()
        break
      input[i] = ("jmp", inst[1])
      i += inst[1]
    of "nop": 
      input[i] = ("jmp", inst[1])
      let p = execute(input)
      if p.isSome():
        echo p.get()
        break
      input[i] = ("nop", inst[1])
      i += 1
    of "end":
      break
    else: 
      abort(input)

when isMainModule:
  main()
  main2()