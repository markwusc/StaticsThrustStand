%Simulation for statics thrust stand


M = readmatrix("C:\Users\Mark\Downloads\Estes_C11.csv");

% Extract relevant columns for analysis, assuming first column is time and second is thrust
time = M(:, 1);
thrust = M(:, 2);

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

%Graph the load cell results compared to time
figure;
plot(time, MotorForce, time, BeamCompression);
xlabel('Time (s)');
ylabel('Load Cell Force (N)');
title('Load Cell Force Profiles vs Time');
legend('Motor Thrust (N)', 'Beam compression force (N)');
grid on;

