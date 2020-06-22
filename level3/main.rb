require './json_file_manipulation'
require 'date'

include JsonFileManipulation

def carriers_hash(carriers)
  carriers_hash = {}
  carriers.each do |carrier|
    carriers_hash[carrier['code']] = {
      delivery_promise: carrier['delivery_promise'],
      saturday_deliveries: carrier['saturday_deliveries'],
      oversea_delay_threshold: carrier['oversea_delay_threshold']
    }
  end
  carriers_hash
end

def off_day?(date, saturday_deliveries)
  date.sunday? || (date.saturday? && !saturday_deliveries)
end

def expected_delivery_date(shipping_date_string, required_working_days, saturday_deliveries)
  shipping_date = Date.parse(shipping_date_string)
  times = required_working_days + 1

  until times.zero?
    shipping_date += 1
    times -= 1 unless off_day?(shipping_date, saturday_deliveries)
  end

  shipping_date
end

def oversea_delay(threshold, distance)
  (distance / threshold.to_f).floor
end

def main(input_file, output_file)
  data = get_json_from_file(input_file)
  output = {
    deliveries: []
  }

  carriers_hash = carriers_hash(data['carriers'])
  packages = data['packages']
  country_distances = data['country_distance']

  output[:deliveries] = packages.map do |package|
    carrier = carriers_hash[package['carrier']]

    origin_country = package['origin_country']
    destination_country = package['destination_country']
    country_distance = country_distances[origin_country][destination_country] || 0

    oversea_delay = oversea_delay(carrier[:oversea_delay_threshold], country_distance)

    required_working_days = carrier[:delivery_promise] + oversea_delay

    expected_delivery_date = expected_delivery_date(
      package['shipping_date'],
      required_working_days,
      carrier[:saturday_deliveries]
    )

    {
      package_id: package['id'],
      expected_delivery: expected_delivery_date,
      oversea_delay: oversea_delay
    }
  end
  write_json_to_file(output, output_file)
end

input_file = 'data/input.json'
output_file = 'data/output.json'
main(input_file, output_file)
