function v = get_context2(arquivoEntrada, filtro)

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

% Rede neural para obter o espaço semântico v:
v = rand(2,length(C)); % Inicia o espaço semântico. v = rand(2,length(C));
w = rand(2,2);         % Matriz w da rede neural.
passo = 0.001;
custofinal = zeros(1,50000);

% Plota o espaço inicial (aleatório).
for k = 1:length(C)
    plot(v(1,k),v(2,k),'b*'); hold on; grid on;
    text(v(1,k),v(2,k),C(k));
end

% Iterações da rede neural.
for i = 1:50000
    % Entrada do tipo one hot (1 no caractere de interesse).
    x = zeros(length(C),1);
    x(find(car(i) == C)) = 1;
    
    vn = v(:,find(car(i) == C));
    y = w*vn;
    
    % Estima um caractere a partir do anterior.
    vnmu = v(:,find(car(i+1) == C));
    e = vnmu-y;
    
    wnovo = w+passo*(e*vn');
    vnovo = v+passo*(w'*e)*x';
    
    w = wnovo;
    v = vnovo;
    
    custofinal(i) = sum(mean(e.^2)); % Calcula o custo.
    
end

figure,
for k = 1:length(C)
    plot(v(1,k),v(2,k),'b*'); hold on; grid on;
    text(v(1,k),v(2,k),C(k));
end

figure, plot(custofinal);

end