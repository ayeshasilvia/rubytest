#!/usr/bin/env ruby

require 'net/http'
require 'net/https'
require 'uri'
require 'json'

uri = URI('https://spinnaker-global-api.intelematics.com/applications/dtcs/pipelines?statuses=TERMINAL')

Net::HTTP.start(uri.host, uri.port,
  :use_ssl => uri.scheme == 'https',
  :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|

  request = Net::HTTP::Get.new uri.request_uri
  request.basic_auth 'username', 'password'

  response = http.request request # Net::HTTPResponse object

  # puts response
  # puts response.body

  begin
    json = JSON.parse(response.body)
  rescue JSON::ParserError => _
    json = nil
  end

puts json
  failed_jobs = []
  succeeded_jobs = []
  jobs = json['jobs']
  jobs.each { |job|

    next if job['color'] == 'disabled'
    next if job['color'] == 'notbuilt'
    next if job['color'] == 'blue'
    next if job['color'] == 'blue_anime'
    next if job['name'].include?('smoke-test')

    failed_jobs.push(label: job['name'])
  }

  puts failed_jobs
  puts succeeded_jobs
end
