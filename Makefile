#Sameer Ghewari, Portland State University, Feb 2015
#This makefile is for TBX BFM Example - Simple booth

#Specify the mode- could be either puresim or veloce
#Always make sure that everything works fine in puresim before changing to veloce

MODE ?= veloce

SIM_TOP_TB = pwm_top_tb
SIM_TOP_HDL = pwm_top_hdl

SIM_TOP_TB_FILE = $(SIM_TOP_TB).sv
SIM_TOP_HDL_FILE = $(SIM_TOP_HDL).sv

SRCS = pwm_if.sv pwm.sv
ALL_FILES = $(SIM_TOP_TB_FILE) $(SIM_TOP_HDL_FILE) $(SRCS)

#make all does everything
all: work build run

#Create respective work libs and map them 
work:
	vlib work.$(MODE)
	vmap work work.$(MODE)
	
#Compile/synthesize the environment
build:
	vlog $(ALL_FILES)
	echo "Mode is $(MODE)"
	
ifeq ($(MODE),veloce)		#If mode is puresim, compile everything else						#else, synthesize!
	velanalyze -extract_hvl_info +define+QUESTA $(SIM_TOP_TB_FILE)	#Analyze the HVL for external task calls in BFM 
	velanalyze pwm_if.sv
	velanalyze $(SIM_TOP_HDL_FILE)		#Analyze the HDL top for synthesis 
	velanalyze pwm.sv
	velcomp -top $(SIM_TOP_HDL)  	#Synthesize!
endif

	velhvl -sim $(MODE)

run:
	vsim -c -do "run -all; quit" $(SIM_TOP_TB) $(SIM_TOP_HDL)	#Run all 
	cp transcript transcript.$(MODE)		#Record transcript 

norun:	#No run lets you control stepping etc. 
	vsim -c +tbxrun+norun $(SIM_TOP_TB) $(SIM_TOP_HDL) -cpppath $(CPP_PATH)
	cp transcript transcript.$(MODE)

clean:
	rm -rf tbxbindings.h modelsim.ini transcript.puresim work work.puresim work.veloce transcript *~ vsim.wlf *.log dgs.dbg dmslogdir veloce.med veloce.wave veloce.map velrunopts.ini edsenv 
	


