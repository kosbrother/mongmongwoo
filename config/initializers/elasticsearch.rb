if ['staging' , 'production'].include? Rails.env
  Elasticsearch::Model.client = Elasticsearch::Client.new host: ENV['ELASTICSEARCH_SERVER']
end