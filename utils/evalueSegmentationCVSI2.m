y = [0.8418 0.9226; 0.9328 0.9681; 0.8306 0.9164; 0.8785 0.9416; 0.7721 0.8915; 0.8743 0.9398; ...
    0.8602 0.9346; 0.8210 0.9155; 0.9232 0.9642; 0.8883 0.9554];
fig=figure();
a=bar(y)
set(a(1),'FaceColor',[0.678, 0.764, 0.8],'EdgeColor',[0.109, 0.082, 0.674],'LineWidth',1.5);
set(a(2),'FaceColor',[0.360, 0.901, 0.376],'EdgeColor',[0.090, 0.431, 0.098],'LineWidth',1.5);
XTickLabel={'Paciente 11'; 'Paciente 12';...
 'Paciente 13';  'Paciente 14';  'Paciente 15';  'Paciente 16';  'Paciente 17';  'Paciente 18';  'Paciente 19'; 'Paciente 20'};
set(gca, 'XTick',XTick);
set(gca, 'XTickLabel', XTickLabel);
set(gca, 'XTickLabelRotation', 45);
legend({'Jaccard','Dice'},'FontSize',8,'Location','SouthOutside','Orientation','horizontal')
ylabel('Valor')