#include "HX711.h"

// Define board pins
const int LOADCELL_DOUT_PIN = 2;
const int LOADCELL_SCK_PIN = 3;

HX711 loadcell;

String readLine() {
  while (!Serial.available()) {}      // wait for input
  return Serial.readStringUntil('\n');
}

void setup() {
  Serial.begin(115200);
  loadcell.begin(LOADCELL_DOUT_PIN, LOADCELL_SCK_PIN);

  if (loadcell.is_ready()) {
    // Set load cell scale to default
    loadcell.set_scale();

    // Zero the load cell in preparation for calibration
    Serial.println("ZEROING, ENSURE LOADCELL IS NOT LOADED");
    delay(5000);
    loadcell.tare();
    Serial.println("SUCCESSFULLY ZEROED");

    // Measure a known weight
    Serial.println("PLACE KNOWN WEIGHT ON LOADCELL, MEASURING IN 30 SECONDS");
    delay(5000);
    long reading = loadcell.get_units(10);
    Serial.print("RESULT (ADC): ");
    Serial.println(reading);
    Serial.println("Enter the known weight in GRAMS, then press ENTER:");
    float known_weight = readLine().toFloat();

    // Calculate, save, and print the calibration factor
    Serial.println("CALCULATING CALIBRATION FACTOR...");
    float calibration_factor = reading / known_weight;
    Serial.print("CALIBRATION FACTOR: ");
    Serial.println(calibration_factor);

    delay(5000);
  }
  else {
    Serial.println("HX711 MODULE NOT FOUND");
  }
}

void loop() {
  // Measure data and show on terminal screen (WILL NOT STORE DATA, USE PYTHON SCRIPT FOR THAT)
  if (loadcell.is_ready()) {
    unsigned long t = micros(); // TIMESTAMP IN MICROSECONDS
    long rawData = loadcell.read();
    Serial.print(t);
    Serial.print(",");
    Serial.println(rawData);
    
  }
}
