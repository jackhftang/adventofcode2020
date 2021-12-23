import moves
import heapqueue

const DEPTH = 4
const EMPTY = 0
const A = 1
const B = 2
const C = 3
const D = 4

type 
  State = int
  
  Board = (array[7, int], array[4, array[DEPTH, int]])
  
proc compress(s: Board): State =
  for x in s[0]:
    result = result * 5 + x
  for i in 0..3:
    for x in s[1][i]:
      result = result * 5 + x

proc decompress(n: State): Board =
  var ds = digits(n, 5)
  while ds.len < 7 + 4*DEPTH: ds.add 0

  var k = 0
  for i in countdown(3, 0):
    for j in countdown(DEPTH-1, 0):
      result[1][i][j] = ds[k]
      k += 1
  for i in countdown(6,0):
    result[0][i] = ds[k]
    k += 1
  
proc encode(m: string): State =
  var bd: Board
  let ls = m.splitLines
  for d in 0..<DEPTH:
    let j = d + 2
    for i in [3,5,7,9]:
      case ls[j][i]:
      of '.': discard
      of 'A': bd[1][(i-3) div 2][j-2] = A
      of 'B': bd[1][(i-3) div 2][j-2] = B
      of 'C': bd[1][(i-3) div 2][j-2] = C
      of 'D': bd[1][(i-3) div 2][j-2] = D
      else: abort(fmt"unknown char {ls[j][i]}")
  return bd.compress

proc decode(n: State): string =
  let s = n.decompress
  var ls = @[
    "#############",
    "#...........#",
    "###.#.#.#.###",
  ]
  (DEPTH-1).times:
    ls.add "  #.#.#.#.#"
  ls.add "  #########"

  let ch = ".ABCD"
  for p in 0..6:
    if p <= 1:
      ls[1][p+1] = ch[s[0][p]]
    elif p <= 4:
      ls[1][2*p] = ch[s[0][p]]
    elif p <= 6:
      ls[1][p+5] = ch[s[0][p]]
  for i in 0..3:
    for j in 0..<DEPTH:
      ls[j+2][3+2*i] = ch[s[1][i][j]]
  result = ls.join("\n")


proc isFinal(n: State): bool =
  let s = n.decompress
  for i in 0..3:
    for x in s[1][i]:
      if x != i+1:
        return false
  return true

proc nei(n: int): seq[(int, State)] =
  let s = n.decompress
  # #############
  # #01.2.3.4.56#
  # ### # # # ###
  #   # # # # #
  #   # # # # #
  #   # # # # #
  #   #########

  # first index of non-empty, otherwise DEPTH + 1
  var firstNonEmpty: array[4, int]  
  for i in 0..3:
    var j = 0
    while j < DEPTH and s[1][i][j] == EMPTY:
      j += 1
    firstNonEmpty[i] = j

  # true if empty or only character-i
  var roomAvail: array[4, bool] 
  roomAvail.fill(true)
  for i in 0..3:
    var j = firstNonEmpty[i]
    while j < DEPTH:
      if s[1][i][j] != i+1:
        roomAvail[i] = false
        break
      j += 1

  let cost = [0, 1, 10, 100, 1000]
  # hcost[i][j] = distacne from room i door to 0 to 6 spots
  let hcost = [
    [2,1,1,3,5,7,8],
    [4,3,1,1,3,5,6],
    [6,5,3,1,1,3,4],
    [8,7,5,3,1,1,2],
  ]

  # move out from room i
  for i in 0..3:
    if roomAvail[i]:
      # already to go in, no move out
      continue

    # try to go to any 7 spots
    let j = firstNonEmpty[i]
    if j >= DEPTH: continue # no character

    let ch = s[1][i][j]

    # to left
    for k in countdown(i+1,0):
      if s[0][k] != EMPTY: break # blocked
      var copy = s
      copy[0][k] = ch
      copy[1][i][j] = EMPTY
      let c = cost[ch] * (j+1+hcost[i][k])
      result.add (c, copy.compress)
    # to right
    for k in i+2..6:
      if s[0][k] != EMPTY: break # blocke
      var copy = s
      copy[0][k] = ch
      copy[1][i][j] = EMPTY
      let c = cost[ch] * (j+1+hcost[i][k])
      result.add (c, copy.compress)
        
  # move into room i
  for i in 0..3:
    if not roomAvail[i]:
      continue

    let j = firstNonEmpty[i]
    if j == 0: continue # room i is full

    # from 7 spots to room i
    block: 
      # from left
      for k in countdown(i+1, 0):
        let ch = s[0][k]
        if ch == EMPTY: continue # no character
        if ch != i+1: break # charactor-room not match
        var copy = s
        copy[0][k] = EMPTY
        copy[1][i][j-1] = ch
        let c = cost[ch] * (j+hcost[i][k])
        result.add (c, copy.compress)
        break
      # from right 
      for k in i+2..6:
        let ch = s[0][k]
        if ch == EMPTY: continue # no character
        if ch != i+1: break # character-room not match
        var copy = s
        copy[0][k] = EMPTY
        copy[1][i][j-1] = ch
        let c = cost[ch] * (j+hcost[i][k])
        result.add (c, copy.compress)
        break
        
proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.encode()
  echo input

  # var cost = 0
  # for i in [15,2,5,2,5,2,3]:
  #   let t = nei(input)[i]
  #   cost += t[0]
  #   input = t[1]
  # for i, n in nei(input):
  #   echo i, " ", cost + n[0], " ", n
  #   echo n[1].decode()

  var milestone = 0
  var q: HeapQueue[(int, State)]
  var visited: Table[int, int]
  q.push (0, input)
  while q.len > 0:
    let s = q.pop()
    if s[1].isFinal:
      echo s
      break

    if s[0] > milestone:
      echo fmt"cost={s[0]} q.len={q.len}"
      milestone += 1_000

    for n in nei(s[1]):
      let state = n[1]
      let cost = n[0] + s[0]
      if state in visited and visited[state] <= cost:
        continue
      visited[state] = cost
      q.push (cost, state)

when isMainModule:
  # main("day23_sample_1.txt")
  # main("day23_input_1.txt")  
  # main("day23_sample_2.txt")
  main("day23_input_2.txt")  