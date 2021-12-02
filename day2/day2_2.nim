import ../common

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.splitLines.mapIt(it.split(" "))

  var x, y: int
  var aim: int
  for cs in input:
    let n = parseInt cs[1]
    case cs[0]:
    of "forward": 
      x += n
      y += aim * n
    of "down": 
      # y += n
      aim += n
    of "up": 
      # y -= n
      aim -= n
    echo x, " ", y, " ", aim
  echo x * y
  

when isMainModule:
  main("day2_input.txt")
  # main("day2_sample1.txt")