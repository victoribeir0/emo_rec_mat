function [y,stress,dy] = get_mds(dx,dims)

stress = zeros(1,length(dims));
J = zeros(1,4000);

for dim = dims
    N = size(dx,1);
    y = 0.001*randn(N,dim);
    dy = calcD(y);
    
    passo = 0.001;
    k = 1;
    % J(k) = sqrt((sum(sum(dx-dy)).^2)/sum(sum(dx.^2)));
    
    a = (dx-dy).^2;
    b = dx.^2;
    J(k) = sqrt(sum(a(:))/sum(b(:)));
    
    for k = 2:5000
        
        pesos = (dx-dy)./(dy+eps);
        for n = 1:N
            vetores = y-ones(N,1)*y(n,:);
            ynovo(n,1:dim) = y(n,:)-passo*pesos(n,:)*vetores;
        end
        
        dy = calcD(ynovo);
        
        a = (dx-dy).^2;
        % b = dx.^2;
        J(k) = sqrt(sum(a(:))/sum(b(:)));
        
        if J(k) < J(k-1)
            y = ynovo;
        end
        
    end
    
    stress(dim) = J(end);
end

plot(stress); grid on;

% Plota o espaço inicial (aleatório).
%for k = 1:length(C)
%    plot(y(k,1),y(k,2),'b*'); hold on; grid on;
%    text(y(k,1),y(k,2),C(k),'FontSize',15);
%end

end