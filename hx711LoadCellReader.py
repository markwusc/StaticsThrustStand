import serial
import csv
import matplotlib.pyplot as plt
from collections import deque
import threading
import sys
import termios
import tty

PORT = "/dev/tty.usbmodem1301"
BAUD = 115200
CSV_FILE = "/Users/gusfisher/Desktop/loadCellData.csv"
WINDOW_SEC = 10

# Open the serial port, if no new data for 1 second throw error
ser = serial.Serial(PORT, BAUD, timeout=1)

csvfile = open(CSV_FILE, "w", newline="")
writer = csv.writer(csvfile)
writer.writerow(["timestamp_us", "raw", "grams"])
logging_enabled = False

# Key listener
last_key = None

def key_listener():
    global last_key
    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    tty.setcbreak(fd)
    try:
        while True:
            k = sys.stdin.read(1)
            last_key = k
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)

threading.Thread(target=key_listener, daemon=True).start()

def read_valid_line(ser):
    while True:
        line = ser.readline().decode().strip()
        if not line:
            continue
        parts = line.split(',')
        if len(parts) != 3:
            continue
        return parts

# Plot buffers
times = []
kilograms_list = []

plt.ion()
fig, ax = plt.subplots()
line, = ax.plot([], [])
ax.set_xlabel("Time (s)")
ax.set_ylabel("Kilograms")

t0 = None  # start time

while True:
    try:
        # logging toggle
        if last_key == 'l':
            logging_enabled = not logging_enabled
            print(f"\nLogging = {logging_enabled}")
            last_key = None

        elif last_key == 'q':
            print("\nClosing...")
            break

        # Reading data
        t_us_str, raw_str, kg_str = read_valid_line(ser)
        t_us = int(t_us_str)
        raw = int(raw_str)
        kilograms = float(kg_str)

        # Normalizing time
        t_s = t_us / 1e6
        if t0 is None:
            t0 = t_s
        t = t_s - t0  # time starts at 0 and increases normally

        # Appending new times and weights
        times.append(t)
        kilograms_list.append(kilograms)

        # Maintaining the rolling window
        while times and (times[-1] - times[0] > WINDOW_SEC):
            times.pop(0)
            kilograms_list.pop(0)

        # Logging data if the logging is enabled
        if logging_enabled:
            writer.writerow([t_us, raw, kilograms])
            csvfile.flush()

        # Updating the plot
        line.set_xdata(times)
        line.set_ydata(kilograms_list)

        # X-axis always shows the rolling window
        if len(times) > 1:
            ax.set_xlim(times[0], times[-1])

        # Autoscale Y-axis to visible data only
        ax.relim()
        ax.autoscale_view(scalex=False, scaley=True)

        plt.pause(0.001)

    except KeyboardInterrupt:
        break

csvfile.close()
ser.close()