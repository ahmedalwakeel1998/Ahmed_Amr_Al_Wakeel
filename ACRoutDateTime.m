clc; clear;

%% Load the input Flight Schedule for the fleet

FS=readtable('FlightSchedule (1).xlsx','sheet',1);
No_of_Flights=size(FS,1);

%% Get the maintenance base airport(s) from the user
countbase=input('Enter number of maintenance base airports: ');
for i=1:countbase
base{i}=input('Enter the maintenance base airport: ','s');
end

%% Break down the input schedule into arrays
ID=table2array(FS(:,1));
Origin=FS{:,2};
Destination=FS{:,3};

dep_time_1 = datetime(FS{:,4},'ConvertFrom','excel', 'Format','HH:mm');
DEPC=cellstr(dep_time_1);
DEPCH=char(DEPC);

for i=1:length(DEPC)
    Dep(i,1)=str2num(DEPCH(i,[1 2]))*100+str2num(DEPCH(i,[4 5]));
end

%Dep=table2array(FS(:,4));

Arr_time_1 = datetime(FS{:,5},'ConvertFrom','excel', 'Format','HH:mm');
DEPC=cellstr(Arr_time_1);
DEPCH=char(DEPC);

for i=1:length(DEPC)
    Arr(i,1)=str2num(DEPCH(i,[1 2]))*100+str2num(DEPCH(i,[4 5]));
end

%Arr=table2array(FS(:,5));
Dur=table2array(FS(:,6));

%% Get the fleet size and desired turnaround time from the user
Fleet_Size=input('Enter number of aircrafts in this fleet: ');
md=100;
trt=input('Enter Turn Around Time in Minutes: ');

%% Create list of the one flight per day (FPD) schedules
One_Flight_Per_Day=zeros(No_of_Flights,1);
for i=1:No_of_Flights
    One_Flight_Per_Day(i)=i;
end

%% Generate 2 flight per day schedules by pairing one extra flight to the 1 FPD Schedule

Two_Flight_Per_Day=0;
j=1;
for i=1:No_of_Flights % i=route from 1 FPD
    for m=1:No_of_Flights % m= flight to be paired
        %Calculation of time between flights
        time2=Dep(m);
        time1=Arr(i);
        minutes1=mod(time1,md);
        hr1=(time1-minutes1)/md;
        basetime1=hr1*60+minutes1;
        minutes2=mod(time2,md);
        hr2=(time2-minutes2)/md;
        basetime2=hr2*60+minutes2;
        if basetime2-basetime1 >=trt && strcmp(Origin(m),Destination(i))==1
            %Adding the one extra flight
            Two_Flight_Per_Day(j,1)=i;
            Two_Flight_Per_Day(j,2)=m;
            j=j+1;
        end
    end
end


%% Generate 3 flight per day schedules by pairing one extra flight to the 2 FPD Schedule

Three_Flight_Per_Day=0;
if Two_Flight_Per_Day~=0
    j=1;
    for i=1:size(Two_Flight_Per_Day,1) % i= route from 2 FPD Schedule
        for m=1:No_of_Flights % m= flight to per paired
            time2=Dep(m);
            time1=Arr(Two_Flight_Per_Day(i,2));
            minutes1=mod(time1,md);
            hr1=(time1-minutes1)/md;
            basetime1=(hr1*60)+minutes1;
            minutes2=mod(time2,md);
            hr2=(time2-minutes2)/md;
            basetime2=(hr2*60)+minutes2;
            if basetime2-basetime1 >=trt && strcmp(Origin(m),Destination(Two_Flight_Per_Day(i,2)))==1
                Three_Flight_Per_Day(j,1)=Two_Flight_Per_Day(i,1);
                Three_Flight_Per_Day(j,2)=Two_Flight_Per_Day(i,2);
                Three_Flight_Per_Day(j,3)=m;
                j=j+1;
            end
        end
    end
end


%% Generate 4 flights per day

