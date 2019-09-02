y = [2505 3098; 1817 2104; 3545 3516; 581 291; 7278 7846; 6218 5745; 4231 3979; 2996 2875];
fig=figure();
a=bar(y)

set(a(1),'FaceColor',[0.619, 0.941, 0.874],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
set(a(2),'FaceColor',[0.772, 0.941, 0.619],'EdgeColor',[0.941, 0.619, 0.937],'LineWidth',1.5);
XTickLabel={'Paciente 2'; 'Paciente 3'; 'Paciente 5'; 
    'Paciente 7'; 'Paciente 9'; 'Paciente 10';  'Paciente 16';  'Paciente 18'};
XTick=[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20]
set(gca, 'XTick',XTick);
set(gca, 'XTickLabel', XTickLabel);
set(gca, 'XTickLabelRotation', 45);
legend('Esperada','Detectada')

title('Volumen quístico pequeño')
xlabel('Pacientes')
ylabel('Area en pixeles')