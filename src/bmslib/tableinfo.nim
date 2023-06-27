##[
  This module provides a function + object for fetching the header/data json objects associated
  with a BMS table that conforms to the spec defined in:
  http://bmsnormal2.syuriken.jp/bms_dtmanager.html
]##

import puppy
import htmlparser
import xmltree
import strtabs
import strutils
import json
import uri

type TableInfo* = object ## Type that contains the header/data json associated with the BMS table
  headerUrl*: string
  headerJson*: JsonNode
  dataUrl*: string
  dataJson*: JsonNode

proc getHeaderUrl(tableurl: string): string
proc parseUrl(baseurl: string, otherurl: string): string

proc initTableInfo*(tableurl: string): TableInfo =
  ##[
    Fetches the header + data json objects for a given BMS table. This should be the URL that you
    enter into GLassist or BeMusicSeeker
  ]##
  let headerurl = getHeaderUrl(tableurl)
  let headerJson = parseJson(fetch(headerurl))

  let dataurl = parseUrl(headerurl, headerJson["data_url"].getStr)
  let dataJson = parseJson(fetch(dataurl))

  TableInfo(headerurl: headerurl, headerJson: headerJson, dataUrl: dataurl, dataJson: dataJson)
  
proc getHeaderUrl(tableurl: string): string =
  let webpage = fetch(tableurl)

  # parse the webpage for a meta tag with bmstable
  let htmldoc = htmlparser.parseHtml(webpage)
  for m in htmldoc.findAll("meta"):
    if (m.attrs.hasKey "name") and m.attrs["name"] == "bmstable":
      return parseUrl(tableurl, m.attrs["content"])

  raise newException(CatchableError, "Header URL not found")

proc parseUrl(baseurl: string, otherurl: string): string =
  if otherurl.toLower.startsWith("http"):
    return otherurl
  else:
    let otheruri = Uri(path: otherurl)
    return $combine(parseUri(baseurl), otheruri)