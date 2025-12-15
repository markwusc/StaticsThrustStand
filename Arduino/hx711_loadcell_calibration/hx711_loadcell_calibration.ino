#include <HX711.h>
#include <EEPROM.h>

const int LOADCELL1_DOUT = 2;
const int LOADCELL1_SCK  = 3;
const int LOADCELL2_DOUT = 4;
const int LOADCELL2_SCK  = 5;

HX711 loadcell1;
HX711 loadcell2;

void setup() {
  Serial.begin(115200);
  loadcell1.begin(LOADCELL1_DOUT, LOADCELL1_SCK);
  loadcell2.begin(LOADCELL2_DOUT, LOADCELL2_SCK);

  while (!loadcell1.is_ready() || !loadcell2.is_ready()) {
    Serial.println("HX711 not ready...");
    delay(500);
  }

  Serial.println("=== LOAD CELL CALIBRATION ===");
  Serial.println("Remove all weight. Zeroing in 5 seconds...");
  delay(5000);

  loadcell1.tare(50);
  Serial.println("Zero complete.");

  Serial.println("Place known weight on scale. Measuring for 5 seconds in 10 seconds");
  delay(10000);

  long sum = 0;
  int samples = 0;
  unsigned long start = millis();

  while (millis() - start < 5000) {
    if (loadcell1.is_ready()) {
      sum += loadcell1.read();
      samples++;
    }
  }

  long avg_raw = sum / samples;
  Serial.print("Average raw: ");
  Serial.println(avg_raw);

  Serial.println("Enter weight in grams, then press ENTER:");
  while (!Serial.available());

  float known_grams = Serial.readStringUntil('\n').toFloat();

  float cal_factor = avg_raw / known_grams;

  Serial.print("Calibration factor = ");
  Serial.println(cal_factor, 6);

  // Save to EEPROM
  EEPROM.put(0, cal_factor);
  Serial.println("Saved to EEPROM at address 1.");
}

void loop() {
  // nothing
}