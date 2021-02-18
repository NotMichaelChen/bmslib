import math
import tables

type
  ClearType* = enum
    fullcombo,
    exhard,
    hard,
    clear,
    easy,
    lightassist,
    assist,
    failed

let defaultStellaClearMapping = {
  ClearType.fullcombo: 12.0,
  ClearType.exhard: 9.0,
  ClearType.hard: 6.0,
  ClearType.clear: 4.0,
  ClearType.easy: 3.0,
  ClearType.lightassist: 2.5,
  ClearType.assist: 2.0,
  ClearType.failed: 1.0,
}.toTable

proc calculateStellaPoints*(
  exscore, level: int64,
  clearType: ClearType,
  clearMapping: Table[ClearType, float] = defaultStellaClearMapping
): float =
  let clearValue = defaultStellaClearMapping[clearType]
  return (sqrt(float(level + 1)) * (float(exscore) / 500)) + (2 * clearValue * float(level + 1))

let defaultDjpClearMapping = {
  ClearType.fullcombo: 0.3,
  ClearType.hard: 0.2,
  ClearType.clear: 0.1,
  ClearType.easy: 0.0,
  ClearType.failed: 0.0,
}.toTable

proc toGradeValue(exscore, totalExscore: int64): float =
  let rate = float(exscore) / float(totalExscore)

  if rate > 0.89:
    return 0.2
  elif rate > 0.78:
    return 0.15
  elif rate > 0.67:
    return 0.1
  else:
    return 0

proc calculateDjp*(
  exscore, totalExscore: int64,
  clearType: ClearType,
  clearMapping: Table[ClearType, float] = defaultDjpClearMapping
): float =
  let clearValue = clearMapping[clearType]
  let gradeValue = toGradeValue(exscore, totalExscore)
  return trunc(float(exscore) * (1.0 + clearValue + gradeValue)) / 100