import ../common

const inputFilename = "day16_input.txt"
# const inputFilename = "day16_sample1.txt"
# const inputFilename = "day16_sample2.txt"
const inputFilePath = currentSourcePath.parentDir / inputFilename

# ----

proc parseRule(s: string): (string, Slice[int], Slice[int]) =
  let ss = s.split(":")
  let s1 = ss[1].split("or")
  let r1 = s1[0].strip.split("-").map(parseInt)
  let r2 = s1[1].strip.split("-").map(parseInt)
  return (ss[0], r1[0]..r1[1], r2[0]..r2[1])

proc isValid(rs: seq[(string, Slice[int], Slice[int])], n: int): bool =
  for r in rs:
    let (s, r1 ,r2) = r
    if (n in r1) or (n in r2):
      return true

proc main() =
  var input = readFile(inputFilePath).strip.split("\n\n")
  let rules = input[0].strip.splitLines.map(parseRule)
  let my = input[1].strip.splitLines[1].split(",").map(parseInt)
  let nb = input[2].strip.splitLines[1..^1].map(s => s.split(",").map(parseInt))
  echo rules
  echo my
  echo nb

  var ns: seq[int]
  for t in nb:
    for n in t:
      if not isValid(rules, n):
        ns.add n
  echo ns
  echo ns.sum
      

when isMainModule:
  main()