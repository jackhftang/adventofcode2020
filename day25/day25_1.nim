import moves

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.splitLines.map(ss => ss.split("").map(c => ".>v".find c)).toMatrix
  
  let H = input.shape[0]
  let W = input.shape[1]

  var step = 0
  whileUpdated updated:

    block:
      let copy = input
      input.fill(0)
      forProd i, j in copy.bounds[0], copy.bounds[1]:
        let x = copy[i,j]
        if x == 1:
          let j2 = (j+1) mod W
          if copy[i,j2] == 0:
            input[i,j2] = 1
            updated = true
          else:
            input[i,j] = 1
        elif x == 2:
          input[i,j] = x

    block:
      let copy = input
      input.fill(0)
      forProd i, j in copy.bounds[0], copy.bounds[1]:
        let x = copy[i,j]
        if x == 2:
          let i2 = (i+1) mod H
          if copy[i2,j] == 0:
            input[i2,j] = 2
            updated = true
          else:
            input[i,j] = 2
        elif x == 1:
          input[i,j] = x

    step += 1
  
  echo step
    

when isMainModule:
  # main("day25_sample_1.txt")
  main("day25_input.txt")  
  