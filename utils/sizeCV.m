y = [124274 114387; 2505 3098; 1817 2104; 17667 16185; 3545 3516; 15700 11103; 581 291; 23331 21134; 7278 7846;...
    6218 5745; 36521 32791; 15330 14209; 17022 17100; 19951 17944; 17302 12801; 4231 3979;...
    13853 12048; 2996 2875; 25711 26792; 41450 44204];
fig=figure();
a=bar(y)

set(a(1),'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
set(a(2),'FaceColor',[0.949, 0.952, 0.509],'EdgeColor',[1, 0.850, 0.101],'LineWidth',1.5);
XTickLabel={'Paciente 1' ; 'Paciente 2'; 'Paciente 3'; 'Paciente 4'; 'Paciente 5'; 'Paciente 6';...
    'Paciente 7'; 'Paciente 8'; 'Paciente 9'; 'Paciente 10'; 'Paciente 11'; 'Paciente 12';...
    'Paciente 13'; 'Paciente 14';  'Paciente 15';  'Paciente 16';  'Paciente 17';  'Paciente 18';  'Paciente 19'; 'Paciente 20'};
XTick=[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20]
set(gca, 'XTick',XTick);
set(gca, 'XTickLabel', XTickLabel);
set(gca, 'XTickLabelRotation', 45);
legend('Esperada','Detectada')

title('Area')
xlabel('Curvedness & shape index')
ylabel('Area en pixeles')