Four_Flight_Per_Day=0;
if Three_Flight_Per_Day~=0
    j=1;
    for i=1:size(Three_Flight_Per_Day,1) % i= route from 3 FPD
        for m=1:No_of_Flights % m= flight to per paired
            time2=Dep(m);
            time1=Arr(Three_Flight_Per_Day(i,3));
            minutes1=mod(time1,md);
            hr1=(time1-minutes1)/md;
            basetime1=hr1*60+minutes1;
            minutes2=mod(time2,md);
            hr2=(time2-minutes2)/md;
            basetime2=hr2*60+minutes2;
            if basetime2-basetime1>=trt && strcmp(Origin(m),Destination(Three_Flight_Per_Day(i,3)))==1
                Four_Flight_Per_Day(j,1:3)=Three_Flight_Per_Day(i,:);
                Four_Flight_Per_Day(j,4)=m;
                j=j+1;
            end
        end
    end
end

%% Generate 5 flights per day

Five_Flight_Per_Day=0;
if Four_Flight_Per_Day~=0
    j=1;
    for i=1:size(Four_Flight_Per_Day,1) % i= route from 4 FPD
        for m=1:No_of_Flights % m= flight to per paired
            time2=Dep(m);
            time1=Arr(Four_Flight_Per_Day(i,4));
            minutes1=mod(time1,md);
            hr1=(time1-minutes1)/md;
            basetime1=hr1*60+minutes1;
            minutes2=mod(time2,md);
            hr2=(time2-minutes2)/md;
            basetime2=hr2*60+minutes2;
            if basetime2-basetime1>=trt && strcmp(Origin(m),Destination(Four_Flight_Per_Day(i,4)))==1
                Five_Flight_Per_Day(j,1:4)=Four_Flight_Per_Day(i,:);
                Five_Flight_Per_Day(j,5)=m;
                j=j+1;
            end
        end
    end
end

%% Generate 6 flights per day

Six_Flight_Per_Day=0;
if Five_Flight_Per_Day~=0
    j=1;
    for i=1:size(Five_Flight_Per_Day,1) % i= route from 5 FPD
        for m=1:No_of_Flights % m= flight to per paired
            time2=Dep(m);
            time1=Arr(Five_Flight_Per_Day(i,5));
            minutes1=mod(time1,md);
            hr1=(time1-minutes1)/md;
            basetime1=hr1*60+minutes1;
            minutes2=mod(time2,md);
            hr2=(time2-minutes2)/md;
            basetime2=hr2*60+minutes2;
            if basetime2-basetime1>=trt && strcmp(Origin(m),Destination(Five_Flight_Per_Day(i,5)))==1
                Five_Flight_Per_Day(j,1:5)=Five_Flight_Per_Day(i,:);
                Five_Flight_Per_Day(j,6)=m;
                j=j+1;
            end
        end
    end
end

%% Generate 7 flights per day

Seven_Flight_Per_Day=0;
if Six_Flight_Per_Day~=0
    j=1;
    for i=1:size(Six_Flight_Per_Day,1) % i= route from 6 FPD
        for m=1:No_of_Flights % m= flight to per paired
            time2=Dep(m);
            time1=Arr(Six_Flight_Per_Day(i,6));
            minutes1=mod(time1,md);
            hr1=(time1-minutes1)/md;
            basetime1=hr1*60+minutes1;
            minutes2=mod(time2,md);
            hr2=(time2-minutes2)/md;
            basetime2=hr2*60+minutes2;
            if basetime2-basetime1>=trt && strcmp(Origin(m),Destination(Six_Flight_Per_Day(i,6)))==1
                Seven_Flight_Per_Day(j,1:6)=Six_Flight_Per_Day(i,:);
                Seven_Flight_Per_Day(j,7)=m;
                j=j+1;
            end
        end
    end
end

%% Generate 8 flights per day

