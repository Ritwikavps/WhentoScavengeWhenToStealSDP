function EnergeticGainsFig(Mp,Mr,AllometricStruct)

%requires AllometricStruct (outputed from SDP run) to be loaded

%Note that this is a rough generative code for the plot. You will mosyt
%likely have to do some moving around by hand  (and potentially the
%addition of a few textboxes to make the figures look like those in the SI)
%create figure
figure1 = figure('PaperUnits','centimeters','PaperType','<custom>','PaperSize',[39.5 35.2],'Color',[1 1 1]);

%subplot: consumed mass (A)
% reate axes
axes1 = axes('Position',[0.144941302027748 0.613769608740767 0.325962905671446 0.334204663370567]);
hold(axes1,'on');
%plotting
plot(Mr,AllometricStruct.ConsumedMassGm_r/1000,'LineWidth',3,'DisplayName','h/k');
plot(Mr,AllometricStruct.ConsumedMassGmSc_r/1000,'LineWidth',3,'DisplayName','s');
%labels + other axes prop
ylabel('Consumed mass (kg)');
xlabel('Prey mass,      (kg)');
title('A');
ylim(axes1,[4.01850152506495 3000])
axis(axes1,'tight');
set(axes1,'FontSize',30,'XLimitMethod','tight','YLimitMethod','tight','YScale','log','YTick',[100 1000 3000]);
legend1 = legend(axes1,'show');
set(legend1,'Position',[0.381378692927484 0.622395651948325 0.0887352427184354 0.0845679012345676],'EdgeColor',[1 1 1]);
hold(axes1,'off');

%subplot: stomach size (B)
%Create axes
axes2 = axes('Position',[0.633840644583706 0.613769608740767 0.323453248970613 0.334204663370567]);
hold(axes2,'on');
%plotting
plot(Mp,AllometricStruct.StmGm_p/1000,'LineWidth',3,'Color','k');
%labels + other prop
ylabel('Stomach size,    (kg)');
xlabel('Predator mass,      (kg)');
title('B');
xlim(axes2,[0 500]);
ylim(axes2,[0 3000]);
set(axes2,'FontSize',30,'XTick',[0 200 400],'YScale','log','YTick',[100 1000 3000]);
hold(axes2,'off');

%subplot: n_max for h/k (C)
%first compute n_max values
for i = 1:numel(Mr)
    for j = 1:numel(Mp)
        Nmax_HuntKlep(i,j) = ceil(AllometricStruct.StmGm_p(j)/AllometricStruct.ConsumedMassGm_r(i));
        Nmax_Scav(i,j) = ceil(AllometricStruct.StmGm_p(j)/AllometricStruct.ConsumedMassGmSc_r(i));
    end
end
%Create axes
axes3 = axes('Position',[0.144941302027748 0.113937007874016 0.359861259338314 0.337890343648904]);
hold(axes3,'on');
%plotting
plot3(Mp,Mp,ones(size(Mp))*100,'LineWidth',1,'LineStyle','--','Color',[1 1 1]);
contourf(Mp,Mr,Nmax_HuntKlep,'LineStyle','none','LevelStep',1);
%colorbar limits
caxis([0 20]); %upper limit set to 20 after looking at n_max for all three strategies; 
%labels + other prop
ylabel('Prey mass,      (kg)');
xlabel('Predator mass,      (kg)');
title('C');
set(axes3,'CLim',[1 20],'FontSize',30,'XMinorTick','on','XScale','log',...
    'XTick',[10 100 500],'YMinorTick','on','YScale','log','YTick',[100 1000],'YTickLabel',{'100','1000'});
axis(axes3,'tight');
hold(axes3,'off');

%subplot: n_max for scav (D)
% Create axes
axes4 = axes('Position',[0.56136606189968 0.113937007874016 0.353255069370331 0.337890343648904]);
hold(axes4,'on');
%plotting
contourf(Mp,Mr,Nmax_Scav,'LineStyle','none','LevelStep',1);
plot3(Mp,Mp,ones(size(Mp))*100,'LineWidth',1,'LineStyle','--','Color',[1 1 1]);
%labels + other prop
ylabel('$M_r$','Interpreter','latex');
title('D');
grid(axes4,'on');
axis(axes4,'tight');
set(axes4,'CLim',[1 20],'FontSize',30,'XMinorTick','on','XScale','log',...
    'XTick',[10 100 500],'YMinorTick','on','YScale','log','YTick',zeros(1,0));
hold(axes4,'off');
% Create colorbar
colorbar(axes4,'Position',[0.924226254002139 0.114443897637795 0.0242626190758531 0.2845062335958]);
caxis([0 20]); %set limits for colorbar; %upper limit set to 20 after looking at n_max for all three strategies; 

%Hacky axis for y axis latex textbox: Create axes
axes5 = axes('Position',[0.974037600716204 0.945220193340494 0.0196956132497762 0.0483351235230925]);
ylabel('$S$','FontSize',35,'Interpreter','latex');
set(axes5,'XColor',[1 1 1],'XTick',zeros(1,0),'YColor',[1 1 1],'YTick',zeros(1,0),'ZColor',[1 1 1]);

%Arros + other annotations
% Create arrow
annotation(figure1,'arrow',[0.494180841539839 0.918071550664091],[0.0311493018259934 0.0314427173001629]);

% Create textbox
annotation(figure1,'textbox',[0.149470899470899 0.399163126808517 0.0702775290957923 0.0504434589800443],...
    'Color',[1 1 1],'String',{'h/k'},'FontSize',30,'EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',[0.566137566137564 0.399163126808517 0.045658012533572 0.0504434589800443],...
    'Color',[1 1 1],'String',{'s'},'FontSize',30,'EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',[0.383243580616073 0.00040219547432847 0.0741154116610917 0.0549889128911257],...
    'String',{'$M_p$'},'Interpreter','latex','FontSize',33,'EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',[0.82972270550177 0.495400789408759 0.0741154116610917 0.0549889128911257],...
    'String',{'$M_p$'},'Interpreter','latex','FontSize',33,'EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',[0.332911514525791 0.496744875430265 0.0736151603896808 0.0549889128911257],...
    'String',{'$M_r$'},'Interpreter','latex','FontSize',33,'EdgeColor','none');

% Create textbox
annotation(figure1,'textbox',[0.918918494802171 0.419433399370737 0.0382592592592593 0.0416666666666667],...
    'String','$n_{\rm max}$','LineWidth',20,'LineStyle','none','Interpreter','latex',...
    'FontSize',30,'FontName','Helvetica Neue','FitBoxToText','off');



