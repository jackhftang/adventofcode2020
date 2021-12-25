import moves

type
  OpTyp = enum
    ADD
    MUL
    DIV
    MOD
    EQL
    # NEQ
  
  NodeKind = enum
    SYM
    VALUE
    OPER

  Node = ref object
    case k: NodeKind
    of SYM:
      sym: int
    of VALUE:
      value: int
    of OPER:
      op: OpTyp
      a,b: Node

proc newValue(n: int): Node = Node(k: VALUE, value: n)
proc newSym(s: int): Node = Node(k: SYM, sym: s)
proc newOp(op: OpTyp, a, b: Node): Node = Node(k: OPER, op: op, a:a, b:b)

# proc copy(n: Node): Node =
#   case n.k:
#   of SYM, VALUE: return n
#   of OPER: return newOp(n.op, n.a.copy(), n.b.copy())

proc `$`(n: Node): string =
  case n.k:
  of SYM: 
    if n.sym < 14:
      return fmt"w{n.sym}"
    else:
      return fmt"v{n.sym-14}"
  of VALUE: return $n.value
  of OPER: 
    if n.op == MUL:
      if n.b.k == VALUE and n.b.value < 0:
        return fmt"{n.a}*({n.b})"
      return fmt"{n.a}*{n.b}"
    if n.op == ADD:
      return fmt"{n.a}+{n.b}"
    return fmt"{n.op}({n.a},{n.b})"

proc simplify(n: Node): Node =
  case n.k:
  of SYM, VALUE: return n
  of OPER:
    if n.a.k == VALUE and n.b.k == VALUE:
      case n.op:
      of ADD: return newValue(n.a.value + n.b.value)
      of MUL: return newValue(n.a.value * n.b.value)
      of DIV: return newValue(n.a.value div n.b.value)
      of MOD: return newValue(n.a.value mod n.b.value)
      of EQL: return newValue(if n.a.value == n.b.value: 1 else: 0)
      # of NEQ: return newValue(if n.a.value != n.b.value: 1 else: 0)
    
    if n.a.k == VALUE and n.b.k != VALUE and n.op in [MUL, ADD, EQL]:
      # move constant to right
      return newOp(n.op, n.b, n.a).simplify

    if n.op == MOD:
      # assumption
      if n.b.value != 26: 
        abort(fmt"mod {n.b.value}")

      # MOD (ADD v0 x) 26 == 
      # if n.a.k == OPER and n.a.a.k == SYM and n.a.a.sym < 14:
      #   if n.a.b.k == VALUE:
      #     let v = n.a.b.value mod 26
      #     if -1 <= v and v <= 25-9:
      #       return n.a
    
    if n.op == DIV:
      # div x 1 = x 
      if n.b.k == VALUE and n.b.value == 1:
        return n.a

    if n.op == MUL:
      # mul x 0 = 0
      if n.b.k == VALUE and n.b.value == 0:
        return newValue(0)
      # mul x 1 = x
      if n.b.k == VALUE and n.b.value == 1:
        return n.a
      
      if n.a.k == OPER and n.a.op == MUL and n.a.b.k == VALUE:
        # mul (mul x v1) v2 = mul x (v1*v2)
        if n.b.k == VALUE:
          return newOp(MUL, n.a.a, newValue(n.b.value * n.a.b.value))
        # mul (mul x v1) (mul y v2) = mul (mul x y) (v1*v2)
        if n.b.k == OPER and n.b.op == MUL and n.b.b.k == VALUE:
          return newOp(MUL, newOp(MUL, n.a.a, n.b.a).simplify, newValue(n.a.b.value * n.b.b.value))
      # mul (add a b) v2 = add (mul a v2) (mul b v2) 
      if n.a.k == OPER and n.a.op == ADD:
        return newOp(ADD, newOp(MUL, n.a.a, n.b).simplify, newOp(MUL, n.a.b, n.b).simplify).simplify
      # mult x (add a b) = add (mul x a) (mul x b)
      if n.b.k == OPER and n.b.op == ADD:
        return newOp(ADD, newOp(MUL, n.a, n.b.a).simplify, newOp(MUL, n.a, n.b.b).simplify).simplify
    
    if n.op == ADD:
      # add x 0 = x
      if n.b.k == VALUE and n.b.value == 0:
        return n.a
      # add (add x a) b = add x (a+b)
      if n.a.k == OPER and n.a.op == ADD and n.b.k == VALUE and n.a.b.k == VALUE:
        return newOp(ADD, n.a.a, newValue(n.b.value + n.a.b.value))
      # add x (add y a) = add (add x y) 
      # move constant to right
      if n.b.k == OPER and n.b.op == ADD:
        return newOp(ADD, newOP(ADD, n.a, n.b.a).simplify, n.b.b)

    if n.op == EQL:
      # EQL(EQL(x, y), 0) = NEQ(x,y)
      # if n.b.k == VALUE and n.b.value == 0 and n.a.k == OPER and n.a.op == EQL:
      #   return newOp(NEQ, n.a.a, n.a.b).simplify()
      # w bound
      if n.a.k == SYM and n.a.sym < 14 and n.b.k == VALUE and (n.b.value < 1 or n.b.value > 9):
        return newValue(0)
      # EQL v0 0 = 1 - v0
      if n.a.k == SYM and n.a.sym >= 14 and n.b.k == VALUE and n.b.value == 0:
        return newOp(ADD, newOp(MUL, n.a, newValue(-1)), newValue(1)) 
      

    # if n.op == NEQ:
    #   # NEQ w1 0 = 1
    #   if n.a.k == SYM and n.a.sym < 14 and n.b.k == VALUE and (n.b.value < 1 or n.b.value > 9):
    #     return newValue(1) 

    # return n
    return newOp(n.op, n.a.simplify(), n.b.simplify())