Eight_Flight_Per_Day=0;
if Seven_Flight_Per_Day~=0
    j=1;
    for i=1:size(Seven_Flight_Per_Day,1) % i= route from 7 FPD
        for m=1:No_of_Flights % m= flight to per paired
            time2=Dep(m);
            time1=Arr(Seven_Flight_Per_Day(i,7));
            minutes1=mod(time1,md);
            hr1=(time1-minutes1)/md;
            basetime1=hr1*60+minutes1;
            minutes2=mod(time2,md);
            hr2=(time2-minutes2)/md;
            basetime2=hr2*60+minutes2;
            if basetime2-basetime1>=trt && strcmp(Origin(m),Destination(Seven_Flight_Per_Day(i,7)))==1
                Eight_Flight_Per_Day(j,1:7)=Seven_Flight_Per_Day(i,:);
                Eight_Flight_Per_Day(j,7)=m;
                j=j+1;
            end
        end
    end
end

%% Generate 9 flights per day

Nine_Flight_Per_Day=0;
if Eight_Flight_Per_Day~=0
    j=1;
    for i=1:size(Eight_Flight_Per_Day,1) % i= route from 8 FPD
        for m=1:No_of_Flights % m= flight to per paired
            time2=Dep(m);
            time1=Arr(Eight_Flight_Per_Day(i,7));
            minutes1=mod(time1,md);
            hr1=(time1-minutes1)/md;
            basetime1=hr1*60+minutes1;
            minutes2=mod(time2,md);
            hr2=(time2-minutes2)/md;
            basetime2=hr2*60+minutes2;
            if basetime2-basetime1>=trt && strcmp(Origin(m),Destination(Eight_Flight_Per_Day(i,4)))==1
                Nine_Flight_Per_Day(j,1:8)=Eight_Flight_Per_Day(i,:);
                Nine_Flight_Per_Day(j,7)=m;
                j=j+1;
            end
        end
    end
end

%% Generate 10 flights per day

Ten_Flight_Per_Day=0;
if Nine_Flight_Per_Day~=0
    j=1;
    for i=1:size(Nine_Flight_Per_Day,1) % i= route from 9 FPD
        for m=1:No_of_Flights % m= flight to per paired
            time2=Dep(m);
            time1=Arr(Nine_Flight_Per_Day(i,7));
            minutes1=mod(time1,md);
            hr1=(time1-minutes1)/md;
            basetime1=hr1*60+minutes1;
            minutes2=mod(time2,md);
            hr2=(time2-minutes2)/md;
            basetime2=hr2*60+minutes2;
            if basetime2-basetime1>=trt && strcmp(Origin(m),Destination(Nine_Flight_Per_Day(i,4)))==1
                Ten_Flight_Per_Day(j,1:9)=Eight_Flight_Per_Day(i,:);
                Ten_Flight_Per_Day(j,10)=m;
                j=j+1;
            end
        end
    end
end

%% Create list of all possible one day routing (1DR)

if One_Flight_Per_Day~=0
    for a=1:size(One_Flight_Per_Day,1)
        One_Day_Routing(a,1)=One_Flight_Per_Day(a);
    end
end

x=size(One_Day_Routing,1);
if Two_Flight_Per_Day~=0
    for a=1:size(Two_Flight_Per_Day,1)
        One_Day_Routing(x+a,1:2)=Two_Flight_Per_Day(a,1:2);
    end
end

x=size(One_Day_Routing,1);
if Three_Flight_Per_Day~=0
    for a=1:size(Three_Flight_Per_Day,1)
        One_Day_Routing(x+a,1:3)=Three_Flight_Per_Day(a,1:3);
    end
end

x=size(One_Day_Routing,1);
if Four_Flight_Per_Day~=0
    for a=1:size(Four_Flight_Per_Day,1)
        One_Day_Routing(x+a,1:4)=Four_Flight_Per_Day(a,1:4);
    end
end

x=size(One_Day_Routing,1);
if Five_Flight_Per_Day~=0
    for a=1:size(Five_Flight_Per_Day,1)
        One_Day_Routing(x+a,1:5)=Five_Flight_Per_Day(a,1:5);
    end
end

x=size(One_Day_Routing,1);
if Six_Flight_Per_Day~=0
    for a=1:size(Six_Flight_Per_Day,1)
        One_Day_Routing(x+a,1:6)=Six_Flight_Per_Day(a,1:6);
    end
