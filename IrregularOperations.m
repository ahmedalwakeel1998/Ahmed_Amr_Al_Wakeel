% Irregular Operations

clear
clc

format long
% Load Flight Schedule and count number of airports
FS=readtable('IrrFlightSchedule.xlsx','sheet',1);
for i=1:size(FS,1)
    basetimef=FS{i,5}*1440;
    [a,b]=quorem(sym(basetimef),sym(60));
    mtime=100*a+b;
    FS{i,5}=double(mtime);
    basetimef=FS{i,6}*1440;
    [a,b]=quorem(sym(basetimef),sym(60));
    mtime=100*a+b;
    FS{i,6}=double(mtime);
end

Airports=vertcat(FS{:,3},FS{:,4});
Airports=unique(Airports);
RON=[];

for i=size(Airports)
    RON(i)=0;
end

% Prompt the User for the time of day, aircraft that is out of service,
% Turnaroud time
Time=input('Enter the current time of day: ','s');
md=100;
Time1=datetime(Time,'InputFormat','HH:mm');
basetime1=hour(Time1)*60+minute(Time1);
[a,b]=quorem(sym(basetime1),sym(60));
mtime=100*a+b;
Time=double(mtime);

basetime2=2400;
minutes2=mod(basetime2,md);
hr2=(basetime2-minutes2)/md;
basetime2=hr2*60+minutes2;

TRT=input('Enter required Turn Around Time: ');

% Filter the flight schedule for remaining flights, calculate the starting
% nodes from the completed flights
FSR=FS(FS{:,5}>Time,:);
AircraftID=table2array(FSR(:,1));
AircraftCount=unique(AircraftID);
FlightID=table2array(FSR(:,2));
Origin=FSR{:,3};
Dest=FSR{:,4};
Dep=table2array(FSR(:,5));
Arr=table2array(FSR(:,6));
Cancel=table2array(FSR(:,7));
Delay=table2array(FSR(:,8));
AircraftSchedule=[];
End=[];

% Find the ending node required to go back to schedule the next day
for i=1:size(AircraftCount)
    AircraftSchedule=FS(FS{:,1}==AircraftCount(i),:);
    Last(i)=max(AircraftSchedule{:,6});
    End{i}=table2cell(AircraftSchedule(AircraftSchedule{:,6}==Last(i),4));
end

for i=1:size(Airports)
    for j=1:size(End,2)
        if strcmp(Airports(i),End{j})==1
            RON(i)=RON(i)+1;
        end
    end
end

StartTime=[];
StartAirport=[];

OutOfService=input('Enter ID of out of service aircraft: ');
Loc=input('Enter the location of out of service aircraft: ','s');
Back=input('Will the aircraft be operational again? (1 for yes, 0 for no) ');


% Find Location of current functioning aircrafts
for i=1:size(AircraftCount,1);
    AFS=FS(FS{:,1}==AircraftCount(i),:);
    AFS=AFS(AFS{:,5}<Time,:);
    if size(AFS,1)~=0
        time1=table2array(AFS(size(AFS,1),6));
        minutes1=mod(time1,md);
        hr1=(time1-minutes1)/md;
        basetime1=hr1*60+minutes1;
        StartTime(i)=basetime1+TRT;
        StartAirport{i}=AFS{size(AFS,1),4};
    else
        StartTime(i)=Time;
        a=FS(FS{:,1}==AircraftCount(i),3);
        StartAirport{i}=table2cell(a(1,1));
    end
end

if Back==1
    bTime=input('Enter the start time for out of service aircraft: ','s');
    md=100;
    bTime1=datetime(bTime,'InputFormat','HH:mm');
    basetime1=hour(bTime1)*60+minute(bTime1);
    [a,b]=quorem(sym(basetime1),sym(60));
    mtime=100*a+b;
    bTime=double(mtime);
    StartTime(OutOfService)=bTime;
    StartAirport{OutOfService}=Loc;
else
    for i=1:size(Airports)
        if strcmp(Loc,Airports(i))==1
            RON(i)=RON(i)-1;
        end
    end
end

% ROUTE GENERATION

% For each of the remaining aircraft, specific routes will be generated
% based on the starting nodes and time of availability of the aircraft
% without duplication of flights or exceeding maximum flight hours
% The delay costs, RON airports are calculated for all routes and each
% route is linked to its designated aircraft

OneRoutes=zeros(1,10);
s=zeros(size(AircraftCount,1)+1,1);
k1=0;
RC=1;
RAC=[];
Del=[];
SN=[];
RDur=[];
RF=[];

