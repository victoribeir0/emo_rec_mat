function [data, dims] = get_seq_mds(emo_data, centros, y_3)

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
    std_part(k,:) = std(part_data);
    ini = n_dados;
end

n_dim = 4; % núm. de dimensões a serem escolhidas.
[vals, dims] = sort(mean(std_part)); % Ordena as médias dos DesvPad.
dims = dims(1:n_dim);

end