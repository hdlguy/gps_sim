# gps_sim
An attempt to synthesize GPS signals in FPGA logic.

It is useful to have a GPS signal source that can be incorporated into FPGA logic to support receiver design. The idea 
is to have sufficient realism to test satellite acquisition and tracking. A realistic navigation solution is beyond the scope
of this little project.

Goals:

- Multiple satellite channels, perhaps 8.
- C/A coarse acquisition sequence, selectable among the 37 possible.
- Programmable noise source.
- Signal strength adjustable per satellite
- Doppler frequency shift adjustable per satellite
- C/A code delay modelling

Stretch Goals:

- P-Code sequence, modelled as an interferor.
- 50 baud message data added to C/A sequence.


