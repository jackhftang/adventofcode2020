import moves

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.splitLines

  var space: HashSet[(int,int,int)]
  for line in input:
    let ss = line.split(" ")
    let act = ss[0]
    let rngs = ss[1].split(",").map(s => s.split("=")[1].split("..").map(s => parseInt(s)))
    if rngs.any(xs => xs.any(x => x < -50 or x > 50)):
      continue

    # echo act, rngs
    for i in rngs[0][0]..rngs[0][1]:
      for j in rngs[1][0]..rngs[1][1]:
        for k in rngs[2][0]..rngs[2][1]:
          if act == "on":
            space.incl (i,j,k)
          elif act == "off":
            space.excl (i,j,k)
  echo space.len

when isMainModule:
  main("day22_sample_1.txt")
  main("day22_input.txt")  
  