import sequtils, sets, deques, heapqueue, strformat, strutils, strscans,
    math, options, sugar, algorithm, random
export sequtils, sets, deques, heapqueue, strformat, strutils, strscans,
    math, options, sugar, algorithm, random

import tables except indexBy
export tables except indexBy

from os import `/`, parentDir
export `/`, parentDir

import macros

# -------------------------------------------------------------
# misc

proc abort*(xs: varargs[string, `$`]) =
  # shorter raise exception
  raise newException(ValueError, xs.join(" "))


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

proc fromDigits*(ds: seq[int], base = 10): int =
  var b = 1
  for d in ds:
    result += d * b
    b *= base

proc extgcd*(a, b: int): tuple[x: int, y: int, g: int] =
  # a*x + b*y == g
  var
    (q, r) = (a, b)
    (x, y) = (1, 0)
    (x2, y2) = (0, 1)
  while r != 0:
    let q2 = q div r
    let r2 = q - r*q2
    (x, y, x2, y2) = (x2, y2, x - q2*x2, y - q2*y2)
    (q, r) = (r, r2)
  if q < 0:
    result = (-x, -y, -q)
  else:
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

iterator integerPartition*(n: int): seq[int] =
  # start slower down when n > 60
  runnableExamples:
    assert toSeq(integerPartition(4)) == @[
      @[1, 1, 1, 1],
      @[1, 1, 2],
      @[1, 3],
      @[2, 2],
      @[4],
    ]
  if n > 0:
    var a = newSeq[int](n)
    var k = 1
    var y = n - 1
    while k != 0:
      var x = a[k - 1] + 1
      k -= 1
      while 2 * x <= y:
        a[k] = x
        y -= x
        k += 1
      let l = k + 1
      while x <= y:
        a[k] = x
        a[l] = y
        yield a[0 .. k + 1]
        x += 1
        y -= 1
      a[k] = x + y
      y = x + y - 1
      yield a[0 .. k]

# -------------------------------------------------------------
# openArray

proc pairToTable*[T](xs: openArray[T]): Table[T,T] =
  # conventional even-positions as key, odd-position as value
  if xs.len mod 2 != 0:
    raise newException(ValueError, "lenght of array must be even")
  var i = 0
  while i < xs.len:
    result[xs[i]] = xs[i+1]
    i += 2 

proc cmp*[I, T](a, b: array[I, T]): int =
  for i, x in a:
    let c = cmp(x, b[i])
    if c != 0: return c

proc cmp*[T](a, b: seq[T]): int =
  ## compare elements from left to right until the first unequal, shorter and smaller.
  runnableExamples:
    assert cmp(@[1, 2], @[2, 1]) == -1
    assert cmp(@[2, 1], @[1, 2]) == 1
    assert cmp(@[1, 2], @[1, 2, 3]) == -1
    assert cmp(@[1, 2, 3], @[1, 2]) == 1
  let
    la = a.len
    lb = b.len
  result = 0
  for i in 0 ..< min(la, lb):
    let c = cmp(a[i], b[i])
    if c != 0: return c
  if la < lb: return -1
  if la > lb: return 1

proc `<`*[I, T](a, b: array[I, T]): bool =
  ## equivalent to `cmp(a,b) < 0`
  cmp(a, b) < 0

proc `<=`*[I, T](a, b: array[I, T]): bool =
  ## equivalent to `cmp(a,b) <= 0`
  cmp(a, b) <= 0

proc `<`*[T](a, b: seq[T]): bool =
  ## equivalent to `cmp(a,b) < 0`
  cmp(a, b) < 0

proc `<=`*[T](a, b: seq[T]): bool =
  ## equivalent to `cmp(a,b) < 0`
  cmp(a, b) <= 0

proc map*[T, S](xs: openArray[T], f: (int, T) -> S): seq[S] =
  ## map with index and value
  for i, x in xs:
    result.add f(i, x)

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

