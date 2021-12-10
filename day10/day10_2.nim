import moves


proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.splitLines

  let scores = {
    ')': 1,
    ']': 2,
    '}': 3,
    '>': 4
  }.totable

  let closes = {
    '(': ')',
    '[': ']',
    '{': '}',
    '<': '>',
  }.toTable

  var corrects: seq[int]
  for line in input:
    block next:
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
            break next
        of ']': 
          let d = s.pop()
          if d != '[':
            break next
        of '}': 
          let d = s.pop()
          if d != '{':
            break next
        of '>': 
          let d = s.pop()
          if d != '<':
            break next
        else:
          abort(fmt"unknown {c}")

      corrects.add s.map(c => scores[closes[c]]).fromDigits(5)
  
  corrects.sort()
  echo corrects[corrects.len div 2]
  
when isMainModule:
  main("day10_sample_1.txt")
  main("day10_input.txt")  
  