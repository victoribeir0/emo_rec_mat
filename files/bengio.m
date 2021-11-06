function w2 = bengio(arquivoEntrada, filtro, viz)

% Leitura do arquivo e determinação dos caracteres.
fileID = fopen(arquivoEntrada);
format = '%c';
texto = fscanf(fileID,format);
car = regexp(texto, '\S', 'match'); % Determina os caracteres.
car = cell2mat(car);                % Transforma em um vetor.
C = unique(car);                    % Obtém os caracteres únicos.

if filtro == 1
    C(regexp(C,'[!,'',",(,),*,-,.,/,_,«,»,À,Á,É,Ó,à,á,â,ã,ç,é,ê,í,ó,ô,õ,ú,ü,–,-,-,:,;,?,`,’,“,”]')) = [];
    car(regexp(car,'[!,'',",(,),*,-,.,/,_,«,»,À,Á,É,Ó,à,á,â,ã,ç,é,ê,í,ó,ô,õ,ú,ü,–,-,-,:,;,?,`,’,“,”]')) = [];
end

dim = 2;

% Rede neural para obter o espaço semântico v:
w1 = rand(dim,length(C)*viz+1); % Inicia o espaço semântico.
w2 = rand(length(C),dim+1);      % Matriz w da rede neural.
passo = 0.01;
custofinal = zeros(1,100000);

% Plota o espaço inicial (aleatório).
for k = 1:length(C)
    plot(w1(1,k),w1(2,k),'b*'); hold on; grid on;
    text(w1(1,k),w1(2,k),C(k),'Fontsize',14);
end

% Iterações da rede neural.
for i = viz:100000
    % Entrada do tipo one hot (1 no caractere de interesse).
    xn = zeros(length(C),1);  
    
    x = [];
    for s = 0:abs(1-viz)
        xn(find(car(i-s) == C)) = 1;
        x = [x; xn];
        xn = zeros(length(C),1);  
    end
    
    x = [1; x];
    z = tanh(w1*x);
    z = [1; z];
    % y = exp(w2*z)/sum(exp(w2*z));
    y = 1./(1+exp(-w2*z));
       
    % Estima um caractere a partir do anterior.
    alvo = zeros(length(C),1); 
    alvo(find(car(i+1) == C)) = 1;
    e = alvo-y;
    
    retro = e .* (y.*(1-y)); % Derivada da sigmoide.
    
    w2novo = w2+passo*(retro*z');
    
    retro = w2(:,2:end)'*e;
    retro = retro.*(1-(z(2:end).^2));
    w1novo = w1+passo*(retro*x');
    
    w2 = w2novo;
    w1 = w1novo;
    
    custofinal(i) = sum(mean(e.^2)); % Calcula o custo.
    
end

figure,
for k = 1:length(C)
    plot(w2(k,1),w2(k,2),'b*'); hold on; grid on;
    text(w2(k,1),w2(k,2),C(k),'Fontsize',14);
end

figure, plot(custofinal);

end