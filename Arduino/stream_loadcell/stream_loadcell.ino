#include <HX711.h>
#include <EEPROM.h>

const int LOADCELL_DOUT = 2;
const int LOADCELL_SCK  = 3;

HX711 scale;
float cal_factor = 1.0f;

void setup() {
  Serial.begin(115200);
  scale.begin(LOADCELL_DOUT, LOADCELL_SCK);

  EEPROM.get(0, cal_factor);
  if (isnan(cal_factor) || cal_factor < 0.001) {
    cal_factor = 1.0;
  }

  Serial.print("Loaded calibration factor: ");
  Serial.println(cal_factor, 6);

  scale.set_scale();
  scale.tare();
}

void loop() {
  if (!scale.is_ready()) return;

  unsigned long t = micros();
  long raw = scale.read();
  float grams = raw / cal_factor;

  Serial.print(t);
  Serial.print(",");
  Serial.print(raw);
  Serial.print(",");
  Serial.println(grams, 4);
}