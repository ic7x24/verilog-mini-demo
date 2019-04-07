# Verilog极简教程

> Verilog是拿来用的，不是用来学的。

## 教程说明

这是Verilog的一份极简教程，涵盖日常设计中的绝大部分基本语法。

语法不重要。

关键是实践。

完整的代码和仿真环境在[github共享](https://github.com/ic7x24/verilog-mini-demo)。


## 运行环境

```shell

# Centos Linux release 7.2.1511 
cat /etc/redhat-release

# QuestaSim-64 vlog 10.4c 
vlog -version

# Verdi 2001
verdi 

```

## RTL: 模块声明与例化(Module)

- 使用ANSI-C风格端口列表
- 参数化
- input都是wire
- output可以是wire或者reg
- 最后一个port没有`,`
- 使用名称关联的方式例化

```verilog 

module mini_top #(
    parameter NUM=8
)(
    input             clk,       
    input             rst_n,     
    input  [15 :0]    i_cw,      
    output reg        o_flag,    
    output [NUM-1:0]  o_data_rd
);

// module instantiation 
wire [15:0] cw;
wire        flag;
wire [15:0] data_rd;

mini_top #(
    .NUM ( 16 )
) u_DUT (
    .clk       ( clk      ) ,
    .rst_n     ( rst_n    ) ,
    .i_cw      ( cw       ) ,
    .o_flag    ( flag     ) ,
    .o_data_rd ( data_rd  ) 
);

```

## RTL: 常数

- 使用`define`定义全局常数
- 使用`localparam` 定义局部常数
- 使用`include`统一管理
- 尽量避免hard-coded number


```verilog

`define NUM_1 8'b0001_1111
`define NUM_2 8'h1F
`define NUM_3 8'd31
`define NUM_4 {4'h1, 4'b1111}
`define NUM_5 {4'h1, {4{1'b1}}}

localparam NUM_6 = 31;
localparam NUM_7 = NUM_6;
localparam NUM_8 = `NUM_1;
localparam NUM_9 = `NUM_1 + NUM_6 - 31;

```

## RTL: 变量(wire, reg)

- 给变量起个合适的名字
- wire只用于组合逻辑 
- wire赋值方式：assign，模块例化
- reg阻塞赋值描述组合逻辑
- reg非阻塞赋值描述时序逻辑

```verilog

wire r_enable;
wire r_start;
wire r_stop; 
wire r_invert;
wire r_skip;

assign {
    r_enable,
    r_start,
    r_stop,
    r_invert,
    r_skip
} = i_cw[4:0];

// reg
// combinational logic

reg flag;
always @* begin
    flag = r_enable | r_skip | r_stop | r_invert;
end

// reg 
// sequential logic
reg       cnt_4b_is_0xa;
reg [3:0] cnt_4b;

always @ (posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        cnt_4b        <= 4'd0;
        cnt_4b_is_0xa <= 1'b0;
        o_flag        <= 1'b0;
    end
    else begin
        cnt_4b        <= cnt_4b + 4'd1;
        cnt_4b_is_0xa <= cnt_4b==4'ha ? 1'b1 : 1'b0;
        o_flag        <= cnt_4b ==4'h8 ? 1'b1 : 1'b0;
    end
end

```

## RTL: 运算符

- 用括号保证优先级
- 优先级顺序表从高到低
    - high: () [] {}
    - h0: ! ~
    - h1: * / %
    - h2: + -
    - h3: << >>
    - h4: < <= > >=
    - h5: == != === !==
    - h6: &
    - h7: ^ ^~
    - h8: |
    - h9: &&
    - h10: ||
    - low: ? :


## RTL: 函数(function)

- 可综合
- 在模块中定义
- 至少包含一个输入
- 不能有输出
- 函数定义中不能出现always块语句
- 函数定义中可以调用函数


```verilog

// function : max
// 
function [7:0] max;
    input [7:0] A;
    input [7:0] B;
    
    begin
        max = A < B ? B : A;
    end
endfunction

wire [7:0] temp_max;

assign temp_max = max(i_din[7:0], NUM_6);

```

## RTL: 存储器(SRAM)

- 可仿真，可综合，可用于fpga
- 使用工艺库的memory compiler


```verilog
module mini_sp_ram #(
    parameter ADDR_BITS=8
)(    
    input             clk,
    input      [ 7:0] addr,
    input      [ 7:0] din,
    input             ce,
    input             we,
    output reg [ 7:0] dout
);

localparam MEM_DEPTH= 1<<ADDR_BITS;

reg [7:0] mem[MEM_DEPTH-1:0];

// synopsys_translate_off
integer i;
initial begin
    for(i=0; i<MEM_DEPTH;i=i+1) begin
        mem[i] = 8'h00;
    end
