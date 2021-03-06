#!/bin/bash

SV_EXT=".sv"

#Variables to update when adding files to project:
SRCS="altctrl.sv dirctrl.sv rpmctrl.sv pidctrl.sv dronetop.sv pwm_if.sv pwm.sv clock_divider.sv motor_feedback.sv drone_top_if.sv"
#SIM_TOP_TB="pwm_top_tb"
#SIM_TOP_HDL="pwm_top_hdl"
SIM_TOP_TB="drone_top_hvl"
SIM_TOP_HDL="drone_top_hdl"

#Intermediate variables used in this script:
SIM_TOP_TB_FILE="${SIM_TOP_TB}${SV_EXT}"
SIM_TOP_HDL_FILE="${SIM_TOP_HDL}${SV_EXT}"

VEL_ANALYZE_FILES=("${SRCS} ${SIM_TOP_HDL_FILE}")
ALL_FILES=(*.sv)

#Variables for command line args
DO_WORK_LIB_MAP=0
DO_BUILD=0
DO_RUN=0
DO_CLEAN=0

MODE="puresim"

set -e
###################################
# PARSE COMMAND LINE ARGS         #
###################################

INVALID_ARG_FOUND=0

#Starting code for bash arg parsing from: http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":awbcrm:h" opt; do
  case $opt in
    a)
      echo "-a option selected! All steps will be run (except clean)" >&2
      DO_WORK_LIB_MAP=1
      DO_BUILD=1
      DO_RUN=1
      ;;
    w)
      echo "-w option selected! 'work' library will be mapped." >&2
      DO_WORK_LIB_MAP=1
      ;;
    b)
      echo "-b option selected! Project will be built." >&2
      DO_BUILD=1
      ;;
    c)
      echo "-c option selected! Project will be cleaned." >&2
      DO_CLEAN=1
      ;;
    r)
      echo "-r option selected! Project will run simulation." >&2
      DO_RUN=1
      ;;
    h)
      echo "-h option selected! Help will be printed; nothing will execute." >&2
      INVALID_ARG_FOUND=1
      ;;
    m)
      echo "-m option provided! Mode is ${OPTARG}" >&2
      MODE="$OPTARG"
      if [ "$MODE" != "puresim" -a "$MODE" != "veloce" ]; then
        echo "Invalid mode encountered: ${MODE}" >&2
        INVALID_ARG_FOUND=1
      fi
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      INVALID_ARG_FOUND=1
      ;;
    :)
      echo "Option -$OPTARG requires an arugment." >&2
      INVALID_ARG_FOUND=1
      ;;
  esac
done

if [ $INVALID_ARG_FOUND -ne 0 ]; then
    #Referenced the following for printing name of script being run:
    #    https://stackoverflow.com/questions/192319/how-do-i-know-the-script-file-name-in-a-bash-script
    echo "Usage: ${0##*/} [options]" >&2
    echo "Options:" >&2
    echo "    -m Select mode (puresim | veloce, puresim is default)." >&2
    echo "    -a Select all build steps (equiv. of -wbr)" >&2
    echo "    -w Map work libraries. Needed before building." >&2
    echo "    -b Build (compile/analyze) the project." >&2
    echo "    -r Run simulation based on mode selection." >&2
    echo "    -c Clean the project, removing all intermediate files." >&2
    echo "    -h Display this help message." >&2
    exit -1
fi

###################################
# EXECUTE                          #
###################################

echo "Configuration:" >&2
echo "    Top TB File:  ${SIM_TOP_TB_FILE}" >&2
echo "    Top HDL File: ${SIM_TOP_HDL_FILE}" >&2
echo "    Source files: ${SRCS}" >&2
echo "    All files:    ${ALL_FILES[@]}" >&2
echo "    Analyze:      ${VEL_ANALYZE_FILES[@]}" >&2

#CLEAN STEP
if [ $DO_CLEAN -eq 1 ]; then
    echo "Cleaning project" >&2
    rm -rf tbxbindings.h modelsim.ini transcript.puresim work work.puresim work.veloce transcript *~ vsim.wlf *.log dgs.dbg dmslogdir veloce.med veloce.wave veloce.map velrunopts.ini edsenv 
fi
if [ $DO_WORK_LIB_MAP -eq 1 ]; then
    echo "Mapping work library"
    vlib work.$MODE
    vmap work work.$MODE
fi
if [ $DO_BUILD -eq 1 ]; then
    echo "Building project" >&2
    for file in "${ALL_FILES[@]}"; do
        echo "    vlog ${file}" >&2
        vlog $file
    done
    if [ "$MODE" == "veloce" ]; then
        for file in "${VEL_ANALYZE_FILES[@]}"; do
            echo "     Analyzing ${file}" >&2
            velanalyze $file
        done
        echo "Analyzing top TB file ${SIM_TOP_TB_FILE} for external tasks" >&2
        velanalyze -extract_hvl_info +define+QUESTA $SIM_TOP_TB_FILE    #Analyze the HVL for external task calls in BFM 
        echo "Synthesizing Top HDL module ${SIM_TOP_HDL_FILE}" >&2
        velcomp -top $SIM_TOP_HDL      #Synthesize!
    elif [ "$MODE" != "puresim" ]; then
        echo "Invalid mode: ${MODE}" >&2
        exit -1
    fi
    echo "Setting up simulation for ${MODE}"
    velhvl -sim $MODE
fi
if [ $DO_RUN -eq 1 ]; then
    echo "Running simulation in ${MODE} mode" >&2
    vsim -c -do "run -all; quit" $SIM_TOP_TB $SIM_TOP_HDL    #Run all
    cp transcript "transcript.${MODE}" #Record transcript 
fi

echo "All done!" >&2
exit 0
