import moves
import options

proc intersection(a, b: seq[int]): seq[int]=
  let x = a.toHashSet()
  let y = b.toHashSet()
  result = (x*y).toSeq
  result.sort()

proc intersection(a,b: Option[seq[int]]): Option[seq[int]] =
  if a.isSome and b.isSome:
    return some intersection(a.get, b.get)
  elif a.isSome:
    return a 
  elif b.isSome:
    return b
  # else: none

proc intersection(a: Option[seq[int]], b: seq[int]): Option[seq[int]] {.inline.} =
  intersection(a, some b)

proc fasterContains(xs: seq[int], x: int): bool =
  let n = xs.len
  if x < xs[0] or x > xs[n-1]: 
    return false
  if n < 16: 
    for i in 0 .. n-1:
      if xs[i] == x: return true
      if xs[i] > x: return false
    return false
  let i = bsearchMax(0, n, i => xs[i] <= x)
  if xs[i] == x:
    return true
  return false

type
  OpType = enum
    ADD
    MUL
    DIV
    MOD
    EQL

  VarTableEntryKind = enum
    SYM
    VALUE
    OP
    EQ

  VarTableEntryIx = distinct int

  VarTableOperand = object
    case isValue: bool
    of true: 
      value: int
    of false:
      to: VarTableEntryIx

  VarTableEntry = object
    case k: VarTableEntryKind
    of SYM: 
      sym: int
    of VALUE:
      value: int
    of EQ:
      to: VarTableEntryIx
    of OP:
      op: OpType
      a,b: VarTableOperand

  VarTable = object
    # computation graph
    vars: seq[VarTableEntry]
    # none means aribrary output
    outs: seq[Option[seq[int]]]
    # none means no constraint 
    cons: seq[Option[seq[int]]]
    # critical to check
    crit: seq[bool]

proc len*(c: VarTable): int = c.vars.len
proc `[]`*(c: VarTable, i: VarTableEntryIx): VarTableEntry = c.vars[i.int]
# proc `[]`*(c: VarTable, i: int): VarTableEntry = c.vars[i.int]
proc outputs*(c: VarTable, i: VarTableEntryIx): Option[seq[int]] = c.outs[i.int]
proc constraints*(c: VarTable, i: VarTableEntryIx): Option[seq[int]] = c.cons[i.int]

proc isRef*(n: VarTableOperand): bool = not n.isValue
proc outputs*(c: VarTable, n: VarTableOperand): Option[seq[int]]  = 
  if n.isValue:
    return some @[n.value]
  else:
    outputs(c, n.to)
proc constraints*(c: VarTable, n: VarTableOperand): Option[seq[int]]  = 
  if n.isValue:
    return some @[n.value]
  else:
    constraints(c, n.to)

proc toVarTableOperand*(n: VarTableEntry): VarTableOperand =
  case n.k:
  of SYM: return VarTableOperand(isValue: false, to: VarTableEntryIx(n.sym))
  of EQ: return VarTableOperand(isValue: false, to: VarTableEntryIx(n.to))
  of VALUE: return VarTableOperand(isValue: true, value: n.value)
  of OP: abort("cannot convert to operand")

proc newValue*(v: int): VarTableEntry = VarTableEntry(k: VALUE, value: v)
proc newEq*(to: VarTableEntryIx): VarTableEntry = VarTableEntry(k: EQ, to: to)
proc newOp*(op: OpType, a, b: VarTableOperand): VarTableEntry = 
  VarTableEntry(k: OP, op: op,a: a, b: b)
proc newOp*(op: OpType, a, b: VarTableEntryIx): VarTableEntry = 
  VarTableEntry(
    k: OP, 
    op: op,
    a: VarTableOperand(isValue: false, to: a), 
    b: VarTableOperand(isValue: false, to: b),
  )
proc newOp*(op: OpType, a, b: VarTableEntry): VarTableEntry =
  VarTableEntry(
    k: OP, 
    op: op,
    a: a.toVarTableOperand(), 
    b: b.toVarTableOperand(),
  )

proc toVarTableEntry(operand: VarTableOperand): VarTableEntry =
  if operand.isValue: result = newValue(operand.value)
  else: result = newEq(operand.to)

proc `$`(n: VarTableOperand): string =
  case n.isValue:
  of true: $n.value
  of false: fmt"v{n.to.int}"

