if ['staging' , 'production'].include? Rails.env
  Item.__elasticsearch__.client = Elasticsearch::Client.new host: ENV['ELASTICSEARCH_SERVER']
end