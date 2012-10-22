# Reverse Geocoding for Swiss Municipalities

For a project I am working on I needed a possibility to tell wether a coordinate is within Switzerland and additionally within which canton and municipality. In order to accomplish that I have downloaded the [swissBOUNDARIES3D](http://www.swisstopo.admin.ch/internet/swisstopo/en/home/products/landscape/swissBOUNDARIES3D.html) file from the official Swiss Topography Portal then opened `Boundaries_2012/V200/ShapeFile_LV95/VEC200_Commune.shp` in [Quantum GIS](http://www.qgis.org/) and exported the whole thing as [GeoJSON](http://www.geojson.org/) as suggested in the comments [here](http://vallandingham.me/shapefile_to_geojson.html). As soon as Sinatra is starting it is going to load the GeoJSON file. Finally, each coordinate provided, via the RESTish interface, will be converted to the [CH1903+ Coordinate System](http://de.wikipedia.org/wiki/Schweizer_Landeskoordinaten#Landesvermessung_1995) in order for the raycasting algorithm to tell within which municipality the point is.


# API

Request

    curl http://reversegeocodingforswitzerland.herokuapp.com/lat/47.174532/long/8.897477


Response

    # successful
    {
      "GEMNAME": "Schübelbach",
      "KANTONSNR": 5,
      "BEZIRKSNR": 505,
      "GEMFLAECHE": 2901
    }


    # coordinates outside of Switzerland
    {
      "message": "Coordinates are not within Switzerland."
    }


    # invalid lat/long coordinates
    {
      "error": "Invalid Latitude and Longitude parameters provided."
    }


# License (MIT) (JUST FOR THE CODE)

Copyright (C) 2012 Philipp Küng

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.