end

x=size(One_Day_Routing,1);
if Seven_Flight_Per_Day~=0
    for a=1:size(Seven_Flight_Per_Day,1)
        One_Day_Routing(x+a,1:7)=Seven_Flight_Per_Day(a,1:7);
    end
end

x=size(One_Day_Routing,1);
if Eight_Flight_Per_Day~=0
    for a=1:size(Eight_Flight_Per_Day,1)
        One_Day_Routing(x+a,1:8)=Eight_Flight_Per_Day(a,1:8);
    end
end

x=size(One_Day_Routing,1);
if Nine_Flight_Per_Day~=0
    for a=1:size(Nine_Flight_Per_Day,1)
        One_Day_Routing(x+a,1:9)=Nine_Flight_Per_Day(a,1:9);
    end
end

x=size(One_Day_Routing,1);
if Ten_Flight_Per_Day~=0
    for a=1:size(Ten_Flight_Per_Day,1)
        One_Day_Routing(x+a,1:10)=Ten_Flight_Per_Day(a,1:10);
    end
end

%% Create 2 day routing (2DR) list by pairing elligible 1DR after each other
% Create record of the starting and ending airports of all 1 day routings

ODR_StartAndEndAirport(:,1)=Origin(One_Day_Routing(:,1));
for i=1:size(One_Day_Routing,1)
    ODR_StartAndEndAirport(i,2)=Destination(One_Day_Routing(i,find(One_Day_Routing(i,:),1,'last')));
end

%% Generate Possible 2DR by comparing the first day destination airport with the second day origin airport

Two_Day_Routing=0;
w=1;
for i=1:size(ODR_StartAndEndAirport,1)
    for j=1:size(ODR_StartAndEndAirport,1)
        if strcmp(ODR_StartAndEndAirport(i,2),ODR_StartAndEndAirport(j,1))==1
            Two_Day_Routing(w,1)=i;
            Two_Day_Routing(w,2)=j;
            w=w+1;
        end
    end
end

%% Generate Possible 3DR by comparing the second day destination airport with the third day origin airport

% Create record of the destination airports of all 2 day routings

for i=1:size(Two_Day_Routing,1)
    q(i,1)=ODR_StartAndEndAirport(Two_Day_Routing(i,2),2);
end
Three_Day_Routing=0;
s=1;
for i=1:size(Two_Day_Routing,1)
    for j=1:size(ODR_StartAndEndAirport,1)
        if strcmp(q(i,1),ODR_StartAndEndAirport(j,1))==1
            Three_Day_Routing(s,1)=Two_Day_Routing(j,1);
            Three_Day_Routing(s,2)=Two_Day_Routing(j,2);
            Three_Day_Routing(s,3)=j;
            s=s+1;
        end
    end
end

for i=1:size(One_Day_Routing,1)
    for j=1:size(Two_Day_Routing,1)
        if strcmp(ODR_StartAndEndAirport(i,2),ODR_StartAndEndAirport(Two_Day_Routing(j,1),1))==1
            Three_Day_Routing(s,2)=Two_Day_Routing(j,1);
            Three_Day_Routing(s,3)=Two_Day_Routing(j,2);
            Three_Day_Routing(s,1)=i;
            s=s+1;
        end
    end
end


%% Create Filter 1 to remove routes that do not satisfy the maintenance constraint

Filter1=0;
v=1;
for i=1:size(Three_Day_Routing,1)
    Overnight_First_Night=ODR_StartAndEndAirport(Three_Day_Routing(i,1),2);
    Overnight_Second_Night=ODR_StartAndEndAirport(Three_Day_Routing(i,2),2);
    Overnight_Third_Night=ODR_StartAndEndAirport(Three_Day_Routing(i,3),2);
    StartAirport=ODR_StartAndEndAirport(Three_Day_Routing(i,1),1);
    if strcmp(Overnight_Third_Night,StartAirport)==1
        if ismember(Overnight_First_Night,base)==1 || ismember(Overnight_Second_Night,base)==1 || ismember(Overnight_Third_Night,base)==1
            Filter1(v,1)=Three_Day_Routing(i,1);
            Filter1(v,2)=Three_Day_Routing(i,2);
            Filter1(v,3)=Three_Day_Routing(i,3);
            v=v+1;
        end
    end
