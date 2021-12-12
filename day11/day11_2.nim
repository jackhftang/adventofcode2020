import moves

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
  var step = 0
  while true:
    cnt = 0
    step += 1

    for p, v in input:
      input[p] += 1
    
    var flashed = initMatrix[bool](input.shape)
    var changed = true
    while changed:
      changed = false

      let copy = input
      for p, v in copy:
        if v >= 10 and not flashed[p]:
          changed = true
          flashed[p] = true
          cnt += 1
          for n in nei8:
            let p2 = p + n
            if input.hasKey(p2) and not flashed[p2]:
              input[p2] += 1
          input[p] = 0
      
    if cnt == 100:
      echo step
      break

when isMainModule:
  # main("day11_sample_1.txt")
  main("day11_input.txt")  
  