y = [124274 114382; 2505 3153; 1817 2280; 17667 16284; 3545 3516];
fig=figure();
a=bar(y);
set(a(1),'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1.5);
set(a(2),'FaceColor',[0.949, 0.952, 0.509],'EdgeColor',[1, 0.850, 0.101],'LineWidth',1.5);
XTickLabel=({'Paciente 1' ; 'Paciente 2'; 'Paciente 3';'Paciente 4'; 'Paciente 5'});
XTick=[1 2 3 4]
set(gca, 'XTick',XTick);
set(gca, 'XTickLabel', XTickLabel);
set(gca, 'XTickLabelRotation', 45);
legend('Esperada','Detectada')

title('Area')
xlabel('Central Media Adaptive')
ylabel('Area en pixeles')