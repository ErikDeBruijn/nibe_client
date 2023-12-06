# frozen_string_literal: true

module NibeUplink
  class System
    def initialize(client, system)
      @system = system
      @client = client
    end

    def get_status
      status = @client.system_status(@system["systemId"])
      entries = []
      status.each do |heading|
        heading_name = heading["title"].downcase.gsub(":","").gsub("-", "").gsub(".", "").strip.tr(" ", "_")
        parameters = heading["parameters"]
        entries += entries_from_params(heading_name, parameters)
      end
      entries.to_h
    end

    def get_service_info(category)
      parameters = @client.system_service_info(@system["systemId"], category)
      to_h_with_suffix(entries_from_params(category, parameters))
    end

    def method_missing(symbol, *_args)
      # underscore to camelcase: test_case -> testCase
      camelcase = symbol.to_s.gsub(/_([a-z])/) { Regexp.last_match(1).upcase }

      @system[camelcase] if @system.key?(camelcase)
    end

    private

    def to_h_with_suffix(array)
      hash = {}
      counts = Hash.new(0)
      array.each do |key, value|
        counts[key] += 1
        key = "#{key}-#{counts[key]}" if counts[key] > 1
        hash[key] = value
      end
      hash
    end

    def entries_from_params(heading_name, parameters)
      parameters.map do |parameter|
        # convert \u00B0C to °C
        unit = parameter["unit"].gsub(/\u00B0C/, "°C")
        param_name = parameter["title"].gsub(":", "").gsub("-", "").gsub(".", "").strip.tr(" ", "_")
        values = { value: parameter["displayValue"].to_f, unit: unit, designation: parameter["designation"] }
        ["#{heading_name}.#{param_name}", values]
      end
    end
  end
end
