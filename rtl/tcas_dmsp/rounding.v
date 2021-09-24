//*************************************************************************************
//Название файла : rounding.v
//Назначение : Модуль для округления чисел
//Автор : Шубин Д.А.
//Дата создания : 12.11.2013
//Синтаксис : IEEE 1364-2001 (Verilog HDL 2001)
//Комментарии :
//Округляет и усекает входные числа в дополнительном коде
//в соответствии с диапазоном номеров битов, задаваемым на входе
//*************************************************************************************
//Состояние модуля : [*] проведена проверка синтаксиса (quartus 13.0, modelsim)
// [*] синтезируется без серьезных предупреждений (quartus 13.0)
// [*] проведена функциональное моделирование (modelsim)
// [ ] проведено временное моделирование (modelsim)
// [ ] проведено тестирование в логическом анализаторе
// [ ] проведено тестирование в целевой системе
//*************************************************************************************
//Ревизия : 1.0.0
//*************************************************************************************

`timescale 1ns / 10ps

module rounding
   #(parameter WIDTH = 32,                         // input width
               START_BIT = 30,                     // output start bit
               END_BIT = 16)                       // output end bit
   (input reset_b,                                 // reset
    input clk,                                     // clock
    input [WIDTH-1:0] data_input,                  // input data
    output reg [START_BIT-END_BIT:0] data_output); // output data

wire flag_sum;
assign flag_sum = ((~data_input[START_BIT]) & (data_input[END_BIT-1]) ) | ( data_input[START_BIT] & data_input[END_BIT-1] & (|(data_input[END_BIT-2:0]))) ;
	
always @ (posedge clk, negedge reset_b)
begin : round_calculate
if(!reset_b)
   data_output <= 0;
else begin
   if (flag_sum)
	   data_output <= data_input[START_BIT:END_BIT] + ({ {(START_BIT-END_BIT){1'b0}},  {(1){1'b1}} });
   else
	   data_output <= data_input[START_BIT:END_BIT];
   end
end

endmodule