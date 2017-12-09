This readme document describes how to setup and run the drone module
on the veloce emulator.

Setup:
1. Please follow the guidelines posted at the following URL for environment setup and accessing file storage which is accessable to the emulator:
http://web.cecs.pdx.edu/~faustm/ece571/resources/Veloce_SetupUsage_OS3.pdf
2. As per the above documentation, enviroment setup was successful if the appropriate responses are received when issuing the following commands:
Command  - echo $VELOCE_BASE
Response - /pkgs/mentor/veloce/v3007
Command  - echo $VMW_HOME
Response - /pkgs/mentor/veloce/v3007/Veloce_v3.0.0.7
3. Connect to the veloce emulator using either putty, ssh, or other means (detailed in enviroment setup document)
4. Copy ECE571_Drone.tar.gz to a folder which is accessible to the veloce emulator.
5. Unzip the package using  the following command:
tar -xvjf ECE571_Drone.tar.gz
6. Change file permissions on the folder:
chmod 0755 -R ./ECE571_Drone
7. Change to that directory:
cd ECE571_Drone

Running the entire flow (assuming a command prompt is available in the ECE571_Drone directory):
1. Check that nobody else is using the emulator (see environment setup documentation)
2. A build script has been provided to run the entire flow. All steps can be run using the following command (will run on the emulator):
./BuildDrone.bash -a -m veloce
3. If everything runs correctly, it will map work libraries, build/analyze the project, and run on the emulator. The last messages printed in the console will show the results of emulation and the testbench.

Running individual steps in the flow:
1. Create work libraries for either puresim or veloce mode:
./BuildDrone.bash -w -m <mode=veloce | puresim>
2. Build project (mode specific:
./BuildDrone.bash -b -m <mode=veloce | puresim>
3. Run simulation in Questa or on emulator (mode=puresim for Questa, mode=veloce for emulator):
./BuildDrone.bash -r -m <mode=veloce | puresim>
4. Clean the project (if wanting to start the process over from a clean starting point):
./BuildDrone.bash -c

The default mode for this script is to run in puresim, so the mode switch can be omitted if running in puresim mode for Questa.

More information:
The testbench being run is drone_top_hvl.sv and drone_top_hdl.sv. It implements the TBX model of emulation, communicating data across the drone_top_if interface. This is implemented as a bus functional model transactor. All other testbenches in this folder are module unit testbenches, with the exception of pwm_top_tb.sv and pwm_top_hdl.sv. This testbench combination is also setup to run on the emulator in TBX mode.

Expected results:
- Everything should run to completion
- There should be 20512 overall tests run and reported by the testbench, with 0 failures
- The percentage of time reported in HDL time advance was just shy of 10% from initial testing runs, total time spent is about 30 seconds.

Concluding thoughts:
- TBX mode is great for visibility into debugging, but seems to communicate a lot of data over the HSL per test case. This strategy would need to be re-evaluated if the testbench were more complex and computationally intensive.
- Better speedup could be achieved if instantiating multiple drone modules in parallel and testing them in parallel. Also, less data would need to be communicated across the HSLs.
