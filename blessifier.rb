#!/usr/bin/env ruby

$:.unshift __dir__

require "pathname"
require "paradox/parser"
require "blessifier/area"
require "blessifier/province"
require "blessifier/region"
require "blessifier/superregion"

EU4 = Pathname.new(ARGV[0])
Timeline = Pathname.new(ARGV[1])

Provinces = Blessifier::Province.from_dir(Timeline / "history" / "provinces")

Areas = Blessifier::Area.from_file(EU4 / "map" / "area.txt", provinces: Provinces)
Climates = Blessifier::Area.from_file(EU4 / "map" / "climate.txt", provinces: Provinces)
Continents = Blessifier::Area.from_file(EU4 / "map" / "continent.txt", provinces: Provinces)
Regions = Blessifier::Region.from_file(EU4 / "map" / "region.txt", areas: Areas)
Superregions = Blessifier::Superregion.from_file(EU4 / "map" / "superregion.txt", regions: Regions)

Objects = (Provinces + Areas + Climates + Continents + Regions + Superregions).map { |e| [e.id.to_s, e] }.to_h

require "csv"

CSV.new(File.read(ARGV[2]), headers: :first_row).each do |row|
  object = Objects.fetch(row["id"])
  provinces = object.provinces

  new_owner = row["owner"]
  new_culture = row["culture"]
  new_religion = row["religion"]
  new_hre = row["hre"]

  provinces.each do |province|
    if new_owner
      old_owner = province.owner

      province.owner = new_owner
      province.controller = new_owner
      province.cores = province.cores - [old_owner] + [new_owner]
    end

    province.culture = new_culture if new_culture
    province.religion = new_religion if new_religion
    province.hre = (new_hre == "yes") if new_hre
  end

  provinces.each(&:persist!)
end
