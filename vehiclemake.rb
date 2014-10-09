require 'rubygems'
require 'rest_client'
require 'pry'
require 'json'
require 'httparty'

elastic_base_uri = "http://localhost:9200/"

base_uri_all_makes = "https://api.edmunds.com/api/vehicle/v2/makes"
base_uri_model_details = "https://api.edmunds.com/api/vehicle/v2"
api_key = "h9kkum47j9tup5a9wcrecjhr"
state = "new"
year = 2014
view = "full"
fmt = "json"


starting_time = Time.now
puts "Fetching all makes----->"

all_makes = RestClient.get "#{base_uri_all_makes}", params: { state: "#{state}", year: "#{year}", view: "#{view}", fmt: "#{fmt}", api_key: "#{api_key}" }
sleep 0.5

all_makes = JSON.parse(all_makes)

HTTParty.post("#{elastic_base_uri}vehicles/allmakes", body: all_makes.to_json, headers: { 'Content-Type' => 'application/json' })



puts all_makes_count = all_makes["makes"].length


make = []
model = []
model_details = []

all_makes["makes"].each do |each_make| # instead of .take(2), change to .each
  model_count = 0

  make << each_make["niceName"]

  makeNiceName = each_make["niceName"]

  each_make["models"].each do |each_model| # instead of .take(2), change to .each
    model_count = model_count + 1

    modelNiceName = each_model["niceName"]
    model << each_model["niceName"]

    puts "Fetching all models for #{makeNiceName}----->"
    current_model_details = RestClient.get "#{base_uri_model_details}/#{makeNiceName}/#{modelNiceName}", params: { state: "#{state}", year: "#{year}", view: "#{view}", fmt: "#{fmt}", api_key: "#{api_key}" }
    current_model_details = JSON.parse(current_model_details)
    model_details << current_model_details

    # TODO problem here; read up on structuring index, doctype, id
    HTTParty.post("#{elastic_base_uri}#{makeNiceName}/#{modelNiceName}", body: current_model_details.to_json, headers: { 'Content-Type' => 'application/json' } )


    sleep 1 # We can go down this furthermore but this is probably better to make sure it doesn't get Forbidden error while running through all

  end
  puts "#{model_count} for #{makeNiceName}"
end

finishing_time = Time.now
duration = ( finishing_time - starting_time ) / 60
puts "Done!"
print "Duration: "
puts "#{duration} minutes"
