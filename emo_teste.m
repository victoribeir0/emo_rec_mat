function erro = emo_teste(res)

% N�mero de vozes para cada emo��o.
rot = [18 17 20 15 11 20 20];

% Inicializa vari�veis.
ind = 1;
rot_vet = [];

% Cria o vetor de r�tulos.
for n = 1:length(rot)
    rot_vet = [rot_vet ind*ones(1,rot(n))];
    ind = ind+1;
end

tam = min(res(:)):1:max(res(:));
fp = zeros(1,size(res,1));
fn = zeros(1,size(res,1));
idx = 1;

for lim = tam
    for lin = 1:size(res,1)
        
        ind = find(res(lin,:) >= lim);
        
        if any(ind ~= rot_vet(lin))
            % Soma todas as falsas aceita��es.
            fp(lin) = sum(ind ~= rot_vet(lin)); % Falso positivo (falsa aceita��o).            
        end
        
        ind = find(res(lin,:) <= lim);
        
        if any(ind == rot_vet(lin))
            fn(lin) = 1; % Falso negativo (falsa rejei��o).
        end          
    end
    
    fpr(idx) = sum(fp/(size(res,2)-1))/size(res,1);
    fnr(idx) = sum(fn)/size(res,1);
    fp = zeros(1,size(res,1));
    fn = zeros(1,size(res,1));
    idx = idx+1;
    
end

plot(tam,fpr,'r'); hold on; plot(tam,fnr,'b'); grid on; xlabel('Limite'); ylabel('Erro (%)');
    
[~, pos] = min(abs(fpr-fnr));
erro = mean([fpr(pos) fnr(pos)]);

end