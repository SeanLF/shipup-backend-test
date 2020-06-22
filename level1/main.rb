require 'json'
require 'date'

def get_json_from_file(filename)
  file = File.read("data/#{filename}")
  JSON.parse(file)
end

def write_json_to_file(data, filename)
  File.open("data/#{filename}", 'w') { |f| f.write(data.to_json) }
end

def carrier_delivery_promises(carriers)
  carriers_hash = {}
  carriers.each do |carrier|
    carrier_name = carrier['code']
    delivery_promise = carrier['delivery_promise']
    carriers_hash[carrier_name] = delivery_promise
  end
  carriers_hash
end

def expected_delivery_date(shipping_date_string, delivery_promise)
  Date.parse(shipping_date_string) + (1 + delivery_promise)
end

def main
  # Input
  data = get_json_from_file('input.json')
  # Output
  output = {
    deliveries: []
  }

  carrier_delivery_promises = carrier_delivery_promises(data['carriers'])
  packages = data['packages']

  output[:deliveries] = packages.map do |package|
    package_id = package['id']
    carrier = package['carrier']
    shipping_date = package['shipping_date']
    delivery_promise = carrier_delivery_promises[carrier]
    expected_delivery_date = expected_delivery_date(shipping_date, delivery_promise)
    {
      package_id: package_id,
      expected_delivery: expected_delivery_date
    }
  end
  write_json_to_file(output, 'output.json')
end

main