proc find*[T](xs: openArray[T], test: proc(t: T): bool): int =
  result = -1
  for i, x in xs:
    if test(x):
      return i

proc minIndexes*[T](xs: openArray[T]): seq[int] =
  if xs.len == 0: return
  var v = xs[0]
  result.add 0
  for i in 1 .. xs.high:
    if xs[i] < v:
      result = @[i]
      v = xs[i]
    elif xs[i] == v:
      result.add i

proc maxIndexes*[T](xs: openArray[T]): seq[int] =
  if xs.len == 0: return
  var v = xs[0]
  result.add 0
  for i in 1 .. xs.high:
    if xs[i] > v:
      result = @[i]
      v = xs[i]
    elif xs[i] == v:
      result.add i

proc indexBy*[K, T](xs: openArray[T], group: proc(t: T): K): Table[K, T] =
  # one rank less than sequtils.indexBy for which compiler cannot infer auto types e.g. [(0,0)].indexBy(x => x[0])
  # faster building table from array 
  for x in xs:
    result[group(x)] = x

proc groupBy*[K, T](xs: openArray[T], group: proc(t: T): K): Table[K, seq[T]] =
  # unlike `indexBy` create seq[T]
  # faster build table from array
  for x in xs:
    let g = group(x)
    result.mgetOrPut(g, @[]).add x

proc unroll*[T](xs: openArray[T], f: proc(a, b: T): T): seq[T] =
  # high-order function like cumsum
  runnableExamples:
    import sugar
    let y = [1, 2, 3, 4].unroll((a, b) => a+b)
    assert y == @[1, 3, 6, 10]
  if xs.len == 0: return
  result = newSeq[T](xs.len)
  result[0] = xs[0]
  for i in 1 .. xs.high:
    result[i] = f(result[i-1], xs[i])

proc unroll*[T, S](xs: openArray[T], init: S, f: proc(a: S, b: T): S): seq[S] =
  # accumulate over states
  runnableExamples:
    import sugar
    let y = [1, 2, 3].unroll(0, (a, b) => a+b)
    assert y == @[0, 1, 3, 6]
  result = newSeq[S](xs.len + 1)
  result[0] = init
  for i, x in xs: result[i+1] = f(result[i], x)

proc fold*[T](xs: openArray[T], f: proc(a, b: T): T): T {.inline.} =
  ## `proc` version of foldl
  if xs.len == 0: raise newException(ValueError, "Cannot fold empty array")
  result = xs[0]
  for i in 1..xs.high:
    result = f(result, xs[i])

proc fold*[T](xs: openArray[T], init: T, f: proc(a, b: T): T): T {.inline.} =
  ## `proc` version of foldl
  ## NOTE: the init is at second argument
  if xs.len == 0: raise newException(ValueError, "Cannot fold empty array")
  result = init
  for x in xs:
    result = f(result, x)

iterator transpose*[T](xs: seq[seq[T]]): seq[T] =
  let m = xs.len
  if m > 0: 
    var n = xs[0].len

    # find max length 
    for ys in xs:
      n = max(n, ys.len)

    for i in 0 ..< n:
      var s = newSeq[T](m)
      for j in 0 ..< m:
        if i < xs[j].len:
          s[j] = xs[j][i]
      yield s

template vectorize*(f, T: untyped): untyped =
  ## make a unary operation applicable over seq[T]
  runnableExamples:
    proc double(x: int): int = 2*x
    vectorize(double, int)
    assert double([1, 2, 3]) == [2, 4, 6]
  type
    S = typeof(f(new(T)[]))

  # seq
  proc `f`*(xs: seq[T]): seq[S] =
    result.setLen(xs.len)
    for i, x in xs: result[i] = f(x)

  # array
  proc `f`*[I](xs: array[I, T]): array[I, S] =
    for i, x in xs: result[i] = f(x)

