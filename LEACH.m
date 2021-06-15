clc;
clear;
close all;
warning off all;
tic;

n=100;                                  
[Area,Model]=setParameters(n);     		

CreateRandomSen(Model,Area);             
load Locations                          
Sensors=ConfigureSensors(Model,n,X,Y);
ploter(Sensors,Model);  
                 
countCHs=0;         
flag_first_dead=0;  
deadNum=0;          

initEnergy=0;      
for i=1:n
      initEnergy=Sensors(i).E+initEnergy;
end

SRP=zeros(1,Model.rmax);   
RRP=zeros(1,Model.rmax);    
SDP=zeros(1,Model.rmax);    
RDP=zeros(1,Model.rmax);   

Sum_DEAD=zeros(1,Model.rmax);
CLUSTERHS=zeros(1,Model.rmax);
AllSensorEnergy=zeros(1,Model.rmax);


global srp rrp sdp rdp
srp=0;          
rrp=0;          
sdp=0;          
rdp=0;          


Sender=n+1;    
Receiver=1:n;   
Sensors=SendReceivePackets(Sensors,Model,Sender,'Hello',Receiver);


Sensors=disToSink(Sensors,Model);
 

SRP(1)=srp;
RRP(1)=rrp;  
SDP(1)=sdp;
RDP(1)=rdp;


for r=1:1:Model.rmax


    member=[];              
    countCHs=0;             
   
    srp=0;          
    rrp=0;          
    sdp=0;          
    rdp=0;          
    SRP(r+1)=srp;
    RRP(r+1)=rrp;  
    SDP(r+1)=sdp;
    RDP(r+1)=rdp;   
    pause(0.001);    
    hold off;       
    

    Sensors=resetSensors(Sensors,Model); 
    AroundClear=10;
    if(mod(r,AroundClear)==0) 
        for i=1:1:n
            Sensors(i).G=0;
        end
    end
    
    deadNum=ploter(Sensors,Model);
    
    if (deadNum>=1)      
        if(flag_first_dead==0)
            first_dead=r;
            flag_first_dead=1;
        end  
    end
    

    [TotalCH,Sensors]=SelectCH(Sensors,Model,r); 

    
    for i=1:length(TotalCH)
        
        Sender=TotalCH(i).id;
        SenderRR=Model.RR;
        Receiver=findReceiver(Sensors,Model,Sender,SenderRR);   
        Sensors=SendReceivePackets(Sensors,Model,Sender,'Hello',Receiver);
            
    end 
    Sensors=JoinToNearestCH(Sensors,Model,TotalCH);
     
    for i=1:n
        
        if (Sensors(i).type=='N' && Sensors(i).dis2ch<Sensors(i).dis2sink && ...
                Sensors(i).E>0)
            
            XL=[Sensors(i).xd ,Sensors(Sensors(i).MCH).xd];
            YL=[Sensors(i).yd ,Sensors(Sensors(i).MCH).yd];
            hold on;
            line(XL,YL);
            
        end
        
    end
    NumPacket=Model.NumPacket;
    for i=1:1:1 
        deadNum=ploter(Sensors,Model);
        
        for j=1:length(TotalCH)
            
            Receiver=TotalCH(j).id;
            Sender=findSender(Sensors,Model,Receiver); 
            Sensors=SendReceivePackets(Sensors,Model,Sender,'Data',Receiver);
            
        end
        
    end
    for i=1:length(TotalCH)
            
        Receiver=n+1;               
        Sender=TotalCH(i).id;       
        Sensors=SendReceivePackets(Sensors,Model,Sender,'Data',Receiver);
            
    end
    for i=1:n
        if(Sensors(i).MCH==Sensors(n+1).id)
            Receiver=n+1;               
            Sender=Sensors(i).id;       
            Sensors=SendReceivePackets(Sensors,Model,Sender,'Data',Receiver);
        end
    end
     
    Sum_DEAD(r+1)=deadNum;
    
    SRP(r+1)=srp;
    RRP(r+1)=rrp;  
    SDP(r+1)=sdp;
    RDP(r+1)=rdp;
    
    CLUSTERHS(r+1)=countCHs;
    
    alive=0;
    SensorEnergy=0;
    for i=1:n
        if Sensors(i).E>0
            alive=alive+1;
            SensorEnergy=SensorEnergy+Sensors(i).E;
        end
    end
    AliveSensors(r)=alive; %#ok
    
    SumEnergyAllSensor(r+1)=SensorEnergy; %#ok
    
    AvgEnergyAllSensor(r+1)=SensorEnergy/alive; %#ok
    
    ConsumEnergy(r+1)=(initEnergy-SumEnergyAllSensor(r+1))/n; %#ok
    
    En=0;
    for i=1:n
        if Sensors(i).E>0
            En=En+(Sensors(i).E-AvgEnergyAllSensor(r+1))^2;
        end
    end
    
    Enheraf(r+1)=En/alive; %#ok
    
    title(sprintf('Round=%d,Dead nodes=%d', r+1, deadNum)); 
    
    

   if(n==deadNum)
       
       lastPeriod=r;  
       break;
       
   end
  
