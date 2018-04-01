#
## ================================================================ 
## Verilog Mini Demo Project 
##  
## Licensed under the MIT License.
## 
## github  : https://github.com/ic7x24/verilog-mini-demo 
## ================================================================
#
# Centos-7 X64, Questasim 10.4C, Verdi2016

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
	@rm -rf *.txt *.ini *.fsdb *.log verdiLog transcript work  novas.*

veryclean: clean

listfile:
	@ls $(RTL_PATH)/*.v   > $(FILE_LIST)
	@ls $(TB_PATH)/*.v   >> $(FILE_LIST)

