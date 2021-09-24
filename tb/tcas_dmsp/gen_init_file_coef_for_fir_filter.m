% ������ ��� ������������� ����� ������������� ��� ������ fir_filter.v
% ������ fir_filter.v �������� ������ ��� ��� ������������ ��.
% ������� ������� ����� ��������� �������� �� ���� R = 7, 15, 23, 31, 39, 47, 55, 63, 71, 79, �
% ������� ��������:
% 1 ��������� fdatool. ������� ��� ������ � ������ ���
% 2 �������������� fdatool ���������� Num � �������������� � ��������� ������
% 3 ������ ����� ���������� WIDTH_IN � FILE_NAME 
% 4 ��������� ������ ������

WIDTH_IN = 26;
FILE_NAME = 'init_file_fir_filter_63.dat'; % ���� �������������

h_pulse_rtl = Num(1:end/2);
h_pulse_rtl = round(h_pulse_rtl*2^(WIDTH_IN));
input_sig = Dop_code(h_pulse_rtl, WIDTH_IN+1, 0);
write_sig(input_sig, WIDTH_IN+1, FILE_NAME);
write_sig(input_sig, WIDTH_IN+1, ['../' FILE_NAME]);  % ��� ������