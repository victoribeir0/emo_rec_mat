% Determina a matriz de dist�ncias, p(i,j), para o t-sne.
% X = Matriz com os dados (NxDim).
% sig = Vari�ncia da gaussiana.

% px = Matriz de dist�ncias (probabilidades), p(i,j).
function px = get_mat_dist_tsne(X,sig)
tic;

[N,Dim] = size(X);
% Caso a matriz esteja transposta (DimxN), transp�e para NxDim.
if Dim > N
    X = X';
    [N,~] = size(X);
end

px = zeros(N);         % Inicia a matriz px.
soma = get_dij(X,sig); % Determina o denominador de p(i,j).
entropia = zeros(1,N);

% Determina o numerador de p(i,j).
for i = 1:N       
    % Determina o calculo do p(i,j) para cada vetor X(i,:).
    mat_temp = repmat(X(i,:),N,1) - X;
    mat_temp = sqrt(diag(mat_temp*mat_temp'));
    mat_temp = exp(-(mat_temp.^2)/(2*(sig^2)));
    mat_temp(i) = 0;
    mat_temp = mat_temp/soma;
    px(i,:) = mat_temp;    
    entropia(i) = entro(nonzeros(px(i,:)));
end

% For�a a simetria da matriz p(i,j).
% px = (px+px')/(2*N^2);
px = px+px';
imagesc(px);
toc;
end

% Determina o denominador de p(i,j).
function soma = get_dij(X,sig)
N = size(X,1);
soma = 0;

for i = 1:N    
    % Determina o calculo do denominador de p(i,j) para cada vetor X(i,:).
    mat_temp = repmat(X(i,:),N,1) - X;
    mat_temp = sqrt(diag(mat_temp*mat_temp'));
    mat_temp = exp(-(mat_temp.^2)/(2*(sig^2)));
    mat_temp(i) = 0;
    soma = soma + sum(mat_temp);       
end
end

function res = entro(p)
res = -sum(p.*log(p));
end