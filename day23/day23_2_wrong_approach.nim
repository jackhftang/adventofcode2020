import moves

const EMPTY = 0
const A = 1
const B = 2
const C = 3
const D = 4

const BASE = 23

type
  State = object
    a,b: int

proc `<`(a,b: State): bool = a.a < b.a or a.b < b.b

proc norm(ns: seq[int]): State =
  assert ns.len == 16
  var ms: seq[int]
  for b in ns.chunked(4):
    let qs = b.sorted()
    ms.add qs
  result.a = fromDigits(ms[0..7], BASE)
  result.b = fromDigits(ms[8..15], BASE)

proc toseq(s: State): seq[int] =
  result.add digits(s.a, BASE)
  while result.len < 8: result.add 0
  result.add digits(s.b, BASE)
  while result.len < 16: result.add 0

proc encode(m: string): State =
  let ls = m.splitLines
  var pos = newSeqWith(4, newSeq[int]())

  # #############
  # #01.2.3.4.56#
  # ###7#8#9#0###
  #   #1#2#3#4#
  #   #5#6#7#8#
  #   #9#0#1#2#
  #   #########

  for i in 0..1:
    case ls[1][1+i]:
    of '.': discard
    of 'A': pos[A-1].add i
    of 'B': pos[B-1].add i
    of 'C': pos[C-1].add i
    of 'D': pos[D-1].add i
    else: abort(fmt"unknown char {ls[1][i]} i={i}")

  for i in 2..4:
    case ls[1][2*i]:
    of '.': discard
    of 'A': pos[A-1].add i
    of 'B': pos[B-1].add i
    of 'C': pos[C-1].add i
    of 'D': pos[D-1].add i
    else: abort(fmt"unknown char {ls[1][i]} i={i}")

  for i in 5..6:
    case ls[1][5+i]:
    of '.': discard
    of 'A': pos[A-1].add i
    of 'B': pos[B-1].add i
    of 'C': pos[C-1].add i
    of 'D': pos[D-1].add i
    else: abort(fmt"unknown char {ls[1][i]} i={i}")
    
  for j in [2,3,4,5]:
    for i in [3,5,7,9]:
      case ls[j][i]:
      of '.': discard
      of 'A': pos[A-1].add 7 + 4*(j-2) + (i-3) div 2
      of 'B': pos[B-1].add 7 + 4*(j-2) + (i-3) div 2
      of 'C': pos[C-1].add 7 + 4*(j-2) + (i-3) div 2
      of 'D': pos[D-1].add 7 + 4*(j-2) + (i-3) div 2
      else: abort(fmt"unknown char {ls[j][i]}")
  
  result = pos.flatten().norm()

proc decode(n: State): string =
  var ds = n.toSeq()

  var ls = [
    "#############",
    "#...........#",
    "###.#.#.#.###",
    "  #.#.#.#.#",
    "  #.#.#.#.#",
    "  #.#.#.#.#",
    "  #########",
  ]
  for i in 0..3:
    let c = "ABCD"[i]
    for j in 0..3:
      let p = ds[4*i+j]
      if p <= 1:
        ls[1][p+1] = c
      elif p <= 4:
        ls[1][2*p] = c
      elif p <= 6:
        ls[1][p+5] = c
      elif p <= 10:
        ls[2][3 + 2*(p-7)] = c
      elif p <= 14:
        ls[3][3 + 2*(p-11)] = c
      elif p <= 18:
        ls[4][3 + 2*(p-15)] = c
      elif p <= 22:
        ls[5][3 + 2*(p-19)] = c
      else:
        abort("unknown pos")

  result = ls.join("\n")

