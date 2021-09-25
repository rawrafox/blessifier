module Blessifier
  class Superregion
    attr_reader :id
    attr_reader :regions

    def initialize(id, regions:, restrict_charter: false)
      @id = id
      @regions = regions
      @restrict_charter = restrict_charter
    end
    
    def self.from_file(path, regions:)
      parser = Paradox::Parser.new

      regions = regions.map { |region| [region.id, region] }.to_h

      parser.parse_file(path).fetch(:values).map do |region|
        name = region.fetch(:key).to_s
        restrict_charter = false

        rs = region.fetch(:value).fetch(:values).map do |e|
          value = e.fetch(:value).to_s

          next if value == "restrict_charter"

          regions.fetch(value)
        end

        Superregion.new(name, regions: rs, restrict_charter: restrict_charter)
      end
    end

    def restrict_charter?
      @restrict_charter
    end

    def provinces
      @regions.flat_map(&:provinces)
    end
  end
end
