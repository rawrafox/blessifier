require "parslet"
require "pathname"

module Paradox
  class Parser < Parslet::Parser
    root :document

    def stri(str)
      str.split("").map { |c| match["#{c.upcase}#{c.downcase}"] }.reduce(:>>)
    end

    rule(:eof) { any.absent? }

    rule(:spaces) { match[" \t\r\n"].repeat(1) }
    rule(:spaces?) { match[" \t\r\n"].repeat }

    rule(:comment) { spaces? >> match("#") >> (str("\n").absent? >> any).repeat >> str("\n") }
    rule(:comment?) { comment.repeat >> spaces? }

    rule(:whitespace) { spaces >> (comment.as(:comment).maybe >> spaces?).repeat }
    rule(:newline) { match("[ \t]").repeat(0) >> ((comment.as(:comment).maybe >> spaces?).repeat(1)).repeat }

    rule(:decimal) { match["+-"].maybe >> match["0-9"].repeat(1) >> str(".") >> match["0-9"].repeat }
    rule(:integer) { match["+-"].maybe >> match["0-9"].repeat(1) }
    rule(:identifier) { match["a-zA-Z"] >> match["a-zA-Z0-9_"].repeat(1) }
    rule(:string) { str("\"") >> (str('\\') >> any | str('"').absent? >> any).repeat >> str("\"") }
    rule(:date) { match["0-9"].repeat(2, 2) >> str(".") >> match["0-9"].repeat(2, 2) >> str(".") >> match["0-9"].repeat(2, 2) }

    rule(:key) { decimal | integer | identifier | string }
    rule(:value) { date | decimal | integer | identifier | string | stri("yes") | stri("no") }

    rule(:separator) { (spaces? >> str(',') >> comment?) | comment? | eof }
    rule(:group) { str("{") >> comment? >> (((key.as(:key) >> spaces? >> str("=") >> spaces? >> (value | group).as(:value)) | value.as(:value)) >> separator).repeat.as(:values) >> str("}") }
    rule(:pair) { key.as(:key) >> spaces? >> str("=") >> spaces? >> (value | group).as(:value) }

    rule(:document) { comment? >> (pair >> separator).repeat.as(:values) }

    def parse_file(path)
      self.parse(Pathname(path).read(encoding: "ISO-8859-1").encode("UTF-8").gsub(/\{\z/, ""))
    end
  end
end