proc nei(n: State): seq[(int, State)] =
  # #############
  # #01.2.3.4.56#
  # ###7#8#9#0###
  #   #1#2#3#4#
  #   #5#6#7#8#
  #   #9#0#1#2#
  #   #########
  var ds = n.toSeq
 
  var space = newSeq[int](BASE)
  for i in 0..3:
    for j in 0..3:
      space[ds[4*i+j]] = i+1

  proc roomAvail(i: int): bool =
    assert i >= 0 and i <= 3
    for j in 0..3:
      if space[7+i+4*j] notin [EMPTY, i]:
        return false
    return true

  let cost = [1, 10, 100, 1000]
  for i in 0..3: # each letters
    for j in [4*i, 4*i+1, 4*i+2, 4*i+3]: # index in ds
      let p = ds[j] # position of i
      
      if p == 0:
        if roomAvail()
        if space[1] == EMPTY:
          ds[j] = 1
          result.add (cost[i], ds.norm())
          ds[j] = p
      
      elif p == 1:
        # move left
        if space[0] == EMPTY:
          ds[j] = 0
          result.add (cost[i], ds.norm())
          ds[j] = p
        # move right
        if space[2] == EMPTY:
          ds[j] = 2
          result.add (2*cost[i], ds.norm())
          ds[j] = p
        # move in
        if i == 0 and space[7] == EMPTY and roomAvail(0):
          ds[j] = 7
          result.add (2*cost[i], ds.norm())
          ds[j] = p

      elif p <= 4:
        # move left
        if space[p-1] == EMPTY:
          ds[j] = p-1
          result.add (2*cost[i], ds.norm())
          ds[j] = p
        # move right
        if space[p+1] == EMPTY:
          ds[j] = p+1
          result.add (2*cost[i], ds.norm())
          ds[j] = p
        # move in-left
        if p-2 == i and space[p+5] == EMPTY and roomAvail(p-2):
          # rule 2: only enter their room
          ds[j] = p+5
          result.add (2*cost[i], ds.norm())
          ds[j] = p
        # move in-right
        if p-1 == i and space[p+6] == EMPTY and roomAvail(p-1):
          ds[j] = p+6
          result.add (2*cost[i], ds.norm())
          ds[j] = p

      elif p == 5:
        # move right
        if space[6] == EMPTY:
          ds[j] = 6
          result.add (cost[i], ds.norm())
          ds[j] = p
        # move left
        if space[4] == EMPTY:
          ds[j] = 4
          result.add (2*cost[i], ds.norm())
          ds[j] = p 
        # move in
        if space[10] == EMPTY and roomAvail(3):
          ds[j] = 10
          result.add (2*cost[i], ds.norm())
          ds[j] = p

      elif p == 6:
        if space[5] == EMPTY:
          ds[j] = 5
          result.add (cost[i], ds.norm())
          ds[j] = p

      elif p <= 10:
        # move out left
        if space[p-6] == EMPTY:
          ds[j] = p-6
          result.add (2*cost[i], ds.norm())
          ds[j] = p
        # move out right
        if space[p-5] == EMPTY:
          ds[j] = p-5
          result.add (2*cost[i], ds.norm())
          ds[j] = p
        # move in
        if space[p+4] == EMPTY and roomAvail(p-7) :
          ds[j] = p+4
          result.add (cost[i], ds.norm())
          ds[j] = p

      elif p <= 18:
        # move up
        if space[p-4] == EMPTY:
          ds[j] = p-4
          result.add (cost[i], ds.norm())
          ds[j] = p
        # move dn
        if space[p+4] == EMPTY and (p-7) mod 4 == i:
          # only correct room can move down
          ds[j] = p+4
          result.add (cost[i], ds.norm())
          ds[j] = p
      
      elif p <= 22:
        # move up
        if space[p-4] == EMPTY and space[p] != i+1:
          # only incorrect char move up
          ds[j] = p-4
          result.add (cost[i], ds.norm())
          ds[j] = p

      else:
        abort(fmt"unknown pos {p}")

import heapqueue

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.encode()
  echo decode(input)
  echo rawInput
  echo decode(input) == rawInput

  # for n in nei(input):
  #   for n2 in nei(n[1]):
  #     echo n2
  #     echo decode(n2[1])
  #   break

  let final = norm(@[
    11,15,19,23,
    12,16,20,24,
    13,17,21,25,
    14,18,22,26
  ])
  echo decode(final)

  var visited: Table[State, int]
  var q: HeapQueue[(int, State)]
  q.push (0, input)
  var milestone = 0
  while q.len > 0:
    let s = q.pop()
    if s[1] == final:
      echo s[0]
      break
    
    if visited.len > milestone:
      echo fmt"visited={visited.len} cost={s[0]} q.len={q.len}"
      milestone += 1_000_000

    for n in nei(s[1]):
      let state = n[1]
      let cost = n[0] + s[0]
      if state in visited and visited[state] <= cost: 
        continue
      visited[state] = cost
      q.push (cost, state)

  echo visited[final]

when isMainModule:
  # main("day23_sample_1.txt")
  main("day23_sample_2.txt")
  # main("day23_input_2.txt")  
  