import ../common

const inputFilename = "day12_input.txt"
# const inputFilename = "day12_sample1.txt"
# const inputFilename = "day12_sample2.txt"
const inputFilePath = currentSourcePath.parentDir / inputFilename

# ----

let dirs = ['E', 'N', 'W', 'S']
let dp = [[1,0], [0,1], [-1,0], [0,-1]]

proc main() =
  var input = readFile(inputFilePath).strip.split("\n").map(
    proc(s: string): (char, string) = return ( s[0], s[1..^1]) 
  )
  echo input
  
  var dir = 'E'
  var pos = @[0,0]
  for (a,d) in input:
    echo pos
    let n = parseInt(d)
    case a:
    of 'N':
      pos = pos + [0,n]
    of 'E':
      pos = pos + [n,0]
    of 'W':
      pos = pos + [-n,0]
    of 'S':
      pos = pos + [0,-n]
    of 'L':
      dir = dirs[(dirs.find(dir) + n div 90) mod 4]
    of 'R':
      dir = dirs[(dirs.find(dir) + 4 - n div 90) mod 4]
    of 'F':
      pos = pos + n * dp[dirs.find(dir)]
    else:
      abort(a)
  echo pos
  echo pos.map(x => abs(x)).sum

proc main2() =
  let input = readFile(inputFilePath).strip.split("\n").map(s => (s[0], parseInt s[1..^1]))
  var dir = @[1,0]
  var pos = @[0,0]
  for (a,n) in input:
    case a:
    of {'N', 'E', 'W', 'S'}:
      pos = pos + n * dp[dirs.find(a)]
    of 'F':
      pos = pos + n * dir
    of 'L':
      dir = rotate90(dir, (n div 90) mod 4)
    of 'R':
      dir = rotate90(dir, (-n div 90) mod 4)
    else:
      abort(a)
  echo pos.map(x => abs(x)).sum

when isMainModule:
  main()
  main2()