% One flight per day routes

for i=1:size(AircraftCount,1)
    if i~=OutOfService || Back==1
        for j=1:size(FSR,1)
            Dur=FSR{j,9};
            time2=StartTime(i);
            minutes2=mod(time2,md);
            hr2=(time2-minutes2)/md;
            basetime2=hr2*60+minutes2+TRT;
            Dur=Dur+basetime2;
            if strcmp(StartAirport{i},FSR{j,3})==1 && Dur <=1470
                time1=FSR{j,5};
                minutes1=mod(time1,md);
                hr1=(time1-minutes1)/md;
                basetime1=hr1*60+minutes1;
                time2=StartTime(i);
                minutes2=mod(time2,md);
                hr2=(time2-minutes2)/md;
                basetime2=hr2*60+minutes2;
                basetime3=FSR{j,9};
                if basetime2 > basetime1
                    RF{RC}(1,:)=FSR(j,2:6);
                    Del(RC,1)=(basetime2-basetime1)*Delay(j);
                    RDur(RC,1)=basetime2+basetime3;
                    basetimef=basetime2;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(1,4)=array2table(double(mtime));
                    basetimef=basetime2+basetime3;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(1,5)=array2table(double(mtime));
                else
                    RF{RC}(1,:)=FSR(j,2:6);
                    basetimef=basetime1;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(1,4)=array2table(double(mtime));
                    basetimef=basetime1+basetime3;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(1,5)=array2table(double(mtime));
                    Del(RC,1)=0;
                    RDur(RC,1)=basetime1+basetime3;
                end
                k1=k1+1;
                OneRoutes(k1,1)=j;
                s(i+1)=s(i+1)+1;
                SN{RC,1}=FSR{j,4};
                RAC(RC,1)=i;
                RC=RC+1;
            end
        end
    end
end

% Multiple flight per day routes (routes are checked for duplication of
% flight and the maximum service hours)

TwoRoutes=zeros(1,10);
k2=0;
if OneRoutes(1,1)~=0
    
    for j=1:size(OneRoutes,1)
        for m=1:size(FSR,1)
            Dur1=RDur(j,1)+TRT;
            Dur=Dur1+FSR{m,9};
            if strcmp(FSR{OneRoutes(j,1),4},FSR{m,3})==1 && OneRoutes(j,1)~=m && Dur<=1470
                time1=FSR{m,5};
                minutes1=mod(time1,md);
                hr1=(time1-minutes1)/md;
                basetime1=hr1*60+minutes1;
                basetime2=RDur(j)+TRT;
                basetime3=FSR{m,9};
                RF{RC}=RF{j};
                RF{RC}(2,:)=FSR(m,2:6);
                if basetime2 > basetime1
                    Del(RC,1)=(basetime2-basetime1)*Delay(m)+Del(j);
                    RDur(RC,1)=basetime2+basetime3;
                    basetimef=basetime2;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(2,4)=array2table(double(mtime));
                    basetimef=basetime2+basetime3;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(2,5)=array2table(double(mtime));
                else
                    basetimef=basetime1;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(2,4)=array2table(double(mtime));
                    basetimef=basetime1+basetime3;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(2,5)=array2table(double(mtime));
                    Del(RC,1)=Del(j);
                    RDur(RC,1)=basetime1+basetime3;
                end
                k2=k2+1;
                TwoRoutes(k2,1)=OneRoutes(j);
                TwoRoutes(k2,2)=m;
                SN{RC,1}=FSR{j,4};
                RAC(RC,1)=RAC(j);
                RC=RC+1;
            end
        end
    end
end

ThreeRoutes=zeros(1,10);
k3=0;

