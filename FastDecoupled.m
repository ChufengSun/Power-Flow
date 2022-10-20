
clc
clear all
%  Brahcn    Bus    To bus  R         X          Line           Rtio
%                                                Charging B     
linedata=[   1      2       0.01938   0.05917    0.0528         1
             1      5       0.05403   0.22304    0.0492         1
             2      3       0.04699   0.19797    0.0438         1
             2      4       0.05811   0.17632    0.0340         1
             2      5       0.05695   0.17388    0.0346         1
             3      4       0.06701   0.17103    0.0128         1
             4      5       0.01335   0.04211    0.0            1
             4      7       0.0       0.20912    0.0        0.978
             4      9       0.0       0.55618    0.0        0.969
             5      6       0.0       0.25202    0.0        0.932
             6     11       0.09498   0.19890    0.0            1
             6     12       0.12291   0.25581    0.0            1
             6     13       0.06615   0.13027    0.0            1
             7      8       0.0       0.17615    0.0            1
             7      9       0.0       0.11001    0.0            1
             9     10       0.03181   0.08450    0.0            1
             9     14       0.12711   0.27038    0.0            1
            10     11       0.08205   0.19207    0.0            1
            12     13       0.22092   0.19988    0.0            1
            13     14       0.17093   0.34802    0.0            1];
        
        numberline=length(linedata(:,1))
        a=linedata(:,1);          % Number of Buses
        b=linedata(:,2);          % Number of to Buses
        R=linedata(:,3);          % Get the resistance
        X=linedata(:,4);          % Get the Reactance
        B_Charging=i*linedata(:,5)/2;        % Get B/2
        T=linedata(:,6);           % Get the ratio of transformer
        Ti=T*i;                  
       
        
    %     |  1   |  2  |  3     |   4        |    5    |    6     |   7   |     8     |   9    |     10       |    11   |    12   |    13  |    14  |   15   |
     %    |  Bi  | Type| Fin-V  | FinAng-Deg |  PL-MW  | QL-MVAR  |  PGen | QGen-MVAR | BaseKV | DesiredVolts | MaxMVAR | MinMVAR | ShuntG |  ShuntB| Remote |        
        
node   = [  1      3     1.060        0.0        0.0       0.0      232.4     -16.9      0.0       1.060          0.0         0.0      0.0     0.0        0;
            2      2     1.045       -4.98      21.7      12.7      40.0      42.4       0.0       1.045         50.0       -40.0      0.0     0.0        0;
            3      2     1.010      -12.72      94.2      19.0       0.0      23.4       0.0       1.010         40.0         0.0      0.0     0.0        0;
            4      0     1.019      -10.33      47.8      -3.9       0.0       0.0       0.0       0.0            0.0         0.0      0.0     0.0        0;
            5      0     1.020       -8.78       7.6       1.6       0.0       0.0       0.0       0.0            0.0         0.0      0.0     0.0        0;
            6      2     1.070      -14.22      11.2       7.5       0.0      12.2       0.0       1.070         24.0        -6.0      0.0     0.0        0;
            7      0     1.062      -13.37       0.0       0.0       0.0       0.0       0.0       0.0            0.0         0.0      0.0     0.0        0;
            8      2     1.090      -13.36       0.0       0.0       0.0      17.4       0.0       1.090         24.0        -6.0      0.0     0.0        0;
            9      0     1.056      -14.94      29.5      16.6       0.0       0.0       0.0       0.0            0.0         0.0      0.0     0.19       0;
           10      0     1.051      -15.10       9.0       5.8       0.0       0.0       0.0       0.0            0.0         0.0      0.0     0.0        0;
           11      0     1.057      -14.79       3.5       1.8       0.0       0.0       0.0       0.0            0.0         0.0      0.0     0.0        0;
           12      0     1.055      -15.07       6.1       1.6       0.0       0.0       0.0       0.0            0.0         0.0      0.0     0.0        0;
           13      0     1.050      -15.16      13.5       5.8       0.0       0.0       0.0       0.0            0.0         0.0      0.0     0.0        0;
           14      0     1.036      -16.04      14.9       5.0       0.0       0.0       0.0       0.0            0.0         0.0      0.0     0.0        0];
      
      numberbus=max(node(:,1));         % Get the number of the node
      V=node(:,10);
      V(~V)=1;                          % The initial voltage from 1
      Vangle=zeros(numberbus,1);        % The initial angle of voltage from 0
      P0=(node(:,7)-node(:,5))/100;           % Get P of each bus
      Q0=(node(:,8)-node(:,6))/100;           % Get Q of each bus
      C=node(:,13)+i*node(:,14);              % Get the Shunt
      
      PVbus=node(:,2)==2;                    % Define 2 is PV bus
      PQbus=node(:,2)==0;                    % Define 0 is PQ bus
      numberPVbus=sum(PVbus);                % Define The number of PV bus
      numberPQbus=sum(PQbus);                % Define the number of PQ bus
      PQ=find(node(:,2)==0|node(:,2)==1);    % Find the order of PQ from the form
      
     
      
        
        Z=R+i*X;       % Define the impedance

        Y=(1./Z);       % Define the resistance
        
        
        
        
        %=====================off Diagonal for Y bus=============================
        Ybus=zeros(14,14);     % Create a new empty Y matrix bus
        for k=1:numberline
         Ybus(linedata(k,1),linedata(k,2))=Ybus(linedata(k,1),linedata(k,2))-Y(k)/T(k);
         Ybus(linedata(k,2),linedata(k,1))=Ybus(linedata(k,1),linedata(k,2));
        end
        
        %===================Diagonal for Y bus=============================
        
       for m=1:numberbus
           for n=1:numberline
               if m==linedata(n,1);
                   Ybus(m,m)=Ybus(m,m)+Y(n)/(T(n)^2)+B_Charging(n);
               elseif m==linedata(n,2);
                   Ybus(m,m)=Ybus(m,m)+Y(n)+B_Charging(n);
               end
           end
           Ybus(m, m) = Ybus(m, m) + C(m);
       end
       
  
    
    
     Yabs=abs(Ybus);    % Get the real of Y bus
    Yangle=angle(Ybus);    % Get the angle of Y bus
    Gi=real(Ybus);            % Get the real of Y bus
    Bi=imag(Ybus);         % Get the imag of Y bus


    
    
