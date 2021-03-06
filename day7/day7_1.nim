import ../common

const inputFilename = "day7_input.txt"
# const inputFilename = "day7_sample.txt"
const inputFilePath = currentSourcePath.parentDir / inputFilename

# ----

type
  Bag = object
    color: string
    bags: seq[(int, string)]

proc parseBag(s: string): Bag =
  let ix = s.find(" bags contain ")
  result.color = s[0..ix-1]
  let xs = s[ix + " bags contain ".len ..^ 1].split(",").mapIt(it.strip)
  if not xs[0].startsWith("no"):
    for s in xs:
      let ix = s.find(" ")
      let n = parseInt(s[0..ix-1])
      let c = s[ix .. s.rfind(" ")-1].strip
      result.bags.add (n, c)    
  echo result

proc canCarryShinyGold(t: Table[string, Bag], s: string): bool =
  if s == "shiny gold": return true
  let b = t[s]
  for x in b.bags:
    if canCarryShinyGold(t, x[1]): return true
  return false 

proc main() =
  let input = readFile(inputFilePath).strip.split("\n").map(parseBag)
  echo input
  var t: Table[string, Bag]
  for x in input: t[x.color] = x
  echo input.count(b => b.color != "shiny gold" and canCarryShinyGold(t, b.color))

when isMainModule:
  main()