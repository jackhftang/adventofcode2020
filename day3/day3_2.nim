import ../common

# const inputFilename = "test.txt"
const inputFilename = "part1.in"
const input = staticRead(inputFilename).strip().split("\n").mapIt(it.split(","))

# ----

type
  Point = object
    x,y: int

  LineKind = enum
    VLINE, HLINE

  Line = object
    d: int
    case kind: LineKind
    of VLINE:
      x: int
      y1: int
      y2: int
    of HLINE:
      y: int
      x1: int
      x2: int


proc toLines(xs: seq[string]): seq[Line] =
  var x = 0
  var y = 0
  var d = 0
  for s in xs:
    case s[0]:
    of 'U':
      let dy = parseInt(s[1 ..< s.len])
      let y2 = y + dy
      result.add Line(kind: VLINE, x: x, y1: y, y2: y2, d: d)
      y = y2
      d += dy
    of 'D':
      let dy = parseInt(s[1 ..< s.len])
      let y2 = y - dy
      result.add Line(kind: VLINE, x: x, y1: y, y2: y2, d: d)
      y = y2
      d += dy
    of 'R':
      let dx = parseInt(s[1 ..< s.len])
      let x2 = x + dx
      result.add Line(kind: HLINE, y: y, x1: x, x2: x2, d: d)
      x = x2
      d += dx
    of 'L':
      let dx = parseInt(s[1 ..< s.len])
      let x2 = x - dx
      result.add Line(kind: HLINE, y: y, x1: x, x2: x2, d: d)
      x = x2
      d += dx 
    else:
      abort(s)


proc between(a,b,c: int): bool =
  if b > c:
    return c <= a and a <= b
  else:
    return b <= a and a <= c

proc cross(a,b: Line): Option[(Point, int)] =
  if a.kind == b.kind: return none[(Point, int)]()
  if a.kind == VLINE:
    if between(a.x, b.x1, b.x2) and between(b.y, a.y1, a.y2):
      var d = a.d + b.d
      d += abs(b.y - a.y1)
      d += abs(a.x - b.x1)
      return some (Point(x: a.x, y: b.y), d)
    return none[(Point,int)]()
  return cross(b,a)


proc main() =
  let lines1 = toLines(input[0])
  let lines2 = toLines(input[1])

  echo lines1
  echo lines2

  var mi = int.high
  for a in lines1:
    for b in lines2:
      let t = cross(a,b)
      if t.isSome:
        let p = t.get()
        let dis = p[1]
        if p[0] != Point(x:0,y:0) and dis < mi:
          echo p
          mi = dis
  echo mi



when isMainModule:
  main()