if TwoRoutes(1,1)~=0
    for j=1:size(TwoRoutes,1)
        for m=1:size(FSR,1)
            Dur1=RDur(k1+j)+TRT;
            Dur=Dur1+FSR{m,9};
            if strcmp(FSR{TwoRoutes(j,2),4},FSR{m,3})==1 && ismember(m,TwoRoutes(j,:))==0 && Dur<=1470
                RF{RC}(1:2,:)=RF{k1+j}(1:2,:);
                time1=FSR{m,5};
                minutes1=mod(time1,md);
                hr1=(time1-minutes1)/md;
                basetime1=hr1*60+minutes1;
                basetime2=Dur1;
                basetime3=FSR{m,9};
                RF{RC}(3,:)=FSR(m,2:6);
                if basetime2 > basetime1
                    Del(RC,1)=(basetime2-basetime1)*Delay(m)+Del(k1+j);
                    RDur(RC,1)=basetime2+basetime3;
                    basetimef=basetime2;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(3,4)=array2table(double(mtime));
                    basetimef=basetime2+basetime3;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(3,5)=array2table(double(mtime));
                else
                    Del(RC,1)=Del(k1+j);
                    basetimef=basetime1;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(3,4)=array2table(double(mtime));
                    basetimef=basetime1+basetime3;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(3,5)=array2table(double(mtime));
                    RDur(RC,1)=basetime1+basetime3;
                end
                k3=k3+1;
                ThreeRoutes(k3,:)=TwoRoutes(j,:);
                ThreeRoutes(k3,3)=m;
                SN{RC,1}=FSR{m,4};
                RAC(RC,1)=RAC(k1+j);
                RC=RC+1;
            end
        end
    end
end

FourRoutes=zeros(1,10);
k4=0;

if ThreeRoutes(1,1)~=0
    for j=1:size(ThreeRoutes,1)
        for m=1:size(FSR,1)
            Dur1=RDur(k1+k2+j)+TRT;
            Dur=Dur1+FSR{m,9};
            if strcmp(FSR{ThreeRoutes(j,3),4},FSR{m,3})==1 && ismember(m,ThreeRoutes(j,:))==0 && Dur<=1470
                RF{RC}(1:3,:)=RF{k1+k2+j}(1:3,:);
                time1=FSR{m,5};
                minutes1=mod(time1,md);
                hr1=(time1-minutes1)/md;
                basetime1=hr1*60+minutes1;
                basetime2=Dur1;
                basetime3=FSR{m,9};
                RF{RC}(4,:)=FSR(m,2:6);
                if basetime2 > basetime1
                    Del(RC,1)=(basetime2-basetime1)*Delay(m)+Del(k1+k2+j);
                    RDur(RC,1)=basetime2+basetime3;
                    basetimef=basetime2;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(4,4)=array2table(double(mtime));
                    basetimef=basetime2+basetime3;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(4,5)=array2table(double(mtime));
                else
                    Del(RC,1)=Del(k1+k2+j);
                    basetimef=basetime1;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(4,4)=array2table(double(mtime));
                    basetimef=basetime1+basetime3;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(4,5)=array2table(double(mtime));
                    RDur(RC,1)=basetime1+basetime3;
                end
                k4=k4+1;
                FourRoutes(k4,:)=ThreeRoutes(j,:);
                FourRoutes(k4,4)=m;
                SN{RC,1}=FSR{m,4};
                RAC(RC,1)=RAC(k1+k2+j);
                RC=RC+1;
            end
        end
    end
end

FiveRoutes=zeros(1,10);
k5=0;
if FourRoutes(1,1)~=0
    for j=1:size(FourRoutes,1)
        for m=1:size(FSR,1)
            Dur1=RDur(k1+k2+k3+j)+TRT;
            Dur=Dur1+FSR{m,9};
            if strcmp(FSR{FourRoutes(j,4),4},FSR{m,3})==1 && ismember(m,FourRoutes(j,:))==0 && Dur<=1470
                RF{RC}(1:4,:)=RF{k1+k2+k3+j}(1:4,:);
                time1=FSR{m,5};
                minutes1=mod(time1,md);
                hr1=(time1-minutes1)/md;
                basetime1=hr1*60+minutes1;
                basetime2=Dur1;
                basetime3=FSR{m,9};
                RF{RC}(5,:)=FSR(m,2:6);
                if basetime2 > basetime1
                    Del(RC,1)=(basetime2-basetime1)*Delay(m)+Del(k1+k2+k3+j);
                    RDur(RC,1)=basetime2+basetime3;
                    basetimef=basetime2;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(5,4)=array2table(double(mtime));
                    basetimef=basetime2+basetime3;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(5,5)=array2table(double(mtime));
                else
                    Del(RC,1)=Del(k1+k2+k3+j);
                    basetimef=basetime1;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(5,4)=array2table(double(mtime));
                    basetimef=basetime1+basetime3;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(5,5)=array2table(double(mtime));
                    RDur(RC,1)=basetime1+basetime3;
                end
                k5=k5+1;
                FiveRoutes(k5,:)=FourRoutes(j,:);
                FiveRoutes(k5,5)=m;
                SN{RC,1}=FSR{m,4};
                RAC(RC,1)=RAC(k1+k2+k3+j);
                RC=RC+1;
            end
        end
    end
