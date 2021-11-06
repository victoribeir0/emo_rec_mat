function dims = get_otm_dims(emo_data, centros, y_3)

for k = 1:size(emo_data,2)
    seq_emo{k,:} = get_clusters(emo_data{k},centros);
end

data = [];
for k = 1:size(emo_data,2)
    data = [data; y_3(seq_emo{k},:)];
end

ini = 1;
for k = 1:size(emo_data,2)
    if k == 1
        n_dados = size(emo_data{k},2) + ini;
    else
        n_dados = size(emo_data{k},2) + ini;
    end
    
    part_data = data(ini:n_dados-1,:);
    med_part(k,:) = mean(part_data);
    std_part(k,:) = std(part_data);
    ini = n_dados;
end

n_dim = 4; % núm. de dimensões a serem escolhidas.
[~, dims_mean] = sort(mean(std_part)); % Ordena as médias dos DesvPad.
dims_mean = dims_mean(1:n_dim); % Mantém somente as N dimensões com menores DesvPad..

[vals, dims_std] = sort(std(std_part),'descend');
dims = intersect(dims_mean,dims_std(1:6));

end