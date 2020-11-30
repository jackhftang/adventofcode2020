import ../common

const inputFilename = "test.txt"
# const inputFilename = "part1.in"
const input = staticRead(inputFilename).strip().split("\n").mapIt(it.split(","))

# ----

type
  Point = object
    x,y: int

  LineKind = enum
    VLINE, HLINE

  Line = object
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
  for s in xs:
    case s[0]:
    of 'U':
      let y2 = y + parseInt(s[1 ..< s.len])
      result.add Line(kind: VLINE, x: x, y1: y, y2: y2)
      y = y2
    of 'D':
      let y2 = y - parseInt(s[1 ..< s.len])
      result.add Line(kind: VLINE, x: x, y1: y, y2: y2)
      y = y2
    of 'R':
      let x2 = x + parseInt(s[1 ..< s.len])
      result.add Line(kind: HLINE, y: y, x1: x, x2: x2)
      x = x2
    of 'L':
      let x2 = x - parseInt(s[1 ..< s.len])
      result.add Line(kind: HLINE, y: y, x1: x, x2: x2)
      x = x2
    else:
      abort(x)

proc between(a,b,c: int): bool =
  if b > c:
    return c <= a and a <= b
  else:
    return b <= a and a <= c

proc cross(a,b: Line): Option[Point] =
  if a.kind == b.kind: return none[Point]()
  if a.kind == VLINE:
    if between(a.x, b.x1, b.x2) and between(b.y, a.y1, a.y2):
      return some(Point(x: a.x, y: b.y))
    return none[Point]()
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
        let dis = abs(p.x) + abs(p.y)
        if p != Point(x:0,y:0) and dis < mi:
          echo p
          mi = dis
  echo mi



when isMainModule:
  main()