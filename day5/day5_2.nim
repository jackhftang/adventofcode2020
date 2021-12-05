import ../common

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.splitLines.map(s => s.split(" -> ").map(w => w.split(",").map(parseInt)))
  
  # echo input
  # for pt in input:
  #   let diff = pt[0] - pt[1] 
  #   if diff[0] != 0 and diff[1] != 0 and diff[0] != -diff[1] and diff[0] != diff[1]:
  #     echo diff

  const N = 1000
  var board = zeros(int, N, N)
  for pair in input:
    let p1 = pair[0]
    let p2 = pair[1]
    let dx = (p2[0] - p1[0]).sgn
    let dy = (p2[1] - p1[1]).sgn

    let dd = [dx, dy]
    var p = p1
    while p != p2 + dd:
      board[p[0]][p[1]] += 1
      p = p + dd

  var cnt = 0
  forProd i, j in 0..<N , 0..<N:
    if board[i][j] > 1:
      cnt += 1
      
  echo cnt

when isMainModule:
  # main("day5_sample1.txt")
  main("day5_input.txt")