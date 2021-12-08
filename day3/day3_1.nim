import moves

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.splitLines.mapIt(it.split("").mapIt(parseInt($it)))
  let l = input.len
  var a = 0
  var b = 0
  for x in input.transpose:
    let n = x.sum()
    if 2*n > l:
      a = 2*a + 1
      b = 2*b
    elif 2*n < l:
      a = 2*a
      b = 2*b + 1
    elif 2*n == l:
      abort("")

  echo a * b 

proc main2(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.splitLines.mapIt(it.split("").mapIt(parseInt($it)))
  let l = input.len
  let cnt =  input.transpose.map(xs => xs.sum)
  var a = cnt.map(x => int(2*x > l)).reversed.fromDigits(2)
  var b = cnt.map(x => int(2*x < l)).reversed.fromDigits(2)
  echo a * b

when isMainModule:
  main("day3_input.txt")
  main2("day3_input.txt")
  # main("day3_sample1.txt")