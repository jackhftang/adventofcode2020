import moves

type
  FooKind = enum
    single
    pair
    node

  Foo = ref object
    case kind: FooKind
    of single:
      v: int
    of pair:
      a, b: int
    of node:
      l, r: Foo

proc copy(n: Foo): Foo =
  result = Foo(kind: n.kind)
  case n.kind:
  of single: 
    result.v = n.v
  of pair: 
    result.a = n.a
    result.b = n.b
  of node:
    result.l = n.l.copy()
    result.r = n.r.copy()

proc `normalize`(a: Foo): Foo =
  if a.kind == node:
    if a.l.kind == single and a.r.kind == single:
      return Foo(kind: pair, a: a.l.v, b: a.r.v)
  return a

proc `+`(a,b: Foo): Foo = 
  Foo(kind: node, l: a, r: b).normalize()

proc addLeft(n: Foo, x: int): Foo =
  case n.kind:
  of single: Foo(kind: single, v: n.v + x)
  of pair: Foo(kind: pair, a: n.a+x, b: n.b)
  of node: Foo(kind: node, l: n.l.addLeft(x), r: n.r.copy()).normalize()

proc addRight(n: Foo, x: int): Foo =
  case n.kind:
  of single: Foo(kind: single, v: n.v + x)
  of pair: Foo(kind: pair, a: n.a, b: n.b+x)
  of node: Foo(kind: node, l: n.l.copy(), r: n.r.addRight(x)).normalize()

proc explode*(n: Foo): (bool, Foo) =
  proc run(lv: int, n: Foo): (bool, int, Foo, int)=
    case n.kind:
    of single:
      return (false, 0, n.copy(), 0)
    of pair:
      if lv >= 4:
        return (true, n.a, Foo(kind: single, v: 0), n.b)
    of node:
      let res1 = run(lv+1, n.l)
      if res1[0]: 
        return (true, res1[1], Foo(kind: node, l: res1[2], r: n.r.addLeft(res1[3])).normalize(), 0)
      else:
        let res2 = run(lv+1, n.r)
        if res2[0]:
          return (true, 0, Foo(kind: node, l: n.l.addRight(res2[1]), r: res2[2]).normalize(), res2[3])
        else:
          return (false, 0, n.copy(), 0)
  let res = run(0, n)
  result = (res[0], res[2])

proc split(n: Foo): (bool, Foo) =
  case n.kind:
  of single:
    if n.v >= 10:
      echo n.v
      let l = n.v div 2
      let r = n.v - l
      return (true, Foo(kind: pair, a: l, b: r))
    else:
      return (false, n)
  of pair:
    if n.a < 10 and n.b < 10:
      return (false, n)

    var l = Foo(kind: single, v: n.a)
    let res1 = l.split()
    if res1[0]:
      return (true, Foo(kind: node, l: res1[1], r: Foo(kind: single, v: n.b)).normalize())

    var r = Foo(kind: single, v: n.b)
    let res2 = r.split()
    if res2[0]:
      return (true, Foo(kind: node, l: Foo(kind: single, v: n.a), r: res2[1]).normalize())

    abort("impossible")
  of node:
    let res1 = split(n.l)
    if res1[0]:
      return (true, Foo(kind: node, l: res1[1], r: n.r).normalize())
    let res2 = split(n.r)
    if res2[0]:
      return (true, Foo(kind: node, l: n.l, r: res2[1]).normalize())
    return (false, n)

proc mag*(foo: Foo): int =
  case foo.kind:
  of single: return foo.v
  of pair: return 3*foo.a + 2*foo.b
  of node: return 3*mag(foo.l) + 2*mag(foo.r)
    
proc parseFoo*(s: string): Foo =
  proc readSingle(i: int): (int, Foo) =
    assert s[i].isDigit
    var n = 0
    while s[i+n].isDigit:
      n += 1
    # echo s[i..i+n-1]
    return (n, Foo(kind: single, v: parseInt(s[i..i+n-1])))

  proc readFoo(i: int): (int, Foo);

  proc readPair(i: int): (int, Foo) =
    var j = i
    assert s[j] == '['
    j += 1

    let res1 = readFoo(j)
    let l = res1[1]
    j += res1[0]

    assert s[j] == ',', fmt"s[{j}]={s[j]} s={s}"
    j += 1

    let res2 = readFoo(j)
    let r = res2[1]
    j += res2[0]
    
    assert s[j] == ']'
    j += 1

    if l.kind == single and r.kind == single:
      return (j-i, Foo(kind: pair, a: l.v, b: r.v))
    else:
      return (j-i, Foo(kind: node, l:l, r:r))

  proc readFoo(i: int): (int, Foo) =
    if s[i].isDigit:
      return readSingle(i)
    elif s[i] == '[':
      return readPair(i)
    
  let res = readFoo(0)
  return res[1]

proc `$`(n: Foo): string =
  case n.kind:
  of single: $n.v
  of pair: fmt"[{$n.a},{$n.b}]"
  of node: fmt"[{$n.l},{$n.r}]"

proc reduce(n: Foo): Foo =
  result = n
  echo "reduce: ", n
  while true:
    while true:
      let res = result.explode()
      if res[0]:
        echo "explode: ", n
        result = res[1]
      else:
        break
    let res2 = result.split()
    if res2[0]:
      echo "split: ", n
      result = res2[1]
    else:
      break
  
proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.splitLines.map(parseFoo)
  
  var foo = input[0]
  for i in 1..input.high:
    echo "----"
    foo = foo + input[i]
    foo = foo.reduce()
    echo foo
    # echo foo.explode
    
    echo foo
  
  echo foo.mag

proc test() =
  let a = parseFoo("[[[[4,3],4],4],[7,[[8,4],9]]]")
  let b = parseFoo("[1,1]")
  var c = a+b
  echo c
  
  var res = c.explode()
  echo res
  c = res[1]
  
  res = c.explode()
  echo res
  c = res[1]
  
  res = c.split()
  echo res
  c = res[1]
  
  res = c.split()
  echo res
  c = res[1]
  
  res = c.explode()
  echo res
  c = res[1]

proc test2() =
  var a = Foo(kind: pair, a:1, b:1)
  for i in 2..5:
    a = a + Foo(kind: pair, a:i, b:i)
    a = a.reduce()
  echo a

  a = Foo(kind: pair, a:1, b:1)
  for i in 2..6:
    let b = Foo(kind: pair, a:i, b:i)
    echo "add: ", b
    a = a + b
    a = a.reduce()
  echo a

when isMainModule:
  # test()
  # test2()
  # main("day18_sample_1.txt")
  # main("day18_sample_2.txt")
  main("day18_input.txt")  
  