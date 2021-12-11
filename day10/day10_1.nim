import moves

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.splitLines

  var wrongs: seq[char]
  for line in input:
    var s: seq[char]
    for c in line:
      case c:
      of '(': s.add '('
      of '[': s.add '['
      of '{': s.add '{'
      of '<': s.add '<'
      of ')': 
        let d = s.pop()
        if d != '(':
          wrongs.add c
          break
      of ']': 
        let d = s.pop()
        if d != '[':
          wrongs.add c
          break
      of '}': 
        let d = s.pop()
        if d != '{':
          wrongs.add c
          break
      of '>': 
        let d = s.pop()
        if d != '<':
          wrongs.add c
          break
      else:
        abort(fmt"unknown {c}")
        
  let scores = {
    ')': 3,
    ']': 57,
    '}': 1197,
    '>': 25137
  }.totable
  echo wrongs.map(c => scores[c]).sum

proc main2(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.splitLines

  let opens = "([{<"
  let closes = ")]}>"

  var ws: seq[char]
  for line in input:
    var s: seq[char]
    for c in line:
      if c in opens:
        s.add c
      elif c in closes:
        let d = s.pop()
        if d != opens[closes.find(c)]:
          ws.add c
          break
      else:
        abort(c)

  let scores = zip(closes, [3,57,1197,25137]).toTable
  echo ws.map(c => scores[c]).sum

when isMainModule:
  main("day10_sample_1.txt")
  main2("day10_sample_1.txt")
  main("day10_input.txt")  
  main2("day10_input.txt")  
  