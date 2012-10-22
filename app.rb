require 'sinatra'
require 'rubygems'
require 'georuby-extras'
require 'json'

configure :production do
  require 'newrelic_rpm'
end

include GeoRuby::SimpleFeatures

VEC200 = JSON.parse(IO.read('VEC200_Commune.geojson').encode('utf-8', replace: nil))['features']

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

    VEC200.each do |feature|
      if feature['properties']['COUNTRY'] == 'CH'
        poly_points = feature['geometry']['coordinates'][0]
        ring = LinearRing.from_coordinates(poly_points)

        point = Point.from_coordinates([y, x])

        if ring.fast_contains?(point)
          
          return {
            :GEMNAME => feature['properties']['GEMNAME'],
            :KANTONSNR => feature['properties']['KANTONSNR'],
            :BEZIRKSNR => feature['properties']['BEZIRKSNR'],
            :GEMFLAECHE => feature['properties']['GEMFLAECHE']
          }.to_json
        end
      end
    end

    return {
      :message => "Coordinates are not within Switzerland."
    }.to_json

  else
    return {
      :error => "Invalid Latitude and Longitude parameters provided."
    }
  end
end

