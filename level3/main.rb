require './json_file_manipulation'
require 'date'

include JsonFileManipulation

def carriers_hash(carriers)
  carriers.map { |hash| [hash['code'], hash] }.to_h
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

def country_distance(distances, origin, destination)
  distances&.dig(origin)&.dig(destination) || 0
end

def oversea_delay(threshold, distance)
  (threshold || 1) / (distance || 0)
end

def expected_delivery_dates(carriers, packages, country_distances)
  packages.map do |package|
    carrier = carriers[package['carrier']]

    oversea_delay = oversea_delay(
      carrier['oversea_delay_threshold'],
      country_distance(country_distances, package['origin_country'], package['destination_country'])
    )

    expected_delivery_date = expected_delivery_date(
      package['shipping_date'],
      carrier['delivery_promise'] + oversea_delay,
      carrier['saturday_deliveries']
    )

    {
      package_id: package['id'],
      expected_delivery: expected_delivery_date,
      oversea_delay: oversea_delay
    }
  end
end

def main(data)
  {
    deliveries: expected_delivery_dates(
      carriers_hash(data['carriers']),
      data['packages'],
      data['country_distance']
    )
  }
end

write_json_to_file(main(get_json_from_file('data/input.json')), 'data/output.json')
