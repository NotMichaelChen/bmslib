import puppy
import htmlparser
import xmltree
import strtabs
import strutils
import json
import uri

type TableInfo* = object
  headerUrl*: string
  headerJson*: JsonNode
  dataUrl*: string
  dataJson*: JsonNode

proc getHeaderUrl(tableurl: string): string
proc parseUrl(baseurl: string, otherurl: string): string

proc initTableInfo*(tableurl: string): TableInfo =
  # let client = newHttpClient()

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