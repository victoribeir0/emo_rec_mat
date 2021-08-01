function [m_nrg, F0, nrg, jit_abs, jit_rel, jit_x, shi_abs, shi_rel, amp_std, mean_dif_picos, hnr] = get_global_contx(x,jans,fs)

[~,~,nrg,~,~] = vad_mix(x,40,10);

[F0, u, hnr] = get_f0_2(x,40,jans,fs);
[jit_abs, jit_rel, jit_x, shi_abs, shi_rel, amp_std, mean_dif_picos, idx_nan] = get_quali_contx(x, 40, u, fs, mean(F0));

F0 = F0(idx_nan);

m_nrg = mean(nrg);
m_f0 = mean(F0);

end

function res = get_ang(y)
x = 1:length(y);

m = [ones(length(x),1) x'];
a = inv(m'*m)*m'*y';
res = a(2);
end