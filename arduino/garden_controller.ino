#include <SHT1x.h> // Temp/humidity sensor
#include <ArduinoJson.h> // Format nice JSON output from the Arduino

/*
 * SETTINGS
 * Change these to match if you move the pins around or want to fiddle
 * with how it works.
 */

// When it's time to water, turn on for this many seconds
#define SECONDS_TO_RUN_PUMP 5

// Only check every once in a while. This could prevent over-watering. Kind of. Maybe.
#define SECONDS_TO_SLEEP_BEFORE_ANOTHER_CHECK 1

// If the soil moisture drops below this sensor level, water.
#define MINIMUM_SOIL_MOISTURE_LEVEL 730

// If the reservoir sensor drops below this level, don't water.
#define MINIMUM_RESERVOIR_LEVEL 100

// Analog in for soil moisture sensor; reports integer value
#define SOIL_MOISTURE_SENSOR_PIN A0
#define RESERVOIR_STATUS_SENSOR_PIN A1

// If this pin is high, turn on watering
#define WATER_COMMAND_PIN A2

// DigitalOut +5V to switch on the SparkFun Beefcake Relay
#define PUMP_RELAY_PIN 2

// Set up and instantiate SHT1x object for DFRobot SHT10 temp/humidity sensor
// Requires PWM. See SHT1x package and examples for more info.
#define SHT1X_DATA_PIN 10
#define SHT1X_CLOCK_PIN 11
SHT1x sht1x(SHT1X_DATA_PIN, SHT1X_CLOCK_PIN);

// Use JSON data format for communication with Raspberry Pi
StaticJsonBuffer<200> jsonBuffer;

/*
 * Arduino `setup()`; runs after power-on/reset
 */

void setup() {
  Serial.begin(115200);

  pinMode(PUMP_RELAY_PIN, OUTPUT);
}

/*
 * Arduino `loop()`; runs forever after `setup()` is run once.
 */

void loop() {
  float tempC;
  float tempF;
  float humidity;

  // Read values from DFRobot moisture sensors
  int soilMoisture = analogRead(SOIL_MOISTURE_SENSOR_PIN);
  int reservoirStatus = analogRead(RESERVOIR_STATUS_SENSOR_PIN);
  int doWatering = analogRead(WATER_COMMAND_PIN);

  // Read values from DFRobot SHT10 temp/humidity sensor
  tempC = sht1x.readTemperatureC();
  humidity = sht1x.readHumidity();

  // Report status in JSON format on serial port
  JsonObject& root = jsonBuffer.createObject();
  Serial.print("soilMoisture=");
  Serial.print(soilMoisture, DEC);
  Serial.print("|reservoirStatus=");
  Serial.print(reservoirStatus, DEC);
  Serial.print("|tempC=");
  Serial.print(tempC, DEC);
  Serial.print("|humidity=");
  Serial.print(humidity, DEC);
  Serial.println();

  // Water the garden if there's water in the reservoir and if the moisture content
  // isn't high enough.
  if (reservoirStatus > MINIMUM_RESERVOIR_LEVEL) {
    if (soilMoisture < MINIMUM_SOIL_MOISTURE_LEVEL) {
      digitalWrite(PUMP_RELAY_PIN, HIGH);
      delay(SECONDS_TO_RUN_PUMP * 1000); // Convert to milliseconds for delay
    }
    else {
      digitalWrite(PUMP_RELAY_PIN, LOW);
    }
  }
}