end
// synopsys_translate_on

always @(posedge clk) begin
    if(ce & we) begin
        mem[addr] = din;
    end
end

always @(posedge clk) begin
    if(ce && (!we)) begin
        dout <= mem[addr];
    end
end

endmodule

```

## RTL: 存储器(ROM)

- 可仿真，可综合，可用于fpga
- 使用工艺库的memory compiler

```verilog


module mini_rom (    
    input             clk,
    input      [ 7:0] addr,
    output reg [ 7:0] dout
);

always @(posedge clk) begin
    case(addr)
        8'h00: dout <= 8'h0A;
        8'h01: dout <= 8'h1A;
        8'h02: dout <= 8'h2A;
        8'h03: dout <= 8'h3A;
        8'h04: dout <= 8'h4A;
        8'h05: dout <= 8'h5A;
        8'h06: dout <= 8'h6A;
        8'h07: dout <= 8'h7A;
        8'h08: dout <= 8'h8A;
        8'h09: dout <= 8'h9A;
        8'h0A: dout <= 8'hAA;
        8'h0B: dout <= 8'hBA;
        8'h0C: dout <= 8'hCA;
        8'h0D: dout <= 8'hDA;
        8'h0E: dout <= 8'hEA;
        8'h0F: dout <= 8'hFA;

        8'h10: dout <= 8'h50;
        8'h11: dout <= 8'h51;
        8'h12: dout <= 8'h52;
        8'h13: dout <= 8'h53;
        8'h14: dout <= 8'h54;
        8'h15: dout <= 8'h55;
        8'h16: dout <= 8'h56;
        8'h17: dout <= 8'h57;
        8'h18: dout <= 8'h58;
        8'h19: dout <= 8'h59;
        8'h1A: dout <= 8'h5A;
        8'h1B: dout <= 8'h5B;
        8'h1C: dout <= 8'h5C;
        8'h1D: dout <= 8'h5D;
        8'h1E: dout <= 8'h5E;
        8'h1F: dout <= 8'h5F;

        default: dout <= 8'hff;
    endcase
end

endmodule

```

## TB : 仿真精度(timescale)

- 或者在仿真器命令选项指定

```verilog

`timescale 1ns/10ps 

```

## TB : 任务(task)

- 不可综合

```verilog

task hello;
    begin
        $display("hello world.");
    end

endtask


initial begin
    hello;
end


```

## TB : 时钟与复位产生(clock_reset_gen)


```verilog

reg clk;
reg rst_n;

initial begin
    clk = 0;
end

// Be careful if CLOCK_CYCLE%2 !=0
always #(`CLOCK_CYCLE/2) clk=~clk;


```

## TB : 波形文件产生(wave_dump)

```verilog

// use +define+DUMP_FSDB in vsim command
// to enable fsdb file dump
//
// -pli $(VERDI_HOME)/share/PLI/MODELSIM/$PLATFORM/novas_fli.so 
//
`ifdef DUMP_FSDB 
initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars(0,tb);
    #`MAX_RUN_TIME
    $finish(2);
end
`endif

```


## TB : 存储器初始化(mem_init)

```verilog

// memory initilization
integer fp_dmem;

initial begin
    fp_dmem = $fopen(`MEM_INIT_FILE, "r");
    if(fp_dmem)
        #5 $readmemh(`MEM_INIT_FILE, `MEM_INST);
    else begin
        $display("%s open failed.",`MEM_INIT_FILE);
        $finish;
    end
end

```


## RUN : Makefile

```makefile

PROJ_PATH = ../..

RTL_PATH  = $(PROJ_PATH)/rtl
TB_PATH   = $(PROJ_PATH)/sim/tb

FILE_LIST = rtl.f
DOFILE    = sim.do

TB_TOP    = tb

sim: 
	@rm -rf work
	vsim -c -do $(DOFILE) 

verdi: 
	@verdi -nologo -f $(FILE_LIST) -top $(TB_TOP) &

clean:
	@rm -rf *.ini *.fsdb *.log verdiLog transcript work 

veryclean: clean

listfile:
	@ls $(RTL_PATH)/*.v  > $(FILE_LIST)
	@ls $(TB_PATH)/*.v  >> $(FILE_LIST)

```

## RUN : Questasim(sim.do)

```tcl
vlib work
vmap work work

vlog -timescale=1ns/1ps +incdir=./ -work work \
    +define+DUMP_FSDB \
    -f rtl.f

vsim +notimingchecks -t 1ps -novopt -L work -l tb.log \
    -pli $env(VERDI_HOME)/share/PLI/MODELSIM/LINUX64/novas_fli.so \
    work.tb

run -all

```
