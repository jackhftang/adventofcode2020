import moves
import tables

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.splitLines
  var rules: Table[(char, char), char]
  var space: CountTable[(char, char)] 
  
  let line0 = "^" & input[0] & "$"
  for i in 0 ..< line0.len-1:
    space.inc (line0[i], line0[i+1])

  for line in input[2..^1]:
    let ss = line.strip.split(" -> ")
    let xs = ss[0].strip.split("")
    rules[(xs[0][0], xs[1][0])] = ss[1][0]

  40.times:
    let copy = space
    space.clear()
    for k, v in copy:
      if k in rules:
        let c = rules[k]
        let k1 = (k[0], c)
        let k2 = (c, k[1])
        space.inc(k1, v)
        space.inc(k2, v)
      else:
        space.inc(k, v)

  var c: CountTable[char]
  for k, v in space:
    c.inc(k[0], v)
    c.inc(k[1], v)
  c.del('$')
  c.del('^')
  echo c.largest[1] div 2 - c.smallest[1] div 2

when isMainModule:
  main("day14_sample_1.txt")
  main("day14_input.txt")  