function outData = extractWingKinematicsRL(fileNameWingKins,fileNamePlumbline,rangeFrames,totalTime,rateFrame,sizeWindowFilter,drawPlots,runAnim)
% note to self: velocity vectors do not have windtunnel speed added.
% useTransversePlane means that wing kinematics are measured relative to the
% body transverse plane rather than the stroke plane
%Import wing kinematic data
%Data output is in Centimeters
ImportedData_raw = importdata(fileNameWingKins, ',', 1);
rawData = ImportedData_raw.data;
n_frames_expected = totalTime*rateFrame+1;
n_frames = rangeFrames(2)-rangeFrames(1)+1;
ind_frames_all = rangeFrames(1):rangeFrames(2);

useBodyRelativeStrokePlane = true;
% copy data into vectors for respective landmark points
headPoints = (rawData(ind_frames_all,1:3))';            %Marker 2 but marked as column 1 in this file
rightWingHingePoints = (rawData(ind_frames_all,19:21))';  %Marker 3 but marked as column 2 in this file
rightWingTipPoints = (rawData(ind_frames_all,37:39))';    %Marker 1 but marked as column 6 in this file
rightWingTrailEdgePoints = (rawData(ind_frames_all,43:45))';        %Marker 9 but marked as column 7 in this file
thoraxPoints = (rawData(ind_frames_all,7:9))';           %Marker 7 but marked as column 4 in this file
abdomenPoints = (rawData(ind_frames_all,13:15))';        %Marker 4 but marked as column 5 in this file
leftWingHingePoints = (rawData(ind_frames_all,49:51))';        %Marker 6 but marked as column 3 in this file
leftWingTipPoints = (rawData(ind_frames_all,67:69))';
leftWingTrailEdgePoints = (rawData(ind_frames_all,73:75))';

flowerLeftPoints = (rawData(ind_frames_all,79:81))';
flowerTopPoints = (rawData(ind_frames_all,85:87))';
flowerRightPoints = (rawData(ind_frames_all,91:93))';

TotalVideoFrames = size(rawData,1);
dt = 1/rateFrame;
% print data stats
digitizedData = struct();
disp(['Frame rate = ' num2str(rateFrame) ' frames per second']);
disp(['Total frames in the csv file = ' num2str(TotalVideoFrames) ' frames']);
disp(['Your expected frames in the video = ' num2str(n_frames_expected) ' frames']);
disp(['Total frames in your specified range = ' num2str(n_frames) ' frames']);

% extract non-NAN (actually digitized) frames and their indices
[digitizedData.head.indices(:,1), digitizedData.head.indices(:,2)] = find(~isnan(headPoints));
[digitizedData.RWH.indices(:,1), digitizedData.RWH.indices(:,2)] = find(~isnan(rightWingHingePoints));
[digitizedData.RWT.indices(:,1), digitizedData.RWT.indices(:,2)] = find(~isnan(rightWingTipPoints));
[digitizedData.RWC.indices(:,1), digitizedData.RWC.indices(:,2)] = find(~isnan(rightWingTrailEdgePoints));
[digitizedData.thorax.indices(:,1), digitizedData.thorax.indices(:,2)] = find(~isnan(thoraxPoints));
[digitizedData.abdomen.indices(:,1), digitizedData.abdomen.indices(:,2)] = find(~isnan(abdomenPoints));
[digitizedData.LWH.indices(:,1), digitizedData.LWH.indices(:,2)] = find(~isnan(leftWingHingePoints));
[digitizedData.LWT.indices(:,1), digitizedData.LWT.indices(:,2)] = find(~isnan(leftWingTipPoints));
[digitizedData.LWC.indices(:,1), digitizedData.LWC.indices(:,2)] = find(~isnan(leftWingTrailEdgePoints));

% make sure no x, y or z coordinates are missing
[digitizedData.head.xyzDataCheck(1), digitizedData.head.xyzDataCheck(2),...
    digitizedData.head.xyzDataCheck(3)] = xyzDataCheck(digitizedData.head.indices);
[digitizedData.RWH.xyzDataCheck(1), digitizedData.RWH.xyzDataCheck(2),...
    digitizedData.RWH.xyzDataCheck(3)] = xyzDataCheck(digitizedData.RWH.indices);
[digitizedData.RWT.xyzDataCheck(1), digitizedData.RWT.xyzDataCheck(2),...
    digitizedData.RWT.xyzDataCheck(3)] = xyzDataCheck(digitizedData.RWT.indices);
[digitizedData.RWC.xyzDataCheck(1), digitizedData.RWC.xyzDataCheck(2),...
    digitizedData.RWC.xyzDataCheck(3)] = xyzDataCheck(digitizedData.RWC.indices);
[digitizedData.thorax.xyzDataCheck(1), digitizedData.thorax.xyzDataCheck(2),...
    digitizedData.thorax.xyzDataCheck(3)] = xyzDataCheck(digitizedData.thorax.indices);
[digitizedData.abdomen.xyzDataCheck(1), digitizedData.abdomen.xyzDataCheck(2),...
    digitizedData.abdomen.xyzDataCheck(3)] = xyzDataCheck(digitizedData.abdomen.indices);
[digitizedData.LWH.xyzDataCheck(1), digitizedData.LWH.xyzDataCheck(2),...
    digitizedData.LWH.xyzDataCheck(3)] = xyzDataCheck(digitizedData.LWH.indices);
[digitizedData.LWT.xyzDataCheck(1), digitizedData.LWT.xyzDataCheck(2),...
    digitizedData.LWT.xyzDataCheck(3)] = xyzDataCheck(digitizedData.LWT.indices);
[digitizedData.LWC.xyzDataCheck(1), digitizedData.LWC.xyzDataCheck(2),...
    digitizedData.LWC.xyzDataCheck(3)] = xyzDataCheck(digitizedData.LWC.indices);

% calculate the number of digitized frames
digitizedData.head.numDigitizedFrames = length(digitizedData.head.indices)/3;
digitizedData.RWH.numDigitizedFrames = length(digitizedData.RWH.indices)/3;
digitizedData.RWT.numDigitizedFrames = length(digitizedData.RWT.indices)/3;
digitizedData.RWC.numDigitizedFrames = length(digitizedData.RWC.indices)/3;
digitizedData.thorax.numDigitizedFrames = length(digitizedData.thorax.indices)/3;
digitizedData.abdomen.numDigitizedFrames = length(digitizedData.abdomen.indices)/3;
digitizedData.LWH.numDigitizedFrames = length(digitizedData.LWH.indices)/3;
digitizedData.LWT.numDigitizedFrames = length(digitizedData.LWT.indices)/3;
digitizedData.LWC.numDigitizedFrames = length(digitizedData.LWC.indices)/3;

