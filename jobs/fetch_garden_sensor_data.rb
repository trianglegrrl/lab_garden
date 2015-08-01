# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '1m', :first_in => 0 do |job|
  send_event('widget_id', { })
end

def get_sensor_data
  ask_arduino_for_data

end

def ask_arduino_for_data
  raise_signal_pin
  read_from_serial_port
  lower_signal_pin
end

def raise_signal_pin
end

def lower_signal_pin
end

def read_from_serial_port
