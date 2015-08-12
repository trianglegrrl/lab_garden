require 'dotenv'
require 'json'
require 'pry'
require 'serialport'
require 'slack-notifier'

Dotenv.load
slacker = GardenSlacker.new

SCHEDULER.every '5s', :first_in => 0 do |job|
  arduino_values = GardenArduino.current_arduino_data
  notified_of_empty_reservoir = false
  
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

    if reservoir_empty && !notified_of_empty_reservoir
      slacker.slack_notification_of_empty_reservoir reservoir_status
      notified_of_empty_reservoir = true
    else
      notified_of_empty_reservoir = false
    end
		 
    send_event('tempC', { current: arduino_values['tempC'].to_f.round(1) })

    send_event('humidity', { current: arduino_values['humidity'].to_i }) if arduino_values['humidity']
  end
end

class GardenSlacker
  def initialize
    @webhook_url = ENV('SLACK_WEBHOOK_URL') or raise "Holy fucking shit! No SLACK_WEBHOOK_URL set! You need to create your .env file."
    @notifier = Slack::Notifier.new webhook_url
    @notifier.username = 'The Garden'
    notifier.ping "Garden starting up...."
  end

  def send_message(message)
    @notifier.ping message 
  end
  
  def slack_notification_of_empty_reservoir(reservoir_value)
    send_message "Please fill my reservoir! My current sensor value is #{reservoir_value}."
  end
end

module GardenArduino
  extend self

  def current_arduino_data
    ask_arduino_for_data
  end

  def ask_arduino_for_data
    return_hash = Hash.new

    line = read_from_serial_port

    values = line.split("|").compact

    values.map do |v|
      key_value = v.split '='
      return_hash[key_value[0]] = key_value[1]
    end

    return_hash
  end

  private
  def serial_port
    #params for serial port
    baud_rate = 115200
    data_bits = 8
    stop_bits = 1
    parity = SerialPort::NONE

    @serial_port ||= SerialPort.new(serial_device, baud_rate, data_bits, stop_bits, parity)
  end

  def read_from_serial_port
    serial_port.flush_input

    serial_port.gets.chomp
  end

  def serial_device
    10.times do |time|
      device_name = "/dev/ttyACM#{time}"
      if File.exist? device_name
        return device_name
      end
    end
  end
end
