##[
  This module contains functions for fetching data from the sqlite databases
  for beatoraja/LR2
]##

import hashes
import sequtils
import sets
import sugar

import tiny_sqlite

type LR2ScoreDb* = object
  dbPath: string

type LR2Score* = tuple
  hash: string
  clear: int
  perfect: int
  great: int
  good: int
  bad: int
  poor: int
  totalnotes: int
  maxcombo: int
  minbp: int
  playcount: int
  clearcount: int
  failcount: int
  rank: int
  rate: int
  clearDb: int
  opHistory: int
  scorehash: string
  ghost: string
  clearSd: int
  clearEx: int
  opBest: int
  rseed: int
  complete: int

proc isValidLR2ScoreSchema(db: DbConn): bool =
  let schema = db.all("PRAGMA table_info(score)")
  hash(schema) == 619376395707537105

proc initLR2ScoreDb*(dbPath: string): LR2ScoreDb =
  let dbConn = openDatabase(dbPath)
  defer:
    dbConn.close()
  
  doAssert(isValidLR2ScoreSchema(dbConn), "\"score\" table is missing or schema is invalid")
  LR2ScoreDb(dbPath: dbPath)

proc initLR2ScoreDbUnsafe*(dbPath: string): LR2ScoreDb =
  LR2ScoreDb(dbPath: dbPath)

proc fetchLR2Scores(db: DbConn, md5Hashes: SomeSet[string]): seq[LR2Score] =
  db.exec(
    """
    CREATE TEMPORARY TABLE table_hashes (
      hash TEXT NOT NULL PRIMARY KEY
    )
    """
  )

  let parameters = md5Hashes.toSeq.map(hash => @[toDbValue(hash)])

  db.execMany("INSERT INTO table_hashes (hash) VALUES (?)", parameters)

  db
    .all("SELECT score.* FROM score JOIN table_hashes on score.hash = table_hashes.hash")
    .map(row => row.unpack(LR2Score))

proc fetchScores*(db: LR2ScoreDb, md5Hashes: SomeSet[string]): seq[LR2Score] =
  let dbConn = openDatabase(db.dbPath)
  defer:
    dbConn.close()
  fetchLR2Scores(dbConn, md5Hashes)