proc `$`(n: VarTableEntry): string =
  case n.k:
  of SYM: fmt"v{n.sym}"
  of VALUE: $n.value
  of OP: fmt"{n.op}({n.a}, {n.b})"
  of EQ: fmt"= v{n.to.int}"

proc `$`(c: VarTable): string =
  for i in 0 .. c.vars.high:
    if i > 0:
      result.add "\n"
    let outs = c.outs[i]
    let cons = c.cons[i]
    var s = "out:"
    s.add (if outs.isNone: "*" else: $outs.get.len)
    s.add " con:"
    s.add (if cons.isNone: "*" else: $cons.get.len)

    if outs.isSome:
      s.add " outs=["
      for i in 0 ..< min(outs.get.len, 10):
        if i != 0: s.add ", "
        s.add $outs.get[i]
      if outs.get.len > 10:
        s.add "..."
      s.add "]"

    if cons.isSome:
      s.add " cons=["
      for i in 0 ..< min(cons.get.len, 10):
        if i != 0: s.add ", "
        s.add $cons.get[i]
      if cons.get.len > 10:
        s.add "..."
      s.add "]"

    let crit = if c.crit[i]: '>' else: ' '
    result.add fmt"{crit}v{i}: {c.vars[i]} {s}"

proc newSym*(c: var VarTable, sols: seq[int]): VarTableEntry = 
  result = VarTableEntry(k: SYM, sym: c.len)
  c.vars.add result
  c.outs.add some(sols)
  c.cons.add none[seq[int]]()
  c.crit.add false
  
proc addNode(c: var VarTable, n: VarTableEntry): VarTableEntry =
  result = VarTableEntry(k: SYM, sym: c.len)
  c.vars.add n
  c.outs.add none[seq[int]]()
  c.cons.add none[seq[int]]()
  c.crit.add false

proc simplify(c: var VarTable): bool =
  var updated = false

  # replace node with constants 
  for i in 0 ..< c.len:
    if c.vars[i].k != VALUE and c.outs[i].isSome and c.outs[i].get.len == 1:
      c.vars[i] = newValue(c.outs[i].get[0])  
      updated = true

  # calculate all constants
  for i in 0 ..< c.len:
    let n = c.vars[i]
    if n.k != OP: continue

    # immediate value
    if n.a.isValue and n.b.isValue:
      updated = true
      case n.op:
      of ADD: c.vars[i] = newValue(n.a.value + n.b.value)
      of MUL: c.vars[i] = newValue(n.a.value * n.b.value)
      of DIV: c.vars[i] = newValue(n.a.value div n.b.value)
      of MOD: c.vars[i] = newValue(n.a.value mod n.b.value)
      of EQL: c.vars[i] = newValue(if n.a.value == n.b.value: 1 else: 0)
    
    # move constant to right
    if n.a.isValue and not n.b.isValue and n.op in [MUL, ADD, EQL]:
      c.vars[i] = newOp(n.op, n.b, n.a)
      updated = true

  # op specific simplifcation
  for i in 0 ..< c.len:
    let n = c.vars[i]
    if n.k != OP: continue

    if n.op == DIV:
      if n.b.isValue and n.b.value == 1:
        c.vars[i] = n.a.toVarTableEntry()
        updated = true

    if n.op == MUL:
      if n.b.isValue and n.b.value == 0:
        c.vars[i] = newValue(0)
        updated = true
      if n.b.isValue and n.b.value == 1:
        c.vars[i] = n.a.toVarTableEntry()
        updated = true
    
    if n.op == ADD:
      if n.b.isValue and n.b.value == 0:
        c.vars[i] = n.a.toVarTableEntry()
        updated = true

  for i in 0 ..< c.len:
    let n = c.vars[i]
    if n.k != OP: continue
    
    # inline eq
    if n.a.isRef and c[n.a.to].k == EQ:
      var m = c[n.a.to]
      while c[m.to].k == EQ: m = c[m.to]
      c.vars[i].a.to = m.to
      updated = true
    if n.b.isRef and c[n.b.to].k == EQ:
      var m = c[n.b.to]
      while c[m.to].k == EQ: m = c[m.to]
      c.vars[i].b.to = m.to
      updated = true

    # inline constants
    if n.a.isRef and c[n.a.to].k == VALUE:
      c.vars[i].a = VarTableOperand(isValue: true, value: c[n.a.to].value)
      updated = true
    if n.b.isRef and c[n.b.to].k == VALUE:
      c.vars[i].b = VarTableOperand(isValue: true, value: c[n.b.to].value)
      updated = true

  result = updated

