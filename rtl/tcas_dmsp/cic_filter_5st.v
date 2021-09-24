
//***************************************************************************************************
// Название проекта  : 
// Название файла    : cic_filter.v
// Назначение        : CIC-фильтр
// Автор             : Шубин Д.А.
// Дата создания     : 12.11.2018
// Синтаксис         : IEEE 1364-2001 (Verilog HDL 2001)
// Комментарии       :
//            Для устойчивости CIC-фильтр реализован в виде звеньев (cic_filter_stage), 
//          в каждом из которых  есть интегрирующее звено и гребенчатый фильтр. 
//          На каждой стадии производится повышение разрядности в соответствии 
//          с коэффициентом передачи звена
//****************************************************************************************************
// Состояние модуля  : [*] проведена проверка синтаксиса (quartus, modelsim)
//                     [*] синтезируется без серьезных предупреждений (quartus)
//                     [*] проведено функциональное моделирование (modelsim)
//                     [] проведено тестирование на стенде
//                     [] проведено тестирование в целевой системе
//****************************************************************************************************



`timescale 1ns / 10ps

module cic_filter_5st
   #(parameter W_IN = 20,            // разрядность входного сигнала
               W_GAIN = 14,          // W_GAIN = ceil(ORDER^n_stages), n_stages - кол-во стадий
               W_GAIN_STAGE = 3,     // повышение разрядности на каждой стадии
               W_OUT = 24,           // W_OUT < W_IN + W_GAIN + 5 
               ORDER = 5)            // задержка в гребенке (определяет постоянную времени фильтра)
   (input reset_b,                   // сброс
    input clk,                       // тактовый сигнал
    input [W_IN-1:0] data_input,     // входной сигнал
    output [W_OUT-1:0] data_output); // выходной сигнал


    localparam NUM_STAGES = 5;                                 // number of stages 
    localparam W_ROUND_OUT = W_GAIN_STAGE*NUM_STAGES - W_GAIN; // width for rounding output
    localparam W_STAGE_1 = W_IN + W_GAIN_STAGE;                // width for stage 1
    localparam W_STAGE_2 = W_IN + W_GAIN_STAGE*2;              // width for stage 2
    localparam W_STAGE_3 = W_IN + W_GAIN_STAGE*3;              // width for stage 3
    localparam W_STAGE_4 = W_IN + W_GAIN_STAGE*4;              // width for stage 4
    localparam W_STAGE_5 = W_IN + W_GAIN_STAGE*5;              // width for stage 5
	
/////////////////// 1 стадия /////////////////////////////////////////////////////////////
    wire [W_STAGE_1-1:0] d_in_1;
    wire [W_STAGE_1-1:0] d_out_1;
    assign d_in_1 = { {(W_GAIN_STAGE){data_input[W_IN-1]}} , {data_input} };

    cic_filter_stage
       #(.WIDTH(W_STAGE_1),
         .ORDER(ORDER))  
    cic_filter_stage_inst_1
       (.clk(clk), 
        .reset_b(reset_b), 
        .data_input(d_in_1), 
        .data_output(d_out_1));


////////////////////// 2 стадия ////////////////////////////////////////////////////////////
    wire [W_STAGE_2-1:0] d_in_2;
    wire [W_STAGE_2-1:0] d_out_2;
    assign d_in_2 = { {(W_GAIN_STAGE){d_out_1[W_STAGE_1-1]}} , {d_out_1} };

    cic_filter_stage
       #(.WIDTH(W_STAGE_2),
         .ORDER(ORDER))  
    cic_filter_stage_inst_2
       (.clk(clk), 
        .reset_b(reset_b), 
        .data_input(d_in_2), 
        .data_output(d_out_2));
        
        
////////////////////// 3 стадия ////////////////////////////////////////////////////////////
    wire [W_STAGE_3-1:0] d_in_3;
    wire [W_STAGE_3-1:0] d_out_3;
    assign d_in_3 = { {(W_GAIN_STAGE){d_out_2[W_STAGE_2-1]}} , {d_out_2} };

    cic_filter_stage
       #(.WIDTH(W_STAGE_3),
         .ORDER(ORDER))  
    cic_filter_stage_inst_3
       (.clk(clk), 
        .reset_b(reset_b), 
        .data_input(d_in_3), 
        .data_output(d_out_3));

/////////////////////// 4 стадия ///////////////////////////////////////////////////////////
    wire [W_STAGE_4-1:0] d_in_4;
    wire [W_STAGE_4-1:0] d_out_4;
    assign d_in_4 = { {(W_GAIN_STAGE){d_out_3[W_STAGE_3-1]}} , {d_out_3} };

    cic_filter_stage
       #(.WIDTH(W_STAGE_4),
         .ORDER(ORDER))  
    cic_filter_stage_inst_4
       (.clk(clk), 
        .reset_b(reset_b), 
        .data_input(d_in_4), 
        .data_output(d_out_4));

/////////////////////// 5 стадия /////////////////////////////////////////////////////////////

    wire [W_STAGE_5-1:0] d_in_5;
    wire [W_STAGE_5-1:0] d_out_5;
    assign d_in_5 = { {(W_GAIN_STAGE){d_out_4[W_STAGE_4-1]}} , {d_out_4} };

    cic_filter_stage
       #(.WIDTH(W_STAGE_5),
         .ORDER(ORDER))  
    cic_filter_stage_inst_5
       (.clk(clk), 
        .reset_b(reset_b), 
        .data_input(d_in_5), 
        .data_output(d_out_5));
        
        
////////////////// Округление /////////////////////////////////
    wire [W_OUT-1:0] data_rounding;
    rounding 
       #(.WIDTH(W_STAGE_5),
         .START_BIT(W_STAGE_5-1 - W_ROUND_OUT),           
         .END_BIT(W_STAGE_5-W_OUT - W_ROUND_OUT))
    rounding_inst
       (.clk(clk), 
        .reset_b(reset_b), 
        .data_input(d_out_5), 
        .data_output(data_rounding));

    assign data_output = data_rounding;


endmodule














