% Скрипт для генерирования файла инициализации для модуля fir_filter.v
% Фильтр fir_filter.v работает только при его симметричной ИХ.
% Порядок фильтра может принимать значения из ряда R = 7, 15, 23, 31, 39, 47, 55, 63, 71, 79, …
% Порядок действий:
% 1 Запустить fdatool. Создать там фильтр с нужной АЧХ
% 2 Экспортировать fdatool переменную Num с коэффициентами с плавающей точкой
% 3 Задать здесь переменные WIDTH_IN и FILE_NAME 
% 4 Запустить данный скрипт

WIDTH_IN = 26;
FILE_NAME = 'init_file_fir_filter_63.dat'; % файл инициализации

h_pulse_rtl = Num(1:end/2);
h_pulse_rtl = round(h_pulse_rtl*2^(WIDTH_IN));
input_sig = Dop_code(h_pulse_rtl, WIDTH_IN+1, 0);
write_sig(input_sig, WIDTH_IN+1, FILE_NAME);
write_sig(input_sig, WIDTH_IN+1, ['../' FILE_NAME]);  % для модуля