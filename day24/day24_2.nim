import ../common

proc tokenize(s: string): seq[string] =
  var n = ""
  for c in s:
    n.add c
    if c in "ew": 
      result.add n
      n = ""

proc location(ss: seq[string]): seq[int] =
  var x,y = 0

  # e, se, sw, w, nw, ne
  for s in ss:
    case s
    of "e":
      x += 2
    of "w":
      x -= 2

    of "se":
      x += 1
      y -= 3
    of "ne":
      x += 1
      y += 3

    of "sw":
      x -= 1
      y -= 3
    of "nw":
      x -= 1
      y += 3

    else:
      abort(s)

  return @[x,y]

proc next(color: Table[seq[int], int]): Table[seq[int], int] = 
  let nei6 = [
    [2,0], 
    [-2,0], 
    [1,-3], 
    [1,3], 
    [-1,3], 
    [-1,-3]
  ]

  var toCheck: seq[seq[int]]
  for loc, c in color:
    if c == 0: continue
    for nei in nei6:
      toCheck.add (loc+nei)

  for loc in toCheck:
    var cnt = 0
    for nei in nei6:
      cnt += color.getOrDefault(loc+nei, 0)

    var c = color.getOrDefault(loc, 0)
    if c == 0 and cnt == 2:
      result[loc] = 1
    elif c == 1 and cnt in [1,2]:
      result[loc] = 1
  
proc main(inputFilename: string) =
  let input = readFile(currentSourcePath.parentDir / inputFilename).strip.splitLines.map(tokenize)
  echo input

  var color: Table[seq[int], int]
  for x in input:
    let loc = location(x)
    if loc in color:
      color[loc] = 1 - color[loc]
    else:
      color[loc] = 1
  echo color
  
  for i in 1..100:
    color = next(color)
    #echo i, ' ', toSeq(color.values).sum
  echo toSeq(color.values).sum


when isMainModule:
  main("day24_input.txt")
  # main("day24_sample1.txt")