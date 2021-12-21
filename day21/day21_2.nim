import moves

type State = tuple[pos: array[2,int], score: array[2,int], round: int]

proc main(z0,z1:int) =
  var xs: seq[int]
  forProd i,j,k in [1,2,3],[1,2,3],[1,2,3]:
    xs.add (i+j+k)
  let xst = xs.toCountTable

  var dp: Table[State, array[2,int]]
  proc solve(xs: State): array[2, int] =
    if xs in dp:
      return dp[xs]

    if xs.score[0] >= 21:
      return [1,0]
    elif xs.score[1] >= 21:
      return [0,1]

    let rm2 = xs.round
    for s, v in xst:
      var ps = xs.pos
      ps[rm2] = 1 + (ps[rm2]+s-1) mod 10
      var scores = xs.score
      scores[rm2] += ps[rm2]
      let res = solve((ps, scores, 1-xs.round))
      result[0] += v*res[0]
      result[1] += v*res[1]

    dp[xs] = result
    return result

  echo solve(([z0,z1], [0,0], 0)).max
  
when isMainModule:
  main(4,8)
  main(10,4)  
  