% Calcula os coeficientes LFPC.
% S = Matriz do espectrograma.
% L = Comprimento de cada janela (am amostras).
% MFCC = Coeficientes Mel-Cepstrais.

function LinFPC = get_linfpc(S, num_bandas)

tam_espec = size(S,1);   % Núm de comp. de freq.
bw = round(tam_espec/num_bandas);

W = zeros(num_bandas,size(S,1));
intervalos = 1:bw:tam_espec;

if length(intervalos) >= num_bandas
    for n = 1:num_bandas-1
        W(n,intervalos(n):intervalos(n+1)-1) = 1;
        
        if n == num_bandas-1
            W(n+1,intervalos(n+1):end) = 1;
        end
    end
    
    LinFPC = 10*log10((W*S+(10^-6)).^2);
else
    LinFPC = [];
    disp('Erro. Número de bandas muito alto.');
end

end