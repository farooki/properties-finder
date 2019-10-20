class LocationsProperty < ApplicationRecord
  belongs_to :location
  belongs_to :property
end
