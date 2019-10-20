require 'nokogiri'
require 'open-uri'


class Property < ApplicationRecord
  def perform(random_id)
    puts "NO USE OF THIS ID IN HERE #{random_id}"
    need_to_stop = false
    loop do
      pq = PropertyQueue.where(status: 'pending').first
      pq.update(status: 'in_process')
      location = Location.find(pq.location_id)
      unless location.locationidentifier.nil?
        # We can scrap the rightmove.co.uk for this keyword
        url = "https://www.rightmove.co.uk/property-for-sale/find.html?searchType=SALE&locationIdentifier=#{location.locationidentifier}&insId=1&radius=0.0"
        doc = Nokogiri::HTML(open(url))
        properties_data = []

        doc.css('div.l-searchResult.is-list.is-not-grid').each do |property|
          property_images = property.css('img').map{|p| p['src'] if p['src'].present?}.compact
          properties_data << {
              property_images: property_images
          }
        end
      end
      sleep(15)
    end
  end
end
