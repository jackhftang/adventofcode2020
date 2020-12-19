import ../common

const inputFilename = "day19_input.txt"
# const inputFilename = "day19_sample1.txt"
# const inputFilename = "day19_sample2.txt"
const inputFilePath = currentSourcePath.parentDir / inputFilename

# ----

proc match(rules: Table[int, string], rix: int, s: string): (bool, string) =
  let r = rules[rix]
  # echo fmt"match({r}, {s})"
  if s.len == 0:
    return (false, s)

  if r[0] == '"':
    if s[0] == r[1]: 
      return (true, s[1..^1])
    else:
      return (false, s)

  let ps = r.split("|").map(s => s.strip.split(" ").map(parseInt))
  for p in ps:
    block next:
      var remain = s
      for rix2 in p:
        let (ok, remain2) = match(rules, rix2, remain)
        if ok: 
          remain = remain2
        else:
          break next
      return (true, remain)
  return (false, s)

proc main() =
  var input = readFile(inputFilePath).strip.split("\n\n")
  let rules = input[0].splitLines
  var rule: Table[int, string]
  for r in rules:
    let ns = r.split(":")
    let n = ns[0].parseInt
    rule[n] = ns[1].strip

  let strs = input[1].splitLines
  
  var ans = 0
  for s in strs:
    let (b, remain) = match(rule, 0, s)
    if b and remain.len == 0: 
      echo s
      ans.inc

  echo ans

when isMainModule:
  main()