% calculate actual number of frames
digitizedData.head.numFrames = digitizedData.head.indices(end-2,2) - digitizedData.head.indices(1,2) + 1;
digitizedData.RWH.numFrames = digitizedData.RWH.indices(end-2,2) - digitizedData.RWH.indices(1,2) + 1;
digitizedData.RWT.numFrames = digitizedData.RWT.indices(end-2,2) - digitizedData.RWT.indices(1,2) + 1;
digitizedData.RWC.numFrames = digitizedData.RWC.indices(end-2,2) - digitizedData.RWC.indices(1,2) + 1;
digitizedData.thorax.numFrames = digitizedData.thorax.indices(end-2,2) - digitizedData.thorax.indices(1,2) + 1;
digitizedData.abdomen.numFrames = digitizedData.abdomen.indices(end-2,2) - digitizedData.abdomen.indices(1,2) + 1;
digitizedData.LWH.numFrames = digitizedData.LWH.indices(end-2,2) - digitizedData.LWH.indices(1,2) + 1;
digitizedData.LWT.numFrames = digitizedData.LWT.indices(end-2,2) - digitizedData.LWT.indices(1,2) + 1;
digitizedData.LWC.numFrames = digitizedData.LWC.indices(end-2,2) - digitizedData.LWC.indices(1,2) + 1;

% print data information (see disp below to see the info headings)
digitizedData.dataLabels = ['Head   ';'RWH    '; 'LWH    '; 'Thorax '; 'Abdomen'; 'RWT    '; 'RWC    ';'LWT    '; 'LWC    '];
digitizedData.dataInfo = [(digitizedData.head.indices(1,2))   (digitizedData.head.indices(end-2,2))   ...
    (digitizedData.head.numFrames)   (digitizedData.head.numDigitizedFrames)...
    (digitizedData.head.xyzDataCheck(1))   (digitizedData.head.xyzDataCheck(2))...
    (digitizedData.head.xyzDataCheck(3));
    (digitizedData.RWH.indices(1,2))   (digitizedData.RWH.indices(end-2,2))   ...
    (digitizedData.RWH.numFrames)   (digitizedData.RWH.numDigitizedFrames)...
    (digitizedData.RWH.xyzDataCheck(1))   (digitizedData.RWH.xyzDataCheck(2))...
    (digitizedData.RWH.xyzDataCheck(3));
    (digitizedData.LWH.indices(1,2))   (digitizedData.LWH.indices(end-2,2))   ...
    (digitizedData.LWH.numFrames)   (digitizedData.LWH.numDigitizedFrames)...
    (digitizedData.LWH.xyzDataCheck(1))   (digitizedData.LWH.xyzDataCheck(2))...
    (digitizedData.LWH.xyzDataCheck(3));
    (digitizedData.thorax.indices(1,2))   (digitizedData.thorax.indices(end-2,2))   ...
    (digitizedData.thorax.numFrames)   (digitizedData.thorax.numDigitizedFrames)...
    (digitizedData.thorax.xyzDataCheck(1))   (digitizedData.thorax.xyzDataCheck(2))...
    (digitizedData.thorax.xyzDataCheck(3));
    (digitizedData.abdomen.indices(1,2))   (digitizedData.abdomen.indices(end-2,2))   ...
    (digitizedData.abdomen.numFrames)   (digitizedData.abdomen.numDigitizedFrames)...
    (digitizedData.abdomen.xyzDataCheck(1))   (digitizedData.abdomen.xyzDataCheck(2))...
    (digitizedData.abdomen.xyzDataCheck(3));
    (digitizedData.RWT.indices(1,2))   (digitizedData.RWT.indices(end-2,2))   ...
    (digitizedData.RWT.numFrames)   (digitizedData.RWT.numDigitizedFrames)...
    (digitizedData.RWT.xyzDataCheck(1))   (digitizedData.RWT.xyzDataCheck(2))...
    (digitizedData.RWT.xyzDataCheck(3));
    (digitizedData.RWC.indices(1,2))   (digitizedData.RWC.indices(end-2,2))   ...
    (digitizedData.RWC.numFrames)   (digitizedData.RWC.numDigitizedFrames)...
    (digitizedData.RWC.xyzDataCheck(1))   (digitizedData.RWC.xyzDataCheck(2))...
    (digitizedData.RWC.xyzDataCheck(3));
    (digitizedData.LWT.indices(1,2))   (digitizedData.LWT.indices(end-2,2))   ...
    (digitizedData.LWT.numFrames)   (digitizedData.LWT.numDigitizedFrames)...
    (digitizedData.LWT.xyzDataCheck(1))   (digitizedData.LWT.xyzDataCheck(2))...
    (digitizedData.LWT.xyzDataCheck(3));
    (digitizedData.LWC.indices(1,2))   (digitizedData.LWC.indices(end-2,2))   ...
    (digitizedData.LWC.numFrames)   (digitizedData.LWC.numDigitizedFrames)...
    (digitizedData.LWC.xyzDataCheck(1))   (digitizedData.LWC.xyzDataCheck(2))...
    (digitizedData.LWC.xyzDataCheck(3))];
disp('--------------------------------------------------------------------------');
disp('Point Name || Start frame | End Frame | No. of frames | No. of digtzd. frames || x OK | y OK | z OK');
disp('--------------------------------------------------------------------------');
for i = 1:size(digitizedData.dataInfo,1)
    disp(strcat(pad(string(digitizedData.dataLabels(i,:)),11), "||", pad(string(num2str(digitizedData.dataInfo(i,1))),13), "|", pad(string(num2str(digitizedData.dataInfo(i,2))),11), "|", ...
        pad(string(num2str(digitizedData.dataInfo(i,3))),15), "|", pad(string(num2str(digitizedData.dataInfo(i,4))),23),...
        "||", pad(string(num2str(digitizedData.dataInfo(i,5))),6), "|", pad(string(num2str(digitizedData.dataInfo(i,6))),6),...
        " | ", pad(string(num2str(digitizedData.dataInfo(i,7))),6)));
end
disp('--------------------------------------------------------------------------');
digitizedData.frameRangeValid = [max(digitizedData.dataInfo(:,1)) min(digitizedData.dataInfo(:,2))];
disp(['Range   | ' num2str(digitizedData.frameRangeValid(1)) ' | ' num2str(digitizedData.frameRangeValid(2))]);
disp('--------------------------------------------------------------------------');

% move data to separate matrices for X data, Y data and Z data but a
% matrix contains all the points (e.g. Xdata(points 1 to 12,frames 1:N))
% 1 head, 2 rwh, 3 lwh, 4 thorax, 5 abdomen, 6 rw tip, 7 rw chord point, 8 lw tip, 9 lw chord, 10 flower left, 11 flower top, 12 flower right
Xdata = [headPoints(1,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2));...
    rightWingHingePoints(1,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2));...
    leftWingHingePoints(1,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2));...
    thoraxPoints(1,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2));...
    abdomenPoints(1,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2));...
    rightWingTipPoints(1,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2));...
    rightWingTrailEdgePoints(1,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2));...
    leftWingTipPoints(1,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2));...
    leftWingTrailEdgePoints(1,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2));...
    flowerLeftPoints(1,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2));...
    flowerTopPoints(1,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2));...
    flowerRightPoints(1,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2))];
