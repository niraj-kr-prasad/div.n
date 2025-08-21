%stratification.m
clear
close all
delete(instrfindall); % Use this if the ports get stuck

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
macORpc = 'pc'; % 'mac' or 'pc' 
portNumber = 10; % COM port number on pc, port index on mac
a1 = 10.41;%Motor acceleration and decceleration value
v1 = 5;%Motor Constant velocity
vartime = [];%array to store the time values corresponding to the conductivity readings above threshold value
recordtime = []; %array that will start the time counter based on vartime
%d1 = [];%array to store the distance travelled by rig during accelaration
d2 = [];%array to store the distance travelled by rig with constant velocity
d3 = [];%array to store the distance travelled by rig during decceleration
d = [];%array to store the total distance travelled by rig
cht = [];%array to store the conductivity readings above threshold value
chf = [];%array to store the the first half of the conductivity readings above threshold value
th = [];%array to store the the time corresponding to the first half of the conductivity readings above threshold value
thf = [];%array that will start time counter based on th[]
%t1 = [];
t2 = [];%array to store the thf[] values when rig travels with constant velocityc
t3 = [];%array to store the thf[] when rig travels during deceleration
t = []; %array to store the t2[] and t3[] values
h = []; %array to store to convert the distance values from d[] to height starting from 40 cm
%htf = [];
C = [];%array that will store the values of the conductivity readings based on distance travelled by rig
rho = [];%array that will store the vdensity readings corresponding to the conductivity readings values from C[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%assigns the object s to serial port
switch macORpc
    case 'pc'
        s1 = serial(['COM' num2str(portNumber)]); % for PC
    otherwise
        s = seriallist;
        disp(['Using port ' s(portNumber) ])
        s1 = serial(s(portNumber)); % for mac
end

set(s1, 'InputBufferSize', 128); %number of bytes in inout buffer
set(s1, 'BaudRate', 115200);
set(s1, 'Parity', 'none');
fopen(s1);
clc
prompt = 'How many samples? (dt ~40 ms typically) ';
nSamples=input(prompt,'s');
fprintf(s1,'%c',nSamples);
nSamples = str2double(nSamples);
ch1=zeros(0,nSamples);
ch2=zeros(0,nSamples);
ch3=zeros(0,nSamples);
ch4=zeros(0,nSamples);

tic
fwrite(s1, '%f'); 
for nSample=1:nSamples
    ch1(nSample)= fscanf(s1, '%f');
    ch2(nSample)= fscanf(s1, '%f');
    ch3(nSample)= fscanf(s1, '%f');
    ch4(nSample)= fscanf(s1, '%f');
end
timeElapsed = toc;
fclose(s1);

dt = timeElapsed/(nSamples-1);
disp(['Actual dt = ' num2str(round(dt*1e3)) ' ms'])
time = 0:dt:(nSamples-1)*dt;

for i = 1:length(time) %loop for storing conductivity readings above threshold value and the corresponding time
    if ch1(i) > 3.1 %threshold need to be confirmed from Figure1
        vartime = [vartime, time(i)];%it stores the succesive values of vartime
        recordtime = [vartime - vartime(1)];%it stores the succesive values of recordtime
        cht = [cht, ch1(i)];%it stores the succesive values of conductivity readings
    end
    
end
 halflength = floor(length(cht)/2); %code to store the first half of the conductivity readings and the corresponding vartime
chf = cht(1:halflength);
th = vartime(1:halflength);
for j = 1:length(th)
    %thf = [thf, th(j)-th(1) + 0.516];%code to store the successive values of thf
    thf = [thf, th(j)-th(1)];%code to store the successive values of thf
end
  ti = thf(end)/10;%the rig moves with deceleration for time ti.
%*if initial acceleration period is considered then this portion of the code
%can be used, in the present setup the readings collected by probes are filtered out during the acceleartion period, thus the acceleration period of the motor is not considered*

 %startTime =thf(1);%loop starts from initial value of thf
 %endTime = ti;%loop ends at time when rig travelled with constant velocity
 %maxIter = 13;
 %i = 1;% starting loop counter
 %while thf(i) >= startTime && thf(i) <= endTime %loop will run during the constant velocity run of rig
        %d1 = [d1, thf(i)*thf(i)*a1*0.5];
        %t1 = [t1, thf(i)];
        %i = i + 1;%distance calculation based on constant velocity, the threshold conductivity reading starts after rig travelled a distance of 1.27 cm
 %end

 % Portion of the code to calculate the distance travelled by rig during
 % the constant velocity
 startTime = thf(1);%loop starts from initial value of thf
 endTime = 9*ti;%loop ends at time when rig travelled with constant velocity
 %maxIter = 13;
 i = 1;% starting loop counter
 while thf(i) >= startTime && thf(i) < endTime %loop will run during the constant velocity run of rig
        d2 = [d2, 1.2 + (thf(i)-thf(1))*v1];%distance calculation based on constant velocity, the threshold conductivity reading starts after rig travelled a distance of 1.2 cm
        t2 = [t2, thf(i)];
        i = i + 1;
 end
 % Portion of the code to calculate the distance travelled by rig during
 % the deceleration of the motor

 startTime = 9*ti;%loop starts from  value of thf when rig starts movement with constant deceleration
 endTime = 10*ti;%loop ends when rig completes first half of the travel.
 %maxIter = 13;
 i = i(end);%loop starts counter right after the previous loop counter ends
 while thf(i) >= startTime && thf(i) < endTime %loop during the deceleration run of rig
          d3 = [d3, d2(end) + (thf(i)-t2(end))*v1 - (thf(i)-t2(end))*(thf(i)-t2(end))*0.5*a1];
          t3 = [t3, thf(i)];% distance calculation during deceleration run of rig
        i = i + 1;
 end
  d = [d2 d3];
 startTime = thf(1); %loop to filter the conductivity reading values based on distance calculation
 endTime = t3(end);%the end time should be taken from the t3[] in order to remove any error arising due to data trimming
 %maxIter = 13;
 j = 1;
 while thf(j) >= startTime && thf(j) <= endTime
          C = [C, chf(j)];
          h = [h, (41.2 - d(j))]; %it will convert the rig travel distnace to the height moved by rig in the tank starting from 40 cm
        j = j + 1;
 end
 t = [t2 t3]; % array to store time values from thf[] with size equal to C[];
 startTime = thf(1); %loop to convert the conductivity reading to the corresponding density values
 endTime = t3(end);%the end time should be taken from the t3[] in order to remove any error arising due to data trimming
 %maxIter = 13;
 k = 1;
 while thf(k) >= startTime && thf(k) <= endTime
          rho = [rho, (1025 + ((C(k) - C(1))/(C(end) - C(1)))*25)];%linear interpolation of data for converting conductivity readings to the corresponding density values
        k = k + 1;
 end
%the portion of the code makes the plot smooth and after that plot tangent, it can be used when there
%is noise in the statification data.
%the portion of code is not required if any additional image processing
%code is being used to draw tanget.
rho_smooth = smoothdata(rho, 'sgolay', 15);
dh = gradient(h,rho_smooth);
d2h = gradient(dh, rho_smooth);
% it will detect the index of the point where tangent to be drawn
idx_inflect = find(diff(sign(d2h))); % it will detect the index of the point where tangent to be drawn
 
%dh = gradient(h,rho);
%d2h = gradient(dh, rho);
% Choose the index of the point where you want the tangent
%idx_inflect = find(diff(sign(d2h))); % Change this index as needed (between 2 and length(x)-1)



plot(ch1);% Plots the total number of samples (figure1)
hold on;
plot(ch2);
plot(ch3);
plot(ch4);
grid on
xlabel('Sample')
ylabel('Reading')

%figure
%plot(time,ch1);%Plots the channel 1 values
%hold on;
%plot(time,ch2);
%plot(time,ch3);
%plot(time,ch4);
%grid on
%xlabel('time, (s)')
%ylabel('Reading')
%legend('ch1', 'ch2', 'ch3', 'ch4')
%pp=axis;
%axis([0 20 0 4])



figure
plot(rho,h);%plots the variation of density with the height
hold on;
%hold on;
%plot(time,ch2);
%plot(time,ch3);
%plot(time,ch4);
grid on
xlabel('Density (kg/m^3)')
ylabel('Height')
%legend('ch1', 'ch2', 'ch3', 'ch4')
pp=axis;
axis([1000 1060 10 50])


figure
plot(rho_smooth,h);%plots the variation of smoothed density with the height
hold on;
%plot(time,ch2);
%plot(time,ch3);
%plot(time,ch4);
grid on
for n = 1:length(idx_inflect)%plots the tangent in the same figure
    i0 = idx_inflect(n);
    rho0 = rho_smooth(i0);
    h0 = h(i0);
    slope = dh(i0);

    tan_rho = linspace(rho0 - 0.5, rho0 + 0.5, 100);
    tan_h = h0 + slope*(tan_rho - rho0);
    %plot(rho0, h0);
    %plot(rho0, h0, 'ro', 'MarkerSize', 8, 'LineWidth', 2);
    %plot(tan_rho, tan_h, 'r--', 'Linewidth', 1.5);
    plot(tan_rho, tan_h);
    %plot([min(rho) max(rho)], [h0 h0]); %plots and horizontal line through
    %the tangent point.
    
end
xlabel('Density (kg/m^3)')
ylabel('Height')
%legend('ch1', 'ch2', 'ch3', 'ch4')
pp=axis;
axis([1000 1060 10 50])
