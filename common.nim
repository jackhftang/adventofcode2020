import sequtils, tables, sets, deques, heapqueue, strformat, strutils, strscans,
    math, options, sugar, algorithm, random
export sequtils, tables, sets, deques, heapqueue, strformat, strutils, strscans,
    math, options, sugar, algorithm, random

from os import `/`, parentDir
export `/`, parentDir

# -------------------------------------------------------------
# misc

proc abort*(xs: varargs[string, `$`]) =
  # shorter raise exception
  raise newException(ValueError, xs.join(" "))

# -------------------------------------------------------------
# openArray

proc count*[T](xs: openArray[T], test: proc(t: T): bool): int =
  # count the number of elements that satisfy `test`
  for x in xs:
    if test(x):
      result.inc()

proc indexes*[T](xs: openArray[T], v: T): seq[int] =
  # return the index that equal to v (similar to find, but find all)
  for i, x in xs:
    if x == v:
      result.add i

proc indexes*[T](xs: openArray[T], test: proc(t: T): bool): seq[int] =
  # return the all index that satisfy `test`
  for i, x in xs:
    if test(x):
      result.add i

proc groupBy*[K, T](xs: openArray[T], group: proc(t: T): K): Table[K, seq[T]] =
  # unlike `indexBy` create seq[T]
  for x in xs:
    let g = group(x)
    result.mgetOrPut(g, @[]).add x

# -------------------------------------------------------------
# string

proc toCountTable*(s: string): CountTable[char] =
  # s.toSeq.toCountTable
  for c in s: result.inc(c)

# -------------------------------------------------------------
# control flow

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

# -------------------------------------------------------------
# arithmetic

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

proc digits*(n: int, base = 10): seq[int] =
  assert n >= 0
  if n == 0: return @[0]
  var t = n
  while t > 0:
    result.add (t mod base)
    t = t div base

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
  result = (x, y, q)

proc modinv*(i, m: int): int =
  let (x, _, g) = extgcd(i, m)
  result = if g < 0: -x else: x
  if result < 0: result += m

proc modpow*(x, p, m: int): int =
  var t = x
  var s = p
  result = 1
  while s > 0:
    if (s and 1) == 1:
      result = result * t mod m
    t = t * t mod m
    s = s shr 1

# -------------------------------------------------------------
# Geometry

type Point* = object
  x, y: int

proc dot*(a, b: Point): int = a.x*b.x + a.y*b.y

# -------------------------------------------------------------
# Combinatorics

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

# -------------------------------------------------------------
# HashSet

proc toHashSet*(s: string): HashSet[char] =
  for c in s: result.incl(c)

proc toCountTable*[T](hs: SomeSet[T]): CountTable[T] =
  for x in hs:
    result.inc(x)

proc filter*[T](hs: SomeSet[T], f: proc(t: T): bool): HashSet[T] =
  for e in hs:
    if f(e):
      result.incl e

# -------------------------------------------------------------
# Table

proc indexes*[K, V](t: Table[K, V], v: V): seq[K] =
  for k, e in t:
    if e == v:
      result.add k

proc indexes*[K, V](t: Table[K, V], test: proc(v: V): bool): seq[K] =
  for k, e in t:
    if test(e):
      result.add k

proc map*[K, V, T](t: Table[K, V], f: proc(v: V): T): Table[K, T] =
  # structural perserved map
  for k, e in t:
    result[k] = f(e)

proc map*[K, V, T](t: Table[K, V], f: proc(k: K, v: V): T): Table[K, T] =
  for k, e in t:
    result[k] = f(k, e)

proc filter*[K, V](t: Table[K, V], f: proc(k: K, v: V): bool): Table[K, V] =
  for k, e in t:
    if f(k, e):
      result[k] = e

# -------------------------------------------------------------
# CountTable

proc `+`*[T](a, b: CountTable[T]): CountTable[T] =
  for k, v in a:
    result.inc(k, v)
  for k, v in b:
    result.inc(k, v)

proc `-`*[T](a, b: CountTable[T]): CountTable[T] =
  for k, v in a:
    result.inc(k, v)
  for k, v in b:
    result.inc(k, -v)

proc indexes*[T](t: CountTable[T], count: int): seq[T] =
  for k, v in t:
    if v == count:
      result.add k

proc indexes*[T](t: CountTable[T], test: proc(n: int): bool): seq[T] =
  for k, v in t:
    if test(v):
      result.add k

proc map*[T, V](t: CountTable[T], f: proc(n: int): V): Table[T, V] =
  for k, e in t:
    result[k] = f(e)

proc map*[T, V](t: CountTable[T], f: proc(t: T, n: int): V): Table[T, V] =
  for k, e in t:
    result[k] = f(k, e)

proc filter*[T](t: CountTable[T], f: proc(k: T, n: int): bool): CountTable[T] =
  for k, e in t:
    if f(k, e):
      result[k] = e
