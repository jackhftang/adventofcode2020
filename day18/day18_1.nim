import ../common

const inputFilename = "day18_input.txt"
# const inputFilename = "day18_sample1.txt"
# const inputFilename = "day18_sample2.txt"
const inputFilePath = currentSourcePath.parentDir / inputFilename

# ----

proc eval(s: string): int =
  echo fmt"eval {s}"
  var i = 0
  var op: seq[proc(a,b: int): int]
  while i < s.len:
    let c = s[i]
    if c.isDigit:
      let n = parseInt($c)
      if op.len == 0:
        result = n
      else:
        let f = op.pop()
        result = f(result, n)
      i.inc
    elif c == ' ':
      i.inc
    elif c == '+':
      op.add proc(a,b:int): int = a+b
      i.inc
    elif c == '*':
      op.add proc(a,b:int): int = a*b
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
      if op.len == 0:
        result = n
      else:
        let f = op.pop()
        result = f(result, n)
    else:
      abort(c)

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