proc eliminateConstants(c: var VarTable): bool =
  # must simplify to inline eq and constants first
  var updated = false

  var remap = newSeq[int](c.len)
  remap.fill(-1)
  var j = 0
  for i in 0 ..< c.len:
    let n = c.vars[i]
    case n.k:
    of EQ, VALUE:
      # ignore
      discard
    of SYM, OP:
      # if i notin keep:
      #   continue 
      remap[i] = j
      if i != j:
        c.vars[j] = n
        c.outs[j] = c.outs[i]
        c.cons[j] = c.cons[i]
        updated = true
      j += 1
  c.vars.setLen(j)
  c.outs.setLen(j)
  c.cons.setLen(j)

  # update reference
  for i in 0 ..< c.len:
    let n = c.vars[i]
    if n.k != OP: continue
    if n.a.isRef and n.a.to.int != remap[n.a.to.int]:
      assert remap[n.a.to.int] >= 0
      c.vars[i].a.to = VarTableEntryIx(remap[n.a.to.int])
      updated = true
    if n.b.isRef and n.b.to.int != remap[n.b.to.int]:
      assert remap[n.b.to.int] >= 0
      c.vars[i].b.to = VarTableEntryIx(remap[n.b.to.int])
      updated = true

  result = updated

proc eliminateNoEffectCons*(c: var VarTable): bool =
  var updated = false

  # only keep useful check and its dependences 
  # i.e. cons < outs, remove cons >= outs
  var keep: HashSet[int]
  for i in countdown(c.len-1, 0):
    let n = c.vars[i]
    # only consider OP
    if n.k != OP: 
      keep.incl i
      continue
    
    if i in keep: 
      if n.a.isRef: keep.incl n.a.to.int
      if n.b.isRef: keep.incl n.b.to.int
      continue

    if c.cons[i].isNone:
      # keep.incl i
      # if n.a.isRef: keep.incl n.a.to.int
      # if n.b.isRef: keep.incl n.b.to.int
      continue

    # keep cons < outs
    let outs = c.outs[i].get.toHashSet
    let cons = c.cons[i].get.toHashSet
    if cons < outs:
      keep.incl i
      if n.a.isRef: keep.incl n.a.to.int
      if n.b.isRef: keep.incl n.b.to.int

  var remap = newSeq[int](c.len)
  remap.fill(-1)
  var j = 0
  for i in 0 ..< c.len:
    if i in keep:
      remap[i] = j
      if i != j:
        c.vars[j] = c.vars[i]
        c.outs[j] = c.outs[i]
        c.cons[j] = c.cons[i]
        updated = true
      j += 1
  c.vars.setLen(j)
  c.outs.setLen(j)
  c.cons.setLen(j)

  # update reference
  for i in 0 ..< c.len:
    let n = c.vars[i]
    if n.k != OP: continue
    if n.a.isRef and n.a.to.int != remap[n.a.to.int]:
      assert remap[n.a.to.int] >= 0
      c.vars[i].a.to = VarTableEntryIx(remap[n.a.to.int])
      updated = true
    if n.b.isRef and n.b.to.int != remap[n.b.to.int]:
      assert remap[n.b.to.int] >= 0
      c.vars[i].b.to = VarTableEntryIx(remap[n.b.to.int])
      updated = true

  result = updated

proc eval(c: VarTable, symVals: seq[int]): seq[int] =
  for i in 0 ..< c.len:
    let n = c.vars[i]
    case n.k:
    of SYM:
      assert i == n.sym 
      let v = symVals[n.sym]
      result.add v
    of VALUE:
      result.add n.value
    of EQ:
      result.add result[n.to.int]
    of OP:
      let va = 
        if n.a.isValue: n.a.value
        else: result[n.a.to.int]
      let vb =
        if n.b.isValue: n.b.value
        else: result[n.b.to.int]
      case n.op:
      of ADD: result.add(va + vb)
      of MUL: result.add(va * vb)
      of DIV: result.add(va div vb)
      of MOD: result.add(va mod vb)
      of EQL: result.add(if va == vb: 1 else: 0)

