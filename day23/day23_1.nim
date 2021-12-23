import moves

const EMPTY = 0
const A = 1
const B = 2
const C = 3
const D = 4

proc norm(ns: seq[int]): int =
  # var ms = newSeq[int](ns.len)
  # for i, n in ns: ms[i] = n
  var ms = ns
  if ms[0] > ms[1]: swap(ms[0],ms[1])
  if ms[2] > ms[3]: swap(ms[2],ms[3])
  if ms[4] > ms[5]: swap(ms[4],ms[5])
  if ms[6] > ms[7]: swap(ms[6],ms[7])
  result = fromDigits(ms, 19)

proc encode(m: string): int =
  let ls = m.splitLines
  var pos = newSeqWith(4, newSeq[int]())

  for i in 0..10:
    case ls[1][1+i]:
    of '.': discard
    of 'A': pos[A-1].add i
    of 'B': pos[B-1].add i
    of 'C': pos[C-1].add i
    of 'D': pos[D-1].add i
    else: abort(fmt"unknown char {ls[1][i]} i={i}")
    
  for j in [2,3]:
    for i in [3,5,7,9]:
      case ls[j][i]:
      of '.': discard
      of 'A': pos[A-1].add 11 + 4*(j-2) + (i-3) div 2
      of 'B': pos[B-1].add 11 + 4*(j-2) + (i-3) div 2
      of 'C': pos[C-1].add 11 + 4*(j-2) + (i-3) div 2
      of 'D': pos[D-1].add 11 + 4*(j-2) + (i-3) div 2
      else: abort(fmt"unknown char {ls[j][i]}")
  
  result = pos.flatten().norm()

proc decode(n: int): string =
  var ds = digits(n, 19)
  while ds.len < 8: ds.add 0
  var ls = [
    "#############",
    "#...........#",
    "###.#.#.#.###",
    "  #.#.#.#.#  ",
    "  #########  ",
  ]
  for i in 0..3:
    let c = "ABCD"[i]
    for p in [ds[2*i], ds[2*i+1]]:
      if p <= 10:
        ls[1][p+1] = c
      elif p <= 14:
        ls[2][3 + 2*(p-11)] = c
      elif p <= 18:
        ls[3][3 + 2*(p-15)] = c
      else:
        abort("unknown pos")

  result = ls.join("\n")



proc nei(n: int): seq[(int, int)] =
  # #############
  # #01234567890#
  # ###1#2#3#4###
  #   #5#6#7#8#
  #   #########
  var ds = digits(n, 19)
  while ds.len < 8: ds.add 0

  var space = newSeq[int](19)
  space[ds[0]] = A
  space[ds[1]] = A
  space[ds[2]] = B
  space[ds[3]] = B
  space[ds[4]] = C
  space[ds[5]] = C
  space[ds[6]] = D
  space[ds[7]] = D

  let cost = [1, 10, 100, 1000]
  for i in 0..3: # echo 
    for j in [2*i, 2*i+1]:
      let p = ds[j]
      if p <= 10:
        if p != 0 and space[p-1] == EMPTY:
          ds[j] = p-1
          result.add (cost[i], ds.norm())
          ds[j] = p
        if p != 10 and space[p+1] == EMPTY:
          ds[j] = p+1
          result.add (cost[i], ds.norm())
          ds[j] = p
        if p in [2,4,6,8]:
          if i == (p-2) div 2 and space[10 + p div 2] == EMPTY: # rule 2
            ds[j] = 10 + p div 2
            result.add (cost[i], ds.norm())
            ds[j] = p
          else:
            return # rule 1
      elif p <= 14:
        for d in [2+2*(p-11), p+4]:
          if space[d] == EMPTY:
            ds[j] = d
            result.add (cost[i], ds.norm())
            ds[j] = p
      else:
        let d = p-4
        if space[d] == EMPTY:
          ds[j] = d
          result.add (cost[i], ds.norm())
          ds[j] = p

import heapqueue

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.encode()
  # echo decode(input)
  # echo rawInput
  # echo decode(input) == rawInput

  # for n in nei(input):
  #   for n2 in nei(n[1]):
  #     echo n2
  #     echo decode(n2[1])
  #   break

  let final = norm(@[11,15,12,16,13,17,14,18])
  echo norm(@[11,12,13,14,15,16,17,18]) + 1
  # echo decode(final)

  var visited: Table[int, int]
  var q: HeapQueue[(int, int)]
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


when isMainModule:
  # main("day23_sample_1.txt")
  main("day23_input_1.txt")  
  