SCHEDULER.every '1m', :first_in => 0 do |job|
  arduino_values = GardenArduino.current_arduino_data

  if arduino_values
    send_event 'soil_moisture', { value: arduino_values['soilMoisture'] }
    send_event 'reservoir_status', { value: arduino_values['reservoirStatus'] }
    send_event 'temp_c', { value: arduino_values['temp_c'] }
    send_event 'humidity', { value: arduino_values['humidity'] }
  end
end

module GardenArduino
  extend self

  def current_arduino_data
    binding.pry
    ask_arduino_for_data
  end

  def ask_arduino_for_data
    json = false

    while !json
      json = JSON.parse(read_from_serial_port)
    end

    json
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
end
