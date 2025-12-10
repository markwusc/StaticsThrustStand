#include <HX711.h>
#include <EEPROM.h>

const int LOADCELL_DOUT = 2;
const int LOADCELL_SCK  = 3;

HX711 scale;

void setup() {
  Serial.begin(115200);
  scale.begin(LOADCELL_DOUT, LOADCELL_SCK);

  while (!scale.is_ready()) {
    Serial.println("HX711 not ready...");
    delay(500);
  }

  Serial.println("=== LOAD CELL CALIBRATION ===");
  Serial.println("Remove all weight. Zeroing in 5 seconds...");
  delay(5000);

  scale.tare(50);
  Serial.println("Zero complete.");

  Serial.println("Place known weight on scale. Measuring for 5 seconds...");
  delay(2000);

  long sum = 0;
  int samples = 0;
  unsigned long start = millis();

  while (millis() - start < 5000) {
    if (scale.is_ready()) {
      sum += scale.read();
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
  Serial.println("Saved to EEPROM at address 0.");
}

void loop() {
  // nothing
}