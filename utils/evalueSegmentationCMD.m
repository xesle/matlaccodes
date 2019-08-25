y = [0.9055 0.95781; 0.6804 0.8396; 0.8014 0.8961; 0.9265 0.9656; 0.6765 0.8305];
fig=figure();
a=bar(y)
set(a(1),'FaceColor',[0.082, 0.482, 0.698],'EdgeColor',[0.109, 0.082, 0.674],'LineWidth',1.5);
set(a(2),'FaceColor',[0.960, 0.635, 0.619],'EdgeColor',[0.768, 0.086, 0.054],'LineWidth',1.5);
XTickLabel={'Paciente 1' ; 'Paciente 2'; 'Paciente 3';'Paciente 4'; 'Paciente 5'};
XTick=[1 2 3 4]
set(gca, 'XTick',XTick);
set(gca, 'XTickLabel', XTickLabel);
set(gca, 'XTickLabelRotation', 45);
legend('Jaccard','Dice')

title('Evaluar segmentación Central Media Adaptive')
xlabel('Casos')
ylabel('Valor')