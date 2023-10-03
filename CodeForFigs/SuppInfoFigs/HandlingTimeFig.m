function HandlingTimeFig(Mp,Mr,AllometricStruct)

%function to generate plot for handling time - by which I mean the time
%spent in interacting with prey or prey biomass during different
%strategies. This is a derived quantity and referred to as resource acquisition time 
% in the supplementary material, and not the T_handle introduced in the main MS. 

%for hunting, this resource acquisition time, denoted by tau^h, is computed as the sum
%of the time spent pursuing and subduing prey, and then consuming prey fat
%and muscle mass. The former is estimated as 20% of the allomtric T_handle
%relationship, while the latter is estimated as 80% of the T_handle
%allomteric relationship for the sum of the prey fat and muscle mass
%substituted in place of the full prey mass. 

%for scavenging, tau^s is simply the 80% of the time computed using the T_handle
%allomteric relationship, with the mass of leftovers (prey mass - fat,
%muscle, and skeletal mass) substiuted in place of the full prey mass

%for the kleptoparasite, tau^k is estimated as 10 percent of the allomteric
%T_handle relationship (the assumption here is that stealing is a quick
%thing and does not take as long as pursuing and subduing prey) + 80% of the T_handle
%allomteric relationship for the sum of the prey fat and muscle mass
%substituted in place of the full prey mass. 

%first, compute these differet times; note that these values are converted
%to hours below
for i = 1:numel(Mr)
    for j = 1:numel(Mp)
        tau_h(i,j) = ((0.2*AllometricStruct.ThandleSec_pr(j,i)) + ...
            (0.8*AllometricFunctions('thandle_s', Mp(j), AllometricStruct.ConsumedMassGm_r(i)/1000)))/60/60;
        tau_s(i,j) = (0.8*AllometricFunctions('thandle_s', Mp(j), AllometricStruct.ConsumedMassGmSc_r(i)/1000))/60/60;
        tau_k(i,j) = ((0.1*AllometricStruct.ThandleSec_pr(j,i)) + ...
            (0.8*AllometricFunctions('thandle_s', Mp(j), AllometricStruct.ConsumedMassGm_r(i)/1000)))/60/60;
    end
end

% Create figure
figure1 = figure('PaperUnits','centimeters','PaperType','<custom>','PaperSize',[48 17.2],'Color',[1 1 1]);

%subplot 1: hunting handling time
% Create axes
axes1 = axes('Position',[0.12962962962963 0.24357007117369 0.231111111111111 0.67517992882631]);
hold(axes1,'on');
%plotting
contourf(Mp,Mr,tau_h,'LineStyle','none','LevelStep',1,'Fill','on');
plot3(Mp,Mp,1000*ones(size(Mp)),'LineWidth',2,'LineStyle','--','Color',[0.941176474094391 0.941176474094391 0.941176474094391]);
%labels + other prop
ylabel('Prey mass,      (kg)');
title('A');
axis(axes1,'tight');
set(axes1,'CLim',[0 572],'FontSize',30,'XScale','log','YScale','log');
hold(axes1,'off');

%subplot 2: scavenging handling time
% Create axes
axes2 = axes('Position',[0.40962962962963 0.24357007117369 0.233652475332147 0.677263262159644]);
hold(axes2,'on');
%plotting
contourf(Mp,Mr,tau_s,'LineColor',[1 1 1],'LevelStep',10);
plot3(Mp,Mp,1000*ones(size(Mp)),'LineWidth',2,'LineStyle','--','Color',[1 1 1]);
%labels + other prop
ylabel('$M_r$');
title('B');
box(axes2,'on');
axis(axes2,'tight');
set(axes2,'BoxStyle','full','CLim',[0 572],...
    'FontSize',30,'Layer','top','XMinorTick','on','XScale','log','YMinorTick','on','YScale','log');
hold(axes2,'off');

%subplot 2: scavenging handling time
% Create axes
axes3 = axes('Position',[0.691613654743338 0.24357007117369 0.223201160071477 0.676477503705024]);
hold(axes3,'on');
%plotting
contourf(Mp,Mr,tau_k,'LineStyle','none','LineColor',[0 0 0],'LevelStep',1);
plot3(Mp,Mp,1000*ones(size(Mp)),'LineWidth',2,'LineStyle','--','Color',[1 1 1]);
%labels + other prop
xlabel('$M_p$');
title('C');
axis(axes3,'tight');
set(axes3,'CLim',[0 572],'FontSize',30,'XMinorTick','on','XScale','log','YMinorTick','on','YScale','log');
hold(axes3,'off');
colorbar(axes3,'Position',[0.931481481481478 0.24375 0.0159259259259291 0.585416666666667]);

%annotations and text boxes
% Create textbox
annotation(figure1,'textbox',[0.437777777777777 0.76698523206751 0.0312035661218425 0.0611814345991561],...
    'Color',[1 1 1],'String',{'20'},'LineStyle','none','FontSize',16);

% Create textbox
annotation(figure1,'textbox',[0.457777777777777 0.708651898734177 0.0312035661218425 0.0611814345991561],...
    'Color',[1 1 1],'String',{'10'},'LineStyle','none','FontSize',16);

% Create textbox
annotation(figure1,'textbox',[0.21111111111111 0.683651898734177 0.0312035661218425 0.0611814345991561],...
    'Color',[1 1 1],'String',{'20'},'LineStyle','none','FontSize',16);

% Create textbox
annotation(figure1,'textbox',[0.224444444444443 0.639901898734177 0.0312035661218425 0.0611814345991561],...
    'Color',[1 1 1],'String',{'10'},'LineStyle','none','FontSize',16);

% Create line
annotation(figure1,'line',[0.126666666666666 0.359259259259259],[0.5375 0.989583333333333],'Color',[1 1 1]);

% Create line
annotation(figure1,'line',[0.128148148148148 0.360740740740741],[0.4625 0.914583333333333],'Color',[1 1 1]);

% Create line
annotation(figure1,'line',[0.685925925925926 0.917777777777776],[0.470833333333333 0.93125],'Color',[1 1 1]);

% Create textbox
annotation(figure1,'textbox',[0.787407407407406 0.658651898734177 0.0312035661218425 0.0611814345991561],...
    'Color',[1 1 1],'String',{'10'},'LineStyle','none','FontSize',16);

% Create arrow
annotation(figure1,'arrow',[0.401931649331352 0.913818722139673],[0.0571428571428574 0.0571428571428572]);

% Create textbox
annotation(figure1,'textbox',[0.919986792141323 0.834691681735988 0.0491312488935678 0.0970464135021097],...
    'String',{'$\tau$'},'Interpreter','latex','FontSize',30,'EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',[0.916291893676736 0.845716707197949 0.0813521545319466 0.0886075949367089],...
    'String',{'     (hr)'},'LineStyle','none','FontSize',27);

% Create textbox
annotation(figure1,'textbox',[0.777048043585932 0.706866184448463 0.0312035661218425 0.0611814345991561],...
    'Color',[1 1 1],'String',{'20'},'LineStyle','none','FontSize',16);

% Create line
annotation(figure1,'line',[0.676272081888723 0.908123933740572],[0.518750000000003 0.97291666666667],'Color',[1 1 1]);


