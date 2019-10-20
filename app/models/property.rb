require 'nokogiri'
require 'open-uri'


class Property < ApplicationRecord
  include Sidekiq::Worker

  def perform(pd_id)
    pq = PropertyQueue.find(pd_id)
    return unless pq.status == 'pending'
    pq.update(status: 'in_process')
    location = Location.find(pq.location_id)
    unless location.locationidentifier.nil?
      # We can scrap the rightmove.co.uk for this keyword
      properties_data = []
      need_to_break = false
      for i in 0 .. 45
        index = i * 24
        begin
          url = "https://www.rightmove.co.uk/property-for-sale/find.html?searchType=SALE&locationIdentifier=#{location.locationidentifier}&index=#{index}&insId=1&radius=0.0"
          doc = Nokogiri::HTML(open(url.strip))
          old_properties_data_count = properties_data.count
          doc.css('div.l-searchResult.is-list.is-not-grid').each do |property|
            property_images = property.css('img').map{|p| p['src'] if p['src'].present?}.compact
            property_price = property.css('div.propertyCard-priceValue').first.text.strip.gsub(',','')[1..-1].to_f rescue 0.0
            source_url = (property.css('.propertyCard-link').first['href']) rescue nil
            next unless source_url.present?
            source_url = 'https://www.rightmove.co.uk' + source_url
            properties_data << {
                images: property_images,
                name: property.css('h2').first.text.strip,
                description: property.css('.propertyCard-link').text.strip.tr("\n",""),
                price: property_price,
                source: 'Rightmove',
                source_url: source_url,
                created_at: Time.now,
                updated_at: Time.now

            }
          end
        rescue
          need_to_break = true
        end
        need_to_break = true  if properties_data.count == old_properties_data_count
        break if need_to_break
      end

      Property.insert_all(properties_data)
      property_ids = Property.where(:source_url => properties_data.map{|s| s[:source_url]}).pluck(:id)
      locations_properties_data = []
      property_ids.each do |prop_id|
        locations_properties_data << {
            location_id: location.id,
            property_id: prop_id,
            radius: pq.radius,
            is_active: true,
            created_at: Time.now,
            updated_at: Time.now
        }
      end
      LocationsProperty.insert_all(locations_properties_data)
      pq.update(status: 'finished')
    end
  end
end
