import unittest
import httpclient

import bmslib/bmstable/tableinfo

suite "TableInfo":
  let httpClient = newHttpClient()

  proc serverAvailable(url: string): bool =
    try:
      discard httpClient.getContent(url)
    except:
      return false
    return true

  test "Connecting to various tables":
    proc tableTest(mainUrl: string, headerUrl: string, dataUrl: string): void =
      if not serverAvailable(mainUrl):
        echo "url: ", mainUrl, " not available, skipping test"
        return
      
      let tableUrls = initTableInfo(mainUrl)
      check(tableUrls.headerUrl == headerUrl)
      check(tableUrls.dataUrl == dataUrl)

    echo "Testing distinct URLs (LN Table)"
    tableTest(
      "http://flowermaster.web.fc2.com/lrnanido/gla/LN.html",
      "http://flowermaster.web.fc2.com/lrnanido/gla/header.json",
      "http://flowermaster.web.fc2.com/lrnanido/gla/score.json"
    )

    echo "Testing relative URL paths (Insane 2nd Table)"
    tableTest(
      "http://rattoto10.jounin.jp/table_insane.html",
      "http://rattoto10.jounin.jp/js/insane_header.json",
      "http://rattoto10.jounin.jp/js/insane_data.json"
    )

    echo "Testing relative URL files (10k Table)"
    tableTest(
      "https://notepara.com/glassist/10k",
      "https://notepara.com/glassist/10k/head.json",
      "https://notepara.com/glassist/10k/body.json"
    )

    echo "Testing relative URLs using dots (Jack Table)"
    tableTest(
      "http://infinity.s60.xrea.com/bms/gla/",
      "http://infinity.s60.xrea.com/bms/gla/header.json",
      "http://infinity.s60.xrea.com/bms/gla/data.json"
    )
