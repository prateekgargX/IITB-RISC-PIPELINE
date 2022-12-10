GHDL = ghdl
WAVVY = gtkwave
FLAGS = "--std=08"

all:
	@$(GHDL) -a LSM2.vhdl LSM2test.vhdl
	@$(GHDL) -e LSMtest
	@$(GHDL) -r LSMtest --wave=wave.ghw 
	@$(WAVVY) wave.ghw