proc populateOutputs*(c: var VarTable): bool =
  var updated = false
  for i in 0 ..< c.len:
    let n = c.vars[i]
    let prev = c.outs[i]
    case n.k:
    of SYM:
      continue
    of VALUE:
      c.outs[i] = some @[n.value]
    of EQ:
      c.outs[i] = outputs(c, n.to)
    of OP:
      let a = intersection(c.outputs(n.a), c.constraints(n.a)).get
      let b = intersection(c.outputs(n.b), c.constraints(n.b)).get
      case n.op:
      of ADD:
        var outs: seq[int]
        forProd x,y in a,b: outs.add(x+y)
        outs.sort()
        c.outs[i] = some outs.deduplicate(true)
        updated = updated or c.outs[i] != prev
      of MUL:
        var outs: seq[int]
        forProd x,y in a,b: outs.add(x*y)
        outs.sort()
        c.outs[i] = some outs.deduplicate(true)
        updated = updated or c.outs[i] != prev
      of DIV:
        var outs: seq[int]
        forProd x,y in a,b: outs.add(x div y)
        outs.sort()
        c.outs[i] = some outs.deduplicate(true)
        updated = updated or c.outs[i] != prev
      of MOD:
        var outs: seq[int]
        forProd x,y in a,b: outs.add(x mod y)
        outs.sort()
        c.outs[i] = some outs.deduplicate(true)
        updated = updated or c.outs[i] != prev
      of EQL:
        if a.len == 1 and b.len == 1 and a[0] == b[0]: 
          # only match possible 
          c.outs[i] = some @[1]
        else:
          let outs = intersection(a, b)
          if outs.len == 0:  
            # disjoint
            c.outs[i] = some @[0]
          else:
            c.outs[i] = some @[0,1]
        updated = updated or c.outs[i] != prev


proc constraintOutput(c: var VarTable, ix: VarTableEntryIx, output: seq[int]) =
  let n = c[ix]
  let i = ix.int
  case n.k:
  of VALUE:
    assert n.value in output
    c.cons[i] = some @[n.value]
  of SYM:
    c.outs[i] = intersection(c.outs[i], output) 
    c.cons[i] = intersection(c.cons[i], output) 
  of EQ:
    c.cons[i] = intersection(c.cons[i], output)
  of OP:
    let a = intersection(c.outputs(n.a), c.constraints(n.a)).get
    let b = intersection(c.outputs(n.b), c.constraints(n.b)).get

    # intersection solution
    c.cons[i] = intersection(c.cons[i], output)
    case n.op:
    of ADD:
      var a2,b2: seq[int]
      if n.a.isValue:
        a2 = a
      else:
        forProd y,x in output, b: a2.add y-x
        a2 = intersection(a, a2)
        if a2 != a: c.constraintOutput(n.a.to, a2)
      if n.b.isValue:
        b2 = b
      else:
        forProd y,x in output, a2: b2.add y-x
        b2 = intersection(b, b2)
        if b2 != b: c.constraintOutput(n.b.to, b2)
    of MUL:
      var a2,b2: seq[int]
      if n.a.isValue or (0 in output and 0 in b):
        a2 = a
      else:
        forProd y, x in output, b:
          if x != 0 and y mod x == 0:
            a2.add (y div x)
        a2 = intersection(a, a2)
        if a2 != a: c.constraintOutput(n.a.to, a2)
      if n.b.isValue or (0 in output and 0 in a2):
        b2 = b
      else:
        forProd y, x in output, a2:
          if x != 0 and y mod x == 0:
            b2.add (y div x)
        b2 = intersection(b, b2)
        if b2 != b: c.constraintOutput(n.b.to, b2)
    of DIV:
      var a2: seq[int]
      for y in output:
        for x in b:
          for i in 0 ..< x:
            a2.add x*y+i
      a2 = intersection(a, a2)
      if a2 != a: c.constraintOutput(n.a.to, a2)
    of MOD:
      assert b.len == 1
      var a2: seq[int]
      for x in a:
        if x mod b[0] in output:
          a2.add x
      a2 = intersection(a, a2)
      if a2 != a: c.constraintOutput(n.a.to, a2)
    of EQL:
      assert output.len > 0 and output.len <= 2
      assert output.all(x => x in [0,1])
      if output.len == 1:
        if output[0] == 1:
          # must equal
          let sol = intersection(a,b)
          if a != sol: c.constraintOutput(n.a.to, sol)
          if b != sol: c.constraintOutput(n.b.to, sol)
        elif b.len == 1:
          # must not equal 
          let a2 = a.filter(x => x != b[0])
          if a2 != a: c.constraintOutput(n.a.to, a2)
        elif a.len == 1:
          # must not equal 
          let b2 = b.filter(x => x != a[0])
          if b2 != b: c.constraintOutput(n.b.to, b2)

