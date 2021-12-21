import moves

proc main(z0,z1:int) =
  var roll = 0
  var pt = 1
  var scores = [0,0]
  var ps = [z0,z1]
  var round = 0
  while true:
    var s = 0
    3.times:
      s += pt
      roll += 1
      pt = pt + 1
      if pt == 101: pt = 1

    let rm2 = round mod 2
    ps[rm2] = 1 + (ps[rm2] + s - 1) mod 10
    scores[rm2] += ps[rm2]
    round += 1

    if scores[rm2] >= 1000:
      break
    
  echo roll
  echo scores.min * roll 
  
when isMainModule:
  main(4,8)
  main(10,4)  
