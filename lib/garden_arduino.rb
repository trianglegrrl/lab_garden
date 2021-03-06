require 'json'
require 'serialport'

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
