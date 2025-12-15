% compareThrustCurves.m
% Compares two thrust curves by aligning their peak thrust times

clear; clc; close all;

gtokg = 0.00981;
offsetFactor = 0.489864006328; %Calibration values
offsetInitial = 125;

fileA = "Estes_C6-5_thrust_curve.csv";
fileB = "loadCellDataFinal.csv";

% Read tables
TA = readtable(fileA);
TB = readtable(fileB);

%% --- Estes data (auto-detect columns) ---
[tA, fA, nameA] = extractTimeAndForce(TA, "Estes");

%% --- Load cell data (FORCE = column 3) ---
tB = TB{:,1};      % assume time is column 1
fB = TB{:,3};      % FORCE column explicitly set to column 3
nameB = "Load cell (col 3)";

% Clean data
[tA, fA] = cleanSeries(tA, fA);
[tB, fB] = cleanSeries(tB*(10^(-6)), fB);

%% --- Align peaks ---
[peakA, idxA] = max(fA);
tPeakA = tA(idxA);

[peakB, idxB] = max(fB);
tPeakB = tB(idxB);

dt = tPeakA - tPeakB;
tBsync = tB + dt;

%% --- Plot aligned curves ---
figure;
plot(tA, fA, "LineWidth", 1.5); hold on;
plot(tBsync, (fB-offsetInitial)*offsetFactor, "LineWidth", 1.5);
grid on;
xlabel("Time (s)");
ylabel("Thrust");
title("Thrust curves aligned by peak thrust time");
legend( ...
    sprintf("%s (peak %.3f at %.3f s)", nameA, peakA, tPeakA), ...
    sprintf("%s shifted by %.6f s", nameB, dt), ...
    "Location", "best" );

% Mark peaks
plot(tPeakA, peakA, "o", "MarkerSize", 7, "LineWidth", 1.5);
plot(tPeakA, (peakB-offsetInitial)*offsetFactor, "o", "MarkerSize", 7, "LineWidth", 1.5);

% Call integrateError function
dataA = [tA, fA];
dataB = [tBsync, (fB-offsetInitial)*offsetFactor];
errMat = integrateError(dataA, dataB, offsetFactor);

% Plot the error results
figure;
subplot(4,1,1);
plot(errMat(:,1), errMat(:,2), 'LineWidth', 1.5);
grid on;
xlabel("Time (s)");
ylabel("Error (N)");
title("Pointwise Error between Thrust Curves");

subplot(4,1,2);
plot(errMat(:,1), errMat(:,3), 'LineWidth', 1.5);
grid on;
xlabel("Time (s)");
ylabel("Absolute Error (N)");
title("Absolute Error between Thrust Curves");

subplot(4,1,3);
plot(errMat(:,1), errMat(:,4), 'LineWidth', 1.5);
grid on;
xlabel("Time (s)");
ylabel("Cumulative Integrated Absolute Error (Ns)");
title("Cumulative Integrated Absolute Error");

subplot(4,1,4);
plot(errMat(:,1), errMat(:,4), 'LineWidth', 1.5);
grid on;
xlabel("Time (s)");
ylabel("Percent Error (%)");
title("Percent Error between Thrust Curves");

%% --- Helper functions ---

function [t, f, label] = extractTimeAndForce(T, tag)
    vars = string(T.Properties.VariableNames);
    label = tag;

    timeMask  = contains(lower(vars), "time");
    forceMask = contains(lower(vars), "thrust") | contains(lower(vars), "force");

    if any(timeMask)
        t = T.(vars(find(timeMask,1)));
    else
        t = T{:,1};
    end

    if any(forceMask)
        f = T.(vars(find(forceMask,1)));
    else
        f = T{:,2};
    end

    t = double(t);
    f = double(f);
end

function [t, f] = cleanSeries(t, f)
    t = t(:);
    f = f(:);

    ok = isfinite(t) & isfinite(f);
    t = t(ok);
    f = f(ok);

    [t, idx] = sort(t);
    f = f(idx);
end

function errMat = integrateError(dataA, dataB, expectedFactor)
% integrateError
% Computes pointwise error between two thrust curves that are already time synced.
% Also returns a cumulative time integral of the absolute error (an "integrated error").
%
% Inputs
%   dataA          Nx2 matrix [time_s, thrustA]
%   dataB          Mx2 matrix [time_s, thrustB]
%   expectedFactor double, expected multiplicative factor between B and A
%                 comparison uses: thrustA minus expectedFactor * thrustB
%
% Output
%   errMat         Nx4 matrix with columns:
%                 [time_s, error_N, absError_N, cumIntAbsError_Ns]

    if nargin < 3 || isempty(expectedFactor)
        expectedFactor = 1.0;
    end
    expectedFactor = double(expectedFactor);

    % Pull columns and force column vectors
    tA = double(dataA(:,1));  fA = double(dataA(:,2));
    tB = double(dataB(:,1));  fB = double(dataB(:,2));
    tA = tA(:); fA = fA(:); tB = tB(:); fB = fB(:);

    % Sort by time just in case
    [tA, idxA] = sort(tA); fA = fA(idxA);
    [tB, idxB] = sort(tB); fB = fB(idxB);

    % Interpolate B onto A time base so they are synchronized
    % Using linear interpolation, extrapolation set to 0 outside range
    fB_on_A = interp1(tB, fB, tA, "linear", 0);

    % Pointwise error
    err = fA - expectedFactor * fB_on_A;
    absErr = abs(err);

    % Integrated absolute error over time, cumulative
    cumIntAbsErr = cumtrapz(tA, absErr);

    %Percent error over time, instantaneous
    
    % Percent error over time, instantaneous
    percentError = (err ./ (expectedFactor * fB_on_A)) * 100;

    % Return matrix for each datapoint in A
    errMat = [tA, err, absErr, cumIntAbsErr, percentError];


end
