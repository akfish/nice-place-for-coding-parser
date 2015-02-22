chai = require 'chai'
expect = chai.expect
fs = require 'fs'
Parser = require '../lib/place-parser'

parser = new Parser()

loadSpecSync = (name) ->
  fs.readFileSync "./test/data/#{name}.md", 'utf-8'

loadAndParse = (name) ->
  src = loadSpecSync name
  parser.parse src

correct_specs = [
  'only-one'
  'more-than-one'
]

incorrect_specs = [
  'no-address'
  'no-note'
  'wrong-address-format'
  'wrong-note-format'
]

describe "Nice place parser", ->

  it "should parse normally", ->
    for spec in correct_specs
      loadAndParse spec
  it "should get correct data", ->
    places = loadAndParse 'more-than-one'
    expect(places).to.be.an('array')
    expect(places.length).to.equal(3)
    expect(places[0]).to.deep.equal
      name: "拉萨时光"
      address: "长宁区安西路23弄4号别墅"
      note: "前段时间住在长宁路，有时候下班之后就去那儿写代码，有时候只有一两个人，很安静，老板挺好的。"
      recommendedBy: "metrue"

    expect(places[1]).to.deep.equal
      name: "马陆图书馆"
      address: "嘉定区马陆镇沪宜公路2228号"
      note: "刚刚搬过来这边不久，周末特别喜欢来这里工作，书不是很多，但是环境很不错，很安静，有专门的儿童区，以后可以经常带女儿过来看书，自己写代码喽。"
      recommendedBy: "metrue"

    expect(places[2]).to.deep.equal
      name: "新单位"
      address: "卢湾区 永嘉路50号"
      note: ""
      recommendedBy: "Livid"

  it "should throw exceptions", ->
    expect(-> loadAndParse('no-address')).throw(Error, "Source not empty but not place information was found")
    expect(-> loadAndParse('no-note')).throw(Error, /Expect note for place \'.*\'/)
    expect(-> loadAndParse('wrong-address-format')).throw(Error, /Wrong address format: \'.*\'/)
    expect(-> loadAndParse('wrong-note-format')).throw(Error, /Wrong note format: \'(.|\r|\n)*'/)
