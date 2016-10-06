Braintree::Configuration.environment = :sandbox
Braintree::Configuration.merchant_id = ENV['merchant_id']
Braintree::Configuration.public_key = ENV['public_key']
Braintree::Configuration.private_key = ENV['private_key']
