L = 513; % tamanho do filtro+1
halfFilt = floor(L/2);
n = -halfFilt:halfFilt;

a = 1; % amplitude
b = 0.15; % abertura do lobulo principal
w = blackman(L)';
hh = a*sinc(b*n);
filter = hh.*w;

plot(filter);
fvtool(filter,1);

RANGE_N = -512; RANGE_P = 511; % 10 bits

f1 = normalize(filter,'range',[RANGE_N,RANGE_P]);
f1 = normalize(f1,'center','median');

for v = 1:1:5
    f1 = normalize(f1,'range',[min(f1),RANGE_P]);
    f1 = normalize(f1,'center','median');
end

filtro = round(f1);
writematrix(filtro,'filtro');

tiledlayout(1,3);
nexttile;
plot(w);grid on;
pbaspect([1 1 1]);
title("janela para truncamento do sinc");
nexttile;
plot(hh);grid on;
pbaspect([1 1 1]);
title("funcao sinc");
nexttile;
plot(filtro);grid on;
pbaspect([1 1 1]);
title("funcao sinc-janelada");



