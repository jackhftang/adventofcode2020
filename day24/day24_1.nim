import ../common

proc tokenize(s: string): seq[string] =
  var n = ""
  for c in s:
    n.add c
    if c in "ew": 
      result.add n
      n = ""

proc location(ss: seq[string]): (int,int) =
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

  return (x,y)
  

proc main(inputFilename: string) =
  let input = readFile(currentSourcePath.parentDir / inputFilename).strip.splitLines.map(tokenize)
  echo input

  var color: Table[(int,int), int]
  for x in input:
    let loc = location(x)
    if loc in color:
      color[loc] = 1 - color[loc]
    else:
      color[loc] = 1
  echo color
  echo toSeq(color.values).sum

when isMainModule:
  main("day24_input.txt")
  # main("day24_sample1.txt")