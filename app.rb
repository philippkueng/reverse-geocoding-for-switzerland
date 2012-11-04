require 'sinatra'
require 'rubygems'
require 'geo_ruby'
require 'json'
require 'uri'
require 'mongo'

configure :production do
  require 'newrelic_rpm'
end

include GeoRuby::SimpleFeatures

class App < Sinatra::Application

  # Connecting to MongoDB
  db = URI.parse(ENV['MONGOHQ_URL'] || 'mongodb://@localhost:27017/reversegeocodingforswitzerland')
  db_name = db.path.gsub(/^\//, '')
  db_connection = Mongo::Connection.new(db.host, db.port).db(db_name)
  db_connection.authenticate(db.user, db.password) unless (db.user.nil? || db.user.nil?)

  municipalities = db_connection.collection('municipalities')


  KANTON_ABK = ["ZH", "BE", "LU", "UR", "SZ", "OW", "NW", "GL", "ZG", "FR", "SO", "BS", "BL", "SH", "AR", "AI", "SG", "GR", "AG", "TG", "TI", "VD", "VS", "NE", "GE", "JU"]


  # Routes
  get '/' do
    "Welcome to the Reverse Geocoding for Swiss Municipalities."  
  end

  get '/lat/:lat/long/:long' do
    content_type 'application/json', :charset => 'utf-8'

    if params[:lat] and params[:long]

      phi = params[:lat].to_f
      lambda = params[:long].to_f

      phi_helper = (phi * 3600 - 169028.66) / 10000
      lambda_helper = (lambda * 3600 - 26782.5) / 10000

      x = 1_000_000 + 200147.07 + 308807.95 * phi_helper + 3745.25 * (lambda_helper**2) + (76.63 * phi_helper**2) + (119.79 * phi_helper**3) - (194.56 * lambda_helper**2 * phi_helper)

      y = 2_000_000 + 600072.37 + 211455.93 * lambda_helper - (10938.51 * lambda_helper * phi_helper) - (0.36 * lambda_helper * phi_helper**2) - (44.54 * lambda_helper**3)

      result = municipalities.find(
        :x_min => {'$lte' => y},
        :x_max => {'$gte' => y},
        :y_min => {'$lte' => x},
        :y_max => {'$gte' => x}
      )

      if result and result.count > 0
        result.each do |municipality|
          poly_points = municipality["points"]
          ring = LinearRing.from_coordinates(poly_points)

          point = Point.from_coordinates([y,x])

          if ring.contains_point?(point)
            return {
              :GEMNAME => municipality["properties"]["GEMNAME"],
              :KANTON => KANTON_ABK[municipality["properties"]["KANTONSNR"].to_i - 1],
              :BEZIRKSNR => municipality["properties"]["BEZIRKSNR"],
              :GEMFLAECHE => municipality["properties"]["GEMFLAECHE"]
            }.to_json
          end
        end

        # The point is near a border
        return {
          :message => "Coordinates are not within Switzerland."
        }.to_json

      else
        return {
          :message => "Coordinates are not within Switzerland."
        }.to_json
      end    

    else
      return {
        :error => "Invalid Latitude and Longitude parameters provided."
      }
    end
  end

end

