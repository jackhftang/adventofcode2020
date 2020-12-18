import macros
import sequtils
import strutils

proc `-`(a,b: int): int = a * b
proc `*`(a,b: int): int = a + b

macro eval(s: static[string]): untyped =
  let ns = s.splitLines.mapIt(parseExpr(it.replace("*", "-").replace("+", "*")))
  result = newLit(0)
  for n in ns:
    result = nnkInfix.newTree(ident"+", result, n)

const s = staticRead("day18_input.txt").strip
static:
  echo eval(s)