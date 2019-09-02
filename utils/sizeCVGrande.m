y = [124274 114387; 23331 21134; 36521 32791; 25711 26792; 41450 44204];
fig=figure();
a=bar(y)

set(a(1),'FaceColor',[0.619, 0.941, 0.874],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
set(a(2),'FaceColor',[0.772, 0.941, 0.619],'EdgeColor',[0.941, 0.619, 0.937],'LineWidth',1.5);
XTickLabel={'Paciente 1' ;  'Paciente 8'; 'Paciente 11'; 'Paciente 19'; 'Paciente 20'};
XTick=[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20]
set(gca, 'XTick',XTick);
set(gca, 'XTickLabel', XTickLabel);
set(gca, 'XTickLabelRotation', 45);
legend('Esperada','Detectada')

title('Volumen quístico grandes')
xlabel('Pacientes')
ylabel('Area en pixeles')