#!/usr/bin/env python3
# coding: latin-1

import urllib.request
import urllib.parse
import json
import time
import os
import sys
from secrets import secrets

# values = {'id':  '5882799',
          # 'appid': 'cf0aba57ff70cd8b0f22192a4860cee6',
          # 'units': 'metric'}

# url = 'http://api.openweathermap.org/data/2.5/weather'
values = {'id':secrets['id'],
           'appid':secrets['appid'],
           'units':secrets['units']}
url  = secrets['url']

url_data = urllib.parse.urlencode(values)
req = url + '?' + url_data

with urllib.request.urlopen(req) as response:
    w_data = json.load(response)

location = w_data['name']
latitude = w_data['coord']['lat']
longitude = w_data['coord']['lon']

obs_time = time.ctime(w_data['dt'])

temp_c = w_data['main']['temp']
weather = w_data['weather'][0]['description']

bar = float(w_data['main']['pressure'])/10

wind_dir = w_data['wind']['deg']
wind_kph = w_data['wind']['speed']
icon_url = 'http://openweathermap.org/img/w/'
icon = w_data['weather'][0]['icon'] + '.png'

req = icon_url + icon
with urllib.request.urlopen(req) as webfile:
    # localFile = open('/home/larry/scripts/icons/current.png', 'wb+')
    localFile = open('current.png', 'wb+')
    localFile.write(webfile.read())

    localFile.close()

print('Obs. time: %s' % (obs_time))
print(w_data['name'])
print("%s\u00B0 long." % (longitude), end='')
print("%s\u00B0 lat." % (latitude))
print()
print()
print("Temp %s \u00B0C" % (temp_c))
print(weather)
print('atm. press. ', bar, ' kPa')
print('wind speed: %s kph' % wind_kph)
print('wind out of - %s\u00B0' % wind_dir)
