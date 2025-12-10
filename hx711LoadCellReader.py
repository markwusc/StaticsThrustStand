from time import sleep
import serial
import csv

PORT = "/dev/tty.usbmodem1401" # unknown until arduino plugged in, run ls /dev/tty.*
BAUD = 115200 # based on Serial.begin(######) command in .ino file
CSV_FILE = "/Users/gusfisher/Desktop/loadCellData.csv" # name of csv file

# Open the serial port, if no new data for 1 second throw error
ser = serial.Serial(PORT, BAUD, timeout=1)

with open(CSV_FILE, "w", newline="") as file:
    writer = csv.writer(file)
    writer.writerow(["time_microseconds", "raw_value"])

    print("LOGGING. PRESS CTRL+C TO STOP")
    sleep(1)
    while True:
        try:
            # Read line, convert to string
            line = ser.readline().decode()

            # Split string at comma
            t, raw = line.split(",")
            print(t + ',' + raw)
            writer.writerow([t, raw])

        # Break if CMD+C
        except KeyboardInterrupt:
            print("\nStopping")
            print("ENSURE TO RENAME CSV, OR IT WILL BE OVERWRITTEN")
            break

        # If error, print
        except Exception:
            print("Error:", Exception)
