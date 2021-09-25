require "paradox/parser"

RSpec.describe Paradox::Parser do
  let(:parser) { Paradox::Parser.new }

  it "parses a key-value pair" do
    expect(parser.parse("owner = ICE")).to eq(values: [{ key: "owner", value: "ICE" }])
  end

  it "parses a key-value pair with a trailing newline" do
    expect(parser.parse("owner = ICE\n")).to eq(values: [{ key: "owner", value: "ICE" }])
  end

  it "parses two key-value pairs" do
    expect(parser.parse("owner = ICE\ncontroller = ICE")).to eq(values: [
      { key: "owner", value: "ICE" },
      { key: "controller", value: "ICE" }
    ])
  end

  it "parses two key-value pairs separated by a comma" do
    expect(parser.parse("owner = ICE, controller = ICE")).to eq(values: [
      { key: "owner", value: "ICE" },
      { key: "controller", value: "ICE" }
    ])
  end

  it "parses an empty group" do
    expect(parser.parse("europe = { }")).to eq(values: [{ key: "europe", value: { values: [] }}])
  end

  it "parses a group" do
    expect(parser.parse("europe = { 1 2 3 }")).to eq(values: [{ key: "europe", value: { values: [
      { value: "1" },
      { value: "2" },
      { value: "3" }
    ]}}])
  end
  
  it "parses a group with a comment" do
    expect(parser.parse("europe = {\n# Comment\n1 2 3\n}")).to eq(values: [{ key: "europe", value: { values: [
      { value: "1" },
      { value: "2" },
      { value: "3" }
    ]}}])
  end

  it "parses a group with both kv-pairs and values" do
    expect(parser.parse("brittany_area = { #5\ncolor = { 1 2 3 }\n1 2 3\n}")).to eq(values: [{ key: "brittany_area", value: { values: [
      { key: "color", value: { values: [
        { value: "1" },
        { value: "2" },
        { value: "3" }
      ]}},
      { value: "1" },
      { value: "2" },
      { value: "3" }
    ]}}])
  end

  it "parses many comments in weird shape" do
    expect(parser.parse("# A\n\n# B\n#C\n\narea = { 1 2 3 }")).to eq(values: [{ key: "area", value: { values: [
      { value: "1" },
      { value: "2" },
      { value: "3" }
    ]}}])
  end

  it "parses dates" do
    expect(parser.parse("monsoon = { 00.06.01 00.09.30 }")).to eq(values: [{ key: "monsoon", value: { values: [
      { value: "00.06.01" },
      { value: "00.09.30" }
    ]}}])
  end

  xit "parses a random file" do
    expect(parser.parse_file("#{__dir__}/random.txt")).to eq(values: [{ key: "europe", value: { values: [
      { value: "1" },
      { value: "2" },
      { value: "3" }
    ]}}])
  end
end