end

%% Create a matrix with flight numbers instead of array index so that it is easier to understand by the user

% Two Day Routing

TDRF=zeros(size(Two_Day_Routing,1),size(One_Day_Routing,2)*2);
t=1;
for i=1:size(Two_Day_Routing,1)
    TDRF(i,1:size(One_Day_Routing,2))=One_Day_Routing(Two_Day_Routing(i,1),:);
    TDRF(i,size(One_Day_Routing,2)+1:size(One_Day_Routing,2)*2)=One_Day_Routing(Two_Day_Routing(i,2),:);
end

Filter2=unique(Filter1,'rows');

% Three Day Routing
THDRF=zeros(size(Filter2,1),size(One_Day_Routing,2)*3);
t=1;
for i=1:size(Filter2,1)
    THDRF(i,1:size(One_Day_Routing,2))=One_Day_Routing(Filter2(i,1),:);
    THDRF(i,size(One_Day_Routing,2)+1:size(One_Day_Routing,2)*2)=One_Day_Routing(Filter2(i,2),:);
    THDRF(i,size(One_Day_Routing,2)*2+1:size(One_Day_Routing,2)*3)=One_Day_Routing(Filter2(i,3),:);
end

%% Create Filter 2 to remove duplicate routes



%% Create Filter 3 to convert three day routing list from matrix index to flight numbers

Filter3=[];
for i=1:size(THDRF,1)
    for j=1:size(THDRF,2)
        if THDRF(i,j)~=0
            Filter3(i,j)=ID(THDRF(i,j));
        end
    end
end

%% Generate Flight-Day-Route Incidence matrix for Coverage Constraint

INC=zeros(size(Filter2,1),No_of_Flights*3);
for i=1:size(Filter3,1)
    for j=1:No_of_Flights
        INC(i,j)=ismember(ID(j),Filter3(i,1:size(One_Day_Routing,2)));
    end
    for j=No_of_Flights+1:2*No_of_Flights
        INC(i,j)=ismember(ID(j-No_of_Flights),Filter3(i,size(One_Day_Routing,2)+1:size(One_Day_Routing,2)*2));
    end
    for j=(2*No_of_Flights)+1:No_of_Flights*3
        INC(i,j)=ismember(ID(j-No_of_Flights*2),Filter3(i,(size(One_Day_Routing,2)*2)+1:size(One_Day_Routing,2)*3));
    end
end

Constraints=transpose(INC);

%% Calculate Objective Function coefficients based on Balanced Utilization

for i=1:size(Filter3,1)
    UH=0;
    for j=1:size(Filter3,2)
        if Filter3(i,j)~=0;
            UH=UH+Dur(THDRF(i,j));
        end
    end
    OBJ(1,i)=UH;
end

%% Calculate Objective Function coeffecients based on maximizing maintenance opportunities (Reference Solution)

BookOBJ=[];
Filter4=unique(Filter1,'rows');

for i=1:size(Filter4,1)
    BookOBJ(1,i)=0;
    Overnight_First_Night(i)=ODR_StartAndEndAirport(Filter4(i,1),2);
    Overnight_Second_Night(i)=ODR_StartAndEndAirport(Filter4(i,2),2);
    Overnight_Third_Night(i)=ODR_StartAndEndAirport(Filter4(i,3),2);
    if ismember(Overnight_First_Night(i),base)==1
        BookOBJ(1,i)=1;
    end
    if ismember(Overnight_Second_Night(i),base)==1
        BookOBJ(1,i)=BookOBJ(1,i)+1;
    end
    if ismember(Overnight_Third_Night(i),base)==1
        BookOBJ(1,i)=BookOBJ(1,i)+1;
    end
end

