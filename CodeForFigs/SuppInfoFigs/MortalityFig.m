function MortalityFig(Mp,Mr,Mc,AllometricStruct)

%function to generate plot for mortality SI fig (Fig. S5) 

% Create figure
figure1 = figure('Color',[1 1 1]);
colormap(hot);

%subplot 1: baseline mortality
%Create axes
axes1 = axes('Parent',figure1,'Position',[0.116991113744851 0.693647540983607 0.325333911535126 0.252049180327869]);
hold(axes1,'on');
%plotting
plot(Mp,AllometricStruct.MuPerSec_p,'Parent',axes1);
%labels + other prop
ylabel(['Baseline              ';'mortality,    (s^{-1})']);
title('A');
box(axes1,'on');
axis(axes1,'tight');
set(axes1,'FontSize',30,'XScale','log','XTick',[10 100 500]);
hold(axes1,'off');

%now compute mortality associated with one scavenging encounter, 
%one hunting encounter, and one kleptoparasitic encouner as a
%function of Mp and Mr (delta_1^i where i is h, k, or s)
for i = 1:numel(Mr)
    for j = 1:numel(Mp)
        deltaH1(i,j) = 24*60*60*AllometricStruct.MuPerSec_p(j) - 0.2*AllometricStruct.ThandleSec_pr(j,i)*AllometricStruct.MuPerSec_p(j)...
            + 0.2*AllometricStruct.ThandleSec_pr(j,i)*AllometricStruct.MuPerSec_p(j)*(1+Mr(i)/Mp(j));
        deltaSc1(i,j) = 24*60*60*AllometricStruct.MuPerSec_p(j);
    end
end

for i = 1:numel(Mc)
    for j = 1:numel(Mp)
        deltaSt1(i,j) = 24*60*60*AllometricStruct.MuPerSec_p(j) - 0.1*AllometricStruct.ThandleSec_pr(j,i)*AllometricStruct.MuPerSec_p(j)...
            + 0.1*AllometricStruct.ThandleSec_pr(j,i)*AllometricStruct.MuPerSec_p(j)*(1+(2*Mc(i)/Mp(j)));
    end
end

%subplot 2: scav mortality for a day, with 1 encounter
axes2 = axes('Parent',figure1,'Position',[0.59028887092959 0.545081967213115 0.319511649452023 0.399590163934426]);
hold(axes2,'on');
%plotting
contourf(Mp,Mr,log10(deltaSc1),'Parent',axes2,'LineStyle','none','LevelStep',0.005);
%labels + other prop
ylabel('Prey mass,      (kg)');
title('B');
box(axes2,'on');
axis(axes2,'tight');
set(axes2,'BoxStyle','full','CLim',[-4.35070891948097 -0.969324788982467],...
    'FontSize',30,'Layer','top','XScale','log','XTick',[10 100 500],'YScale','log','YTick',[10 100 1000],'YTickLabel',{'10','100','1000'});
hold(axes2,'off');

%subplot 3: hunting mortality for a day, with 1 encounter
axes3 = axes('Parent',figure1,'Position',[0.116991113744851 0.11 0.325333911535126 0.479139344262295]);
hold(axes3,'on');
%plotting
contourf(Mp,Mr,log10(deltaH1),'Parent',axes3,'LineStyle','none','LevelStep',0.01);
plot3(Mp,500*ones(size(Mp)),1000*ones(size(Mp)),'Parent',axes3,'LineStyle','--','Color',[0.901960784313726 0.901960784313726 0.901960784313726]);
%labels + other prop
ylabel('Prey mass,      (kg)');
xlabel('Predator mass,      (kg)');
title('C');
box(axes3,'on');
axis(axes3,'tight');
set(axes3,'BoxStyle','full','CLim',[-4.35070891948097 -0.969324788982467],'FontSize',30,'Layer','top','XMinorTick','on','XScale','log','XTick',...
    [10 100 500],'XTickLabel',{'10','100','500'},'YMinorTick','on','YScale','log','YTickLabel',{'10','100','1000'});
hold(axes3,'off');

%subplot 4: stealing mortality for a day, with 1 encounter
axes4 = axes('Parent',figure1,'Position',[0.59028887092959 0.11 0.320378952140661 0.326475409836066]);
hold(axes4,'on');
%plotting
contourf(Mp,Mc,log10(deltaSt1),'Parent',axes4,'LineStyle','none','LevelStep',0.01);
%labels + other prop
ylabel('Competitor mass,      (kg)');
xlabel('$M_p$','Interpreter','latex');
title('D');
box(axes4,'on');
axis(axes4,'tight');
set(axes4,'BoxStyle','full','CLim',[-4.35070891948097 -0.969324788982467],...
    'FontSize',30,'Layer','top','XScale','log','XTick',[10 100 500],'YScale','log','YTick',[10 100 500]);
hold(axes4,'off');
% Create colorbar
colorbar(axes4,'Position',[0.937767312918131 0.109884332281809 0.0187831173517519 0.790730421816552],...
    'TickLabels',{'-4','3.5','-3','-2.5','-2','-1.5','-1'});


%Additional blank axes for extra y labels in latex
axes5 = axes('Parent',figure1,'Position',[0.116402116402116 0.717829457364341 0.00132275132275132 0.0155038759689923]);
hold(axes5,'on');
ylabel('$\mu$','Interpreter','latex');
axis(axes5,'tight');
set(axes5,'FontSize',30,'XTick',zeros(1,0),'YTick',zeros(1,0));
hold(axes5,'off');

% Create axes
axes6 = axes('Parent',figure1,'Position',[0.996693121693122 0.976744186046512 0.00132275132275128 0.0170542635658915]);
ylabel('$M_r$','Interpreter','latex');
set(axes6,'FontSize',30,'XTick',zeros(1,0),'YTick',zeros(1,0));

% Create axes
axes7 = axes('Parent',figure1,'Position',[1.00330687830688 0.961240310077519 0.00132275132275139 0.0170542635658915]);
ylabel('$M_r$','Interpreter','latex');
set(axes7,'FontSize',30,'XTick',zeros(1,0),'YTick',zeros(1,0));

% Create axes
axes11 = axes('Parent',figure1,'Position',[0.997737556561086 0.0461065573770492 0.00150829562594268 0.0235655737704918]);
ylabel('$M_c$','Interpreter','latex');
set(axes11,'FontSize',30,'XTick',zeros(1,0),'YTick',zeros(1,0));

% Create textbox
annotation(figure1,'textbox',[0.119155354449472 0.539471311475412 0.0399698340874811 0.0466188524590164],...
    'String',{'h'},'FontSize',30,'EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',[0.592006033182505 0.901151639344267 0.0384615384615384 0.0466188524590164],...
    'Color',[1 1 1],'String',{'s'},'FontSize',30,'EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',[0.592006033182505 0.389881147540989 0.0392156862745098 0.0466188524590164],...
    'Color',[1 1 1],'String',{'k'},'FontSize',30,'EdgeColor','none');

% Create arrow
annotation(figure1,'arrow',[0.407239819004525 0.906485671191554],[0.0317868852459017 0.0317622950819673]);

% Create textbox
annotation(figure1,'textbox',[0.928355957767723 0.905250000000004 0.0935143288084462 0.0558401639344263],...
    'String',{'(day^{-1})'},'FontSize',30,'FitBoxToText','off','EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',[0.914027149321268 0.906274590163939 0.0373303167420814 0.0466188524590164],...
    'String',{'log_{10}\delta_{\it 1}'},'FontSize',30,'EdgeColor','none');

