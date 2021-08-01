%{
    Determina o modelo do GMM para um conjunto de dados X.
    X = Dados. (N� observa��es x N� de carac.)
    K = N� de centros (gaussianas).
    Ite = N� de itera��es. 
    
    P0 = Vetor de probabilidade de cada gaussiana.
    C = Posi��o dos centros.
    S = Diagonais das matrizes de covari�ncia.
    L = Verossimilhan�a. 
%}

function [P0,C,S,L] = gmm_em(X, K, Ite, plotimg)

% Inicializa��o de par�metros:
[N,Dim] = size(X); % N = num. dados, Dim = Dimens�o.

% Inicializa os centros aleatoriamente (C).
idx = randperm(N,K);
C = X(idx,:);

% Inicializa a matriz de covari�ncia (S).
S_ini = X-(ones(N,1)*mean(X,1)); % Subtrai X das m�dias de cada coluna da mat. X.
S_ini = (S_ini'*S_ini)/(N-1);    % Obt�m a mini covari�ncia.
S_ini = diag(S_ini)';            % Obt�m a diagonal da mat. de cov.

% S = zeros(size(Dim)); 
% P0 = zeros(1,K);
valMin = min(abs((S_ini(abs(S_ini)>0)))); % Encontra o menor valor absoluto.
S_ini(S_ini==0) = valMin; % Caso haja um zero no vetor S_ini, esse zero � substitu�do por valMin
invRini = S_ini.^(-1);    % Inverso do vetor S_ini (diag. da mat. de cov.).

S = ones(K,1)*S_ini;  % Inicializa mat. de cov;
P0 = (1/K)*ones(K,1); % Inicializa o vetor de pesos das gaussianas.

% La�o EM:
for i=1:Ite % Troquei uma condic�o de parada por Niter itera��es
    P = zeros(K,N); % Inicializa a matriz de probabilidades P.
    
    % Para acelerar o processamento no Matlab, o duplo la�o deve ser substitu�do
    % pelas opera��es matriciais seguintes:
    A = X';
    for k = 1:K
        B = C(k,:)';
        pos = find(S(k,:) == 0);
        S(k,pos) = valMin;   % Casa haja um zero no vetor R, esse zero � substitu�do por valMin
        invR = S(k,:).^(-1); % Calcula a inversa da diagonal da mat. cov.
        meioR = invR.^(1/2); % Calcula a meia inversa da diagonal da mat. cov.
        
        % Obs: O det. da mat. cov. � calculado usando o vetor da diagonal.
        % log(a*b*c*...*n) = log(a) + log(b) + log(c) + ... + log(n)
        % (a*b*c*...*n) = exp(log(a*b*c*...*n))
        % O real � devido a: log de num. < 0 retorna complexo.
        detR = real(exp(sum(log(S(k,:))))); % Calcula o determinante da mat. cov.
          
        % Calculo da dist. de Mahalanobis:  
        % Aqui � usada a meia cov., esta deforma o espa�o dos dados para calcular a dist.
        A2 = sum(((meioR'*ones(1,N)).*A).^2,1); % Dados X.
        B2 = sum((meioR'.*B).^2,1);             % Centros C.
        
        pAB = (A'.*(ones(N,1)*invR))*B;
        dm2 = (A2'*ones(1,size(B,2)) + ones(size(A,2),1)*B2 - 2*pAB);
        dm2 = dm2'; % Converte em vetor linha de dist�ncias.
        denominador = (2*pi)^(Dim/2)*detR^(1/2);
        
        % Calcula as probabilidades de cada observa��o(n) pertencer a um centro(k).
        if denominador > 0 % Aten��o: outra gambiarra!
            P(k,:) = P0(k)*(1/denominador)*exp(-0.5*dm2);
        end
    end
    
    % Como vamos usar Log, devemos testar os argumentos para que sejam sempre positivos:
    somaColunasP = sum(P,1);
    pos = find(somaColunasP>0);
    L(i) = sum(log(somaColunasP(pos)))/length(pos);    
    
    P = P./(ones(K,1)*sum(P,1));
    
    % Atualizando os aprioris:
    P0 = sum(P,2);
    
    % Outra gambiarra:
    pos = find(P0==0);
    P0(pos) = 0.00000001;
    P0=P0/sum(P0);
    
    % Vers�o acelerada (no Scilab) do la�o for acima:
    pos=find(P==0);
    P(pos)=10^(-9); % Gambiarra para evitar nulos por truncamento num�rico na matriz P
    Pesos=P./(sum(P,2)*ones(1,N));
    C=Pesos*X;
    
    % Atualizando as matrizes de covari�ncia:
    R_velho=S; % Guarda uma c�pia de matrizes supostamente bem condicionadas, para o caso de problemas de condicionamento ap�s atualiza��o
    for k=1:K
        
        % Outra gambiarra:
        sumLinhaP = sum(P(k,:));
        if sumLinhaP == 0
            sumLinhaP = 0.00000001;
        end
        
        Pesos = P(k,:)/sumLinhaP;
        B = X-ones(N,1)*C(k,:);
        A = (B').*(ones(Dim,1)*Pesos);
        Raux = A*B;
        Raux=diag(Raux);
                        
        if min(abs(Raux)) < 0.00000001
            S(k,:) = R_velho(k,:);
        else
            S(k,:) = Raux';
        end        
    end    
end

if plotimg
    subplot(211);
    plot(L); title('Verossimilhan�a'); grid on;
    
    subplot(212);
    plot(X(:,1),X(:,2),'k*'); hold on;
    plot(C(:,1),C(:,2),'bo'); grid on;
    
    for k = 1:K
        ss = repmat(S(k,:),2,1);
        ss = ss.*eye(2);
        plot_iso(C(k,:),ss)
    end
    
end

end

function plot_iso(cen,S)
a = 0:0.1:(2*pi)+0.1;
%S = repmat(S,length(S),1).*eye(length(S));
x = (S.^(1/2))*[cos(a); sin(a)];
cen = cen(:);
x = x+(cen*ones(1,length(a)));
plot(x(1,:),x(2,:),'r');
end