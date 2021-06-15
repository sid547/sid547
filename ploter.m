function deadNum=ploter(Sensors,Model)

    deadNum=0;
    n=Model.n;
    for i=1:n
       
        if (Sensors(i).E>0)
            
            if(Sensors(i).type=='N' )      
                plot(Sensors(i).xd,Sensors(i).yd,'o');     
            else       
                plot(Sensors(i).xd,Sensors(i).yd,'kx','MarkerSize',10);
            end
            
        else
            deadNum=deadNum+1;
            plot(Sensors(i).xd,Sensors(i).yd);
        end
        
        hold on;
        
    end 
    plot(Sensors(n+1).xd,Sensors(n+1).yd,'g*','MarkerSize',28); 
    axis square

end