Ydata = [headPoints(2,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2));...
    rightWingHingePoints(2,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2));...
    leftWingHingePoints(2,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2));...
    thoraxPoints(2,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2));...
    abdomenPoints(2,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2));...
    rightWingTipPoints(2,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2));...
    rightWingTrailEdgePoints(2,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2));...
    leftWingTipPoints(2,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2));...
    leftWingTrailEdgePoints(2,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2));...
    flowerLeftPoints(2,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2));...
    flowerTopPoints(2,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2));...
    flowerRightPoints(2,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2))];
Zdata = [headPoints(3,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2));...
    rightWingHingePoints(3,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2));...
    leftWingHingePoints(3,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2));...
    thoraxPoints(3,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2));...
    abdomenPoints(3,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2));...
    rightWingTipPoints(3,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2));...
    rightWingTrailEdgePoints(3,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2));...
    leftWingTipPoints(3,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2));...
    leftWingTrailEdgePoints(3,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2));...
    flowerLeftPoints(3,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2));...
    flowerTopPoints(3,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2));...
    flowerRightPoints(3,digitizedData.frameRangeValid(1):digitizedData.frameRangeValid(2))];


n_quants = size(Xdata,1); % no of landmark points
n_frames = size(Xdata,2); % no of total frames (digtzd + interpd)
%% interpolate data
for i = 1:n_quants
    Xdata(i,:) = inpaintn(Xdata(i,:));
    Ydata(i,:) = inpaintn(Ydata(i,:));
    Zdata(i,:) = inpaintn(Zdata(i,:));
