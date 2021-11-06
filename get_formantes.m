function formantes = get_formantes(x,P,Fs)

[coefs,~,~] = get_lpcc(x,P,Fs,0);
rts = roots(coefs);
rts = rts(imag(rts)>=0);
angz = atan2(imag(rts),real(rts));

[frqs,indices] = sort(angz.*(Fs/(2*pi)));
bw = -1/2*(Fs/(2*pi))*log(abs(rts(indices)));

nn = 1;
for kk = 1:length(frqs)
    if (frqs(kk) > 90 && bw(kk) <400)
        formantes(nn) = frqs(kk);
        nn = nn+1;
    end
end

end