function AllometricRltnshipsForEncounterProbFigure(Mp,Mr,AllometricStruct)

%function to generate figure for allometric relationships that go into computing encounter probability disribution:
% population density, body velocity, reaction distance, and Rohr probability

%requires AllometricStruct (outputed from SDP run) to be loaded

% Create figure
figure1 = figure('PaperUnits','centimeters','PaperType','<custom>','PaperSize',[48 36.2],'Color',[1 1 1]);

%subplot 1.1: population density: prey
axes1 = axes('Parent',figure1,'Position',[0.13 0.615077101485615 0.108095238095238 0.334181658622203],'YMinorTick','on','YScale','log');
hold(axes1,'on');
colororder([0 0.447 0.741]);
% Activate the left side of the axes
yyaxis(axes1,'left');
%plotting
semilogy(Mr,AllometricStruct.RhoPerm2_r/10^(-6),'LineWidth',2,'Color','b');
%labels + other prop
ylabel({'Population density, \rho','(num/km^2)         '});
set(axes1,'YColor',[0 0.447 0.741],'YMinorTick','on','YScale','log');
% Activate the right side of the axes
yyaxis(axes1,'right');
%plotting
semilogy(Mr,AllometricStruct.RhoPerm2_r.*Mr/10^(-6),'LineWidth',2,'Color','r');
set(axes1,'YColor',[0.85 0.325 0.098],'YMinorTick','on','YScale','log');
xlabel('Body mass (kg)');
title('A');
box(axes1,'on');
axis(axes1,'tight');
set(axes1,'FontSize',30);
hold(axes1,'off');

%subplot 1.2: population density: prey
axes7 = axes('Parent',figure1,'Position',[0.287698412698413 0.614203454894434 0.117063492063492 0.335892514395393],'YMinorTick','on','YScale','log');
hold(axes7,'on');
colororder([0 0.447 0.741]);
% Activate the left side of the axes
yyaxis(axes7,'left');
semilogy(Mp,AllometricStruct.RhoPerm2_c/10^(-6),'LineWidth',2);
set(axes7,'YColor',[0 0.447 0.741],'YMinorTick','on','YScale','log'); % Set the remaining axes properties
% Activate the right side of the axes
yyaxis(axes7,'right');
semilogy(Mp,AllometricStruct.RhoPerm2_c.*Mp/10^(-6),'LineWidth',2);
%labels + other prop
ylabel('Biomass density (kg/km^2)');
set(axes7,'YColor',[0.85 0.325 0.098],'YMinorTick','on','YScale','log');
% Create title
title('B');
box(axes7,'on');
axis(axes7,'tight');
hold(axes7,'off');
% Set the remaining axes properties
set(axes7,'FontSize',30);


%subplot 2: body velocity
% Create axes
axes2 = axes('Position',[0.620024739262542 0.613729508196721 0.271152582737948 0.330891409499012]);
hold(axes2,'on');
%plotting
plot(Mp,AllometricFunctions('v_mpers', Mp),'LineWidth',2);
%labels + other prop
ylabel('Body velocity       (m/s)');
xlabel('Predator mass, ');
title('C');
box(axes2,'on');
axis(axes2,'tight');
set(axes2,'FontSize',30);
hold(axes2,'off');

%subplot 3: reaction distance
%first compute reaction distance
for j = 1:numel(Mr)
    for i = 1:numel(Mp)
        RcnDistanceM_pj(j,i) = AllometricFunctions('reactiondist_m', Mp(i), Mr(j));
    end
end
% Create axes
axes3 = axes('Position',[0.13 0.116981132075472 0.274697380307136 0.334181658622203]);
hold(axes3,'on');
%plotting
surf(Mp,Mr,RcnDistanceM_pj,'EdgeColor','none');
plot3(Mp,Mp,200*ones(size(Mp)),'LineWidth',1,'LineStyle','--','Color',[1 1 1]);
%labels + other prop
ylabel('Target mass,     (kg)');
xlabel('Predator mass, ');
title('D');
axis(axes3,'tight');
set(axes3,'FontSize',30,'XMinorTick','on','XScale','log','YMinorTick','on','YScale','log');
hold(axes3,'off');
colorbar(axes3,'Position',[0.416292205689351 0.117250673854447 0.0180668473351409 0.285413260571782]);

%subplot 4: linking probability (Rohr et al; Matthias et al)
% Create axes
axes4 = axes('Position',[0.620024739262542 0.119877049180328 0.273380861460132 0.329918032786885]);
hold(axes4,'on');
%plotting
surf(Mp,Mr,transpose(AllometricStruct.LinkProb_pr),'EdgeColor','none');
plot3(Mp,Mp,200*ones(size(Mp)),'LineWidth',1,'LineStyle','--','Color',[0 0 0]);
%labels + other prop
title('E');
axis(axes4,'tight');
set(axes4,'FontSize',30,'XMinorTick','on','XScale','log','YMinorTick','on','YScale','log');
hold(axes4,'off');
colorbar(axes4,'Position',[0.911020776874433 0.131401617250674 0.0194218608852774 0.241549202421457]);

%blank plots for y-oriented latex axis lables
%Create axes
axes5 = axes('Parent',figure1,'Position',[0.994716981132075 0.992546583850932 0.00301886792452832 0.00745341614906825]);
hold(axes5,'on');
ylabel('$v$','Interpreter','latex');
hold(axes5,'off');
set(axes5,'FontSize',30,'XTick',zeros(1,0),'YTick',zeros(1,0));

% Create axes
axes6 = axes('Parent',figure1,'Position',[1.0022641509434 0.980124223602485 0.00301886792452821 0.00745341614906814]);
hold(axes6,'on');
ylabel('$M_j$','Interpreter','latex');
hold(axes6,'off');
set(axes6,'FontSize',30,'XTick',zeros(1,0),'YTick',zeros(1,0));

%textboxes and annotations
% Create textbox
annotation(figure1,'textbox',[0.896260162601625 0.370888845585357 0.09 0.0838509316770186],...
    'String',{'Prob.','success'},'LineStyle','none','FontSize',24);

% Create textbox
annotation(figure1,'textbox',[0.309149685254224 0.00421326677722028 0.0624806904342939 0.061614906121485],...
    'String',{'$M_p$'},'Interpreter','latex','FontSize',33,'EdgeColor','none');

% Create arrow
annotation(figure1,'arrow',[0.40976211653829 0.899622641509431],[0.033863826732088 0.0348360655737715]);

% Create textbox
annotation(figure1,'textbox',[0.441164459443336 0.392886367685536 0.0705660377358491 0.0521739130434783],...
    'String',{'   (m)'},'LineStyle','none','FontSize',27,'FontName','Helvetica Neue');

% Create textbox
annotation(figure1,'textbox',[0.406508175820262 0.394352306993273 0.0594591450241377 0.061614906121485],...
    'String',{'$d_{pj}$'},'Interpreter','latex','FontSize',33,'EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',[0.807262892801395 0.487590011911306 0.0624806904342939 0.061614906121485],...
    'String',{'$M_p$'},'Interpreter','latex','FontSize',33,'EdgeColor','none');
