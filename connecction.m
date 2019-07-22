function varargout = connecction(L, num, positiveCases)

res = ones(1, num);
for i=1:num
  aux = zeros(size(positiveCases));
  aux(L == i) = 1;
  s = aux & positiveCases;
  ss = sum(s(:) == 1);

 if ss == 0
    res(i) = 0;
 end

end 

% if sum(res) == num 
%     all = true;
% else
%     all = false;
% end    

varargout  = {sum(res)};      

end      
      