end 

hold off;
figure(2);

xm=100;
ym=100;
x=0; 
y=0; 
n=100;
dead_nodes=0;
sinkx=0;
sinky=0;
Eo=2; 
Eelec=50*10^(-9); 
ETx=50*10^(-9); 
ERx=50*10^(-9); 
Eamp=100*10^(-12); 
EDA=5*10^(-9); 
k=100; 
operating_nodes=n;
transmissions=0;
d(n,n)=0;
temp_dead=0;
dead_nodes=0;
selected=0;
flag1stdead=0;
count=0;
turn=0;
temp_val=0;
for i=1:n
    
    
    SN(i).id=i; 
    SN(i).x=rand(1,1)*xm;   
    SN(i).y=rand(1,1)*ym;   
    SN(i).E=Eo;     
    SN(i).cond=1;   
    SN(i).dts=0;    
    SN(i).role=0;   
    SN(i).pos=0;
    SN(i).dis=0;    
    SN(i).sel=0;    
    SN(i).rop=0;      
    order(i)=0;
    hold on;
    figure(2);
    plot(x,y,xm,ym,SN(i).x,SN(i).y,'ob',sinkx,sinky);
    title 'LOCALIZATION';
    
end
 
 for i=1:n
    SN(i).dts=sqrt((sinkx-SN(i).x)^2 + (sinky-SN(i).y)^2);
    SN(i).Esink=Eelec*k + Eamp*k*(SN(i).dts)^2;
    T(i)=SN(i).dts;
 end
 
    A=sort(T,'descend'); 
    A_id(1:n)=0;
     for i=1:n
         for j=1:n
            if A(i)==SN(j).dts
               A_id(i)=SN(j).id;
            end
         end
     end
     
            for i=1:n
                SN(i).closest=0;
            for j=1:n
                d(j,i)=sqrt((SN(i).x-SN(j).x)^2 + (SN(i).y-SN(j).y)^2);
                if d(j,i)==0
                    d(j,i)=9999;
                end
             end
            end
       
                  
        for i=1:n     
            [M,I]=min(d(:,i)); 
            [Row, Col] = ind2sub(size(d),I); 
            SN(i).closest=Row; 
            SN(i).dis= d(Row,i);
        end
     
        for i=1:n
             if SN(A_id(i)).E>0 && SN(A_id(i)).sel==0 && SN(A_id(i)).cond==1
                set= A_id(i);
                SN(set).sel=1;
                SN(set).pos=1;
                break;
             end
        end
     
     temp=1;   
        while selected<n
             min_dis=9999;
             for i=1:n
                if  SN(i).sel==0 
                    d=sqrt((SN(i).x-SN(set).x)^2 + (SN(i).y-SN(set).y)^2);
                    if d<min_dis
                        min_dis=d;
                        next=i; 
                    end
                end
            end
            selected=selected+1;
            SN(set).dis=min_dis;
            SN(next).sel=1;
            plot([SN(set).x SN(next).x], [SN(set).y SN(next).y])
            hold on;
            set=next;
            temp=temp+1;
            order(temp)=set;
        end

hold off;
figure(3);

dataset.nodeNo = 42; 
dataset.nodePosition(1,:) = [1 42 42]; 
dataset.nodePosition(2,:) = [2 900 900]; 
dataset.NeighborsNo = 5;
dataset.range = 250; 
dataset.atenuationFactor = 1.8; 
dataset.minEnergy = 80; 
dataset.maxEnergy = 100; 
dataset.energyconsumptionperCicle = 0.35;
dataset.energyrecoveryperCicle = 0.2;
dataset.energyfactor = 0.001;
STenergy=10000;
packet=0;
iterationcounter=1;


