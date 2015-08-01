require "json"
require "artoo-raspi"

module GardenArduino
  STATUS_REQUEST_PIN = 5 # The pin that gets raised when you need a status reported from the Arduino
  WATERING_PIN = 10 # The pin that gets raised to do the watering

  def report_sensor_data
    values = ask_arduino_for_data
  end

  def ask_arduino_for_data
    raise_pin STATUS_REQUEST_PIN

    values = JSON.parse(read_from_serial_port)

    lower_pin STATUS_REQUEST_PIN
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

  def raise_pin(pin)
    # Do the thing that raises the pin
  end

  def lower_pin(pin)
    # Do the thing that lowers the pin
  end

  def read_from_serial_port
    waiting_for_data = true

    while waiting_for_data do
      line = serial_port.gets.chomp
      waiting_for_data = true if line
    end

    line
  end

  def serial_device
    10.times do |time|
      device_name = "/dev/ttyACM#{time}"
      if File.exist? device_name
        return device_name
      end
    end
  end

  def start_watering
    raise_pin WATERING_PIN
  end

  def end_watering
    lower_pin WATERING_PIN
  end
end
