import ../common

const inputFilename = "day18_input.txt"
# const inputFilename = "day18_sample1.txt"
# const inputFilename = "day18_sample2.txt"
const inputFilePath = currentSourcePath.parentDir / inputFilename

# ----
    
type Op = enum
  ADD, MUL

proc eval(op: Op, a,b: int): int =
  case op:
  of ADD: a+b
  of MUL: a*b

proc eval(s: string): int =
  echo fmt"eval {s}"
  var i = 0
  var op: seq[Op]
  var ns: seq[int]

  proc process(n: int) =
    if op.len == 0:
      ns.add n
      return
    if op[^1] == ADD:
      ns.add n + ns.pop()
      return
    ns.add n

  while i < s.len:
    let c = s[i]
    if c.isDigit:
      let n = parseInt($c)
      i.inc
      process(n)
    elif c == ' ':
      i.inc
    elif c == '+':
      op.add ADD
      i.inc
    elif c == '*':
      op.add MUL
      i.inc
    elif c == '(':
      i.inc
      var j = i
      var cnt = 1
      while cnt > 0: 
        if s[i] == '(': cnt.inc
        elif s[i] == ')': cnt.dec
        i.inc
      let n = eval(s[j..<i-1])
      process(n)
    else:
      abort(c)
  ns.prod

proc main() =
  var input = readFile(inputFilePath).strip.split("\n")
  var ans = 0
  for x in input:
    echo x
    let n = eval(x)
    echo n
    ans += n
  echo ans

when isMainModule:
  main()