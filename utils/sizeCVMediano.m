y = [17667 16185; 15700 11103; 15330 14209; 17022 17100; 19951 17944; 17302 12801; 13853 12048];
fig=figure();
a=bar(y)

set(a(1),'FaceColor',[0.619, 0.941, 0.874],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
set(a(2),'FaceColor',[0.772, 0.941, 0.619],'EdgeColor',[0.941, 0.619, 0.937],'LineWidth',1.5);
XTickLabel={'Paciente 4';  'Paciente 6'; 'Paciente 12';'Paciente 13'; 'Paciente 14';  'Paciente 15';  'Paciente 17'};
XTick=[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20]
set(gca, 'XTick',XTick);
set(gca, 'XTickLabel', XTickLabel);
set(gca, 'XTickLabelRotation', 45);
legend('Esperada','Detectada')

title('Volumen quístico mediano')
xlabel('Pacientes')
ylabel('Area en pixeles')