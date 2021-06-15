function [Area,Model]=setParameters(n)

Area.x=n;
Area.y=n;

Sinkx=0.5*Area.x;
Sinky=Sinkx;

p=0.1;
Eo=0.5;

ETX=50*0.000000001;
ERX=50*0.000000001;

Efs=10*0.000000000001;
Emp=0.0013*0.000000000001;

EDA=5*0.000000001;

do=sqrt(Efs/Emp);

rmax=100;

DpacketLen=4000;

HpacketLen=100;

NumPacket=10;

RR=0.5*Area.x*sqrt(2);

Model.n=n;
Model.Sinkx=Sinkx;
Model.Sinky=Sinky;
Model.p=p;
Model.Eo=Eo;
Model.ETX=ETX;
Model.ERX=ERX;
Model.Efs=Efs;
Model.Emp=Emp;
Model.EDA=EDA;
Model.do=do;
Model.rmax=rmax;
Model.DpacketLen=DpacketLen;
Model.HpacketLen=HpacketLen;
Model.NumPacket=NumPacket;
Model.RR=RR;

end