end

SixRoutes=zeros(1,10);
k6=0;

if FiveRoutes(1,1)~=0
    for j=1:size(FiveRoutes,1)
        for m=1:size(FSR,1)
            Dur1=RDur(k1+k2+k3+k4+j,1)+TRT;
            Dur=Dur1+FSR{m,9};
            if strcmp(FSR{FiveRoutes(j,5),4},FSR{m,3})==1 && ismember(m,FiveRoutes(j,:))==0 && Dur<=1470
                RF{RC}(1:5,:)=RF{k1+k2+k3+k4+j}(1:5,:);
                time1=FSR{m,5};
                minutes1=mod(time1,md);
                hr1=(time1-minutes1)/md;
                basetime1=hr1*60+minutes1;
                basetime2=Dur1;
                basetime3=FSR{m,9};
                RF{RC}(6,:)=FSR(m,2:6);
                if basetime2 > basetime1
                    Del(RC,1)=(basetime2-basetime1)*Delay(m)+Del(k1+k2+k3+k4+j);
                    RDur(RC,1)=basetime2+basetime3;
                    basetimef=basetime2;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(6,4)=array2table(double(mtime));
                    basetimef=basetime2+basetime3;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(6,5)=array2table(double(mtime));
                else
                    Del(RC,1)=Del(k1+k2+k3+k4+j);
                    basetimef=basetime1;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(6,4)=array2table(double(mtime));
                    basetimef=basetime1+basetime3;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(6,5)=array2table(double(mtime));
                    RDur(RC,1)=basetime1+basetime3;
                end
                k6=k6+1;
                SixRoutes(k6,:)=FiveRoutes(j,:);
                SixRoutes(k6,6)=m;
                SN{RC,1}=FSR{m,4};
                RAC(RC,1)=RAC(k1+k2+k3+k4+j);
                RC=RC+1;
            end
        end
    end
end

SevenRoutes=zeros(1,10);
k7=0;
if SixRoutes(1,1)~=0
    for j=1:size(SixRoutes,1)
        for m=1:size(FSR,1)
            Dur1=RDur(k1+k2+k3+k4+k5+j,1)+TRT;
            Dur=Dur1+FSR{m,9};
            if strcmp(FSR{SixRoutes(j,6),4},FSR{m,3})==1 && ismember(m,SixRoutes(j,:))==0 && Dur<=1470
                RF{RC}(1:6,:)=RF{k1+k2+k3+k4+k5+j}(1:6,:);
                time1=FSR{m,5};
                minutes1=mod(time1,md);
                hr1=(time1-minutes1)/md;
                basetime1=hr1*60+minutes1;
                basetime2=Dur1;
                basetime3=FSR{m,9};
                RF{RC}(7,:)=FSR(m,2:6);
                if basetime2 > basetime1
                    Del(RC,1)=(basetime2-basetime1)*Delay(m)+Del(k1+k2+k3+k4+k5+j);
                    RDur(RC,1)=basetime2+basetime3;
                    basetimef=basetime2;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(7,4)=array2table(double(mtime));
                    basetimef=basetime2+basetime3;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(7,5)=array2table(double(mtime));
                else
                    Del(RC,1)=Del(k1+k2+k3+k4+k5+j);
                    basetimef=basetime1;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(7,4)=array2table(double(mtime));
                    basetimef=basetime1+basetime3;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(7,5)=array2table(double(mtime));
                    RDur(RC,1)=basetime1+basetime3;
                end
                k7=k7+1;
                SevenRoutes(k7,:)=SixRoutes(j,:);
                SevenRoutes(k7,7)=m;
                SN{RC,1}=FSR{m,4};
                RAC(RC,1)=RAC(k1+k2+k3+k4+k5+j);
                RC=RC+1;
            end
        end
    end
end

