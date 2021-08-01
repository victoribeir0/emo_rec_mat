function seq = get_clusters(x,centros)

N_dados = size(x,2);
N_centros = size(centros,2);
seq = zeros(1,N_dados);

for i = 1:N_dados
    vet = repmat(x(:,i),1,N_centros);
    vet = sqrt(sum((vet-centros).^2));
    [~, seq(i)] = min(vet);
end

end