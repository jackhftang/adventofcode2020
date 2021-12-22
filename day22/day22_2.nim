import moves

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.splitLines.map(s => s.split(" "))
  var actions = input.map(x => (if x[0] == "on": 1 else: 0))
  let ps = input.map(x => x[1].split(",").map(s => s.split("=")[1].split("..").map((i,s) => parseInt(s)+i)))
  let xs = ps.map(xs => xs[0]).flatten().sorted()
  let ys = ps.map(xs => xs[1]).flatten().sorted()
  let zs = ps.map(xs => xs[2]).flatten().sorted()
  var m = zeros(int, xs.len-1, ys.len-1, zs.len-1)

  for i in actions.bound:
    let cube = ps[i]
    for x in xs.find(cube[0][0]) ..< xs.find(cube[0][1]):
      for y in ys.find(cube[1][0]) ..< ys.find(cube[1][1]):
        for z in zs.find(cube[2][0]) ..< zs.find(cube[2][1]):
          m[x][y][z] = actions[i]
  
  var ans = 0
  for i in m.bound:
    for j in m[0].bound:
      for k in m[0][0].bound:
        if m[i][j][k] == 1:
          ans += (xs[i+1]-xs[i])*(ys[j+1]-ys[j])*(zs[k+1]-zs[k])
  
  echo ans

when isMainModule:
  # main("day22_sample_1.txt")
  # main("day22_sample_2.txt")
  main("day22_input.txt")  
  