EightRoutes=zeros(1,10);
k8=0;
if SevenRoutes(1,1)~=0
    for j=1:size(SevenRoutes,1)
        for m=1:size(FSR,1)
            Dur1=RDur(k1+k2+k3+k4+k5+k6+j,1)+TRT;
            Dur=Dur1+FSR{m,9};
            if strcmp(FSR{SevenRoutes(j,7),4},FSR{m,3})==1 && ismember(m,SevenRoutes(j,:))==0 && Dur<=1470
                RF{RC}(1:7,:)=RF{k1+k2+k3+k4+k5+k6+j}(1:7,:);
                time1=FSR{m,5};
                minutes1=mod(time1,md);
                hr1=(time1-minutes1)/md;
                basetime1=hr1*60+minutes1;
                basetime2=Dur1;
                basetime3=FSR{m,9};
                RF{RC}(8,:)=FSR(m,2:6);
                if basetime2 > basetime1
                    Del(RC,1)=(basetime2-basetime1)*Delay(m)+Del(k1+k2+k3+k4+k5+k6+j);
                    RDur(RC,1)=basetime2+basetime3;
                    basetimef=basetime2;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(8,4)=array2table(double(mtime));
                    basetimef=basetime2+basetime3;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(8,5)=array2table(double(mtime));
                else
                    Del(RC,1)=Del(k1+k2+k3+k4+k5+k6+j);
                    basetimef=basetime1;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(8,4)=array2table(double(mtime));
                    basetimef=basetime1+basetime3;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(8,5)=array2table(double(mtime));
                    RDur(RC,1)=basetime1+basetime3;
                end
                k8=k8+1;
                EightRoutes(k8,:)=SevenRoutes(j,:);
                EightRoutes(k8,8)=m;
                SN{RC,1}=FSR{m,4};
                RAC(RC,1)=RAC(k1+k2+k3+k4+k5+k6+j);
                RC=RC+1;
            end
        end
    end
end

NineRoutes=zeros(1,10);
k9=0;
if EightRoutes(1,1)~=0
    for j=1:size(EightRoutes,1)
        for m=1:size(FSR,1)
            Dur1=RDur(k1+k2+k3+k4+k5+k6+k7+j,1)+TRT;
            Dur=Dur1+FSR{m,9};
            if strcmp(FSR{EightRoutes(j,8),4},FSR{m,3})==1 && ismember(m,EightRoutes(j,:))==0 && Dur<=1470
                RF{RC}(1:8,:)=RF{k1+k2+k3+k4+k5+k6+k7+j}(1:8,:);
                time1=FSR{m,5};
                minutes1=mod(time1,md);
                hr1=(time1-minutes1)/md;
                basetime1=hr1*60+minutes1;
                basetime2=Dur1;
                basetime3=FSR{m,9};
                RF{RC}(9,:)=FSR(m,2:6);
                if basetime2 > basetime1
                    Del(RC,1)=(basetime2-basetime1)*Delay(m)+Del(k1+k2+k3+k4+k5+k6+k7+j);
                    RDur(RC,1)=basetime2+basetime3;
                    basetimef=basetime2;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(9,4)=array2table(double(mtime));
                    basetimef=basetime2+basetime3;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(9,5)=array2table(double(mtime));
                else
                    Del(RC,1)=Del(k1+k2+k3+k4+k5+k6+k7+j);
                    basetimef=basetime1;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(9,4)=array2table(double(mtime));
                    basetimef=basetime1+basetime3;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(9,5)=array2table(double(mtime));
                    RDur(RC,1)=basetime1+basetime3;
                end
                k9=k9+1;
                NineRoutes(k9,:)=EightRoutes(j,:);
                NineRoutes(k9,9)=m;
                SN{RC,1}=FSR{m,4};
                RAC(RC,1)=RAC(k1+k2+k3+k4+k5+k6+k7+j);
                RC=RC+1;
            end
        end
    end
end

TenRoutes=zeros(1,10);
k10=0;
if NineRoutes(1,1)~=0
    for j=1:size(NineRoutes,1)
        for m=1:size(FSR,1)
            Dur1=RDur(k1+k2+k3+k4+k5+k6+k7+k8+j,1)+TRT;
            Dur=Dur1+FSR{m,9};
            if strcmp(FSR{NineRoutes(j,9),4},FSR{m,3})==1 && ismember(m,NineRoutes(j,:))==0 && Dur<=1470
                RF{RC}(1:9,:)=RF{k1+k2+k3+k4+k5+k6+k7+k8+j}(1:9,:);
                time1=FSR{m,5};
                minutes1=mod(time1,md);
                hr1=(time1-minutes1)/md;
                basetime1=hr1*60+minutes1;
                basetime2=Dur1;
                basetime3=FSR{m,9};
                RF{RC}(10,:)=FSR(m,2:6);
                if basetime2 > basetime1
                    Del(RC,1)=(basetime2-basetime1)*Delay(m)+Del(k1+k2+k3+k4+k5+k6+k7+k8+j);
                    RDur(RC,1)=basetime2+basetime3;
                    basetimef=basetime2;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(10,4)=array2table(double(mtime));
                    basetimef=basetime2+basetime3;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(10,5)=array2table(double(mtime));
                else
                    Del(RC,1)=Del(k1+k2+k3+k4+k5+k6+k7+k8+j);
                    basetimef=basetime1;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(10,4)=array2table(double(mtime));
                    basetimef=basetime1+basetime3;
                    [a,b]=quorem(sym(basetimef),sym(60));
                    mtime=100*a+b;
                    RF{RC}(10,5)=array2table(double(mtime));
                    RDur(RC,1)=basetime1+basetime3;
                end
                k10=k10+1;
                TenRoutes(k10,:)=NineRoutes(j,:);
                TenRoutes(k10,10)=m;
                SN{RC,1}=FSR{m,4};
                RAC(RC,1)=RAC(k1+k2+k3+k4+k5+k6+k7+k8+j);
                RC=RC+1;
            end
        end
    end
