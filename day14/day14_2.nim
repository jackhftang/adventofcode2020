import ../common

const inputFilename = "day14_input.txt"
# const inputFilename = "day14_sample1.txt"
# const inputFilename = "day14_sample2.txt"
const inputFilePath = currentSourcePath.parentDir / inputFilename

# ----

iterator powerset(m: seq[char], x: int): int =
  var ns = m.indexes('X')

  var t = newSeqWith[int](m.len, 0)
  var xs = x.digits(2)
  for i in t.slice:
    if m[i] == '0':
      t[i] = if i < xs.len: xs[i] else: 0 
    elif m[i] == '1':
      t[i] = 1
    else:
      assert m[i] == 'X'
      assert i in ns

  for i in 0 ..< (1 shl ns.len):
    let ds = i.digits(2)
    for i, d in ds:
      t[ns[i]] = d   
    yield fromDigits(t, 2)

proc main() =
  var input = readFile(inputFilePath).strip.split("\n")
  var mask: seq[char]
  var mem: Table[int, int]
  for line in input:
    if line.startsWith("mask"):
      let ss = line.split(" ")
      mask = ss[2].toSeq.reversed
    elif line.startsWIth("mem"):
      var x, y: int
      assert scanf(line, "mem[$i] = $i", x, y)
      for a in powerset(mask, x):
        mem[a] = y
    else:
      abort(line)

  var ans = 0
  for k, v in mem: 
    ans += v
  
  echo ans

when isMainModule:
  main()