proc markCritical(c: var VarTable) =
  # must populateOutputs first
  for i in 0 ..< c.len:
    # cons < outs
    if c.cons[i].isNone:
      continue
    let a = c.cons[i].get.toHashSet
    let b = c.outs[i].get.toHashSet
    c.crit[i] = a < b

proc find(c: VarTable, vs: seq[int], reverse: bool): (bool, seq[int]) =
  let i = vs.len
  if i == c.len:
    return (true, vs)

  if i == 6:
    echo vs[0..5]

  let n = c.vars[i]
  case n.k
  of SYM:
    if reverse:
      for v in c.outs[i].get.reversed:
        var vs2 = vs
        vs2.add v
        let res = find(c, vs2, reverse)
        if res[0]: return res
    else:
      for v in c.outs[i].get:
        var vs2 = vs
        vs2.add v
        let res = find(c, vs2, reverse)
        if res[0]: return res
  of OP:
    let a = if n.a.isValue: n.a.value else: vs[n.a.to.int]
    let b = if n.b.isValue: n.b.value else: vs[n.b.to.int]
    let v = case n.op:
      of ADD: a + b
      of MUL: a * b
      of DIV: a div b
      of MOD: a mod b
      of EQL: (if a == b: 1 else: 0)
    if not c.crit[i] or fasterContains(c.cons[i].get, v):
      # todo: check only if cons != outs
      var vs2 = vs
      vs2.add v
      let res = find(c, vs2, reverse)
      if res[0]: return res
  else:
    abort("simplify first")

proc part1(c: VarTable, vs: seq[int]): (bool, seq[int]) = c.find(vs, true)

proc part2(c: VarTable, vs: seq[int]): (bool, seq[int]) = c.find(vs, false)

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

  var cg: VarTable
  var wcnt = 0
  var ws: seq[VarTableEntry]
  14.times:
    ws.add cg.newSym(arange(1,10))
  
  # registers
  var wxyz = [
    newValue(0),
    newValue(0),
    newValue(0),
    newValue(0)
  ]
  for i, line in input:
    let ss = line.split(" ")
    case ss[0]:
    of "inp": 
      let j = ss[1][0].ord - 'w'.ord
      wxyz[j] = ws[wcnt]
      wcnt += 1
    else:
      let j = ss[1][0].ord - 'w'.ord
      let v1 = wxyz[j]
      let v2 = 
        try: 
          newValue(parseInt(ss[2]))
        except:
          wxyz[ss[2][0].ord - 'w'.ord]
      # create new node for every operation
      let node = newOp(opmap[ss[0]], v1, v2)
      wxyz[j] = cg.addNode(node)

  while true:
    while cg.simplify():
      echo "==== after simplification ===="
      
    if cg.eliminateConstants():
      echo "==== after constant elimination ===="
    else:
      break

  discard cg.populateOutputs()
  echo "==== after population ===="
 
  cg.constraintOutput(VarTableEntryIx(cg.len-1), @[0])
  echo "==== after constraint ===="
 
  var updated = true
  while updated:
    updated = false

    if cg.populateOutputs():
      echo "==== after population ===="
      updated = true

    while cg.simplify():
      echo "==== after simplification ===="
      updated = true

    if cg.eliminateConstants():
      echo "==== after constant elimination ===="
      updated = true

    if cg.eliminateNoEffectCons():
      echo "==== after no effect constraint elimination ===="
      updated = true

  cg.markCritical()

  echo cg

  block:
    var res = cg.part1(@[])
    if res[0]:
      echo res[1][0..13].join()
  block:
    var res = cg.part2(@[])
    if res[0]:
      echo res[1][0..13].join()

when isMainModule:
  # main("day24_sample_1.txt")  
  main("day24_input.txt")  