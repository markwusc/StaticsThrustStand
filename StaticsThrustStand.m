%Simulation for statics thrust stand

%Adjust filePath to your machine
filePath = "C:\Users\Mark\Downloads\Estes_C11.csv";

%Read predicted values
projectedThrust = readmatrix(filePath);

%Read real data
% loadThrust = readmatrix("");
% loadCompression = readmatrix("");

% Extract relevant columns for analysis, assuming first column is time and second is thrust
time = projectedThrust(:, 1);
thrust = projectedThrust(:, 2);

% Plot the thrust over time
% figure;
% plot(time, thrust);
% xlabel('Time (s)');
% ylabel('Thrust (N)');
% title('Thrust vs Time');
% grid on;

% Calculate the average thrust
averageThrust = mean(thrust);

%Calculate the load cell force profiles
MotorForce = thrust;
BeamCompression = sqrt(2) * thrust / 2;

%Graph the predicted results compared to time
figure;
plot(time, MotorForce, time, BeamCompression);
xlabel('Time (s)');
ylabel('Load Cell Force (N)');
title('Load Cell Force Profiles vs Time');
legend('Motor Thrust (N)', 'Beam compression force (N)');
grid on;

%Graph the load cell results compared to time
figure;
plot(time, MotorForce, time, BeamCompression);
xlabel('Time (s)');
ylabel('Load Cell Force (N)');
title('Load Cell Force Profiles vs Time');
legend('Motor Thrust (N)', 'Beam compression force (N)');
grid on;