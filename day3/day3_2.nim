import moves

proc o1(input: seq[seq[int]]): int =
  var curr = input

  for i in 0 ..< curr[0].len:
    let l = curr.len
    if l == 1:
      break 
    let n = curr.map(lis => lis[i]).sum()
    if 2*n >= l:
      curr = curr.filter(lis => lis[i] == 1)
    else:
      curr = curr.filter(lis => lis[i] == 0)

  echo curr
  result = curr[0].reversed.fromDigits(2)

proc o2(input: seq[seq[int]]): int =
  var curr = input

  for i in 0 ..< curr[0].len:
    let l = curr.len
    if l == 1:
      break 
    let n = curr.map(lis => lis[i]).sum()    
    if 2*n >= l:
      curr = curr.filter(lis => lis[i] == 0)
    else:
      curr = curr.filter(lis => lis[i] == 1)

  echo curr
  result = curr[0].reversed.fromDigits(2)

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 

  var input = rawInput.splitLines.mapIt(toSeq(it).mapIt(parseInt($it)))
  let a = o1(input)
  let b = o2(input)
  echo a, " ", b
  echo a * b 

when isMainModule:
  main("day3_input.txt")
  # main("day3_sample1.txt")