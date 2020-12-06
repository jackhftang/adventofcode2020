import sequtils, tables, sets, deques, heapqueue, strformat, strutils, strscans, math, options, sugar, algorithm, random
export sequtils, tables, sets, deques, heapqueue, strformat, strutils, strscans, math, options, sugar, algorithm, random

from os import `/`, parentDir
export `/`, parentDir

proc count*[T](xs: openArray[T], test: proc(t: T): bool): int =
  for x in xs:
    if test(x):
      result.inc()

proc abort*(xs: varargs[string, `$`]) =
  # shorter raise exception
  raise newException(ValueError, xs.join(" "))

proc bsearchMax*[T: SomeInteger](lo, up: T, test: proc(t: T): bool): T =
  # find maximun value v in [lo, up] such that test(v) hold
  # test(lo) is assumed to be true
  var a = lo
  var b = up
  while a + 1 < b:
    let mid = (a+b) div 2
    if test(mid): a = mid
    else: b = mid
  result = a

proc bsearchMin*[T: SomeInteger](lo, up: T, test: proc(t: T): bool): T =
  # find minimum value v in [lo, up] such that test(v) hold
  # test(up) is assumed to be true
  var a = lo
  var b = up
  while a + 1 < b:
    let mid = (a+b) div 2
    if test(mid): b = mid
    else: a = mid
  result = b

proc logFloor*(x, base: int): int =
  assert base > 0
  var t = 1
  while t <= x:
    t *= base
    result.inc

proc logCeil*(x, base: int): int =
  assert base > 0
  var t = 1
  while t < x:
    t *= base
    result.inc

proc bti*(b: bool): int =
  # boolean to int
  if b: result = 1

proc extgcd*(a, b: int): tuple[x: int, y: int, g: int] =
  # a*x + b*y == g
  var
    q = a
    r = b
    x = 1
    y = 0
    x2 = 0
    y2 = 1
  while r != 0:
    let q2 = q div r
    let r2 = q mod r
    let tx = x
    let ty = y
    x = x2
    y = y2
    x2 = tx - q2*x2
    y2 = ty - q2*y2
    q = r
    r = r2
  result = (x,y,q)

type Point* = object
  x, y: int

proc dot*(a,b: Point): int = a.x*b.x + a.y*b.y

iterator permutation*(n: int): seq[int] =
  var c = toSeq(0..<n)
  while true:
    yield c
    if not nextPermutation(c):
      break

iterator combination*(m, n: int): seq[int] =
  var c = toSeq(0..<n)  
  block outer:
    while true:
      yield c
      
      # continue if not yet overflow (leaf operation)
      inc c[^1]
      if c[^1] <= m - 1: continue
  
      # seek i to that index that not yet overflow (rewind)
      var i = n - 1
      while c[i] >= m - n + i:
        dec i
        if i < 0: break outer

      # reset i..m-1 values (reset to leaf)
      inc c[i]
      for j in i+1 ..< n: c[j] = c[j-1] + 1 

proc `+`*[T](a,b: CountTable[T]): CountTable[T] =
  for k, v in a:
    result.inc(k, v)
  for k, v in b:
    result.inc(k, v)

proc `-`*[T](a,b: CountTable[T]): CountTable[T] =
  for k, v in a:
    result.inc(k, v)
  for k, v in b:
    result.inc(k, -v)