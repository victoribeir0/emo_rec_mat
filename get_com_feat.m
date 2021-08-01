function [vet, dx] = get_com_feat(x,viz)

folder = 'C:\Users\victo\Documents\Dataset _ EmoDB2';
cd(folder);

load('centros64.mat');
seq = get_clusters(x,centros);
[cen_g] = get_mod(64,10,0);
N_cen = size(cen_g,1);

if length(seq)-viz > viz+1
    [dx,~,~] = get_com_voz(seq,10,0,64);
    
    dx(dx == 0) = 255;
    dx(dx > 128) = 255;
    dx(dx <= 128) = 1;
    [l,c] = find(dx == 1);
    % dx = reshape(dx,1,64*64);
            
%     l = l(1:N_cen);
%     c = c(1:N_cen);
    
    ll = []; cc = [];
    
    for k = 1:size(cen_g,3)
        
        for i = 1:length(c)
            ll = [ll length(find(cen_g(:,1,k) == l(i)))/size(cen_g,1)];
            cc = [cc length(find(cen_g(:,2,k) == c(i)))/size(cen_g,2)];
        end
        
        vet(k) = sum(sqrt((ll.^2)+(cc.^2)));
        ll = []; cc = [];
    end
    
else
    dx = 0;
    vet = 's';
end

end