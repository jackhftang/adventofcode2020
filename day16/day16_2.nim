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
  var rules = input[0].strip.splitLines.map(parseRule)
  let my = input[1].strip.splitLines[1].split(",").map(parseInt)
  let nb = input[2].strip.splitLines[1..^1].map(s => s.split(",").map(parseInt))
  echo rules
  echo my
  echo nb

  var tickets: seq[seq[int]]
  for t in nb:
    var all = true
    for n in t:
      all = all and isValid(rules, n)
    if all:
      tickets.add t
      
  var colToRules = newSeqWith(rules.len, newSeq[int]())
  for i in tickets[0].slice:
    for j, r in rules:
      if tickets.all(x => x[i] in r[1] or x[i] in r[2] ):
        colToRules[i].add j

  # special structure...
  echo colToRules
  echo colToRules.map(x => x.len).prod
  echo colToRules.sorted((a,b) => a.len - b.len)

  var perm = newSeq[int](rules.len)
  while true:
    let ix = colToRules.indexes(x => x.len == 1)
    if ix.len == 0: break
    if ix.len == 1:
      let k = colToRules[ix[0]][0]
      perm[ix[0]] = k
      for i in colToRules.slice:
        colToRules[i] = colToRules[i].filter(x => k != x)
      
  echo colToRules
  echo perm

  var ans = 1
  for i,j in perm:
    if rules[j][0].startsWith("departure"): 
      ans *= my[i]

  echo ans

when isMainModule:
  main()