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
  

when isMainModule:
  main("day10_sample_1.txt")
  main("day10_input.txt")  
  