%%%%%%%%%% Get the initial P and Q Value %%%%%%%%%%%%%%%%%%%%%%%%%
      Pi=zeros(numberbus,1);
      Qi=zeros(numberbus,1);
      for m=1:numberbus
          for n=1:numberbus
              Pi(m)=Pi(m)+Yabs(m,n)*V(m)*V(n)*cos(Vangle(m)-Vangle(n)-Yangle(m,n));
              Qi(m)=Qi(m)+Yabs(m,n)*V(m)*V(n)*sin(Vangle(m)-Vangle(n)-Yangle(m,n));
             
          end
          
      end
      
      dP=P0-Pi;
      dQ=Q0-Qi;
      dm=[dP(2:end);dQ(PQ)];  % Get the first time mismatches   
   
    
      Tol=1  
      Iter=0;
      
      
 
  while max(abs(Tol))>1e-2 && (Iter<20)  
      
    
    %%%%%% Creat the equations to create B11 and B22 %%%%%%%%%%%%%
     dP=dP(2:end)./V(2:end);    
     dQ=dQ(PQ)./V(PQ);
   
     Vangle=Vangle(2:end);  %
     V=V(PQ);
    
   %%%%%%%%%%%% Create B11 %%%%%%%%%%%%%%%%%%%%%%%
    for i=1:(numberPQbus+numberPVbus)
        for j=1:(numberPQbus+numberPVbus)
            sum=0
            sum=Bi(i+1,j+1)
            if i==j
                B11(i,j)=sum;
            else
                B11(i,j)=Bi(i+1,j+1);
            end
        end
    end
    
    
            
     %%%%%%%%%%%% B22 %%%%%%%%%%%%%%%%
     
     
     
     for i=2:numberPQbus+1
         k1=PQ(i-1)
          for j=2:numberPQbus+1
              k2=PQ(j-1)
              if k1==k2
                  sum1=0
                  sum1=Bi(k1,k2);
                  B22(i-1,j-1)=2*Bi(k1,k2)-sum1
              else
                  B22(i-1,j-1)=Bi(k1,k2)
              end
          end
     end
     
     
    
   
     %%%%%%%%%%%%  Get the angle and V after the calculation%%%%%%%%%%
    ddelta=inv(B11)*dP;
    dV=inv(B22)*dQ;
    delta_new=Vangle-ddelta;
    V_new=V-dV;
    
    
    
    Vangle=[0;delta_new];    %  Get the Vangle excepting slack bus
      V=node(:,10);           % Get the V from the node data
      V(~V)=V_new;           % Use the V0 to instead of 0 
      
      
      
    %%%%%%  Get a new P and Q after the calculation %%%%%%%%%%%%%
      Pi=zeros(numberbus,1);
      Qi=zeros(numberbus,1);
      for m=1:numberbus
          for n=1:numberbus
              Pi(m)=Pi(m)+Yabs(m,n)*V(m)*V(n)*cos(Vangle(m)-Vangle(n)-Yangle(m,n));
              Qi(m)=Qi(m)+Yabs(m,n)*V(m)*V(n)*sin(Vangle(m)-Vangle(n)-Yangle(m,n));
              
          end
          
      end
    
    
      dP=P0-Pi;
      dQ=Q0-Qi;
      dm=[dP(2:end)./V(2:end);dQ(PQ)./V(PQ)];  % Mismatches
       
      
     disp dm
      
      Tol=dm;
      Iter=Iter+1;
    
    
    
  end    
   Vangle=Vangle*(180/pi);
  disp V;
  disp Vangle;