for a = 3 : dataset.nodeNo
    
   dataset.nodeId = a; 
   garbage.x = randi([1 900]); 
   garbage.y = randi([1 900]); 
   dataset.nodePosition(a,:) = [dataset.nodeId garbage.x garbage.y]; 
   
end

for i = 1 : dataset.nodeNo
    for j = 1: dataset.nodeNo
        garbage.x1 = dataset.nodePosition(i,2); 
        garbage.x2 = dataset.nodePosition(j,2); 
        garbage.y1 = dataset.nodePosition(i,3); 
        garbage.y2 = dataset.nodePosition(j,3);
        
        dataset.euclidiana(i,j) = sqrt(  (garbage.x1 - garbage.x2) ^2 + (garbage.y1 - garbage.y2)^2  ); 
        
    end
end

dataset.weights = lt(dataset.euclidiana,dataset.range);

G=graph(dataset.weights,'omitselfloops'); 

for a = 1 : height(G.Edges)
    garbage.s = G.Edges.EndNodes(a,1);
    garbage.t = G.Edges.EndNodes(a,2);
    garbage.Z(a,:) = dataset.euclidiana(garbage.s,garbage.t);
end
G.Edges.Euclidiana = garbage.Z(:,1);

[dataset.nodePosition(:,4)] = dataset.maxEnergy -(dataset.maxEnergy-dataset.minEnergy)*rand(dataset.nodeNo,1);
dataset.nodePosition(1:2,4)=STenergy;

for a = 1: length(dataset.nodePosition(:,1))
   
    dataset.nodePosition(a,5) = degree(G,dataset.nodePosition(a,1));
    
end

[G.Edges.Pathloss] = (10*dataset.atenuationFactor)*log10(G.Edges.Euclidiana);

for a = 1 : height(G.Edges)
    garbage.Sourcenode = G.Edges.EndNodes(a,1);
    garbage.Targetnode = G.Edges.EndNodes(a,2);
    G.Edges.SourcenodeXpos(a) = dataset.nodePosition(garbage.Sourcenode,2);
    G.Edges.SourcenodeYpos(a) = dataset.nodePosition(garbage.Sourcenode,3);
    G.Edges.TargetnodeXpos(a) = dataset.nodePosition(garbage.Targetnode,2);
    G.Edges.TargetnodeYpos(a) = dataset.nodePosition(garbage.Targetnode,3);
    G.Edges.ActiveEdge(a) = 1;
end

figure('units','normalized','innerposition',[0 0 1 1],'MenuBar','none')
subplot(1,1,1) 

garbage.Xmax = 100;
garbage.Xmin = 0;
garbage.Ymax = 100;
garbage.Ymin = 0;
p = plot(G,'XData',(dataset.nodePosition(:,2)),'YData',(dataset.nodePosition(:,3))); 
line(dataset.nodePosition(1:10,2),dataset.nodePosition(1:10,3),'color','green','marker','o','linestyle','none','markersize',50)
garbage.ax = gca;
garbage.ax.XAxis.TickValues = 0:100:1000;
garbage.ax.YAxis.TickValues = 0:100:1000;
grid on
hold on
title(['Original WSN | ','Nodes number: ',num2str(dataset.nodeNo),' | Nodes range: ', num2str(dataset.range)])
pause(2)

garbage.deadnodelist=[];
garbage.deadnodeneighbors=[];

G2 = shortestpathtree(G,1,2);

fileID = fopen('report-noACO-simulation.txt','w'); 
fprintf(fileID,'%6s %20s %20s %20s %20s\r\n','|NodeNo|','|No ACO Scene|','|Hops|','|Packets sent|','|Dead node|');

while ~isempty(G2.Edges)
    G2 = shortestpathtree(G,1,2);
    iterationcounter=iterationcounter+1;
    if isempty(G2.Edges)
        break
    end
    
    for a = 1 : height(G2.Edges)
        source = G2.Edges.EndNodes(a,1);
        target = G2.Edges.EndNodes(a,2);
        garbage.edgesrow(a,:) = findedge(G,source,target);
    end
    garbage.routingnodes = unique(G2.Edges.EndNodes);
    garbage.routepath = shortestpath(G,1,2);
            
    for a = 1 : length(garbage.routingnodes)
        garbage.b=garbage.routingnodes(a,1);
        dataset.routingnodesPosition(a,:)=dataset.nodePosition(garbage.b,:);
    end
        
    [garbage.Outroutenodes, garbage.Outroutenodesidx] = setdiff(dataset.nodePosition(:,1),garbage.routingnodes(:,1),'stable');
    
    while min(dataset.nodePosition(:,4))>0 
        for a = 1 : length(garbage.routingnodes)
            node=garbage.routingnodes(a,1);
            dataset.nodePosition(node,4)=dataset.nodePosition(node,4)-dataset.energyconsumptionperCicle^rand()+dataset.energyrecoveryperCicle^rand();
            packet=packet+1;
               
        end
        
         for c = 1 : length(garbage.Outroutenodesidx)
             rechargeblenode=garbage.Outroutenodesidx(c,1);
             dataset.nodePosition(rechargeblenode,4)=dataset.nodePosition(rechargeblenode,4)+dataset.energyrecoveryperCicle*dataset.energyfactor*rand();
             b=1;
        end
