clear
folder_data_in = '..\data-in';
folder_data_out = '..\data-out'; % enter folder path 
file_cur = '2023-09-12_Msx118_000000_unfiltd.csv';
file_cur_plumbline = 'Plumblines\2023-09-12_Plumbline_117_3.csv';
rateSampling = 375;
rangeFrames = [1 12750]; % start and end (max) frame indices
totalTime = 34; % seconds
fileName = strcat(folder_data_in,'\',file_cur);
fileName_plumbline = strcat(folder_data_in,'\',file_cur_plumbline);
dataKinematics = extractWingKinematicsRL(fileName,fileName_plumbline,rangeFrames,totalTime,rateSampling,3,0,0);
condition = "sum-of-sines lateral";
n_wingstrokes_SP = length(dataKinematics.ws_ends_SP_R)-1;
n_wingstrokes_TP = length(dataKinematics.ws_ends_TP_R)-1;
n_wingstrokes = n_wingstrokes_TP;
t_total = dataKinematics.t(end);
save(strcat(folder_data_out,'\',file_cur(1:17),'.mat'),'dataKinematics','n_wingstrokes','t_total','rateSampling','condition');
%%
axis_label = ["x","y","z"];
figure;
sgtitle('Raw x, y and z plots');
for i = 1:3
    subplot(310+i);
    plot(dataKinematics.t,dataKinematics.pos_flower(i,:),'r');
    hold on;
    plot(dataKinematics.t,dataKinematics.pos_thorax(i,:),'b');
    ylabel(axis_label(i) + " pos (mm)");
    legend('flower','moth');
end

%% generate wingstroke-averaged data for SP frame
pos_head_SP_wsavg = zeros(3,n_wingstrokes_SP);
pos_thorax_SP_wsavg = zeros(3,n_wingstrokes_SP);
pos_abdomen_SP_wsavg = zeros(3,n_wingstrokes_SP);
pos_flower_SP_wsavg = zeros(3,n_wingstrokes_SP);
amp_phi_SP_R_wsavg = zeros(1,n_wingstrokes_SP);
mean_phi_SP_R_wsavg = zeros(1,n_wingstrokes_SP);
amp_alpha_SP_R_wsavg = zeros(1,n_wingstrokes_SP);
mean_alpha_SP_R_wsavg = zeros(1,n_wingstrokes_SP);
amp_theta_SP_R_wsavg = zeros(1,n_wingstrokes_SP);
mean_theta_SP_R_wsavg = zeros(1,n_wingstrokes_SP);

amp_phi_SP_L_wsavg = zeros(1,n_wingstrokes_SP);
mean_phi_SP_L_wsavg = zeros(1,n_wingstrokes_SP);
amp_alpha_SP_L_wsavg = zeros(1,n_wingstrokes_SP);
mean_alpha_SP_L_wsavg = zeros(1,n_wingstrokes_SP);
amp_theta_SP_L_wsavg = zeros(1,n_wingstrokes_SP);
mean_theta_SP_L_wsavg = zeros(1,n_wingstrokes_SP);

time_array_SP_R = zeros(1,n_wingstrokes_SP);
% wingstrokes are chunked based on right wing

for i = 1:n_wingstrokes_SP
    ind_1 = dataKinematics.ws_ends_SP_R(i);
    ind_2 = dataKinematics.ws_ends_SP_R(i+1);
    time_array_SP_R(i) = mean(dataKinematics.t(ind_1:ind_2)); % middle of a wingstroke
    pos_flower_SP_wsavg(:,i) = mean(dataKinematics.pos_flower(:,ind_1:ind_2),2);
    pos_head_SP_wsavg(:,i) = mean(dataKinematics.pos_head(:,ind_1:ind_2),2);
    pos_thorax_SP_wsavg(:,i) = mean(dataKinematics.pos_thorax(:,ind_1:ind_2),2);
    pos_abdomen_SP_wsavg(:,i) = mean(dataKinematics.pos_abdomen(:,ind_1:ind_2),2);
    mean_phi_SP_R_wsavg(:,i) = mean(dataKinematics.phi_SP_R(:,ind_1:ind_2),2);
    mean_alpha_SP_R_wsavg(:,i) = mean(dataKinematics.alpha_SP_R(:,ind_1:ind_2),2);
    mean_theta_SP_R_wsavg(:,i) = mean(dataKinematics.theta_SP_R(:,ind_1:ind_2),2);
    amp_phi_SP_R_wsavg(:,i) = max(dataKinematics.phi_SP_R(ind_1:ind_2)) - min(dataKinematics.phi_SP_R(ind_1:ind_2));
    amp_alpha_SP_R_wsavg(:,i) = max(dataKinematics.alpha_SP_R(ind_1:ind_2)) - min(dataKinematics.alpha_SP_R(ind_1:ind_2));
    amp_theta_SP_R_wsavg(:,i) = max(dataKinematics.theta_SP_R(ind_1:ind_2)) - min(dataKinematics.theta_SP_R(ind_1:ind_2));
    mean_phi_SP_L_wsavg(:,i) = mean(dataKinematics.phi_SP_L(:,ind_1:ind_2),2);
    mean_alpha_SP_L_wsavg(:,i) = mean(dataKinematics.alpha_SP_L(:,ind_1:ind_2),2);
    mean_theta_SP_L_wsavg(:,i) = mean(dataKinematics.theta_SP_L(:,ind_1:ind_2),2);
    amp_phi_SP_L_wsavg(:,i) = max(dataKinematics.phi_SP_L(ind_1:ind_2)) - min(dataKinematics.phi_SP_L(ind_1:ind_2));
    amp_alpha_SP_L_wsavg(:,i) = max(dataKinematics.alpha_SP_L(ind_1:ind_2)) - min(dataKinematics.alpha_SP_L(ind_1:ind_2));
    amp_theta_SP_L_wsavg(:,i) = max(dataKinematics.theta_SP_L(ind_1:ind_2)) - min(dataKinematics.theta_SP_L(ind_1:ind_2));
end
figure;
time_period_data = time_array_SP_R(1:end)-[0 time_array_SP_R(1:end-1)];
plot(time_period_data,'o');
xlim([0 n_wingstrokes_SP]);
ylabel('time periods (s)');ylim([0 max(time_period_data)*1.2]);grid on;
figure;
for i = 1:3
    subplot(310+i);
    plot(time_array_SP_R,pos_flower_SP_wsavg(i,:),'ko');
    hold on;
    plot(time_array_SP_R,pos_head_SP_wsavg(i,:),'bo');
    plot(time_array_SP_R,pos_thorax_SP_wsavg(i,:),'ro');
    plot(time_array_SP_R,pos_abdomen_SP_wsavg(i,:),'mo');
    xlabel("time (s)");
    legend('flower','head','thorax','abdomen');
    grid on;
end
%
figure;
sgtitle('Stroke plane frame');
title('Right wing');
subplot(211);
plot(time_array_SP_R,amp_phi_SP_R_wsavg*180/pi,'bo');
hold on;
plot(time_array_SP_R,amp_alpha_SP_R_wsavg*180/pi,'ro');
plot(time_array_SP_R,amp_theta_SP_R_wsavg*180/pi,'ko');
legend('amp phi','amp alpha','amp theta');
grid on;
subplot(212);
plot(time_array_SP_R,mean_phi_SP_R_wsavg*180/pi,'bo');
hold on;
plot(time_array_SP_R,mean_alpha_SP_R_wsavg*180/pi,'ro');
plot(time_array_SP_R,mean_theta_SP_R_wsavg*180/pi,'ko');
legend('mean phi','mean alpha','mean theta');
grid on;
%
figure;
sgtitle('Stroke plane frame');
title('Left wing')
subplot(211);
plot(time_array_SP_R,amp_phi_SP_L_wsavg*180/pi,'bo');
hold on;
plot(time_array_SP_R,amp_alpha_SP_L_wsavg*180/pi,'ro');
plot(time_array_SP_R,amp_theta_SP_L_wsavg*180/pi,'ko');
legend('amp phi','amp alpha','amp theta');
grid on;
subplot(212);
plot(time_array_SP_R,mean_phi_SP_L_wsavg*180/pi,'bo');
hold on;
plot(time_array_SP_R,mean_alpha_SP_L_wsavg*180/pi,'ro');
plot(time_array_SP_R,mean_theta_SP_L_wsavg*180/pi,'ko');
legend('mean phi','mean alpha','mean theta');
grid on;

%% generate wingstroke-averaged data for TP frame
pos_head_TP_wsavg = zeros(3,n_wingstrokes_TP);
pos_thorax_TP_wsavg = zeros(3,n_wingstrokes_TP);
pos_abdomen_TP_wsavg = zeros(3,n_wingstrokes_TP);
pos_flower_TP_wsavg = zeros(3,n_wingstrokes_TP);
amp_phi_TP_R_wsavg = zeros(1,n_wingstrokes_TP);
mean_phi_TP_R_wsavg = zeros(3,n_wingstrokes_TP);
amp_alpha_TP_R_wsavg = zeros(3,n_wingstrokes_TP);
mean_alpha_TP_R_wsavg = zeros(3,n_wingstrokes_TP);
amp_theta_TP_R_wsavg = zeros(3,n_wingstrokes_TP);
mean_theta_TP_R_wsavg = zeros(3,n_wingstrokes_TP);

amp_phi_TP_L_wsavg = zeros(3,n_wingstrokes_TP);
mean_phi_TP_L_wsavg = zeros(3,n_wingstrokes_TP);
amp_alpha_TP_L_wsavg = zeros(3,n_wingstrokes_TP);
mean_alpha_TP_L_wsavg = zeros(3,n_wingstrokes_TP);
amp_theta_TP_L_wsavg = zeros(3,n_wingstrokes_TP);
mean_theta_TP_L_wsavg = zeros(3,n_wingstrokes_TP);

time_array_TP_R = zeros(1,n_wingstrokes_TP);
% wingstrokes are chunked based on right wing

for i = 1:n_wingstrokes_TP
    ind_1 = dataKinematics.ws_ends_TP_R(i);
    ind_2 = dataKinematics.ws_ends_TP_R(i+1);
    time_array_TP_R(i) = mean(dataKinematics.t(ind_1:ind_2)); % middle of a wingstroke
    pos_flower_TP_wsavg(:,i) = mean(dataKinematics.pos_flower(:,ind_1:ind_2),2);
    pos_head_TP_wsavg(:,i) = mean(dataKinematics.pos_head(:,ind_1:ind_2),2);
    pos_thorax_TP_wsavg(:,i) = mean(dataKinematics.pos_thorax(:,ind_1:ind_2),2);
    pos_abdomen_TP_wsavg(:,i) = mean(dataKinematics.pos_abdomen(:,ind_1:ind_2),2);
    mean_phi_TP_R_wsavg(:,i) = mean(dataKinematics.phi_TP_R(:,ind_1:ind_2),2);
    mean_alpha_TP_R_wsavg(:,i) = mean(dataKinematics.alpha_TP_R(:,ind_1:ind_2),2);
    mean_theta_TP_R_wsavg(:,i) = mean(dataKinematics.theta_TP_R(:,ind_1:ind_2),2);
    amp_phi_TP_R_wsavg(:,i) = max(dataKinematics.phi_TP_R(ind_1:ind_2)) - min(dataKinematics.phi_TP_R(ind_1:ind_2));
    amp_alpha_TP_R_wsavg(:,i) = max(dataKinematics.alpha_TP_R(ind_1:ind_2)) - min(dataKinematics.alpha_TP_R(ind_1:ind_2));
    amp_theta_TP_R_wsavg(:,i) = max(dataKinematics.theta_TP_R(ind_1:ind_2)) - min(dataKinematics.theta_TP_R(ind_1:ind_2));
    mean_phi_TP_L_wsavg(:,i) = mean(dataKinematics.phi_TP_L(:,ind_1:ind_2),2);
    mean_alpha_TP_L_wsavg(:,i) = mean(dataKinematics.alpha_TP_L(:,ind_1:ind_2),2);
    mean_theta_TP_L_wsavg(:,i) = mean(dataKinematics.theta_TP_L(:,ind_1:ind_2),2);
    amp_phi_TP_L_wsavg(:,i) = max(dataKinematics.phi_TP_L(ind_1:ind_2)) - min(dataKinematics.phi_TP_L(ind_1:ind_2));
    amp_alpha_TP_L_wsavg(:,i) = max(dataKinematics.alpha_TP_L(ind_1:ind_2)) - min(dataKinematics.alpha_TP_L(ind_1:ind_2));
    amp_theta_TP_L_wsavg(:,i) = max(dataKinematics.theta_TP_L(ind_1:ind_2)) - min(dataKinematics.theta_TP_L(ind_1:ind_2));
end
figure;
time_period_data = time_array_TP_R(1:end)-[0 time_array_TP_R(1:end-1)];
plot(time_period_data,'o');
xlim([0 n_wingstrokes_TP]);
ylabel('time periods (s)');ylim([0 max(time_period_data)*1.2]);grid on;
figure;
for i = 1:3
    subplot(310+i);
    plot(time_array_TP_R,pos_flower_TP_wsavg(i,:),'ko');
    hold on;
    plot(time_array_TP_R,pos_head_TP_wsavg(i,:),'bo');
    plot(time_array_TP_R,pos_thorax_TP_wsavg(i,:),'ro');
    plot(time_array_TP_R,pos_abdomen_TP_wsavg(i,:),'mo');
    xlabel("time (s)");
    legend('flower','head','thorax','abdomen');
    grid on;
end
%
figure;
sgtitle('Transverse plane frame');
title('Right wing');
subplot(211);
plot(time_array_TP_R,amp_phi_TP_R_wsavg*180/pi,'bo');
hold on;
plot(time_array_TP_R,amp_alpha_TP_R_wsavg*180/pi,'ro');
plot(time_array_TP_R,amp_theta_TP_R_wsavg*180/pi,'ko');
legend('amp phi','amp alpha','amp theta');
grid on;
subplot(212);
plot(time_array_TP_R,mean_phi_TP_R_wsavg*180/pi,'bo');
hold on;
plot(time_array_TP_R,mean_alpha_TP_R_wsavg*180/pi,'ro');
plot(time_array_TP_R,mean_theta_TP_R_wsavg*180/pi,'ko');
legend('mean phi','mean alpha','mean theta');
grid on;
%
figure;
sgtitle('Transverse plane frame');
title('Left wing')
subplot(211);
plot(time_array_TP_R,amp_phi_TP_L_wsavg*180/pi,'bo');
hold on;
plot(time_array_TP_R,amp_alpha_TP_L_wsavg*180/pi,'ro');
plot(time_array_TP_R,amp_theta_TP_L_wsavg*180/pi,'ko');
legend('amp phi','amp alpha','amp theta');
grid on;
subplot(212);
plot(time_array_TP_R,mean_phi_TP_L_wsavg*180/pi,'bo');
hold on;
plot(time_array_TP_R,mean_alpha_TP_L_wsavg*180/pi,'ro');
plot(time_array_TP_R,mean_theta_TP_L_wsavg*180/pi,'ko');
legend('mean phi','mean alpha','mean theta');
grid on;
%% make big data X and U matrices
% X: head, thorax, abdomen, amp phi R, mean phi R, amp alpha R, mean alpha R,
%    amp theta R, mean theta R, amp phi L, mean phi L, amp alpha L, mean alpha L,
%    amp theta L, mean theta L  (3x3 + 6 x 2 = 21 states)
% U : flower (3 x 1 = 3 states)
time_array = time_array_TP_R;
X = [pos_head_SP_wsavg;pos_thorax_SP_wsavg;pos_abdomen_SP_wsavg; amp_phi_SP_R_wsavg;...
    mean_phi_SP_R_wsavg; amp_alpha_SP_R_wsavg; mean_alpha_SP_R_wsavg; amp_theta_SP_R_wsavg;...
    mean_theta_SP_R_wsavg; amp_phi_SP_L_wsavg; mean_phi_SP_L_wsavg; amp_alpha_SP_L_wsavg;...
    mean_alpha_SP_L_wsavg; amp_theta_SP_L_wsavg;mean_theta_SP_L_wsavg];
U = pos_flower_SP_wsavg;
%save(strcat(file_cur(1:end-4),'.mat'),'X','U','time_array');