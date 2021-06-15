function Sensors=ConfigureSensors(Model,n,GX,GY)

EmptySensor.xd=0;
EmptySensor.yd=0;
EmptySensor.G=0;
EmptySensor.df=0;
EmptySensor.type='N';
EmptySensor.E=0; 
EmptySensor.id=0;
EmptySensor.dis2sink=0;
EmptySensor.dis2ch=0;
EmptySensor.MCH=n+1;   


Sensors=repmat(EmptySensor,n+1,1);

for i=1:1:n
    
    Sensors(i).xd=GX(i); 
    Sensors(i).yd=GY(i);
    Sensors(i).G=0;
    Sensors(i).df=0; 
    Sensors(i).type='N';
    Sensors(i).E=Model.Eo;
    Sensors(i).id=i;    

end 

Sensors(n+1).xd=Model.Sinkx; 
Sensors(n+1).yd=Model.Sinky;
Sensors(n+1).E=100;
Sensors(n+1).id=n+1;

end