template vectorize*(f, T, S: untyped): untyped =
  ## make a binary operation applicable over (seq[T], seq[S])
  runnableExamples:
    vectorize(`+`, int, int)
    assert [1, 2] + [3, 4] == [4, 6]
    assert 1 + [2, 3] == [3, 4]
    assert [1, 2] + 3 == [4, 5]
  runnableExamples:
    vectorize(`+`, int, int)
    vectorize(`*`, int, int)
    let x = [1, 2, 3]
    assert (1+x) * 4 == 4*x + 4
  type
    outType = typeof(f(new(T)[], new(S)[]))
    
  # vector-vector
  proc `f`*(xs: openArray[T], ys: openArray[S]): seq[outType] =
    let l = xs.len
    if l != ys.len: raise newException(ValueError, "cannot vectorize over unequal length")
    result.setLen(l)
    for i in 0 ..< l: result[i] = f(xs[i], ys[i])

  # vector-scale
  proc `f`*(xs: openArray[T], y: S): seq[outType] =
    result.setLen(xs.len)
    for i in 0 ..< xs.len: result[i] = f(xs[i], y)

  # scale-vector
  proc `f`*(x: T, ys: openArray[S]): seq[outType] =
    result.setLen(ys.len)
    for i in 0 ..< ys.len: result[i] = f(x, ys[i])

vectorize(`+`, int, int)
vectorize(`-`, int, int)
vectorize(`*`, int, int)
vectorize(`div`, int, int)
vectorize(`mod`, int, int)

vectorize(`+`, float, float)
vectorize(`-`, float, float)
vectorize(`*`, float, float)
vectorize(`/`, float, float)

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

proc filter*[K, V](t: Table[K, V], f: proc(v: V): bool): Table[K, V] =
  for k, e in t:
    if f(e):
      result[k] = e

proc filter*[K, V](t: Table[K, V], f: proc(k: K, v: V): bool): Table[K, V] =
  for k, e in t:
    if f(k, e):
      result[k] = e

proc inversed*[K,V](t: Table[K,V]): Table[V,K] =
  for k, v in t:
    result[v] = k

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

proc filter*[T](t: CountTable[T], f: proc(n: int): bool): CountTable[T] =
  for k, e in t:
    if f(e):
      result[k] = e

proc filter*[T](t: CountTable[T], f: proc(k: T, n: int): bool): CountTable[T] =
  for k, e in t:
    if f(k, e):
      result[k] = e

# -------------------------------------------------------------
# macros


macro forSum*(args: varargs[untyped]): untyped =
  ## transform to a serial of  `for` statement
  ##
  ## ..code-block: nim
  ##  forSum i in 1..10, "abcd":
  ##    echo i
  ##
  ## transform to
  ##
  ## ..code-block: nim
  ##  for i in 1..10:
  ##    echo i
  ##  for i in "abcd":
  ##    echo i

  # deal with the in operator
  expectKind(args[0], nnkInfix)
  expectLen(args[0], 3)
  assert args[0][0].strVal == "in"
  expectKind(args[0][1], nnkIdent)

  let ident = args[0][1]
  var iterators = @[args[0][2]]

  # get iterators
  for i in 1 .. args.len-2:
    iterators.add(args[i])

  # code
  let code = args[args.len-1]

  # generate code
  result = newStmtList()
  for it in iterators:
    var t = newNimNode(nnkForStmt)
    t.add(ident)
    t.add(it)
    t.add(copyNimTree(code))
    result.add(t)

