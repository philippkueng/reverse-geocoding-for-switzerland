require 'rubygems'
require 'uri'
require 'mongo'
require 'json'

namespace :data do
  desc "Load the necessary data into MongoDB"
  task :load do
    puts "Establishing connection with MongoDB."

    db = URI.parse(ENV['MONGOHQ_URL'] || 'mongodb://@localhost:27017/reversegeocodingforswitzerland')
    db_name = db.path.gsub(/^\//, '')
    db_connection = Mongo::Connection.new(db.host, db.port).db(db_name)
    db_connection.authenticate(db.user, db.password) unless (db.user.nil? || db.user.nil?)

    municipalities = db_connection.collection('municipalities')

    puts "Loading GeoJSON file."
    VEC200 = JSON.parse(IO.read('VEC200_Commune.geojson').encode('utf-8', replace: nil))['features']

    puts "Inserting into MongoDB."
    VEC200.each do |feature|
      if feature['properties']['COUNTRY'] == 'CH'
        points = feature['geometry']['coordinates'][0]

        x_min = x_max = points[0][0]
        y_min = y_max = points[0][1]

        points.each do |point|
          if point[0] < x_min
            x_min = point[0]
          elsif point[0] > x_max
            x_max = point[0]
          end

          if point[1] < y_min
            y_min = point[1]
          elsif point[1] > y_max
            y_max = point[1]
          end
        end

        new_muni = {
          :x_min => x_min, 
          :x_max => x_max, 
          :y_min => y_min, 
          :y_max => y_max, 
          :points => points, 
          :properties => feature['properties']
        }
        muni_id = municipalities.insert(new_muni)
      end
    end

    puts "Loading data into MongoDB."
  end
end