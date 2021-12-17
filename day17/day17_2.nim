import moves

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput[12..^1].split(",").map(s => s.strip.split("=")[1].split("..").map(parseInt))
  echo input
  
  proc highesty(dp: array[2,int]): int =
    var v = dp
    var p = [0,0]
    var mxy = 0
    # while p[0] <= input[0][1] and p[1] >= input[1][1]:
    while true:
      p = p + v
      v[0] = max(0, v[0] - 1)
      v[1] -= 1
      mxy = max(mxy, p[1])
      # echo p, mxy
      if p[0] in input[0][0] .. input[0][1] and p[1] in input[1][0] .. input[1][1]:
        # echo "in", mxy
        return mxy
      elif p[0] > input[0][1]:
        # to right area
        return -1
      elif p[1] < input[1][0]:
        return -2

  # echo highesty([7,2])
  # echo highesty([6,3])
  # echo highesty([9,0])
  # echo highesty([17,-4])
  
  var cnt = 0
  forProd vx, vy in 0 .. input[0][1], input[1][0] .. -input[1][0]:
    if highesty([vx, vy]) >= 0:
      cnt += 1
  echo cnt 

when isMainModule:
  main("day17_sample_1.txt")
  main("day17_input.txt")  
  