macro forProd*(args: varargs[untyped]): untyped =
  ## Transform to nested `for` statement
  ##
  ## Example:
  ##
  ## ..code-block: nim
  ##  forProd i,j,k in 1..10, "abc", [false, true]:
  ##    echo i, " ", j, " ", k
  ##
  ## transform to
  ##
  ## ..code-block: nim
  ##  for i in 1..10:
  ##    for j in "abc":
  ##      for k in [false, true]:
  ##        echo i, " ", j, " ", k
  ##

  var i = 0
  var idents: seq[NimNode] = @[]

  # number of argument must be odd number
  assert args.len mod 2 == 0, "number of identifiers must equal to number of iterators"
  var n = args.len div 2

  # get identifiers
  while i < args.len:
    # echo args[i].kind
    let node = args[i]
    if node.kind == nnkIdent:
      idents.add(node)
      i.inc
    else:
      break
  assert idents.len == n-1, "too many identifiers"

  # deal with the in operator
  expectKind(args[i], nnkInfix)
  expectLen(args[i], 3)
  assert args[i][0].strVal == "in"
  expectKind(args[i][1], nnkIdent)
  idents.add(args[i][1])

  # get iterators
  var iterators = @[args[i][2]]
  i.inc
  while i < args.len - 1:
    iterators.add(args[i])
    i.inc

  # code
  let code = args[i]

  # generate code
  var forStmt = newNimNode(nnkForStmt)
  forStmt.add(idents[n-1])
  forStmt.add(iterators[n-1])
  forStmt.add(code)
  for i in countdown(n-2, 0):
    let t = newNimNode(nnkForStmt)
    t.add(idents[i])
    t.add(iterators[i])
    t.add(forStmt)
    forStmt = t

  result = forStmt

macro forZip*(args: varargs[untyped]): untyped =
  ## Each iterators need to have len() implementation
  ##
  ## Example:
  ##
  ## ..code-block: nim
  ##  forZip i,j in [1,2,3], "abc":
  ##    echo i, j
  ##
  ## transform to
  ##
  ## ..code-block: nim
  ##  block:
  ##    let
  ##      l = min(ident1.len,ident2.len)
  ##      lis1 = [1,2,3]
  ##      lis2 = "abc"
  ##    for ix in 0 ..< l:
  ##      let i = sym1[ix]
  ##      let j = sym2[ix]
  ##      echo i, j
  ##
  var i = 0
  var idents: seq[NimNode] = @[]

  # number of argument must be odd number
  assert args.len mod 2 == 0, "number of identifiers must equal to number of lists"
  var n = args.len div 2

  # get identifiers
  while i < args.len:
    # echo args[i].kind
    let node = args[i]
    if node.kind == nnkIdent:
      idents.add(node)
      i.inc
    else:
      break
  assert idents.len == n-1, "too many identifiers"

  # deal with the in operator
  expectKind(args[i], nnkInfix)
  expectLen(args[i], 3)
  assert args[i][0].strVal == "in"
  expectKind(args[i][1], nnkIdent)
  idents.add(args[i][1])

  # get iterators
  var lists = @[args[i][2]]
  i.inc
  while i < args.len - 1:
    lists.add(args[i])
    i.inc

  # code
  let code = args[i]

  # generate code
  let stmts = newStmtList()

  # let statements
  var symLists: seq[NimNode] = @[]
  for it in lists:
    let sym = genSym()
    symLists.add sym
    stmts.add newLetStmt(sym, it)

  # minimum length among lists
  let symMin = genSym()
  var minExpr = newCall(ident("len"), symLists[0])
  for i in 1..<symLists.len:
    minExpr = newCall(ident("min"), newCall(ident("len"), symLists[i]), minExpr)
  stmts.add newLetStmt(symMin, minExpr)

  # for loop
  var symIx = genSym(nskForVar)
  var forStmt = newNimNode(nnkForStmt)
    .add(symIx)
    .add(newNimNode(nnkInfix).add(ident "..<").add(newIntLitNode(0), symMin))

  # for loop body
  let body = newStmtList()
  for i, ident in idents:
    body.add newLetStmt(ident, newNimNode(nnkBracketExpr).add(symLists[i]).add(symIx))
  body.add code
  forStmt.add body

  stmts.add forStmt
  result = newBlockStmt(stmts)
