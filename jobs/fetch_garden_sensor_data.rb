SCHEDULER.every '1m', :first_in => 0 do |job|
  arduino_values = GardenArduino.current_arduino_data

  if arduino_values
    send_event 'soil_moisture', { value: arduino_values['soilMoisture'] }
    send_event 'reservoir_status', { value: arduino_values['reservoirStatus'] }
    send_event 'temp_c', { value: arduino_values['temp_c'] }
    send_event 'humidity', { value: arduino_values['humidity'] }
  end
end

