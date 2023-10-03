function EnergeticCostsFig(Mp,Mr,AllometricStruct)

%requires AllometricStruct (outputed from SDP run) to be loaded

% Create figure
figure1 = figure('PaperUnits','centimeters','PaperType','<custom>','PaperSize',[57 18.7],'Color',[1 1 1]);

%subplot A: energy expenditure for scavenger/kleptoparasite for a day and
%BMR, MMR, etc
%create axes
axes3 = axes('Position',[0.0741935483870968 0.2 0.225806451612903 0.725],'YMinorTick','on','YScale','log');
hold(axes3,'on');
colororder([0.85 0.325 0.098]);
%Activate the left side of the axes
yyaxis(axes3,'left');
%plotting
semilogy(Mp,AllometricStruct.Bmr12hr_p/12/60/60,'LineWidth',3,...
    'DisplayName','BMR','Color',[0 0 1]); %convert BMR expenditure for 12 hours to per second
semilogy(Mp,AllometricStruct.FmrJperSec_p,'LineWidth',3,'DisplayName','FMR','Color',[0 1 0]);
semilogy(Mp,AllometricStruct.MmrJperSec_p,'LineWidth',3,'DisplayName','MMR','Color',[0 0 0]);
%Create ylabel + other prop
ylabel('Metabolic rate (J/s)');
set(axes3,'YColor',[0 0.447 0.741],'YMinorTick','on','YScale','log');
% Activate the right side of the axes
yyaxis(axes3,'right');
%plotting
semilogy(Mp,AllometricStruct.Bmr12hr_p + (AllometricStruct.FmrJperSec_p*12*60*60),'LineWidth',3,'LineStyle','--');
%labels + other prop
ylabel({'Daily energy expenditure:','scavenger/kleptoparasite (J)'});
set(axes3,'YColor',[0.85 0.325 0.098],'YMinorTick','on','YScale','log');
xlabel('Predator mass,  ');
title('A');
xlim(axes3,[0 501]);
box(axes3,'on');
hold(axes3,'off');
set(axes3,'FontSize',30,'LineStyleOrderIndex',2);
% Create legend
legend1 = legend('BMR','FMR','MMR');
set(legend1,'Position',[0.220829758283813 0.217146833429729 0.0710491367861885 0.204453441295547],...
    'EdgeColor',[1 1 1]);
hold(axes3,'off');

%next, we plot teh energy expenditure for the hunter per day, for num.
%successful encounters = 1 and 2, as a fucntion of predator and prey mass.
%So first, we calculate these numbers
for i = 1:numel(Mr)
    for j = 1:numel(Mp)
        EnergyExp_nh1(i,j) = AllometricStruct.Bmr12hr_p(j) + (AllometricStruct.FmrJperSec_p(j)*12*60*60) ...
            - AllometricStruct.FmrJperSec_p(j)*(0.2*AllometricStruct.ThandleSec_pr(j,i)) + ...
            AllometricStruct.MmrJperSec_p(j)*(0.2*AllometricStruct.ThandleSec_pr(j,i)); %subtract fmr for time spent interacting with prey, 
        %and add mmr for that time (for one encounter)
        EnergyExp_nh2(i,j) = AllometricStruct.Bmr12hr_p(j) + (AllometricStruct.FmrJperSec_p(j)*12*60*60) ...
            - 2*AllometricStruct.FmrJperSec_p(j)*(0.2*AllometricStruct.ThandleSec_pr(j,i)) +...
            2*AllometricStruct.MmrJperSec_p(j)*(0.2*AllometricStruct.ThandleSec_pr(j,i)); %same, for two encounters
    end
end

