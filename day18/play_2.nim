import macros
import sequtils
import strutils

proc `-`(a,b: int): int = a * b
proc `*`(a,b: int): int = a + b

macro eval(s: static[string]): untyped =
  let ns = s.splitLines.mapIt(parseExpr it.multiReplace({
    "+": "*",
    "*": "-"
  }))
  result = ns.foldl(nnkInfix.newTree(ident"+", a, b))

static:
  echo staticRead("day18_input.txt").strip.eval