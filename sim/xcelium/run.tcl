# Simulation control script
if {[info exists ::env(ENABLE_WAVES)] && $::env(ENABLE_WAVES) == 1} {
    set wave_name $::env(WAVE_NAME)
    puts "Enabling waveform dumping to ${wave_name}.shm"
    database -open ${wave_name}.shm -default
    probe -create testbench -shm -packed 0 -unpacked 0 -all -memories -variables -generics -depth all -tasks -functions
} else {
    puts "Waveform dumping disabled"
}
run
exit