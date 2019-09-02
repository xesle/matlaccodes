P = [ 0.9461 0.6656 0.8436 0.9760 0.7713 0.9878 0.8557 0.8722 0.8783  0.9772 ... 
     0.9355 0.9797 0.8604   0.9546 0.9672  0.9505 0.9654 0.8807 0.9138  0.8706];
 
S =  [0.8560 0.8479 0.9769 0.9051 0.7650 0.6985 0.4286 0.8632 0.9468 0.9029 0.8399 0.9080 ...
              0.8644 0.8586 0.7156 0.8939 0.8396 0.8451 0.9522 0.9285];
D = [];

for i=1:numel(P)

d = sqrt((1-P(i))^2+(1-S(i))^2);
D = [D (1-d)];    
        
end              

N = 1:20;

tamano=get(0,'ScreenSize');
figure('position',[tamano(1) tamano(2) tamano(3) tamano(4)]);
hold on;
grid on;
plot(P,S,'*');
xlabel('Precision');
ylabel('Sensitivity');
xlim([0.68 1]);
ylim([0.86 1]);
for j=1:numel(P)
xx =[P(j) 1];
yy =[S(j) 1];
plot(xx,yy);
end
Z = 1:1:numel(P);
strValues  = strtrim(cellstr(num2str([Z(:) D(:)],'%d:%6.3f'))); 
text(P,S,strValues,'VerticalAlignment','bottom','Color','red','FontSize',12);
% savefig(figDir);
% h=openfig(figDir,'new','invisible');
% saveas(h,outputDir,'png');
% close all;