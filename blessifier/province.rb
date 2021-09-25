require "stringio"

module Blessifier
  class Province
    attr_reader :path
    attr_reader :id

    attr_accessor :owner
    attr_accessor :controller
    attr_accessor :capital
    attr_accessor :culture
    attr_accessor :religion
    attr_accessor :trade_goods
    attr_accessor :latent_trade_goods
    attr_accessor :buildings
    attr_accessor :base_tax
    attr_accessor :base_production
    attr_accessor :base_manpower
    attr_accessor :extra_cost
    attr_accessor :center_of_trade
    attr_accessor :cores
    attr_accessor :permanent_claims
    attr_accessor :discovered_by
    attr_accessor :is_city
    attr_accessor :hre
    attr_accessor :native_size
    attr_accessor :native_ferocity
    attr_accessor :native_hostileness
    attr_accessor :permanent_province_modifiers
    attr_accessor :province_triggered_modifiers
    attr_accessor :add_nationalism

    def initialize(path, id:)
      @path = path
      @id = id

      @cores = []
      @permanent_claims = []
      @buildings = []
      @discovered_by = []
      @permanent_province_modifiers = []
      @province_triggered_modifiers = []
    end

    def self.wasteland(id:)
      Province.new(nil, id: id)
    end

    def self.from_dir(path)
      path.glob("*").map { |e| Province.from_file(e) }
    end

    def self.from_file(path)
      parser = Paradox::Parser.new

      province = parser.parse_file(path)

      id = path.basename(".txt").to_s.split("-").first.to_i
      result = Province.new(path, id: id)

      province.fetch(:values).each do |e|
        value = e.fetch(:value)

        case key = e.fetch(:key)
        when "owner" then result.owner = value.to_s
        when "controller" then result.controller = value.to_s
        when "capital" then result.capital = value.to_s
        when "is_city" then result.is_city = (value == "yes")
        when "culture" then result.culture = value.to_s
        when "religion" then result.religion = value.to_s
        when "trade_goods" then result.trade_goods = value.to_s
        when "latent_trade_goods" then result.latent_trade_goods = value.fetch(:values).map { |e| e.fetch(:value).to_s }
        when "fort_15th" then result.buildings << "fort_15th" if value == "yes"
        when "base_tax" then result.base_tax = value.to_i
        when "base_production" then result.base_production = value.to_i
        when "base_manpower" then result.base_manpower = value.to_i
        when "extra_cost" then result.extra_cost = value.to_i
        when "center_of_trade" then result.center_of_trade = value.to_i
        when "add_core" then result.cores << value.to_s
        when "add_permanent_claim" then result.permanent_claims << value.to_s
        when "discovered_by" then result.discovered_by << value.to_s
        when "hre" then result.hre = (value == "yes")
        when "native_size" then result.native_size = value.to_i
        when "native_ferocity" then result.native_ferocity = value.to_i
        when "native_hostileness" then result.native_hostileness = value.to_i
        when "add_permanent_province_modifier" then result.permanent_province_modifiers << value
        when "add_province_triggered_modifier" then result.province_triggered_modifiers << value.to_s
        when "add_nationalism" then result.center_of_trade = value.to_i
        else
          raise ArgumentError, "unknown key in province (#{key})"
        end
      end

      result
    end

    def hre?
      @hre
    end

    def is_city?
      @is_city
    end

    def provinces
      [self]
    end

    def to_string
      result = StringIO.new
      result.puts "owner = #{@owner}" if @owner
      result.puts "controller = #{@controller}" if @controller
      result.puts "capital = #{@capital}" if @capital
      result.puts "is_city = #{@is_city ? "yes" : "no"}" unless @is_city.nil?
      result.puts "culture = #{@culture}" if @culture
      result.puts "religion = #{@religion}" if @religion
      result.puts "trade_goods = #{@trade_goods}" if @trade_goods

      @buildings.each do |building|
        result.puts "#{building} = yes"
      end

      result.puts "hre = #{@hre ? "yes" : "no"}" unless @hre.nil?
      result.puts "base_tax = #{@base_tax}" if @base_tax
      result.puts "base_production = #{@base_production}" if @base_production
      result.puts "base_manpower = #{@base_manpower}" if @base_manpower
      result.puts "extra_cost = #{@extra_cost}" if @extra_cost
      result.puts "center_of_trade = #{@center_of_trade}" if @center_of_trade

      @cores.each do |core|
        result.puts "add_core = #{core}"
      end

      @permanent_claims.each do |claim|
        result.puts "add_permanent_claim = #{claim}"
      end

      @discovered_by.each do |discoverer|
        result.puts "discovered_by = #{discoverer}"
      end

      @permanent_province_modifiers.each do |modifier|
        result.puts "add_permanent_province_modifier = {"
        modifier.fetch(:values).each do |pair|
          value = pair.fetch(:value)

          if key = pair[:key]
            result.puts "\t#{key} = #{value}"
          else
            result.puts "\t#{value}"
          end
        end
        result.puts "}"
      end

      @province_triggered_modifiers.each do |modifier|
        result.puts "add_province_triggered_modifier = #{modifier}"
      end

      if @latent_trade_goods
        result.puts "latent_trade_goods = {"
        @latent_trade_goods.each do |trade_goods|
          result.puts "\t#{trade_goods}"
        end
        result.puts "}"
      end

      result.string
    end

    def persist!
      @path.write(self.to_string.encode("ISO-8859-1"))
    end
  end
end
