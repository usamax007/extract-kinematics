function [global_x,global_y,global_z] = findGlobalFrame(fileNamePlumbline,axis_y_temp)
ImportedData_raw = importdata(fileNamePlumbline, ',', 1);
rawData = ImportedData_raw.data;

% copy data into vectors for respective landmark points

pointTop1 = mean(rawData(:,1:3),1)';
pointTop2 = mean(rawData(:,7:9),1)';
pointTop3 = mean(rawData(:,13:15),1)';
pointBot1 = mean(rawData(:,19:21),1)';
pointBot2 = mean(rawData(:,25:27),1)';
pointBot3 = mean(rawData(:,31:33),1)';

pointTop = 1/3*(pointTop1 + pointTop2 + pointTop3);
pointBot = 1/3*(pointBot1 + pointBot2 + pointBot3);

global_z = normalizeVect(pointBot - pointTop);
global_x = normalizeVect(cross(axis_y_temp,global_z));
global_y = cross(global_z,global_x);