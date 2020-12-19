import ../common

const inputFilename = "day19_input.txt"
# const inputFilename = "day19_sample1.txt"
# const inputFilename = "day19_sample2.txt"
# const inputFilename = "day19_sample3.txt"
const inputFilePath = currentSourcePath.parentDir / inputFilename

# ----

proc prefixMatch(rules: Table[int, string], rix: int, s: string): (bool, string) =
  let r = rules[rix]
  # echo fmt"match({rix}, {r}, {s})"
  if s.len == 0:
    return (false, s)

  if r[0] == '"':
    if s[0] == r[1]: 
      return (true, s[1..^1])
    else:
      return (false, s)

  let ps = r.split("|").map(s => s.strip.split(" ").map(parseInt))
  # echo r, " => ", ps
  for p in ps:
    block next:
      var remain = s
      for rix2 in p:
        let (ok, remain2) = prefixMatch(rules, rix2, remain)
        if ok: 
          remain = remain2
        else:
          break next
      return (true, remain)
  return (false, s)

proc prefixMatchN(rules: Table[int, string], ix: int, n: int, s: string): (bool, string) = 
  if n == 0:
    return (true, s)

  let (ok, remain) = prefixMatch(rules, ix, s)
  if ok:
    return prefixMatchN(rules, ix, n-1, remain)
  else:
    return (false, s)

proc maxMatchTimes(rules: Table[int, string], ix: int, s: string): (int, string) =
  var remain = s
  var cnt = 0
  while true:
    let (ok, remain2) = prefixMatch(rules, ix, remain)
    if ok:
      cnt.inc
      remain = remain2
    else:
      return (cnt, remain)

proc match(rules: Table[int, string], s: string): (bool, string) =
  # match at least 2 42
  let (ok, remain2) = prefixMatchN(rules, 42, 2, s)
  if not ok:
    return (false, s)
  if remain2.len == 0:
    return (true, "")

  var remain = remain2
  var mx = 1
  while true:
    let (n, remain2) = maxMatchTimes(rules, 31, remain)
    if 0 < n and n <= mx and remain2.len == 0:
      return (true, "")

    # take one 42
    let (ok, remain3) = prefixMatch(rules, 42, remain)
    if ok:
      mx.inc
      remain = remain3
    else:
      return (false, s)

proc main() =
  var input = readFile(inputFilePath).strip.split("\n\n")
  let rules = input[0].splitLines
  var rule: Table[int, string]
  for r in rules:
    let ns = r.split(":")
    let n = ns[0].parseInt
    rule[n] = ns[1].strip
  rule[8] = "42 | 42 8"
  rule[11] = "42 31 | 42 11 31"

  let strs = input[1].splitLines
  
  var ans = 0
  for s in strs:
    let (b, remain) = match(rule, s)
    if b and remain.len == 0:
      ans.inc
  echo ans

when isMainModule:
  main()