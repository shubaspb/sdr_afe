//*************************************************************************************
//Название файла : comb2_filter.v
//Назначение : Гребенчатый фильтр n-го порядка
//Автор : Шубин Д.А.
//Дата создания : 12.11.2013
//Синтаксис : IEEE 1364-2001 (Verilog HDL 2001)
//Комментарии :
//Служит составной частью CIC-фильтра
//*************************************************************************************
//Состояние модуля : [*] проведена проверка синтаксиса (quartus 13.0, modelsim)
// [*] синтезируется без серьезных предупреждений (quartus 13.0)
// [*] проведена функциональное моделирование (modelsim)
// [*] проведено временное моделирование (modelsim)
// [ ] проведено тестирование в логическом анализаторе
// [ ] проведено тестирование в целевой системе
//*************************************************************************************
//Ревизия : 1.0.0
//*************************************************************************************

`timescale 1ns / 10ps

module cic_filter_stage
   #(parameter WIDTH = 16,    // вх/вых разрядность
     parameter ORDER = 20)    // задержка в гребенке
   (input reset_b,                       // сброс
    input clk,                           // тактовый сигнал
    input [WIDTH-1:0] data_input,        // входной сигнал
    output reg [WIDTH-1:0] data_output); // выходной сигнал


///////////// Интегратор /////////////////////////////////////////
	reg [WIDTH-1:0] data_integ;
	always @ (posedge clk, negedge reset_b) begin : integrator
		if(!reset_b)
		   data_integ <= {(WIDTH){1'b0}};
		else 
		   data_integ <= data_integ + data_input;
	end
//////////////////////////////////////////////////////////////////	
		
//////////// Гребенка ////////////////////////////////////////////
	reg [WIDTH-1:0] data_output_reg;
	reg [WIDTH-1:0] rg_delay [0:ORDER-2]; 

	// Задержка в соответствии с порядком фильтра
	always @ (posedge clk, negedge reset_b) begin : delay_n
		integer index;
		if(!reset_b) begin
			rg_delay[0] <= {(WIDTH){1'b0}};
				for(index = 0; index < ORDER-2; index = index + 1)
					rg_delay[index+1] <= {(WIDTH){1'b0}};
		   data_output_reg <= {(WIDTH){1'b0}};
		end else begin
		   rg_delay[0] <= data_integ;
			  for(index = 0; index < ORDER-2; index = index + 1)
				  rg_delay[index+1] <= rg_delay[index];
		   data_output_reg <= rg_delay[ORDER-2];
		end
	end

	// вычитатель
	always @ (posedge clk, negedge reset_b) begin : output_sub
		if(!reset_b)
		   data_output <= {(WIDTH){1'b0}};
		else 
		   data_output <= data_integ - data_output_reg;
	end
////////////////////////////////////////////////////////////////////

endmodule








