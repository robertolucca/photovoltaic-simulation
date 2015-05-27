$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'pvlib.rb'
#power profile timing from supplied table
power_profile=[20,20,100,100,20,20,60,60,20,20,110,110,20,20]
time_profile=[0,15,95,130,134,154,156,191,193,213,218,253,353,360]
profile_index=0
seconds_timer=0
channel_list='1,2,3' #output channels for the profile
mpp_power=200.0 #power level at 100% power
mpp_voltage=50 #voltage at the MPP
# Connect to TerraSAS 
#default connection is 'localhost',4944 which works when TerraSAS and Ruby run on the same computer
#use pv=Pvsim.new('localhost',4944) to connect to TerraSAS on another computer
pv=Pvsim.new()
resp=pv.Connect()
if resp[0] !=0 then
    puts resp[1]
    abort
end
resp=pv.Get_id()
puts "Connected to:",resp
pv.Create_en_curve(mpp_power.to_s,mpp_voltage.to_s,'csi','sta') #cristalline silicon with MPP 200W 50V, static simulation
pv.Execute_curve('EN 50530 CURVE',channel_list)
pv.Set_en50530_power(0,channel_list)
pv.Output_control('on',channel_list)
timer=Time.now.to_f
while profile_index < power_profile.size
  if seconds_timer >= time_profile[profile_index] then
    pw=power_profile[profile_index]
    printf("At %4d seconds power was set to %5d \%\n",seconds_timer,pw)
    pv.Set_en50530_power(pw*mpp_power/100,channel_list)
    profile_index+=1
  end    
  while (Time.now.to_f < timer+1.0)
  end
  timer=timer+1.0
  seconds_timer+=1
  sleep 0.5
end
pv.Disconnect()
puts "Profile execution completed."
