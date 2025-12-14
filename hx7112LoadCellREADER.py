import serial
import csv
import matplotlib.pyplot as plt
from collections import deque

PORT = "/dev/tty.usbmodem11301"
BAUD = 115200
CSV_FILE = "/Users/gusfisher/Desktop/loadCellData.csv"
WINDOW_SEC = 10

ser = serial.Serial(PORT, BAUD, timeout=1)

csvfile = open(CSV_FILE, "w", newline="")
writer = csv.writer(csvfile)
writer.writerow(["timestamp_us", "raw1", "grams1", "raw2", "grams2"])
logging_enabled = False
running = True

def on_key(event):
    global logging_enabled, running
    if event.key == 'l':
        logging_enabled = not logging_enabled
        print(f"Logging = {logging_enabled}")
    elif event.key == 'q':
        running = False

def try_read_line():
    line = ser.readline().decode(errors="ignore").strip()
    if not line:
        return None

    parts = line.split(',')
    if len(parts) != 5:
        return None

    try:
        return (
            int(parts[0]),
            int(parts[1]),
            float(parts[2]),
            int(parts[3]),
            float(parts[4]),
        )
    except ValueError:
        return None

# ---- plot setup ----
times = deque()
g1 = deque()
g2 = deque()

fig, ax = plt.subplots()
line1, = ax.plot([], [], label="Load Cell 1")
line2, = ax.plot([], [], label="Load Cell 2")
ax.set_xlabel("Time (s)")
ax.set_ylabel("Grams")
ax.legend()

fig.canvas.mpl_connect("key_press_event", on_key)

plt.show(block=False)

t0 = None

# ---- main loop ----
while running:
    data = try_read_line()

    if data is not None:
        t_us, raw1, grams1, raw2, grams2 = data

        t_s = t_us / 1e6
        if t0 is None:
            t0 = t_s
        t = t_s - t0

        times.append(t)
        g1.append(grams1)
        g2.append(grams2)

        while times and (times[-1] - times[0] > WINDOW_SEC):
            times.popleft()
            g1.popleft()
            g2.popleft()

        if logging_enabled:
            writer.writerow([t_us, raw1, grams1, raw2, grams2])
            csvfile.flush()

        line1.set_data(times, g1)
        line2.set_data(times, g2)

        if len(times) > 1:
            ax.set_xlim(times[0], times[-1])

        ax.relim()
        ax.autoscale_view(scalex=False, scaley=True)

    # IMPORTANT: GUI must always breathe
    plt.pause(0.01)

csvfile.close()
ser.close()
plt.close()