proc substitute(n: Node, ws: seq[int], vs: seq[int]): Node =
  case n.k:
  of SYM: 
    if n.sym < 14 and n.sym < ws.len:
        return newValue(ws[n.sym])
    if n.sym >= 14 and n.sym - 14 < vs.len:
      return newValue(vs[n.sym-14])
    return n
  of VALUE:
    return n
  of OPER:
    return newOp(n.op, n.a.substitute(ws,vs), n.b.substitute(ws,vs)).simplify()
    
proc countw(n: Node): seq[int] =
  case n.k:
  of SYM:
    if n.sym < 14: return @[n.sym]
    return @[]
  of VALUE:
    return @[]
  of OPER:
    let a = n.a.countw()
    let b = n.b.countw()
    return (a&b).deduplicate

proc eval(n: Node, ws, vs: seq[int]): int =
  let t = n.substitute(ws, vs)
  if t.k != VALUE: abort(fmt"cannot eval {n}")
  return t.value

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.splitLines
  
  var vars = [
    newValue(0),
    newValue(0),
    newValue(0),
    newValue(0)
  ]
  let opmap = {
    "add": ADD,
    "mul": MUL,
    "div": DIV,
    "mod": MOD,
    "eql": EQL,
  }.toTable
  
  var bounds = newSeqWith(14, arange(1,10))
  proc bound(n: Node): seq[int] =
    case n.k:
    of SYM: return bounds[n.sym]
    of VALUE: return @[n.value]
    of OPER:
      let a = n.a.bound
      let b = n.b.bound
      case n.op:
      of ADD: 
        var c: seq[int]
        forProd x,y in a,b: c.add(x+y)
        return c.deduplicate()
      of MUL:
        var c: seq[int]
        forProd x,y in a,b: c.add(x*y)
        return c.deduplicate()
      of DIV:
        var c: seq[int]
        forProd x,y in a,b: c.add(x div y)
        return c.deduplicate()
      of MOD:
        var c: seq[int]
        forProd x,y in a,b: c.add(x mod y)
        return c.deduplicate()
      of EQL:
        if a.len == 1 and b.len == 1 and a[0] == b[0]: return @[1]       
        let m = a.toHashSet()
        let n = b.toHashSet()
        if (m*n).len == 0: return @[0]
        return @[0,1]
  
  var wcnt = 0
  var vs: seq[Node]
  
  for i, line in input:
    let ss = line.split(" ")
    echo fmt"==== {i}:{line} ===="

    case ss[0]:
    of "inp": 
      vars[0] = newSym(wcnt)
      wcnt += 1
    else:
      let j = ss[1][0].ord - 'w'.ord
      let v1 = vars[j]
      let v2 = 
        try: 
          newValue(parseInt(ss[2]))
        except:
          vars[ss[2][0].ord - 'w'.ord]
      let op2 = newOp(opmap[ss[0]], v1, v2).simplify()
      if op2.k == OPER and op2.op in [EQL,MOD,DIV]:
        let bnd = op2.bound
        if bnd.len == 0:
          abort("impossible")
        if bnd.len == 1:
          vars[j] = newValue(bnd[0])
        else:
          vars[j] = newSym(14 + vs.len)
          vs.add op2
          bounds.add bnd
      else:
        vars[j] = op2
    
    echo fmt"w={vars[0]}"
    echo fmt"x={vars[1]}"
    echo fmt"y={vars[2]}"
    echo fmt"z={vars[3]}"
    for i, v in vs:
      echo fmt"v{i}={v}"
    # if i >= 80: return

  let z = vars[3]
  
  for i in 0..3:
    echo "==== ", char(i + 'w'.ord), " ===="
    echo vars[i]
    echo vars[i].countw().len

  for i, v in vs:
    echo "==== ", i, " ===="
    echo v

  return 

  var cnt: CountTable[int]
  for i in 0 .. 2^vs.len-1:
    var ms = digits(i, 2)
    while ms.len < vs.len: ms.add 0
    # echo "==== vs=", i, " ===="
    let t = z.substitute(@[], ms)
    cnt.inc(t.countw.len)
  echo cnt

  # for i in countdown(2^vs.len - 1, 0):
  for i in 0 .. 2^vs.len - 1:
    var ms = digits(i, 2)
    while ms.len < vs.len: ms.add 0
    echo fmt"testing i={i} ms={ms}"

    proc find(i: int, ws: seq[int]): (bool, seq[int]) =
      # echo fmt"find({i}, {ws})"

      if i == 14:
        if z.eval(ws, ms) == 0:
          return (true, ws)
        return (false, ws)

      for j in countdown(9, 1):
        var ws2 = ws
        ws2.add j
        
        var allPass = true
        for k in 0..<i:
          if vs[k].eval(ws2, ms) != ms[k]:
            allPass = false
            break

        if allPass:
          let res = find(i+1, ws2)
          if res[0]:
            return res
    
    let res = find(0, @[])
    if res[0]:
      echo res[1].map(x => $x).join("")

when isMainModule:
  # main("day24_sample_1.txt")
  main("day24_input.txt")  
  