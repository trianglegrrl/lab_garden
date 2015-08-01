require 'json'
require 'pry'
require 'serialport'

SCHEDULER.every '5s', :first_in => 0 do |job|
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
    
    if reservoir_status
      reservoir_full = reservoir_status < 100 ? "Empty" : "Full"
      send_event('reservoirStatus', { text: reservoir_full })
    end

    send_event('tempC', { current: arduino_values['tempC'].to_f.round(1) })

    send_event('humidity', { current: arduino_values['humidity'].to_i }) if arduino_values['humidity']
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
