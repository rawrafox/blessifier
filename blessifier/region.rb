module Blessifier
  class Region
    attr_reader :id
    attr_reader :areas
    attr_reader :monsoon

    def initialize(id, areas:, monsoon: nil)
      @id = id
      @areas = areas
      @monsoon = monsoon
    end
    
    def self.from_file(path, areas:)
      parser = Paradox::Parser.new

      areas = areas.map { |area| [area.id, area] }.to_h

      parser.parse_file(path).fetch(:values).map do |region|
        name = region.fetch(:key).to_s
        values = region.fetch(:value).fetch(:values)
        as = []
        monsoon = nil

        values.each do |value|
          case key = value.fetch(:key)
          when "areas"
            as = value.fetch(:value).fetch(:values).map { |e| areas.fetch(e.fetch(:value).to_s) }
          when "monsoon"
            dates = value.fetch(:value).fetch(:values).map { |e| e.fetch(:value).to_s }

            monsoon = dates[0] .. dates[1]
          else
            raise ArgumentError, "unknown key in region (#{key})"
          end
        end

        Region.new(name, areas: as, monsoon: monsoon)
      end
    end

    def provinces
      @areas.flat_map(&:provinces)
    end
  end
end