% Create the Linear equality matrix are coverage constraint

for i=1:size(Constraints,1)
    RHSeq(i,1)=1;
end

% Create Linear inequality matrix for Fleet Size

for i=1:size(INC,1)
    LHSineq(i)=1;
end

% Generate the solution table headings

pre = 'Day';
pre2= 'Flight';
names = {};
for k = 1:3
    for i=1:size(One_Day_Routing,2)
        names = [names;strcat([pre,num2str(k,'%02d'),pre2,num2str(i,'%02d')],x)];
    end
end

names2 = {};
for k = 1:3
    for i=1:size(One_Day_Routing,2)
        names2 = [names2;strcat([pre,num2str(k,'%02d'),pre2,num2str(i,'%02d')],x)];
    end
end

result1=input('Do you want to show result(1 for yes, 0 for no)?');

% Generate upper and lower bound matrix for the binary linear programming
lb = zeros(size(OBJ,2),1);
ub = ones(size(OBJ,2),1);

%Prompt the user to specify desired part of the solution
while result1==1
    disp('1 for 1 flight per day, 2 for 2 flight per day, 3 for 3 flight per day');
    disp('4 for 4 flight per day, 5 for 5 flight per day, 11 for one day routing');
    disp('12 for 2 day routing, 20 for Solution based on balanced utilization,');
    disp('30 for maximum maintenance opportunities (book solution)');
    r2=input('Specify wanted result= ');
    if r2==1
        One_Flight_Per_Day
    elseif r2==2
        Two_Flight_Per_Day
    elseif r2==3
        Three_Flight_Per_Day
    elseif r2==4
        Four_Flight_Per_Day
    elseif r2==5
        Five_Flight_Per_Day
    elseif r2==11
        One_Day_Routing
    elseif r2==12
        TDRF
    elseif r2==20
        [solution Value]=intlinprog((OBJ.^2),(1:size(OBJ,2)),LHSineq,Fleet_Size,Constraints,RHSeq,lb,ub);
        ansindex=find(solution);
        
        for i=1:length(ansindex)
            SolutionRoutes(i,1:(size(One_Day_Routing,2))*3)=Filter3(ansindex(i),:);
            SROBJ(i,1:(size(One_Day_Routing,2))*3)=SolutionRoutes(i,:);
            SROBJ(i,(size(One_Day_Routing,2))*3+1)=OBJ(1,ansindex(i));
        end
        Table=array2table(SolutionRoutes,'VariableNames',names);
        % Saving the solution to a spreadsheet in the root directory
        writetable(Table,'C:\AR\AircraftRoutingUtilizationHours.xls');
        names(size(One_Day_Routing,2)*3+1,1)=cellstr('UtilizationHours');
        % Displaying the solution to the user
        Table2=array2table(SROBJ,'VariableNames',[names])
    elseif r2==30
        [booksolution Value]=intlinprog((-BookOBJ),(1:size(OBJ,2)),(LHSineq),(Fleet_Size),Constraints,RHSeq,lb,ub);
        ansbook=find(booksolution>0.999);
        
        for i=1:length(ansbook)
            BookSolutionRoutes(i,1:(size(One_Day_Routing,2))*3)=Filter3(ansbook(i),:);
            BSROBJ(i,1:(size(One_Day_Routing,2))*3)=BookSolutionRoutes(i,:);
            BSROBJ(i,(size(One_Day_Routing,2))*3+1)=BookOBJ(1,ansbook(i));
        end
        Table=array2table(BookSolutionRoutes,'VariableNames',names2);
        % Saving the solution to a spreadsheet in the root directory
        writetable(Table,'C:\AR\AircraftRoutingMaximizeMaintenance.xls');
        names2(size(One_Day_Routing,2)*3+1,1)=cellstr('MaintenanceOppor');
        % Displaying the Solution to the user
        Table2=array2table(BSROBJ,'VariableNames',[names2])
    else
        r2=input('Invalid result code, please enter valid result code= ');
    end
    result1=input('Do you want any other results (1 for Yes, 0 for No)? ');
end