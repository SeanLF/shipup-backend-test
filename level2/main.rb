require 'json'
require 'date'

def get_json_from_file(filename)
  file = File.read("data/#{filename}")
  JSON.parse(file)
end

def write_json_to_file(data, filename)
  File.open("data/#{filename}", 'w') { |f| f.write(data.to_json) }
end

def carriers_hash(carriers)
  carriers_hash = {}
  carriers.each do |carrier|
    carriers_hash[carrier['code']] = {
      delivery_promise: carrier['delivery_promise'],
      saturday_deliveries: carrier['saturday_deliveries']
    }
  end
  carriers_hash
end

def expected_delivery_date(shipping_date_string, delivery_promise, saturday_deliveries)
  shipping_date = Date.parse(shipping_date_string)
  times = delivery_promise + 1
  until times.zero?
    shipping_date += 1
    times -= 1 unless shipping_date.sunday? || (shipping_date.saturday? && !saturday_deliveries)
  end
  shipping_date
end

def main
  # Input
  data = get_json_from_file('input.json')
  # Output
  output = {
    deliveries: []
  }

  carriers_hash = carriers_hash(data['carriers'])
  packages = data['packages']

  output[:deliveries] = packages.map do |package|
    # Carrier info
    carrier = carriers_hash[package['carrier']]

    shipping_date = package['shipping_date']
    delivery_promise = carrier[:delivery_promise]
    saturday_deliveries = carrier[:saturday_deliveries]

    expected_delivery_date = expected_delivery_date(shipping_date, delivery_promise, saturday_deliveries)
    {
      package_id: package['id'],
      expected_delivery: expected_delivery_date
    }
  end
  write_json_to_file(output, 'output.json')
end

main