end

AllRoutes=[OneRoutes ; TwoRoutes ; ThreeRoutes ; FourRoutes ; FiveRoutes ; SixRoutes ; SevenRoutes ; EightRoutes ; NineRoutes ; TenRoutes];
AllRoutes( all(~AllRoutes,2), : ) = [];

% Flight Route Incidence Matrix and reverse
% cancellation costs are calculated

CanRev=zeros(size(AllRoutes,1),1);
INC=zeros(size(AllRoutes,1),size(FSR,1));
for i=1:size(AllRoutes,1)
    for j=1:size(FSR,1)
        INC(i,j)=ismember(j,AllRoutes(i,:));
        if INC(i,j)==1
            CanRev(i)=CanRev(i)+FSR{j,7};
        end
    end
end

% Objective Function
% Summation of Delay costs + Cancellation - Cancellation Reverse
OBJ=transpose(Del-CanRev);

% Constraints

% Coverage
Coverage=transpose(INC);

% One route should be accepted for each of the aircrafts, satisfying the constraints of the starting node and
% time of availability
for i=1:size(AircraftCount,1)
    A{i}=[];
    for j=1:size(AllRoutes,1)
        if RAC(j)==i
            A{i}(j)=1;
        else
            A{i}(j)=0;
        end
    end
end

% Ending nodes constraints

for i=1:size(AllRoutes,1)
    for j=1:size(Airports,1)
        if strcmp(SN{i},Airports{j})==1
            SNC{j}(i)=1;
        else
            SNC{j}(i)=0;
        end
    end
end
            
% Set the RHS side of the matrix            

RHSineq=[];

for i=1:size(FSR,1)
    RHSineq(i,1)=1;
end

RHSineq=[RHSineq ; transpose(RON)];

LHSineq=[Coverage];

for i=1:size(Airports,1)
   LHSineq=[LHSineq;SNC{i}];
end

RHSeq=ones(size(AircraftCount,1),1);
if Back==0
    RHSeq(OutOfService,1)=0;
end

for i=1:size(AircraftCount,1)
    LHSeq(i,:)=A{i};
end

% Generate upper and lower bound matrix for the binary linear programming
lb = zeros(size(OBJ,2),1);
ub = ones(size(OBJ,2),1);

solution=intlinprog(OBJ,(1:size(OBJ,2)),LHSineq,RHSineq,LHSeq,RHSeq,lb,ub);
ansindex=find(solution);


%for m=1:size(RF,2)
%    for i=1:size(RF{1,m},2)
%        timex=table2array(RF{1,m}(i,4));
%        minutes2=mod(timex,md);
%        hr2=(timex-minutes2)/md;
%        basetimex=(hr2*60+minutes2)/1440;
%        RF{1,m}(i,4)=datetime(basetimex,'ConvertFrom','excel', 'Format','HH:mm'));
%        timex=table2array(RF{1,m}{i,5});
%        minutes2=mod(timex,md);
%        hr2=(timex-minutes2)/md;
%        basetimex=(hr2*60+minutes2)/1440;
%        RF{1,m}(i,5)=datetime(basetimex,'ConvertFrom','excel', 'Format','HH:mm'));
%    end
%end

for i=1:size(ansindex);
    disp('Aircraft ID:');
    disp(RAC(ansindex(i)));
    disp('New Schedule:');
    disp(RF{1,ansindex(i)});
end

for i=1:size(AllRoutes,1)
    for j=1:size(AllRoutes,2)
        if AllRoutes(i,j)~=0
        ZAllRoutes(i,j)=FlightID(AllRoutes(i,j));
        end
    end
end


Cost=OBJ*solution+sum(Cancel)