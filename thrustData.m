clear, clc, close all

thrust = readmatrix("loadCellDataFinal.csv");
time = thrust(:,1)';
raw = thrust(:,2)';
grams = thrust(:,3)';

avgYIntercept = sum(grams(:, 1:63)) / 63;

t = linspace(1, length(time), 194);

offsetGrams = [];
for i = 1:length(grams)
    offsetGrams(end+1) = grams(i) - avgYIntercept;
end

plot(t, offsetGrams);
modifiedLoadCell = [t',offsetGrams'];
writematrix(modifiedLoadCell, "modifiedLoadCell.csv")