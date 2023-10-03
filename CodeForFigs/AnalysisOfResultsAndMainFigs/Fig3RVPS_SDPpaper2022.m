function Fig3RVPS_SDPpaper2022(BasePath, Mp, Mr, Mc, FracH_p_mean, FracScav_p_mean, FracKlep_p_mean, FracH_r_mean, FracScav_r_mean, FracKlep_r_mean,...
    FracH_c_mean, FracScav_c_mean, FracKlep_c_mean, FracH_rp_mean, FracScav_rp_mean, FracKlep_rp_mean)

% Create figure
figure1 = figure('PaperUnits','centimeters','PaperType','<custom>','PaperSize',[36 34.3],'Color',[1 1 1]);

%subplot A: prop of strategy as a fn of Mp
% Create axes
axes1 = axes('Position',[0.109525661132124 0.762295081967213 0.301016042780747 0.196646523872201]);
hold(axes1,'on');
%plotting
area1 = area(Mp,[FracH_p_mean' FracScav_p_mean' FracKlep_p_mean']);
set(area1(1),'FaceColor',[0.576470613479614 0.631372570991516 0.964705884456635]);
set(area1(2),'FaceColor',[0.23137255012989 0.18823529779911 0.823529422283173]);
set(area1(3),'FaceColor',[0.5686274766922 0.925490200519562 0.960784316062927]);
%labels + other prop
ylabel('Proportion of strategy, ');
xlabel('Predator mass,','FontSize',33,'FontName','Helvetica Neue');
title('A');
box(axes1,'on');
axis(axes1,'tight');
set(axes1,'FontSize',30,'XMinorTick','on','XScale','log','XTick',[10 65 500],'XTickLabel',{'10','65','500'});
hold(axes1,'off');

%subplot B: strategy prop as fn of Mr
% Create axes
axes2 = axes('Position',[0.109525661132124 0.443647540983607 0.301016042780748 0.197745901639344]);
hold(axes2,'on');
%plotting
area2 = area(Mr,[FracH_r_mean' FracScav_r_mean' FracKlep_r_mean']);
set(area2(1),'FaceColor',[0.576470613479614 0.631372570991516 0.964705884456635]);
set(area2(2),'FaceColor',[0.23137255012989 0.18823529779911 0.823529422283173]);
set(area2(2),'FaceColor',[0.5686274766922 0.925490200519562 0.960784316062927]);
% labels + other prop
ylabel('$P$','FontName','Helvetica Neue','Interpreter','latex');
xlabel('Prey mass, ');
title('B');
box(axes2,'on');
axis(axes2,'tight');
set(axes2,'FontSize',30,'XMinorTick','on','XScale','log','XTick',[10 100 1000],'XTickLabel',{'10','100','1000'});
hold(axes2,'off');

%subplot C: strategy prop as fn of Mc
% Create axes
axes3 = axes('Position',[0.109525661132124 0.126198994854612 0.301016042780748 0.197571496948666]);
hold(axes3,'on');
%plotting
area3 = area(Mc,[FracH_c_mean' FracScav_c_mean' FracKlep_c_mean']);
set(area3(1),'DisplayName','h','FaceColor',[0.576470613479614 0.631372570991516 0.964705884456635]);
set(area3(2),'DisplayName','s','FaceColor',[0.23137255012989 0.18823529779911 0.823529422283173]);
set(area3(3),'DisplayName','k','FaceColor',[0.5686274766922 0.925490200519562 0.960784316062927]);
%labels + other prop
xlabel('Competitor mass, ');
title('C');
box(axes3,'on');
axis(axes3,'tight');
set(axes3,'FontSize',30,'XMinorTick','on','XScale','log','XTick',...
    [10 65 500],'XTickLabel',{'10','65','500'});
hold(axes3,'off');
% Create legend
legend1 = legend(axes3,'show');
set(legend1,'Position',[0.237544044960533 0.130968050735909 0.166833667334669 0.0368852459016393],'Orientation','horizontal');

%subplot D: hunting prop as fn of Mr and Mp
% Create axes
axes4 = axes('Position',[0.608304812396374 0.711678832116788 0.309469380051395 0.245211678832115]);
hold(axes4,'on');
%plotting
surf(Mr,Mp,FracH_rp_mean,'EdgeColor','none');
caxis([0 1])
plot3(Mr,Mr,100*ones(size(Mr)),'LineWidth',2,'LineStyle',':','Color',[1 0 0]);
%plot obs data
%first get path
TablePath = strcat(BasePath,'CodeForGitHub/ObsDataFromLit/');
%readtables
SinclairData = readtable(strcat(TablePath,'SinclairData.xlsx'));
CarboneData = readtable(strcat(TablePath,'CarboneEnergetic1999MostCommonPreyMass.csv'));
for i = 1:numel(SinclairData.Weight_kg)
    if i ~= 2
        plot3([SinclairData.smallest_prey_kg(i) SinclairData.largest_prey_kg(i)],[SinclairData.Weight_kg(i) SinclairData.Weight_kg(i)],...
            [100 100],'LineWidth',6,'Color',[0.635294139385223 0.0784313753247261 0.184313729405403]);
        plot3([SinclairData.Prefer_prey_low_kg(i) SinclairData.Prefer_prey_high_kg(i)],[SinclairData.Weight_kg(i) SinclairData.Weight_kg(i)],...
            [100 100],'LineWidth',7,'Color',[0 0 0]);
    else
        %stagger hyena and leopard for visualisation
        plot3([SinclairData.smallest_prey_kg(i) SinclairData.largest_prey_kg(i)],[68 68],...
            [100 100],'LineWidth',6,'Color',[0.635294139385223 0.0784313753247261 0.184313729405403]);
        plot3([SinclairData.Prefer_prey_low_kg(i) SinclairData.Prefer_prey_high_kg(i)],[68 68],...
            [100 100],'LineWidth',7,'Color',[0 0 0]);
    end
end
%carbone plots
plot3(CarboneData.MostCommonPreyMasskg,CarboneData.PredatorMasskg,100*ones(size(CarboneData.PredatorMasskg)),...
    'MarkerFaceColor',[0.862745106220245 0.850980401039124 0.823529422283173],'MarkerSize',10,'Marker','o','LineStyle','none','Color',[0 0 0]);
%labels + other prop
ylabel('Predator mass, ');
title('D');
xlim(axes4,[10 3090]);
ylim(axes4,[10 500]);
hold(axes4,'off');
set(axes4,'FontSize',30,'XLimitMethod','tight','XMinorTick','on','XScale','log','XTick',zeros(1,0),'XTickLabel',{},'YLimitMethod','tight',...
    'YMinorTick','on','YScale','log','YTick',[10 100 500],'YTickLabel',{'10','100','500'},'ZLimitMethod','tight');

%subplot E: Prop scav as fn of Mr and Mp
% Create axes
axes5 = axes('Position',[0.608304812396374 0.420479551309573 0.309469380051395 0.245211678832115]);
hold(axes5,'on');
surf(Mr,Mp,FracScav_rp_mean,'EdgeColor','none');
caxis([0 1])
plot3(Mr,Mr,100*ones(size(Mr)),'LineWidth',2,'LineStyle',':','Color',[1 0 0]);
%labels + other prop
ylabel('$M_p$','FontName','Helvetica Neue','Interpreter','latex');
title('E');
ylim(axes5,[10 500]);
set(axes5,'FontSize',30,'XLimitMethod','tight','XMinorTick','on','XScale','log','XTick',zeros(1,0),'XTickLabel',{},'YLimitMethod','tight',...
    'YMinorTick','on','YScale','log','YTick',[10 100 500],'YTickLabel',{'10','100','500',''},'ZLimitMethod','tight');
hold(axes5,'off');

%subplot F: klep proportion as fn of Mr and Mp
% Create axes
axes6 = axes('Position',[0.608304812396374 0.126423357664234 0.309469380051395 0.245211678832115]);
hold(axes6,'on');
%plotting
surf(Mr,Mp,FracKlep_rp_mean,'EdgeColor','none');
caxis([0 1])
plot3(Mr,Mr,100*ones(size(Mr)),'LineWidth',2,'LineStyle',':','Color',[1 0 0]);
%labels + other prop
ylabel('(kg)');
xlabel('Prey mass,');
title('F');
xlim(axes6,[10 3090]);
ylim(axes6,[10 500]);
hold(axes6,'off');
set(axes6,'FontSize',30,'XLimitMethod','tight','XMinorTick','on','XScale','log','XTick',[10 100 1000],'XTickLabel',{'10','100','1000'},'YLimitMethod',...
    'tight','YMinorTick','on','YScale','log','YTick',[10 100 500],'YTickLabel',{'10','100','500',''},'ZLimitMethod','tight');
% Create colorbar
colorbar(axes6,'Position',[0.924502598241437 0.125912408759124 0.0173811692936326 0.784948246978581]);


%annotations etc
% Create arrow
annotation(figure1,'arrow',[0.450351053159478 0.449541383445837],[0.0980315902835947 0.966754218020819],...
    'Color',[0.501960813999176 0.501960813999176 0.501960813999176],'LineWidth',2,'LineStyle',':','HeadStyle','none');

% Create textbox
annotation(figure1,'textbox',[0.60481444332999 0.773485461289935 0.0531594784353059 0.0430327868852459],'String',{'C'},'FontSize',27,...
    'FitBoxToText','off','EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',[0.816449348044132 0.856514658370227 0.0551654964894684 0.0430327868852459],...
    'String',{'Li'},'FontSize',27,'FitBoxToText','off','EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',[0.779338014042126 0.79903290654541 0.0636910732196589 0.0430327868852459],...
    'Color',[1 1 1],'String',{'Le'},'FontSize',27,'FitBoxToText','off','EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',[0.780341023069208 0.754324877348328 0.0591775325977933 0.0430327868852459],...
    'Color',[1 1 1],'String',{'W'},'FontSize',27,'FitBoxToText','off','EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',[0.60481444332999 0.820467033624504 0.0531594784353059 0.0430327868852459],...
    'String','H','FontSize',27,'FitBoxToText','off','EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',[0.324971909717125 0.662319672717426 0.0830360228941218 0.0508196715448723],...
    'String',{'$M_p$'},'Interpreter','latex','FontSize',33,'FitBoxToText','off','EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',[0.374119352044106 0.667032786885248 0.0922768304914742 0.0502049180327869],...
    'String',{'(kg)'},'FontSize',33,'FontName','Helvetica Neue','FitBoxToText','off','EdgeColor','none');

% Create arrow
annotation(figure1,'arrow',[0.020055155446298 0.0202484947597369],[0.492880220174707 0.966602847911928]);

% Create textbox
annotation(figure1,'textbox',[0.288870619875658 0.342647541569889 0.0824755608377869 0.0508196715448726],...
    'String',{'$M_r$'},'Interpreter','latex','FontSize',33,'FitBoxToText','off','EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',[0.337016058194622 0.347360655737709 0.0922768304914742 0.0502049180327869],...
    'String',{'(kg)'},'FontSize',33,'FontName','Helvetica Neue','FitBoxToText','off','EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',[0.920760276822449 0.911737824578195 0.0658016377011894 0.0471311475409836],...
    'String','$P$','Interpreter','latex','FontSize',30,'FontName','Helvetica Neue','FitBoxToText','off','EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',[0.610220440881759 0.625024590163937 0.0470941883767535 0.0430327868852459],...
    'Color',[1 1 1],'String',{'s'},'FontSize',27,'FontName','Helvetica Neue','EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',[0.610220440881756 0.328918032786889 0.0480961923847696 0.0430327868852459],...
    'Color',[1 1 1],'String',{'k'},'FontSize',27,'FontName','Helvetica Neue','EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',[0.611222444889778 0.914983606557378 0.0490981963927856 0.0430327868852459],...
    'String',{'h'},'FontSize',27,'FontName','Helvetica Neue','EdgeColor','none');

% Create arrow
annotation(figure1,'arrow',[0.477650171649979 0.479438314944834],[0.465644728969726 0.966288524590165]);

% Create arrow
annotation(figure1,'arrow',[0.253201273854384 0.253201273854384],[0.928378688524604 0.762434892904164],'Color',[1 0 0],'LineWidth',2,'LineStyle',':');

% Create textbox
annotation(figure1,'textbox',[0.397183534571649 0.029737704918035 0.092276830491474 0.0502049180327869],...
    'String',{'(kg)'},'FontSize',33,'FontName','Helvetica Neue','FitBoxToText','off','EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',[0.798405235747318 0.0250245907502158 0.0824755608377868 0.0508196715448724],...
    'String',{'$M_r$'},'Interpreter','latex','FontSize',33,'FitBoxToText','off','EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',[0.848554682082314 0.029737704918035 0.0922768304914744 0.0502049180327868],...
    'String','(kg)','FontSize',33,'FontName','Helvetica Neue','FitBoxToText','off','EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',[0.347034088236651 0.0250245907502159 0.0814055516463943 0.0508196715448724],...
    'String',{'$M_c$'},'Interpreter','latex','FontSize',33,'FitBoxToText','off','EdgeColor','none');

% Create line
annotation(figure1,'line',[0.0991983967935887 0.601603206412823],[0.981581967213118 0.981581967213118]);



