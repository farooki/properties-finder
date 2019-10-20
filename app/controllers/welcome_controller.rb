require 'open-uri'
require 'net/http'


class WelcomeController < ApplicationController
  def index
  end

  def location_suggester
    base_url = "https://www.rightmove.co.uk/typeAhead/uknostreet/"
    sub_url = ''
    params[:location].strip.upcase.chars.each_slice(2) do |loc|
      sub_url += loc.join('') + '/'
    end
    api_url = base_url + sub_url
    response = []
    begin
      uri = URI(api_url)
      res = Net::HTTP.get(uri)
      data = JSON.parse(res)
      response = data['typeAheadLocations'].map{|loc| loc['displayName']}
      Thread.new do
        insert_able_data = data['typeAheadLocations'].map{|f| f.slice('displayName', 'locationIdentifier', 'normalisedSearchTerm')}
        insert_able_data.each do |ir|
          ir['created_at'] = Time.now
          ir['updated_at'] = Time.now
        end
        Location.insert_all(insert_able_data)
      end
    rescue
    end
    render json: response
  end
end
