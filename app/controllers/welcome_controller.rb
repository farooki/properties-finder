require 'open-uri'
require 'net/http'


class WelcomeController < ApplicationController
  def index
    @available_properties = []
    @is_search_string_present = params[:search].present?
    @location =  params[:search]
    if params[:search].present?
      location = params[:search].split('--').first.strip
      radius = params[:search].split('--').last.strip.to_f
      if location.present?
        available_locations = Location.where("displayname LIKE ?", "%#{location}%")
        if available_locations.empty?
          available_locations = [Location.create(:displayname => location)]
        end

        properties_sql = "SELECT property_id from #{LocationsProperty.table_name}
                              WHERE location_id IN (#{available_locations.map(&:id).join(',')})
                                  AND is_active = true"
        unless radius == 0.0
          properties_sql += " AND radius <= #{radius}"
        end

        available_properties = LocationsProperty.find_by_sql(properties_sql).pluck(:property_id)
        if available_properties.empty?
          available_locations.map(&:id).each do |location_id|
            pq = PropertyQueue.find_or_create_by(location_id: location_id, radius: radius)
            Property.perform_async(pq.id)
          end
        else
          @available_properties = available_properties
        end
      end
    end
  end

  def location_suggester
    base_url = "https://www.rightmove.co.uk/typeAhead/uknostreet/"
    sub_url = ''
    params[:location].upcase.chars.each_slice(2) do |loc|
      sub_url += loc.map{|l| l.gsub(' ', '%20')}.join('') + '/'
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
        new_fields = []
        insert_able_data.each do |ir|
          new_fields << {
              :created_at => Time.now,
              :updated_at => Time.now,
              :displayname => ir['displayName'],
              :locationidentifier => ir['locationIdentifier'],
              :normalisedsearchierm => ir['normalisedSearchTerm']
          }
        end
        Location.insert_all(new_fields)
        Location.where(:displayname => new_fields.map{|nf| nf[:displayname]}).each do |loc|
          pq = PropertyQueue.find_or_create_by(location_id: loc.id, radius: 0.0)
          Property.perform_async(pq.id)
        end
      end
    rescue
    end
    render json: response
  end
end
