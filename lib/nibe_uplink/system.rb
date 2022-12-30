# frozen_string_literal: true

module NibeUplink
  class System
    def initialize(client, system)
      @system = system
      @client = client
    end

    def get_status
      status = @client.system_status(@system["systemId"])
      entries = {}
      status.each do |heading|
        heading["parameters"].each do |parameter|
          # convert \u00B0C to °C
          unit = parameter["unit"]
          unit = unit.gsub(/\u00B0C/, "°C")
          # heading_name = heading["title"].tr(".: -", "  _ ").strip.gsub(" ", "")
          heading_name = heading["title"].downcase.gsub(":","").gsub("-", "").gsub(".", "").strip.tr(" ", "_")
          param_name = parameter["title"].gsub(":","").gsub("-", "").gsub(".", "").strip.tr(" ", "_")
          entries["#{heading_name}.#{param_name}"] = { value: parameter["displayValue"].to_f, unit: unit, designation: parameter["designation"] }
        end
      end
      entries
    end

    def method_missing(symbol, *args)
      # underscore to camelcase: test_case -> testCase
      camelcase = symbol.to_s.gsub(/_([a-z])/) { Regexp.last_match(1).upcase }

      @system[camelcase] if @system.key?(camelcase)
    end

  end
end
