include bmslib/bmsdb

import md5
import typetraits
import unittest

const createLR2ScoreTable =
  """
  CREATE TABLE score(
    hash TEXT primary key,
    clear INTEGER,
    perfect INTEGER,
    great INTEGER,
    good INTEGER,
    bad INTEGER,
    poor INTEGER,
    totalnotes INTEGER,
    maxcombo INTEGER,
    minbp INTEGER,
    playcount INTEGER,
    clearcount INTEGER,
    failcount INTEGER,
    rank INTEGER,
    rate INTEGER,
    clear_db INTEGER,
    op_history INTEGER,
    scorehash TEXT,
    ghost TEXT,
    clear_sd INTEGER,
    clear_ex INTEGER,
    op_best INTEGER,
    rseed INTEGER,
    complete INTEGER
  );
  """

func mkLR2Score(hash: string): LR2Score =
  (
    hash: hash,
    clear: 0,
    perfect: 0,
    great: 0,
    good: 0,
    bad: 0,
    poor: 0,
    totalnotes: 0,
    maxcombo: 0,
    minbp: 0,
    playcount: 0,
    clearcount: 0,
    failcount: 0,
    rank: 0,
    rate: 0,
    clearDb: 0,
    opHistory: 0,
    scorehash: "",
    ghost: "",
    clearSd: 0,
    clearEx: 0,
    opBest: 0,
    rseed: 0,
    complete: 0,
  )

# This might be useful in the tiny_sqlite lib
func tupleToDbValue[T: tuple](row: T): seq[DbValue] =
  for val in row.fields():
    result.add(toDbValue(val))

suite "LR2ScoreDb.verifyLR2Schema":
  test "accept valid schema":
    let dbConn = openDatabase(":memory:")
    defer:
      dbConn.close()
    
    dbConn.exec(createLR2ScoreTable)

    check(isValidLR2ScoreSchema(dbConn))

  test "reject missing table":
    let dbConn = openDatabase(":memory:")
    defer:
      dbConn.close()
    
    check(not isValidLR2ScoreSchema(dbConn))

  test "reject invalid schema":
    let dbConn = openDatabase(":memory:")
    defer:
      dbConn.close()
    
    dbConn.exec("CREATE TABLE score(foo TEXT, bar INTEGER)")
    
    check(not isValidLR2ScoreSchema(dbConn))

suite "LR2ScoreDb.fetchScores":
  test "correctly fetch scores":
    let dbConn = openDatabase(":memory:")
    defer:
      dbConn.close()

    dbConn.exec(createLR2ScoreTable)

    let hash1 = getMD5("str1")
    let hash2 = getMD5("str2")
    let hash3 = getMD5("str3")

    let scores = [
      mkLR2Score(hash1),
      mkLR2Score(hash2),
    ]

    let md5Hashes = [
      hash2,
      hash3
    ].toHashSet

    let expected = [
      mkLR2Score(hash2)
    ]

    dbConn.execMany("INSERT INTO score VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", scores.map(score => tupleToDbValue(score)))

    let res = fetchLR2Scores(dbConn, md5Hashes)

    check(res == expected)