end
if(drawPlots == 1)
    figure;
    plot3(Xdata',Ydata',Zdata','o');
    hold on;
    plot3(Xdata',Ydata',Zdata','.');
    grid on; title('Interpolated Data');
    legend(digitizedData.dataLabels(1,:),digitizedData.dataLabels(2,:),digitizedData.dataLabels(3,:),...
        digitizedData.dataLabels(4,:),digitizedData.dataLabels(5,:),digitizedData.dataLabels(6,:),...
        digitizedData.dataLabels(7,:),digitizedData.dataLabels(8,:),digitizedData.dataLabels(9,:));
end

%% plot a stick figure of the first frame
ii = 1;
RWT_RWH = [[Xdata(6,ii);Ydata(6,ii);Zdata(6,ii)]...
    [Xdata(2,ii);Ydata(2,ii);Zdata(2,ii)]];
LWT_LWH = [[Xdata(8,ii);Ydata(8,ii);Zdata(8,ii)]...
    [Xdata(3,ii);Ydata(3,ii);Zdata(3,ii)]];
RWH_LWH = [[Xdata(2,ii);Ydata(2,ii);Zdata(2,ii)]...
    [Xdata(3,ii);Ydata(3,ii);Zdata(3,ii)]];
head_TAB = [[Xdata(1,ii);Ydata(1,ii);Zdata(1,ii)]...
    [Xdata(4,ii);Ydata(4,ii);Zdata(4,ii)]];
TAB_abd = [[Xdata(4,ii);Ydata(4,ii);Zdata(4,ii)]...
    [Xdata(5,ii);Ydata(5,ii);Zdata(5,ii)]];

temp_rightWingSurfX = [Xdata(6,ii) Xdata(7,ii) Xdata(2,ii)];
temp_rightWingSurfY = [Ydata(6,ii) Ydata(7,ii) Ydata(2,ii)];
temp_rightWingSurfZ = [Zdata(6,ii) Zdata(7,ii) Zdata(2,ii)];

temp_leftWingSurfX = [Xdata(8,ii) Xdata(9,ii) Xdata(3,ii)];
temp_leftWingSurfY = [Ydata(8,ii) Ydata(9,ii) Ydata(3,ii)];
temp_leftWingSurfZ = [Zdata(8,ii) Zdata(9,ii) Zdata(3,ii)];

% MOTH STICK FIGURE OF FIRST DIGITIZED POINT
if(drawPlots==1)
    figure
    hold on
    % plot stick vectors
    line(RWT_RWH(1,:), RWT_RWH(2,:), RWT_RWH(3,:), 'color','b', 'linewidth',5);
    line(LWT_LWH(1,:), LWT_LWH(2,:), LWT_LWH(3,:), 'color','b', 'linewidth',5);
    line(RWH_LWH(1,:), RWH_LWH(2,:), RWH_LWH(3,:), 'color','y', 'linewidth',7);
    line(head_TAB(1,:), head_TAB(2,:), head_TAB(3,:), 'color','k', 'linewidth',10);
    line(TAB_abd(1,:), TAB_abd(2,:), TAB_abd(3,:), 'color', 'k', 'linewidth',10);
    % Draw wing surface
    fill3(temp_rightWingSurfX, temp_rightWingSurfY, temp_rightWingSurfZ,[0.5 0.5 0.5]);
    fill3(temp_leftWingSurfX, temp_leftWingSurfY, temp_leftWingSurfZ,[0.5 0.5 0.5]);
    % plot ball points
    plot3(Xdata(2,ii), Ydata(2,ii), Zdata(2,ii), 'r-o','markersize',8,'markerfacecolor','r');
    plot3(Xdata(6,ii), Ydata(6,ii), Zdata(6,ii), 'b-o','markersize',8,'markerfacecolor','b');
    plot3(Xdata(7,ii), Ydata(7,ii), Zdata(7,ii), 'b-o','markersize',8,'markerfacecolor','b');
    plot3(Xdata(8,ii), Ydata(8,ii), Zdata(8,ii), 'b-o','markersize',8,'markerfacecolor','b');
    plot3(Xdata(9,ii), Ydata(9,ii), Zdata(9,ii), 'b-o','markersize',8,'markerfacecolor','b');
    plot3(Xdata(3,ii), Ydata(3,ii), Zdata(3,ii), 'r-o','markersize',8,'markerfacecolor','r');
    plot3(Xdata(5,ii), Ydata(5,ii), Zdata(5,ii), 'm-o','markersize',8,'markerfacecolor','m');
    plot3(Xdata(1,ii), Ydata(1,ii), Zdata(1,ii), 'g-o','markersize',8,'markerfacecolor','g');
    plot3(Xdata(4,ii), Ydata(4,ii), Zdata(4,ii), 'k-o','markersize',10,'markerfacecolor','r');
    % plot wing surface

    title('Raw Interpolated data')
    xlabel('x'); ylabel('y'); zlabel('z'); grid on;

end
%% filter data to smooth it out
for i = 1:n_quants
    Xdata(i,:) = movmean(Xdata(i,:),sizeWindowFilter);
    Ydata(i,:) = movmean(Ydata(i,:),sizeWindowFilter);
    Zdata(i,:) = movmean(Zdata(i,:),sizeWindowFilter);
end

if(drawPlots == 1)
    figure;
    plot3(Xdata',Ydata',Zdata');
    grid on; title('Filtered Data');
    legend(digitizedData.dataLabels(1,:),digitizedData.dataLabels(2,:),digitizedData.dataLabels(3,:),...
        digitizedData.dataLabels(4,:),digitizedData.dataLabels(5,:),digitizedData.dataLabels(6,:),...
        digitizedData.dataLabels(7,:), digitizedData.dataLabels(8,:), digitizedData.dataLabels(9,:));
end

%% animation
temp_FLP = [Xdata(10,:);Ydata(10,:);Zdata(10,:)]; % flower left
temp_FTP = [Xdata(11,:);Ydata(11,:);Zdata(11,:)]; % flower top
temp_FRP = [Xdata(12,:);Ydata(12,:);Zdata(12,:)]; % flower right

% calculate the axes of the global frame
temp_vect_FL2FR = mean(temp_FRP - temp_FLP,2);
[global_axis_x,global_axis_y,global_axis_z] = findGlobalFrame(fileNamePlumbline,temp_vect_FL2FR);
R_global = [global_axis_x global_axis_y global_axis_z];
% set the global origin as the starting point of the flower (just take avg of 3 flower points in frame 1)
origin_global = 1/3*(temp_FLP(:,1) + temp_FTP(:,1) + temp_FRP(:,1));

temp_head = R_global\([Xdata(1,:);Ydata(1,:);Zdata(1,:)] - origin_global);
temp_thorax = R_global\([Xdata(4,:);Ydata(4,:);Zdata(4,:)] - origin_global);
temp_abdomen = R_global\([Xdata(5,:);Ydata(5,:);Zdata(5,:)] - origin_global);
temp_RWH = R_global\([Xdata(2,:);Ydata(2,:);Zdata(2,:)] - origin_global);
temp_RWT = R_global\([Xdata(6,:);Ydata(6,:);Zdata(6,:)] - origin_global);
temp_RWC = R_global\([Xdata(7,:);Ydata(7,:);Zdata(7,:)] - origin_global);
temp_LWH = R_global\([Xdata(3,:);Ydata(3,:);Zdata(3,:)] - origin_global);
temp_LWT = R_global\([Xdata(8,:);Ydata(8,:);Zdata(8,:)] - origin_global);
temp_LWC = R_global\([Xdata(9,:);Ydata(9,:);Zdata(9,:)] - origin_global);
temp_FLP = R_global\([Xdata(10,:);Ydata(10,:);Zdata(10,:)] - origin_global); % flower left
temp_FTP = R_global\([Xdata(11,:);Ydata(11,:);Zdata(11,:)] - origin_global); % flower top
temp_FRP = R_global\([Xdata(12,:);Ydata(12,:);Zdata(12,:)] - origin_global); % flower right
vectDown = mean(temp_abdomen,2) - mean(temp_head,2);
global_axis_x = [1;0;0];
global_axis_y = [0;1;0];
global_axis_z = [0;0;1];
origin_global = [0;0;0];

%% Calculate the coordinate axis of the frontal (coronal) plane
axis_x_FP_all = zeros(3,n_frames); % FP : frontal plane
axis_y_FP_all = zeros(3,n_frames);
axis_z_FP_all = zeros(3,n_frames);
axis_y_FP_all_temp = temp_RWH - temp_LWH;
% A: thorax
% B: right
% C: left
for i_frame = 1:n_frames
    axis_y_FP_all(:,i_frame) = normalizeVect(axis_y_FP_all_temp(:,i_frame));
    axis_z_FP_all(:,i_frame) = -normalizeVect(cross(temp_RWH(:,i_frame)-temp_thorax(:,i_frame),temp_LWH(:,i_frame)-temp_thorax(:,i_frame)));
    axis_x_FP_all(:,i_frame) = normalizeVect(cross(axis_y_FP_all(:,i_frame),axis_z_FP_all(:,i_frame)));
end

%% Calculate body roll, pitch and yaw rotations
psi_b = zeros(1,n_frames);
theta_b = zeros(1,n_frames);
phi_b = zeros(1,n_frames);
detR_b = zeros(1,n_frames);
errorR_b = zeros(1,n_frames);
for i_frame = 1:n_frames
    [psi_b(i_frame), theta_b(i_frame), phi_b(i_frame), detR_b(i_frame), errorR_b(i_frame)] = ...
        axes2rpyAngles([global_axis_x global_axis_y global_axis_z], [axis_x_FP_all(:,i_frame) axis_y_FP_all(:,i_frame) axis_z_FP_all(:,i_frame)]);
end
psi_b = unwrap(psi_b);
theta_b = unwrap(theta_b);
phi_b = unwrap(phi_b);
%% First, get estimate of the stroke plane in which wing kinematics are measured
%if ~useTransversePlane % use left and right stroke plane to measure wing kinematics
% undo body rotation to make stroke-plane fixed relative to the
% body-attached frame
temp_RWT_b = zeros(3,n_frames);
temp_RWC_b = zeros(3,n_frames);
temp_RWH_b = zeros(3,n_frames);
temp_LWT_b = zeros(3,n_frames);
temp_LWC_b = zeros(3,n_frames);
temp_LWH_b = zeros(3,n_frames);
if useBodyRelativeStrokePlane
    for i_frame = 1:n_frames
        R_cur = rpyRotMatrix(psi_b(i_frame),theta_b(i_frame),phi_b(i_frame));
        temp_RWT_b(:,i_frame) = R_cur\(temp_RWT(:,i_frame)-temp_thorax(:,i_frame));
        temp_RWC_b(:,i_frame) = R_cur\(temp_RWC(:,i_frame)-temp_thorax(:,i_frame));
        temp_RWH_b(:,i_frame) = R_cur\(temp_RWH(:,i_frame)-temp_thorax(:,i_frame));
        %
        temp_LWT_b(:,i_frame) = R_cur\(temp_LWT(:,i_frame)-temp_thorax(:,i_frame));
        temp_LWC_b(:,i_frame) = R_cur\(temp_LWC(:,i_frame)-temp_thorax(:,i_frame));
        temp_LWH_b(:,i_frame) = R_cur\(temp_LWH(:,i_frame)-temp_thorax(:,i_frame));
    end
else
    temp_RWT_b = temp_RWT;
    temp_RWC_b = temp_RWC;
    temp_RWH_b = temp_RWH;
    temp_LWT_b = temp_LWT;
    temp_LWC_b = temp_LWC;
    temp_LWH_b = temp_LWH;
end

% fit 3D lines to wing tip trajectories
[RWT_xFitData, RWT_yFitData, RWT_zFitData]= LineFit(temp_RWT_b(1,:)',temp_RWT_b(2,:)',temp_RWT_b(3,:)');
[LWT_xFitData, LWT_yFitData, LWT_zFitData]= LineFit(temp_LWT_b(1,:)',temp_LWT_b(2,:)',temp_LWT_b(3,:)');
SP_vect2 = mean(temp_RWH_b,2) - mean(temp_LWH_b,2); % projection of this vector on the stroke plane will be used as the y-axis of the stroke plane
% find vectors normal to the stroke plane, where the origin is the
% wing hinge point in each case. Wing hinge point is averaged to
% eliminate noise.
temp_spAxis_z_R = cross([RWT_xFitData(end);RWT_yFitData(end);RWT_zFitData(end)] - mean(temp_RWH_b,2), [RWT_xFitData(1);RWT_yFitData(1);RWT_zFitData(1)] - mean(temp_RWH_b,2));
temp_spAxis_z_L = cross([LWT_xFitData(end);LWT_yFitData(end);LWT_zFitData(end)] - mean(temp_LWH_b,2), [LWT_xFitData(1);LWT_yFitData(1);LWT_zFitData(1)] - mean(temp_LWH_b,2));
spAxis_z_R_b = normalizeVect(temp_spAxis_z_R*sign(temp_spAxis_z_R'*vectDown)); % right wing stroke plane normal (z) is in the ventral direction
spAxis_x_R_b = normalizeVect(cross(SP_vect2,spAxis_z_R_b)); % x axis is the cross product of the vector joining wing hinges and the stroke plane normal vector
spAxis_y_R_b = normalizeVect(cross(spAxis_z_R_b,spAxis_x_R_b)); % y axis is the projection of SP_vect2 on the stroke plane

spAxis_z_L_b = -normalizeVect(temp_spAxis_z_L*sign(temp_spAxis_z_L'*vectDown)); % left wing stroke plane normal (z) is in the dorsal direction
spAxis_x_L_b = normalizeVect(cross(SP_vect2,spAxis_z_L_b)); % x axis is the cross product of the vector joining wing hinges and the stroke plane normal vector
spAxis_y_L_b = normalizeVect(cross(spAxis_z_L_b,spAxis_x_L_b)); % y axis is the projection of SP_vect2 on the stroke plane

%else % use transverse body plane to measure wing kinematics
%% Second, also get estimate of the body transverse plane in which alternative wing kineamtics are measured
axis_x_FP_b = [1;0;0]; % FP : frontal plane in the body frame
axis_y_FP_b = [0;1;0];
axis_z_FP_b = [0;0;1];
% convert FP to TP (transverse plane) through 90 deg CW rotation about y axis
axis_x_TP_b = axis_z_FP_b;
axis_y_TP_b = axis_y_FP_b;
axis_z_TP_b = -axis_x_FP_b;

axis_TP_x_R_b = axis_x_TP_b;
axis_TP_y_R_b = axis_y_TP_b;
axis_TP_z_R_b = axis_z_TP_b;
% 
axis_TP_x_L_b = -axis_x_TP_b;
axis_TP_y_L_b = axis_y_TP_b;
axis_TP_z_L_b = -axis_z_TP_b;

[psi_sp_R, theta_sp_R, phi_sp_R, detR_sp_R, errorR_sp_R] = ...
    axes2rpyAngles([1 0 0; 0 1 0; 0 0 1], [spAxis_x_R_b spAxis_y_R_b spAxis_z_R_b]);
[psi_sp_L, theta_sp_L, phi_sp_L, detR_sp_L, errorR_sp_L] = ...
    axes2rpyAngles([-1 0 0; 0 1 0; 0 0 -1], [spAxis_x_L_b spAxis_y_L_b spAxis_z_L_b]);
%% Calculate wing kinematic angles

%RWT_rho = sqrt(sum((temp_RWT_b-temp_RWH_b).*(temp_RWT_b-temp_RWH_b),1));
RWT_rho = zeros(1,n_frames);
RWT_theta_SP = zeros(1,n_frames);
RWT_phi_SP = zeros(1,n_frames);
RWT_alpha_SP = zeros(1,n_frames);
RWT_theta_TP = zeros(1,n_frames);
RWT_phi_TP = zeros(1,n_frames);
RWT_alpha_TP = zeros(1,n_frames);

%LWT_rho = sqrt(sum((temp_LWT_b-temp_LWH_b).*(temp_LWT_b-temp_LWH_b),1));
LWT_rho = zeros(1,n_frames);
LWT_theta_SP = zeros(1,n_frames);
LWT_phi_SP = zeros(1,n_frames);
LWT_alpha_SP = zeros(1,n_frames);
LWT_theta_TP = zeros(1,n_frames);
LWT_phi_TP = zeros(1,n_frames);
LWT_alpha_TP = zeros(1,n_frames);

for i = 1:n_frames
    % right wing
    temp_RWT_sp = ((temp_RWT_b(:,i)-temp_RWH_b(:,i))'*[spAxis_x_R_b spAxis_y_R_b spAxis_z_R_b])';
    temp_RWC_sp = ((temp_RWC_b(:,i)-temp_RWH_b(:,i))'*[spAxis_x_R_b spAxis_y_R_b spAxis_z_R_b])';
    temp_RWT_sp_TP = ((temp_RWT_b(:,i) - temp_RWH_b(:,i))'*[axis_TP_x_R_b axis_TP_y_R_b axis_TP_z_R_b])';
    temp_RWC_sp_TP = ((temp_RWC_b(:,i) - temp_RWH_b(:,i))'*[axis_TP_x_R_b axis_TP_y_R_b axis_TP_z_R_b])';
    
    RWT_rho(i) = norm(temp_RWT_sp_TP);
    RWT_theta_SP(i) = asin(temp_RWT_sp(3)/RWT_rho(i)); % elevation angle
    RWT_phi_SP(i) = atan(-temp_RWT_sp(1)/temp_RWT_sp(2)); % azimuthal angle
    RWT_theta_TP(i) = asin(temp_RWT_sp_TP(3)/RWT_rho(i)); % elevation angle
    RWT_phi_TP(i) = atan(-temp_RWT_sp_TP(1)/temp_RWT_sp_TP(2)); % azimuthal angle

    % left wing
    temp_LWT_sp = ((temp_LWT_b(:,i)-temp_LWH_b(:,i))'*[spAxis_x_L_b spAxis_y_L_b spAxis_z_L_b])';
    temp_LWC_sp = ((temp_LWC_b(:,i)-temp_LWH_b(:,i))'*[spAxis_x_L_b spAxis_y_L_b spAxis_z_L_b])';
    temp_LWT_sp_TP = ((temp_LWT_b(:,i) - temp_LWH_b(:,i))'*[axis_TP_x_L_b axis_TP_y_L_b axis_TP_z_L_b])';
    temp_LWC_sp_TP = ((temp_LWC_b(:,i) - temp_LWH_b(:,i))'*[axis_TP_x_L_b axis_TP_y_L_b axis_TP_z_L_b])';
    
    LWT_rho(i) = norm(temp_LWT_sp_TP);
    LWT_theta_SP(i) = asin(-temp_LWT_sp(3)/LWT_rho(i)); % elevation angle
    LWT_phi_SP(i) = atan(-temp_LWT_sp(1)/temp_LWT_sp(2)); % azimuthal angle
    LWT_theta_TP(i) = asin(-temp_LWT_sp_TP(3)/LWT_rho(i)); % elevation angle
    LWT_phi_TP(i) = atan(-temp_LWT_sp_TP(1)/temp_LWT_sp_TP(2)); % azimuthal angle

    %%%% Calculate alpha (wing pitching angle) relative to stroke plane
    % 1. calculate the vector normal to the wing surface
    % 2. calculate x-axis and y-axis of the wing-attached frame
    % these axes are different from my BEM because in this case
    % xy-plane is the wing surface.
    % y-axis is in the direction of the weighted average of wingtip and
    % wing chord points
    temp_wingAxis_R_z = normalizeVect(cross(temp_RWT_sp,temp_RWC_sp));
    temp_wingAxis_R_y = normalizeVect(temp_RWT_sp);
    temp_wingAxis_R_x = normalizeVect(cross(temp_wingAxis_R_y,temp_wingAxis_R_z)); % trailing edge to leading edge vector
    % 3. rotate x-axis to undo phi and theta rotations
    temp2_wingAxis_R_x = w2b(RWT_phi_SP(i),RWT_theta_SP(i),0,0,0,0,0,temp_wingAxis_R_x,'inverseSP','R');
    RWT_alpha_SP(i) = -atan2(temp2_wingAxis_R_x(3),temp2_wingAxis_R_x(1));

    % repeat for the left wing
    temp_wingAxis_L_z = normalizeVect(cross(temp_LWT_sp,temp_LWC_sp));
    temp_wingAxis_L_y = normalizeVect(temp_LWT_sp);
    temp_wingAxis_L_x = normalizeVect(cross(temp_wingAxis_L_y,temp_wingAxis_L_z)); % trailing edge to leading edge vector
    temp2_wingAxis_L_x = w2b(LWT_phi_SP(i),LWT_theta_SP(i),0,0,0,0,0,temp_wingAxis_L_x,'inverseSP','L');
    LWT_alpha_SP(i) = -atan2(-temp2_wingAxis_L_x(3),-temp2_wingAxis_L_x(1));

    %%%% Calculate alpha (wing pitching angle) relative to transverse plane
    % 1. calculate the vector normal to the wing surface
    % 2. calculate x-axis and y-axis of the wing-attached frame
    % these axes are different from my BEM because in this case
    % xy-plane is the wing surface.
    % y-axis is in the direction of the weighted average of wingtip and
    % wing chord points
    temp_wingAxis_R_z = normalizeVect(cross(temp_RWT_sp_TP,temp_RWC_sp_TP));
    temp_wingAxis_R_y = normalizeVect(temp_RWT_sp_TP);
    temp_wingAxis_R_x = normalizeVect(cross(temp_wingAxis_R_y,temp_wingAxis_R_z)); % trailing edge to leading edge vector
    % 3. rotate x-axis to undo phi and theta rotations
    temp2_wingAxis_R_x = w2b(RWT_phi_TP(i),RWT_theta_TP(i),0,0,0,0,0,temp_wingAxis_R_x,'inverseSP','R');
    RWT_alpha_TP(i) = -atan2(temp2_wingAxis_R_x(3),temp2_wingAxis_R_x(1));

    % repeat for the left wing
    temp_wingAxis_L_z = normalizeVect(cross(temp_LWT_sp_TP,temp_LWC_sp_TP));
    temp_wingAxis_L_y = normalizeVect(temp_LWT_sp_TP);
    temp_wingAxis_L_x = normalizeVect(cross(temp_wingAxis_L_y,temp_wingAxis_L_z)); % trailing edge to leading edge vector
    temp2_wingAxis_L_x = w2b(LWT_phi_TP(i),LWT_theta_TP(i),0,0,0,0,0,temp_wingAxis_L_x,'inverseSP','L');
    LWT_alpha_TP(i) = -atan2(-temp2_wingAxis_L_x(3),-temp2_wingAxis_L_x(1));
end

% RWT_phi_SP = unwrap(RWT_phi_SP);
% RWT_theta_SP = unwrap(RWT_theta_SP);
%RWT_alpha_SP = unwrap(RWT_alpha_SP);
% RWT_phi_TP = unwrap(RWT_phi_TP);
% RWT_theta_TP = unwrap(RWT_theta_TP);
%RWT_alpha_TP = unwrap(RWT_alpha_TP);

% LWT_phi_SP = unwrap(LWT_phi_SP);
% LWT_theta_SP = unwrap(LWT_theta_SP);
% LWT_alpha_SP = unwrap(LWT_alpha_SP);
% LWT_phi_TP = unwrap(LWT_phi_TP);
% LWT_theta_TP = unwrap(LWT_theta_TP);
% LWT_alpha_TP = unwrap(LWT_alpha_TP);
%%
[peaks_R_SP,locs_R_SP] = findpeaks(RWT_phi_SP*180/pi);
[~,peak_inds_R_SP] = find(peaks_R_SP>10);
[peaks_L_SP,locs_L_SP] = findpeaks(LWT_phi_SP*180/pi);
[~,peak_inds_L_SP] = find(peaks_L_SP>10);
%
[peaks_R_TP,locs_R_TP] = findpeaks(RWT_phi_TP*180/pi);
[~,peak_inds_R_TP] = find(peaks_R_TP>10);
[peaks_L_TP,locs_L_TP] = findpeaks(LWT_phi_TP*180/pi);
[~,peak_inds_L_TP] = find(peaks_L_TP>10);
%
indices_R = 1:n_frames;
indices_L = indices_R;
if(drawPlots == 1)
    figure;
    sgtitle('Stroke plane frame');
    ax2 = subplot(212);hold on;
    plot(RWT_theta_SP(indices_R)*180/pi,'k-','linewidth',2);
    ylabel('Degrees');
    plot(RWT_phi_SP(indices_R)*180/pi,'b-','linewidth',2);
    plot(locs_R_SP(peak_inds_R_SP),peaks_R_SP(peak_inds_R_SP),'bo','linewidth',2,'HandleVisibility','off');
    plot(RWT_alpha_SP(indices_R)*180/pi,'r-','linewidth',2);
    grid on;
    legend('\theta','\phi','\alpha');
    title(strcat("Right: ",num2str(round(psi_sp_R*180/pi*10)/10),",",num2str(round(theta_sp_R*180/pi*10)/10),",",num2str(round(phi_sp_R*180/pi*10)/10)));
    xlim([indices_R(1) indices_R(end)]);
    hold off;
    ax1 = subplot(211);hold on;
    plot(LWT_theta_SP(indices_L)*180/pi,'k-','linewidth',2);
    ylabel('Degrees');
    plot(LWT_phi_SP(indices_L)*180/pi,'b-','linewidth',2);
    plot(locs_L_SP(peak_inds_L_SP),peaks_L_SP(peak_inds_L_SP),'bo','linewidth',2,'HandleVisibility','off');
    plot(LWT_alpha_SP(indices_L)*180/pi,'r-','linewidth',2);
    grid on;
    legend('\theta','\phi','\alpha');
    title(strcat("Left: ",num2str(round(psi_sp_L*180/pi*10)/10),",",num2str(round(theta_sp_L*180/pi*10)/10),",",num2str(round(phi_sp_L*180/pi*10)/10)));
    xlim([indices_L(1) indices_L(end)]);
    hold off;
    linkaxes([ax1,ax2],'xy');
    %
    figure;
    sgtitle('Transverse plane frame');
    ax2 = subplot(212);hold on;
    plot(RWT_theta_TP(indices_R)*180/pi,'k-','linewidth',2);
    ylabel('Degrees');
    plot(RWT_phi_TP(indices_R)*180/pi,'b-','linewidth',2);
    plot(locs_R_TP(peak_inds_R_TP),peaks_R_TP(peak_inds_R_TP),'bo','linewidth',2,'HandleVisibility','off');
    plot(RWT_alpha_TP(indices_R)*180/pi,'r-','linewidth',2);
    grid on;
    legend('\theta','\phi','\alpha');
    title(strcat("Right: ",num2str(round(psi_sp_R*180/pi*10)/10),",",num2str(round(theta_sp_R*180/pi*10)/10),",",num2str(round(phi_sp_R*180/pi*10)/10)));
    xlim([indices_R(1) indices_R(end)]);
    hold off;
    ax1 = subplot(211);hold on;
    plot(LWT_theta_TP(indices_L)*180/pi,'k-','linewidth',2);
    ylabel('Degrees');
    plot(LWT_phi_TP(indices_L)*180/pi,'b-','linewidth',2);
    plot(locs_L_TP(peak_inds_L_TP),peaks_L_TP(peak_inds_L_TP),'bo','linewidth',2,'HandleVisibility','off');
    plot(LWT_alpha_TP(indices_L)*180/pi,'r-','linewidth',2);
    grid on;
    legend('\theta','\phi','\alpha');
    title(strcat("Left: ",num2str(round(psi_sp_L*180/pi*10)/10),",",num2str(round(theta_sp_L*180/pi*10)/10),",",num2str(round(phi_sp_L*180/pi*10)/10)));
    xlim([indices_L(1) indices_L(end)]);
    hold off;
    linkaxes([ax1,ax2],'xy');
    %
    figure;
    subplot(211);
    plot(psi_b(indices_R)*180/pi,'k-','linewidth',2);
    hold on;
    ylabel('degrees');
    plot(theta_b(indices_R)*180/pi,'b-','linewidth',2);
    plot(phi_b(indices_R)*180/pi,'r-','linewidth',2);
    grid on;
    legend('\psi_b','\theta_b','\phi_b');
    title('Body angles');
    xlim([indices_R(1) indices_R(end)]);
    subplot(212);
    plot(errorR_b(indices_R),'r-','linewidth',2);hold on;
    plot(detR_b(indices_R),'b-','linewidth',2);
    xlim([indices_R(1) indices_R(end)]);
end
%% output data and shift by flower's mean position
outData.n_frames = n_frames;
outData.dt = dt;
outData.t = 0:dt:((n_frames-1)/rateFrame);
outData.pos_flower = 1/3*(temp_FLP + temp_FTP + temp_FRP);
%
outData.pos_head = temp_head;
outData.pos_thorax = temp_thorax;
outData.pos_abdomen = temp_abdomen;
outData.psi_b = psi_b; 
outData.theta_b = theta_b;
outData.phi_b = phi_b;
%
outData.pos_RWT = temp_RWT;
outData.pos_RWH = temp_RWH;
outData.pos_RWC = temp_RWC;
outData.pos_LWT = temp_LWT;
outData.pos_LWH = temp_LWH;
outData.pos_LWC = temp_LWC;
%
outData.gamma_roll_R = psi_sp_R; 
outData.gamma_R = theta_sp_R;
outData.gamma_roll_L = psi_sp_L; 
outData.gamma_L = theta_sp_L;
%
outData.phi_SP_R = RWT_phi_SP;
outData.phi_SP_L = LWT_phi_SP;
outData.alpha_SP_R = RWT_alpha_SP;
outData.alpha_SP_L = LWT_alpha_SP;
outData.theta_SP_R = RWT_theta_SP;
outData.theta_SP_L = LWT_theta_SP;
outData.ws_ends_SP_R = locs_R_SP(peak_inds_R_SP);
outData.ws_ends_SP_L = locs_L_SP(peak_inds_L_SP);
%
outData.phi_TP_R = RWT_phi_TP;
outData.phi_TP_L = LWT_phi_TP;
outData.alpha_TP_R = RWT_alpha_TP;
outData.alpha_TP_L = LWT_alpha_TP;
outData.theta_TP_R = RWT_theta_TP;
outData.theta_TP_L = LWT_theta_TP;
outData.ws_ends_TP_R = locs_R_TP(peak_inds_R_TP);
outData.ws_ends_TP_L = locs_L_TP(peak_inds_L_TP);
%% animation
if (runAnim == 1)
    N_sim = n_frames;
    figVideo = figure; hold on;
    for ii = 1:N_sim
        RWT_RWH = [temp_RWT(:,ii) temp_RWH(:,ii)];
        LWT_LWH = [temp_LWT(:,ii) temp_LWH(:,ii)];
        RWH_LWH = [temp_RWH(:,ii) temp_LWH(:,ii)];
        head_TAB = [temp_head(:,ii) temp_thorax(:,ii)];
        TAB_abd = [temp_thorax(:,ii) temp_abdomen(:,ii)];
        rightWingSurfX = [temp_RWT(1,ii) temp_RWC(1,ii) temp_RWH(1,ii)];
        rightWingSurfY = [temp_RWT(2,ii) temp_RWC(2,ii) temp_RWH(2,ii)];
        rightWingSurfZ = [temp_RWT(3,ii) temp_RWC(3,ii) temp_RWH(3,ii)];
        leftWingSurfX = [temp_LWT(1,ii) temp_LWC(1,ii) temp_LWH(1,ii)];
        leftWingSurfY = [temp_LWT(2,ii) temp_LWC(2,ii) temp_LWH(2,ii)];
        leftWingSurfZ = [temp_LWT(3,ii) temp_LWC(3,ii) temp_LWH(3,ii)];

        %%MOTH STICK FIGURE OF FIRST DIGITIZED POINT

        % plot stick vectors
        if ii == 1
            RWT_RWH_handle = line(RWT_RWH(1,:), RWT_RWH(2,:), RWT_RWH(3,:), 'color','b', 'linewidth',5);
            LWT_LWH_handle = line(LWT_LWH(1,:), LWT_LWH(2,:), LWT_LWH(3,:), 'color','b', 'linewidth',5);
            RWH_LWH_handle = line(RWH_LWH(1,:), RWH_LWH(2,:), RWH_LWH(3,:), 'color','y', 'linewidth',7);
            head_TAB_handle = line(head_TAB(1,:), head_TAB(2,:), head_TAB(3,:), 'color','k', 'linewidth',10);
            TAB_abd_handle = line(TAB_abd(1,:), TAB_abd(2,:), TAB_abd(3,:), 'color', 'k', 'linewidth',10);
            % Draw wing surface

            rightWingSurf_handle =  fill3(rightWingSurfX, rightWingSurfY, rightWingSurfZ,[0.5 0.5 0.5]);
            leftWingSurf_handle =  fill3(leftWingSurfX, leftWingSurfY, leftWingSurfZ,[0.5 0.5 0.5]);

            % plot ball points
            RWH_handle = plot3(temp_RWH(1,ii), temp_RWH(2,ii), temp_RWH(3,ii), 'r-o','markersize',8,'markerfacecolor','r');
            RWT_handle = plot3(temp_RWT(1,ii), temp_RWT(2,ii), temp_RWT(3,ii), 'b-o','markersize',8,'markerfacecolor','b');
            RWC_handle = plot3(temp_RWC(1,ii), temp_RWC(2,ii), temp_RWC(3,ii), 'b-o','markersize',8,'markerfacecolor','b');
            LWH_handle = plot3(temp_LWH(1,ii), temp_LWH(2,ii), temp_LWH(3,ii), 'r-o','markersize',8,'markerfacecolor','r');
            LWT_handle = plot3(temp_LWT(1,ii), temp_LWT(2,ii), temp_LWT(3,ii), 'b-o','markersize',8,'markerfacecolor','b');
            LWC_handle = plot3(temp_LWC(1,ii), temp_LWC(2,ii), temp_LWC(3,ii), 'b-o','markersize',8,'markerfacecolor','b');
            abd_handle = plot3(temp_abdomen(1,ii), temp_abdomen(2,ii), temp_abdomen(3,ii), 'm-o','markersize',8,'markerfacecolor','m');
            head_handle = plot3(temp_head(1,ii), temp_head(2,ii), temp_head(3,ii), 'g-o','markersize',8,'markerfacecolor','g');
            TAB_handle = plot3(temp_thorax(1,ii), temp_thorax(2,ii), temp_thorax(3,ii), 'k-o','markersize',10,'markerfacecolor','r');

            grid on;
            axis equal;
            axis([-50 70 -40 20 400 600]);
            view(0,90);
            camup([0 -1 0]);
            xlabel('x');ylabel('y');zlabel('z');

        else
            set(RWT_RWH_handle,'XDATA',RWT_RWH(1,:),'YDATA', RWT_RWH(2,:),'ZDATA', RWT_RWH(3,:));
            set(LWT_LWH_handle,'XDATA',LWT_LWH(1,:),'YDATA', LWT_LWH(2,:),'ZDATA', LWT_LWH(3,:));
            set(RWH_LWH_handle,'XDATA',RWH_LWH(1,:),'YDATA', RWH_LWH(2,:),'ZDATA', RWH_LWH(3,:));
            set(head_TAB_handle,'XDATA',head_TAB(1,:),'YDATA', head_TAB(2,:),'ZDATA', head_TAB(3,:));
            set(TAB_abd_handle,'XDATA',TAB_abd(1,:),'YDATA', TAB_abd(2,:),'ZDATA', TAB_abd(3,:));

            % Draw wing surfaces
            set(rightWingSurf_handle,'XDATA',rightWingSurfX,'YDATA', rightWingSurfY,'ZDATA', rightWingSurfZ);
            set(leftWingSurf_handle,'XDATA',leftWingSurfX,'YDATA', leftWingSurfY,'ZDATA', leftWingSurfZ);

            % plot ball points
            set(RWH_handle,'XDATA',temp_RWH(1,ii),'YDATA', temp_RWH(2,ii),'ZDATA', temp_RWH(3,ii));
            set(RWT_handle,'XDATA',temp_RWT(1,ii),'YDATA', temp_RWT(2,ii),'ZDATA', temp_RWT(3,ii));
            set(RWC_handle,'XDATA',temp_RWC(1,ii),'YDATA', temp_RWC(2,ii),'ZDATA', temp_RWC(3,ii));
            set(LWH_handle,'XDATA',temp_LWH(1,ii),'YDATA', temp_LWH(2,ii),'ZDATA', temp_LWH(3,ii));
            set(LWT_handle,'XDATA',temp_LWT(1,ii),'YDATA', temp_LWT(2,ii),'ZDATA', temp_LWT(3,ii));
            set(LWC_handle,'XDATA',temp_LWC(1,ii),'YDATA', temp_LWC(2,ii),'ZDATA', temp_LWC(3,ii));
            set(abd_handle,'XDATA',temp_abdomen(1,ii),'YDATA', temp_abdomen(2,ii),'ZDATA', temp_abdomen(3,ii));
            set(head_handle,'XDATA',temp_head(1,ii),'YDATA', temp_head(2,ii),'ZDATA', temp_head(3,ii));
            set(TAB_handle,'XDATA',temp_thorax(1,ii),'YDATA', temp_thorax(2,ii),'ZDATA', temp_thorax(3,ii));
        end
        videoFrames(ii) = getframe(gcf);
        %pause(0.1);
        drawnow();
    end
    writerObj = VideoWriter('video04.avi');
    writerObj.FrameRate = 10;
    % set the seconds per image
    % open the video writer
    open(writerObj);
    % write the frames to the video
    for i=1:length(videoFrames)
        % convert the image to a frame
        curFrame = videoFrames(i) ;
        writeVideo(writerObj, curFrame);
    end
    % close the writer object
    close(writerObj);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
