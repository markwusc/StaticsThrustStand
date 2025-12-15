#include <HX711.h>
#include <EEPROM.h>

const int LOADCELL1_DOUT = 2;
const int LOADCELL1_SCK  = 3;
const int LOADCELL2_DOUT = 4;
const int LOADCELL2_SCK  = 5;

HX711 loadcell1;
HX711 loadcell2;
float cal_factor1 = -1.0f;
float cal_factor2 = 1.0f;

void setup() {
  Serial.begin(115200);
  loadcell1.begin(LOADCELL1_DOUT, LOADCELL1_SCK);
  loadcell2.begin(LOADCELL2_DOUT, LOADCELL2_SCK);

  EEPROM.get(0, cal_factor1);
  EEPROM.get(1, cal_factor2);
  if (isnan(cal_factor1) || cal_factor1 < 0.001) {
    cal_factor1 = 1.0;
  }
  if (isnan(cal_factor2) || cal_factor2 < 0.001) {
    cal_factor2 = 1.0;
  }

  Serial.print("Loaded calibration factor 1: ");
  Serial.println(cal_factor1, 6);
  Serial.print("Loaded calibration factor 2: ");
  Serial.println(cal_factor2, 6);

  loadcell1.set_scale();
  loadcell1.tare();
  loadcell2.set_scale();
  loadcell2.tare();
}

void loop() {
  if (!loadcell1.is_ready() && loadcell2.is_ready()) return;

  unsigned long t = micros();
  long raw1 = loadcell1.read();
  float grams1 = raw1 / cal_factor1;
  long raw2 = loadcell2.read();
  float grams2 = raw2 / cal_factor2;

  Serial.print(t);
  Serial.print(",");
  Serial.print(raw1);
  Serial.print(",");
  Serial.print(grams1, 4);
  Serial.print(",");
  Serial.print(raw2);
  Serial.print(",");
  Serial.println(grams2, 4);
}