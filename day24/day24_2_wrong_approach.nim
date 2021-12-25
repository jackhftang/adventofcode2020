import moves

proc intersection(a,b: seq[int]): seq[int] =
  let x = a.toHashSet()
  let y = b.toHashSet()
  result = (x*y).toSeq
  result.sort()

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

proc `$`(n: Node): string =
  case n.k:
  of SYM: 
    return fmt"v{n.sym}"
  of VALUE: 
    return $n.value
  of OPER: 
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
      
      # if n.a.k == OPER and n.a.op == MUL and n.a.b.k == VALUE:
      #   # mul (mul x v1) v2 = mul x (v1*v2)
      #   if n.b.k == VALUE:
      #     return newOp(MUL, n.a.a, newValue(n.b.value * n.a.b.value))
      #   # mul (mul x v1) (mul y v2) = mul (mul x y) (v1*v2)
      #   if n.b.k == OPER and n.b.op == MUL and n.b.b.k == VALUE:
      #     return newOp(MUL, newOp(MUL, n.a.a, n.b.a).simplify, newValue(n.a.b.value * n.b.b.value))
      # # mul (add a b) v2 = add (mul a v2) (mul b v2) 
      # if n.a.k == OPER and n.a.op == ADD:
      #   return newOp(ADD, newOp(MUL, n.a.a, n.b).simplify, newOp(MUL, n.a.b, n.b).simplify).simplify
      # # mult x (add a b) = add (mul x a) (mul x b)
      # if n.b.k == OPER and n.b.op == ADD:
      #   return newOp(ADD, newOp(MUL, n.a, n.b.a).simplify, newOp(MUL, n.a, n.b.b).simplify).simplify
    
    if n.op == ADD:
      # add x 0 = x
      if n.b.k == VALUE and n.b.value == 0:
        return n.a
      # # add (add x a) b = add x (a+b)
      # if n.a.k == OPER and n.a.op == ADD and n.b.k == VALUE and n.a.b.k == VALUE:
      #   return newOp(ADD, n.a.a, newValue(n.b.value + n.a.b.value))
      # # add x (add y a) = add (add x y) 
      # # move constant to right
      # if n.b.k == OPER and n.b.op == ADD:
      #   return newOp(ADD, newOP(ADD, n.a, n.b.a).simplify, n.b.b)

    if n.op == EQL:
      # EQL(EQL(x, y), 0) = NEQ(x,y)
      # if n.b.k == VALUE and n.b.value == 0 and n.a.k == OPER and n.a.op == EQL:
      #   return newOp(NEQ, n.a.a, n.a.b).simplify()
      # w bound
      if n.a.k == SYM and n.a.sym < 14 and n.b.k == VALUE and (n.b.value < 1 or n.b.value > 9):
        return newValue(0)
      # EQL v0 0 = 1 - v0
      # if n.a.k == SYM and n.a.sym >= 14 and n.b.k == VALUE and n.b.value == 0:
      #   return newOp(ADD, newOp(MUL, n.a, newValue(-1)), newValue(1)) 
      

    # if n.op == NEQ:
    #   # NEQ w1 0 = 1
    #   if n.a.k == SYM and n.a.sym < 14 and n.b.k == VALUE and (n.b.value < 1 or n.b.value > 9):
    #     return newValue(1) 

    # return n
    return newOp(n.op, n.a.simplify(), n.b.simplify())

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.splitLines

  let opmap = {
    "add": ADD,
    "mul": MUL,
    "div": DIV,
    "mod": MOD,
    "eql": EQL,
  }.toTable

  var bounds: seq[seq[int]]
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
        c.sort()
        return c.deduplicate(true)
      of MUL:
        var c: seq[int]
        forProd x,y in a,b: c.add(x*y)
        c.sort()
        return c.deduplicate(true)
      of DIV:
        var c: seq[int]
        forProd x,y in a,b: c.add(x div y)
        c.sort()
        return c.deduplicate(true)
      of MOD:
        var c: seq[int]
        forProd x,y in a,b: c.add(x mod y)
        c.sort()
        return c.deduplicate(true)
      of EQL:
        if a.len == 1 and b.len == 1 and a[0] == b[0]: 
          # only match possible 
          return @[1]
        let c = intersection(a,b)
        if c.len == 0:  
          # disjoint
          return @[0]
        return @[0,1]

  # variables
  var vars: seq[Node]
  for i in 0..13:
    vars.add newSym(i)
    bounds.add arange(1,10)

  # registers
  var wxyz = [
    newValue(0),
    newValue(0),
    newValue(0),
    newValue(0)
  ]
  var wcnt = 0
  for i, line in input:
    let ss = line.split(" ")
    echo fmt"==== {i}:{line} ===="

    case ss[0]:
    of "inp": 
      wxyz[0] = vars[wcnt]
      wcnt += 1
    else:
      let j = ss[1][0].ord - 'w'.ord
      let v1 = wxyz[j]
      let v2 = 
        try: 
          newValue(parseInt(ss[2]))
        except:
          wxyz[ss[2][0].ord - 'w'.ord]

      let op2 = newOp(opmap[ss[0]], v1, v2).simplify
      if op2.k in [VALUE, SYM]:
        wxyz[j] = op2
      else:
        echo op2
        let bnd = op2.bound
        if bnd.len == 1:
          wxyz[j] = newValue(bnd[0])
        else:
          let sym2 = newSym(vars.len)
          vars.add op2
          bounds.add op2.bound
          wxyz[j] = sym2
          echo fmt"{sym2} bounds {bounds[^1].len}"

      # if op2.k == OPER and op2.op in [EQL,MOD,DIV]:
      #   let bnd = op2.bound
      #   if bnd.len == 0:
      #     abort("impossible")
      #   if bnd.len == 1:
      #     wxyz[j] = newValue(bnd[0])
      #   else:
      #     wxyz[j] = newSym(14 + vs.len)
      #     vs.add op2
      #     bounds.add bnd
      # else:
      #   wxyz[j] = op2

  proc back(n: Node, output: seq[int]) =
    echo fmt"back {n} {(if output.len <= 10: $output else: $output.len)}"
    assert n.k != OPER

    if n.k == VALUE:
      echo n, ' ', output
      return

    let v = vars[n.sym]
    case v.k:
    of VALUE:
      assert v.value in output
      return 
    of SYM:
      # the 14 variables
      bounds[n.sym] = intersection(bounds[n.sym], output)
    of OPER:
      assert v.a.k in [SYM, VALUE]
      assert v.b.k in [SYM, VALUE]
      case v.op:
      of ADD: 
        let a = v.a.bound
        let b = v.b.bound

        var out2: seq[int] 
        forProd y,x in output, b:
          out2.add y-x
        let a2 = intersection(a, out2)
        back(v.a, a2)

        out2.setLen(0)
        forProd y,x in output, a2:
          out2.add y-x
        let b2 = intersection(b, out2)
        back(v.b, b2)

        # intersection solution
        bounds[n.sym] = intersection(bounds[n.sym], output)
      of MUL:
        let a = v.a.bound
        let b = v.b.bound

        var out2, a2, b2: seq[int]

        if (0 in output) and (0 in b):
          # a could be any values
          a2 = a
        else:
          forProd y, x in output, b:
            if x != 0 and y mod x == 0:
              out2.add (y div x)
          a2 = intersection(a, out2)
          if a2 != a:
            back(v.a, a2)
         
        out2.setLen(0)
        if (0 in output) and (0 in a2):
          discard
        else:
          forProd y, x in output, a2:
            if x != 0 and y mod x == 0:
              out2.add (y div x)
          b2 = intersection(b, out2)
          if b2 != b:
            back(v.b, b2)

        # intersection solution
        bounds[n.sym] = intersection(bounds[n.sym], output)
      of DIV:
        let a = v.a.bound
        let b = v.b.bound
        # div x 26
        assert b == @[26]
        
        var out2: seq[int]
        for y in output:
          for i in 0..25:
            out2.add 26*y+i
        let a2 = intersection(a, out2)
        if a2 != a:
          back(v.a, a2)

        bounds[n.sym] = intersection(bounds[n.sym], output)
      of MOD:
        let a = v.a.bound
        let b = v.b.bound 
        # MOD x 26
        assert b == @[26]
        var a2: seq[int]
        for x in a:
          if x mod 26 in output:
            a2.add x
        if a2 != a:
          back(v.a, a2)

        bounds[n.sym] = intersection(bounds[n.sym], output)
      of EQL:
        assert output.len > 0
        if output.len == 1:
          if output[0] == 1:
            # must equal
            let a = v.a.bound 
            let b = v.b.bound 
            let c = intersection(a,b)
            if a != c:
              back(v.a, c)
            if b != c:
              back(v.b, c)
            bounds[n.sym] = intersection(bounds[n.sym], output)
          elif v.b.k == VALUE:
            # must not equal
            let a = v.a.bound
            let a2 = a.filter(x => x != v.b.value)
            if a2 != a:
              back(v.a, a2)
            
  
  echo "==== back ===="
  back(newSym(vars.len-1), @[0])

  # forward again
  
        
  for i, v in vars:
    let s = if bounds[i].len <= 10: $bounds[i] else: ""
    echo fmt"v{i} {bounds[i].len} {vars[i]} {s}"


  

when isMainModule:
  main("day24_input.txt")  