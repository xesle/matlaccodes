y = [0.91086 0.95964; 0.8899 0.9505; 0.8899 0.9505; 0.8899 0.9505];
fig=figure();
a=bar(y)
XTickLabel={'Paciente 1' ; 'Paciente 2'; 'Paciente 3'; 'Paciente 4'};
XTick=[1 2 3 4]
set(gca, 'XTick',XTick);
set(gca, 'XTickLabel', XTickLabel);
set(gca, 'XTickLabelRotation', 45);
legend('Jaccard','Dice')

title('Curvedness & shape index')
xlabel('Indices')
ylabel('Grado de similitud')