## ================================================================ 
## Verilog Mini Demo Project 
##  
## Licensed under the MIT License.
## 
## github  : https://github.com/ic7x24/verilog-mini-demo 
## ================================================================

vlib work
vmap work work

vlog -timescale=1ns/1ps +incdir=./ -work work \
    +define+DUMP_FSDB \
    -f rtl.f

vsim +notimingchecks -t 1ps -novopt -L work -l tb.log \
    -pli $env(VERDI_HOME)/share/PLI/MODELSIM/LINUX64/novas_fli.so \
    work.tb

run -all

