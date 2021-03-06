import ../common

# const inputFilename = "sample.txt"
const inputFilename = "input.txt"
const input = staticRead(inputFilename).strip().split("\n")

# ----

type
  Passport = ref object
    t: Table[string, string]

proc parse(p: Passport, line: string) =
  let xs = line.split(" ")
  for x in xs:
    let ys = x.split(":")
    p.t[ys[0]] = ys[1]

proc isValid(p: Passport): bool =
  for k in ["byr","iyr","eyr","hgt","hcl","ecl","pid"]:
    if k notin p.t: 
      return false

  return true

proc main() =
  var lines = input.reversed
  var cnt = 0
  while lines.len > 0:
    var t = Passport()

    var l = lines.pop()
    parse(t, l)
    while lines.len > 0:
      l = lines.pop()
      if l == "": break
      parse(t, l)

    if isValid(t):
      cnt += 1
  echo cnt

proc main2() =
  let input = readFile(currentSourcePath.parentDir / inputFilename).strip.split("\n\n").map(ss => ss.replace("\n", " ").split(' '))
  var cnt = 0
  for xs in input:
    let t = newTable[string, string]()
    for x in xs:
      let ss = x.split(":")
      t[ss[0]] = ss[1]
    if ["byr","iyr","eyr","hgt","hcl","ecl","pid"].allIt(it in t):
      cnt.inc
  echo cnt

when isMainModule:
  main()
  main2()