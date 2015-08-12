require 'dotenv'
require 'json'
require 'pry'
require 'serialport'
require 'slack-notifier'
require_relative '../lib/garden_arduino.rb'
require_relative '../lib/garden_slacker.rb'

slacker = GardenSlacker.new

SCHEDULER.every '30m', :first_in => 0 do |job|
  arduino_values = GardenArduino.current_arduino_data
  
  puts arduino_values

  if arduino_values
    puts "sending events"
    
    soil_moisture = arduino_values['soilMoisture'].to_i
    
    if soil_moisture
      needs_water = soil_moisture < 100 ? "I'm thirsty!" : "Happy!"
      send_event('soilMoisture', { text: needs_water })
    end

    reservoir_status = arduino_values['reservoirStatus'].to_i
    reservoir_empty = reservoir_status < 100
    
    if reservoir_status
      reservoir_full = reservoir_status < 100 ? "Empty" : "Full"
      send_event('reservoirStatus', { text: reservoir_full })
    end

    if reservoir_empty
      slacker.slack_notification_of_empty_reservoir reservoir_status
      notified_of_empty_reservoir = true
    elsif !reservoir_empty
      notified_of_empty_reservoir = false
    end
		 
    send_event('tempC', { current: arduino_values['tempC'].to_f.round(1) })

    send_event('humidity', { current: arduino_values['humidity'].to_i }) if arduino_values['humidity']
  end
end

