echo 0 > /sys/class/fpga_manager/fpga0/flags
cp SoC_wrapper.bit /lib/firmware/
echo SoC_wrapper.bit > /sys/class/fpga_manager/fpga0/firmware