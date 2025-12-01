import serial
import csv

PORT = "/dev/tty.usbmodemXXXX" # unknown until arduino plugged in, run ls /dev/tty.*
BAUD = 115200 # based on Serial.begin(######) command in .ino file
CSV_FILE = "loadCellData.csv" # name of csv file

# Open the serial port, if no new data for 1 second throw error
ser = serial.Serial(PORT, BAUD, timeout=1)

with open(CSV_FILE, "w", newline="") as file:
    writer = csv.writer(file)
    writer.writerow(["time_microseconds", "raw_value"])

    print("LOGGING. PRESS CMD+C TO STOP")
    while True:
        try:
            # Read line, convert to string
            line = ser.readLine().decode()

            # Split string at comma
            t, raw = line.split(",")
            writer.writerow([t, raw])

        # Break if CMD+C
        except KeyboardInterrupt:
            print("\nStopping")
            print("ENSURE TO RENAME CSV, OR IT WILL BE OVERWRITTEN")
            break

        # If error, print
        except Exception:
            print("Error:", Exception)
