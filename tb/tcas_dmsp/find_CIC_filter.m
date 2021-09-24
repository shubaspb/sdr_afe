% Назначение : Поиск структуры CIC фильтра с корректором (ФНЧ)
% Автор : Шубин Д.А.
% Комментари: 
% - находится структура CIC фильтра в соответствии с заданными параметрами
% - ищется оптимальный корректирующий фильтр заданного порядка, который в 
% сочетании с CIC-фильтром реализует ФНЧ с заданной полосой пропускания

clear all;
clc;

%%%%%%%%%%%% Интерфейс %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Выбор действия (режим):
flag_control = 1;  % 0 - подбор и анализ фильтров
                   % 1 - генерирование файла инициализации для выбранного фильтра 

%%%%%%%%%%%%%% Параметры %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ========= Параметры CIC-фильтра =========================
m = 1;     % Differential delays in the filter.
s = 9;     % Filter sections
r = 5;     % Decimation factor
% ========= Параметры корректора ==========================
WIDTH_CIC = 20;  % входная разрядность фильтра
COEFF_FILE = 'init_file_corrector_23.dat';  % Файл инициализации для фильтра
% (если хотим сгенерировать файл инициализации для выбранного порядка, то
% задаем его в перечень порядков mat_num_order   
mat_num_order = 23; % Порядки фильтров, которые проверяем в качестве корректора  
Fs=100e6;
Fc = 5.5e6;              % Требуемая полоса пропускания
B = WIDTH_CIC+1;          % Разрядность коэффициентов
K_gain = 2.5;     % дБ
K_gain = 10^(K_gain/20);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





n = 100000;
win = blackman(1,n);

% ======= Generator input signal ====================
dF = 20e6;
F_chirp = 500;
F_ch_0 = 0;
tt = (0:n-1)/1.000001;
X = sinc(tt);
%Spectr(X, Fs, 12);


% ============== CIC filter ====================================
X_cic = X;
hm=mfilt.cicdecim(r, m, s);
X_cic = double(filter(hm,X_cic));
% ==============================================================
legend_str = [];

for num_order = 1:length(mat_num_order)
    
    % ==== compensator ==============================================
    L = mat_num_order(num_order);            %% Filter order; must be even
    R = r;                                   %% Decimation factor
    M = m;                                   %% Differential delay
    N = s;                                   %% Number of stages
    h_pulse_comp_norm = compensator_generate(Fs, Fc, M, N, R, L);
    K_B = 2^(B-1)*K_gain;
    h_pulse_comp = round(h_pulse_comp_norm*K_B);

    Y=filter(h_pulse_comp,1,X_cic);
    %Y=X_cic;

    % График спектра компенсатора
    Y_comp=filter(h_pulse_comp,1,X);

    Sp = 20*log10(abs(fft(X.*win)));
    Sp_comp = 20*log10(abs(fft(Y_comp/K_B.*win)));
    figure(3)
    freq = (0:n-1)*Fs/n/1e6/r;
    f_n = 1:length(freq)/2;
    plot(freq(f_n), Sp_comp(:,f_n) - Sp(:,f_n))
    grid on
    xlabel('МГц')
    ylabel('dB')
    title('АЧХ компенсатора')

    % ===============================================================
    
    % ===== write filter coeff  ==================
    if (flag_control==1)
    h_pulse_rtl = h_pulse_comp(1:end/2);
    input_sig = Dop_code(h_pulse_rtl, B, 0);
    write_sig(input_sig, B, COEFF_FILE);
    %write_sig(input_sig, B, ['../' COEFF_FILE]); % для модуля
    end
    
    
    % Сохранение спектра для текущего порядка фильтра
    limit_dB = -120;
    limit_dB_band = -3;
    Sp = fft(Y.*win);
    angl_Sp = unwrap(angle(Sp));
    Sp_3 = abs(Sp);
    K_sp = 1/2^(2*B-3);
    Sp_all_cor = 20*log10(Sp_3 * K_sp); % c истиным коэфф передачи
    Sp_all_cor(Sp_all_cor<=limit_dB)=limit_dB;
    
    Sp_3 = convert_dB(Sp_3);
    Sp_3(Sp_3<=limit_dB)=limit_dB;
    Sp_3_band = Sp_3;
    Sp_3_band(Sp_3_band<=limit_dB_band)=limit_dB_band;
    

    Sp_all(num_order,:) = Sp_all_cor;
    Sp_band(num_order,:) = Sp_3_band;
    ang_Sp_all(num_order,:) = angl_Sp;
    legend_str = [legend_str;  num2str(L)];
    
end


% ========== Построение графиков ============================
figure(8)
freq = (0:r:n-1)*Fs/n/1e6/r;

subplot(3,1,1)
f_n = 1:length(freq)/2;
freq_out = freq;
plot(freq(f_n), Sp_all(:,f_n)')
grid on
xlabel('МГц')
ylabel('dB')
legend(legend_str)
title('АЧХ CIC+компенсатор')

subplot(3,1,2)
plot(freq(f_n), Sp_band(:,f_n)')
grid on
xlabel('МГц')
ylabel('dB')
legend(legend_str)
title('Неравномерность АЧХ CIC+компенсатор')

subplot(3,1,3)
plot(freq(f_n), ang_Sp_all(:,f_n)')
grid on
xlabel('МГц')
ylabel('рад')
legend(legend_str)
title('ФЧХ CIC+компенсатор')
%=============================================================














