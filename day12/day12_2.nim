import ../common

const inputFilename = "day12_input.txt"
# const inputFilename = "day12_sample1.txt"
# const inputFilename = "day12_sample2.txt"
const inputFilePath = currentSourcePath.parentDir / inputFilename

# ----

let dirs = ['E', 'N', 'W', 'S']
let dp = [[1,0], [0,1], [-1,0], [0,-1]]

proc main() =
  var input = readFile(inputFilePath).strip.split("\n").map(s => ( s[0], s[1..^1]))
  echo input
  var pos = @[0,0]
  var wp = @[10, 1]
  for (a,d) in input:
    echo wp, pos
    let n = parseInt(d)
    case a:
    of 'N':
      wp = wp + [0,n]
    of 'E':
      wp = wp + [n,0]
    of 'W':
      wp = wp + [-n,0]
    of 'S':
      wp = wp + [0,-n]
    of 'L':
      case (n div 90) mod 4:
      of 0: discard
      of 1: wp = @[-wp[1], wp[0]]
      of 2: wp = @[-wp[0], -wp[1]]
      of 3: wp = @[wp[1], -wp[0]]
      else: abort(n)
    of 'R':
      case (n div 90) mod 4:
      of 0: discard
      of 1: wp = @[wp[1], -wp[0]]
      of 2: wp = @[-wp[0], -wp[1]]
      of 3: wp = @[-wp[1], wp[0]]
      else: abort(n)
    of 'F':
      pos = pos + n * wp
    else:
      abort(a)
  echo pos
  echo pos.map(x => abs(x)).sum

proc main2() =
  let input = readFile(inputFilePath).strip.split("\n").map(s => (s[0], parseInt s[1..^1]))
  var pos = @[0, 0]
  var wp = @[10, 1]
  for (a,n) in input:
    case a:
    of {'N', 'E', 'W', 'S'}:
      wp = wp + n * dp[dirs.find(a)]
    of 'F':
      pos = pos + n * wp
    of 'L':
      wp = rotate90cw(wp, (-n div 90) mod 4)
    of 'R':
      wp = rotate90cw(wp, (n div 90) mod 4)
    else:
      abort(a)
  echo pos.map(x => abs(x)).sum

when isMainModule:
  main()
  main2()