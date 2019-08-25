y = [0.91086 0.95964; 0.6670 0.8327; 0.8710 0.9350; 0.9253 0.9656; 0.6765 0.8305];
fig=figure();
a=bar(y)
set(a(1),'FaceColor',[0.678, 0.764, 0.8],'EdgeColor',[0.109, 0.082, 0.674],'LineWidth',1.5);
set(a(2),'FaceColor',[0.360, 0.901, 0.376],'EdgeColor',[0.090, 0.431, 0.098],'LineWidth',1.5);
XTickLabel={'Paciente 1' ; 'Paciente 2'; 'Paciente 3'; 'Paciente 4'; 'Paciente 5'};
XTick=[1 2 3 4 5]
set(gca, 'XTick',XTick);
set(gca, 'XTickLabel', XTickLabel);
set(gca, 'XTickLabelRotation', 45);
legend('Jaccard','Dice')

title('Evaluar segmentación curvedness shape index')
xlabel('Casos')
ylabel('Valor')