import moves
from algorithm import product

const nei8* = [
  # positive toward right and bottom
  # [y, x]
  # in anti-clockwise order
  [0, 1],
  [-1, 1],
  [-1, 0],
  [-1, -1],
  [0, -1],
  [1, -1],
  [1, 0],
  [1, 1],
]

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.splitLines.map(s => s.split("").map(parseInt)).toMatrix

  var cnt = 0
  for step in 1..100:
    for p, v in input:
      input[p] += 1
    
    var flashed = initMatrix[bool](input.shape)
    whileUpdated updated:
      let copy = input
      for p, v in copy:
        if v >= 10 and not flashed[p]:
          updated = true
          flashed[p] = true
          cnt += 1
          for n in nei8:
            let p2 = p + n
            if input.hasKey(p2) and not flashed[p2]:
              input[p2] += 1
          input[p] = 0
  echo cnt
  

when isMainModule:
  main("day11_sample_1.txt")
  main("day11_input.txt")  
  