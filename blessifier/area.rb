module Blessifier
  class Area
    attr_reader :id
    attr_reader :color
    attr_reader :provinces

    def initialize(id, color: nil, provinces:)
      @id = id
      @color = color
      @provinces = provinces
    end

    def self.from_file(path, provinces:)
      parser = Paradox::Parser.new

      provinces = provinces.map { |province| [province.id, province] }.to_h

      parser.parse_file(path).fetch(:values).map do |area|
        name = area.fetch(:key).to_s
        color = nil
        value = area.fetch(:value)

        next unless value.is_a?(Hash)

        ps = value.fetch(:values).flat_map do |e|
          case key = e[:key]
          when nil
            province_id = e.fetch(:value).to_i

            [provinces.fetch(province_id) { provinces[province_id] = Province.wasteland(id: province_id) }]
          when "color"
            color = e.fetch(:value).fetch(:values).map { |c| c.fetch(:value).to_i }

            []
          else
            raise ArgumentError, "unknown key in area (#{key})"
          end
        end

        Area.new(name, color: color, provinces: ps)
      end.compact
    end
  end
end