%subplot B: energy expenditure for hunter, for 1 encounter in 24 hours, as a function of predator and prey mass
%Create axes
axes1 = axes('Position',[0.490322580645161 0.2 0.20857825567503 0.721666666666667]);
hold(axes1,'on');
%plotting
contourf(Mp,Mr,EnergyExp_nh1,'LineStyle','none','LevelStep',100000);
%labels + other prop
ylabel('Prey mass,       (kg)');
xlabel({'Predator mass,'});
title('B');
box(axes1,'on');
axis(axes1,'tight');
set(axes1,'BoxStyle','full','CLim',[3229955.68590808 263576613.891191],'FontSize',30,'Layer','top'); %these limits are set AFTER looking at the 
%min and max values attained by both EnergyExp_nh1 and EnergyExp_nh2.
%Please check these values before plotting (as a sanity check)
hold(axes1,'off');

%subplot C: energy expenditure for hunter, for 2 encounter in 24 hours, as a function of predator and prey mass
% Create axes
axes2 = axes('Position',[0.727096774193548 0.2 0.204635603345281 0.720999073364008]);
hold(axes2,'on');
%plotting
contourf(Mp,Mr,EnergyExp_nh2,'LineStyle','none','LevelStep',100000);
%labels + other prop
ylabel('$M_r$','Interpreter','latex');
title('C');
box(axes2,'on');
axis(axes2,'tight');
set(axes2,'BoxStyle','full','CLim',[3229955.68590808 263576613.891191],'FontSize',30,'Layer','top','YTick',zeros(1,0));%these limits are set AFTER looking at the 
%min and max values attained by both EnergyExp_nh1 and EnergyExp_nh2.
%Please check these values before plotting (as a sanity check)
%Create colorbar
colorbar(axes2,'Position',[0.942198327359617 0.283333333333333 0.0155555555555555 0.6375]);
hold(axes2,'off');


%textboxes and annotations
% Create textbox
annotation(figure1,'textbox',[0.9305376344086 0.185108299595142 0.0670650730411686 0.0850202429149797],...
    'String',{'J/day'},'LineStyle','none','FontSize',27,'FontName','Helvetica Neue');

% Create line
annotation(figure1,'line',[0.398064516129032 0.398064516129032],[0.990784750337379 0.0109514170040454],'LineStyle',':');

% Create textbox
annotation(figure1,'textbox',[0.656773885404292 0.00974759292146609 0.0549713909863476 0.100404857141286],...
    'String',{'$M_p$'},'Interpreter','latex','FontSize',33,'EdgeColor','none');

% Create arrow
annotation(figure1,'arrow',[0.740243215565796 0.940314900153609],[0.048582995951417 0.0503524040308517]);

% Create textbo
annotation(figure1,'textbox',[0.693099173780084 0.000386075529302286 0.0610889774236387 0.0991902834008097],...
    'String',{'(kg)'},'FontSize',33,'FontName','Helvetica Neue','EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',[0.262727950021768 0.000386075529302282 0.0610889774236388 0.0991902834008097],...
    'String',{'(kg)'},'FontSize',33,'FontName','Helvetica Neue','EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',[0.228370574259046 0.00974759292146612 0.0549713909863476 0.100404857141286],...
    'String',{'$M_p$'},'Interpreter','latex','FontSize',33,'EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',[0.49361324458098 0.872307888494534 0.031084656084656 0.0396475770925114],...
    'String','$n^h$','Interpreter','latex','FontSize',30,'FontName','Helvetica Neue','FitBoxToText','off','EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',[0.514115890083623 0.874332179992511 0.0612809353132011 0.0396475770925114],...
    'String',{'= 1'},'FontSize',30,'FontName','Helvetica Neue','FitBoxToText','off','EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',[0.731048813790747 0.816266858058419 0.0442273974576952 0.0936643160306491],...
    'String',{'$n^h$'},'Interpreter','latex','FontWeight','bold','FontSize',30,'FontName','Helvetica Neue','EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',[0.752872503840235 0.872307888494535 0.0540058030380703 0.0396475770925114],...
    'String',{'= 2'},'FontSize',30,'FontName','Helvetica Neue','FitBoxToText','off','EdgeColor','none');




