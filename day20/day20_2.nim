import moves

proc main(inputFilename: string) =
  let rawInput = readFile(currentSourcePath.parentDir / inputFilename).strip 
  var input = rawInput.splitLines
  let code = input[0].split("").map(c => (if c == "#": 1 else: 0))
  
  var m: Table[MatrixKey, int]
  var negate = 0
  for h in 2 .. input.high:
    let i = h-2
    for j in 0 .. input[h].high:
      if input[h][j] == '#':
        m[[i,j]] = 1
  # echo m

  for r in 1..50:
    echo fmt"round {r} {m.len}"
    let copy = m
    let neg = negate
    m.clear()
    if negate == 0: negate = code[0]
    else: negate = code[^1]

    for k, v in copy:
      if v == 1-neg:
        let w = 2
        for c0 in k[0]-w..k[0]+w:
          for c1 in k[1]-w..k[1]+w:
            # echo fmt"c={c0},{c1}"
            let k2 = [c0,c1]
            if k2 notin m:
              var s = 0
              for di in -1..1:
                for dj in -1..1:
                  var v = copy.getOrDefault([c0+di, c1+dj], 0)
                  if neg == 1:
                    v = 1-v
                  s = 2*s + v
              # echo fmt"s={s}"
              if negate == 0:
                m[[c0,c1]] = code[s]
              else:
                m[[c0,c1]] = 1-code[s]
    # echo negate, m
  # echo negate
  echo m.valseq.sum

when isMainModule:
  main("day20_sample_1.txt")
  main("day20_input.txt")  
  
  