line(dataset.nodePosition(1:10,2),dataset.nodePosition(1:10,3),'color','green','marker','o','linestyle','none','markersize',100)
    end
    
    [garbage.deadnoderow] = find(dataset.nodePosition(:,4)<=0);
    for a = 1 : length(garbage.deadnoderow)
        deadnode=garbage.deadnoderow(a,1);
        for b = 1 : height(G.Edges)
            if ismember(G.Edges.EndNodes(b,1),deadnode) == 1 || ismember(G.Edges.EndNodes(b,2),deadnode) == 1
                G.Edges.ActiveEdge(b)=0;
                deadnode;
                pause(2)
            end
        end
    end
    garbage.deadnodelist(length(garbage.deadnodelist)+1,1)=deadnode;
    [garbage.deadedgerow]=find(G.Edges.ActiveEdge==0);

    [garbage.deaddatasetnoderow]=find(dataset.nodePosition(:,4)<=0);
    for a = 1 : length(garbage.deaddatasetnoderow)
        b=garbage.deaddatasetnoderow(a,1);
        dataset.nodePosition(b,4)=NaN;
    end
    
    hopsnumber=length(garbage.routingnodes);
    
    msg=['Without ACO - Scene #: ',num2str(iterationcounter),' | Hops : ',num2str(hopsnumber),' | Packets sent: ', num2str(packet),' | Dead node: ', num2str(deadnode),' | Routing nodes: ', num2str(garbage.routepath)];
    disp(msg)
    
    figure('units','normalized','innerposition',[0 0 1 1],'MenuBar','none')
    p = plot(G,'XData',(dataset.nodePosition(:,2)),'YData',(dataset.nodePosition(:,3))); 
    line(dataset.nodePosition(1:10,2),dataset.nodePosition(1:10,3),'color','green','marker','o','linestyle','none','markersize',50);
    garbage.ax = gca;
    garbage.ax.XAxis.TickValues = 0:100:1000;
    garbage.ax.YAxis.TickValues = 0:100:1000;
    hold on;
    
    for a = 1 : length(garbage.deadnodelist)
        garbage.b=garbage.deadnodelist(a,1);
        scatter(dataset.nodePosition(garbage.b,2),dataset.nodePosition(garbage.b,3),'MarkerFaceColor','red');
    end
    
    title(['WSN shortest path: ',num2str(iterationcounter),' |hops: ',num2str(hopsnumber),' |Packets sent: ',num2str(packet),' |Dead node: ',num2str(deadnode),' |Router nodes: ', num2str(garbage.routepath)])
    grid on
    pause(2)
   
    report1=[dataset.nodeNo;iterationcounter;hopsnumber;packet;deadnode];
    fprintf(fileID,'%6.0f %20.0f %20.0f %20.0f %20.0f\r\n',report1);

    G = rmedge(G,garbage.deadedgerow(:,1));

    scatter(dataset.routingnodesPosition(:,2),dataset.routingnodesPosition(:,3),'MarkerFaceColor','green');
    pause(0.2)        

end

fclose(fileID);

    for a = 1 : length(garbage.deadnodelist)
        garbage.b=garbage.deadnodelist(a,1);
        scatter(dataset.nodePosition(garbage.b,2),dataset.nodePosition(garbage.b,3),'MarkerFaceColor','red');
    end

title(['WSN shortest path: ',num2str(iterationcounter),' |hops: ',num2str(hopsnumber),' |Packets sent: ',num2str(packet),' |Dead node: ',num2str(deadnode),' |Router nodes: ', num2str(garbage.routepath),'{\color{red} - ALL ROUTES UNAVAILABLE}']);
