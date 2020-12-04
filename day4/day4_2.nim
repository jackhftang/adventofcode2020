import ../common

# const inputFilename = "sample1.txt"
# const inputFilename = "sample2.txt"
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
    echo  ys
    p.t[ys[0]] = ys[1]

proc isValid(p: Passport): bool =
  for k in ["byr","iyr","eyr","hgt","hcl","ecl","pid"]:
    if k notin p.t: 
      return false

    let v = p.t[k]

    if k == "byr":
      if v.len != 4: return false
      let n = parseInt(v)
      if n < 1920 or n > 2002: return false
    
    if k == "iyr":
      if v.len != 4: return false
      let n = parseInt(v)
      if n < 2010 or n > 2020: return false
    
    if k == "eyr":
      if v.len != 4: return false
      let n = parseInt(v)
      if n < 2020 or n > 2030: return false

    if k == "hgt":
      if v[v.len-2 .. v.len-1] == "cm":
        let n = parseInt(v[0..^3])
        if n < 150 or n > 193: return false
      elif v[v.len-2 .. v.len-1] == "in":
        let n = parseInt(v[0..^3])
        if n < 59 or n > 76: return false
      else:
        return false

    if k == "hcl":
      if v.len != 7: return false
      if v[0] != '#': return false
      for c in v[1..^1]:
        if (c notin '0'..'9') and (c notin 'a'..'f'): return false

    if k == "ecl":
      if v notin ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]: return false

    if k == "pid":
      if v.len != 9: return false
      try:  parseInt(v)
      except: return false

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

    let b = isValid(t)
    if b: cnt += 1
    echo b

  echo cnt


when isMainModule:
  main()