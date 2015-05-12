$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'pvlib.rb'
$power_profile=[]
$power_profile_index=0
$power_level=5.0 #initial power level
channel_list='1,2,3' #output channels for the profile
mpp_power=200.0 #power level at 100% power
mpp_voltage=50 #voltage at the MPP
def build_profile (duration,gradient)
  for i in (1..duration) do
  $power_profile[$power_profile_index]=$power_level
  $power_profile_index+=1
  $power_level+=gradient
  end
end
#build a simple power profile
build_profile(10,5.0) #ramp up for 10 seconds at a rate of 5.0% per second
build_profile(10,0.0) #dwell for 10 seconds 
build_profile(10,-5.0) #ramp down for 10 seconds at a rate of -5.0% per second
# Connect to TerraSAS 
pv=Pvsim.new
#default connection is 'localhost',4944
#use resp=pv.Connect(your_ip_address,4944) to connect to TerraSAS on another machine
resp=pv.Connect()
if resp[0] !=0 then
    puts resp[1]
    Thread.current.kill
end
resp=pv.Get_id()
puts "Connected to:",resp
pv.Create_en_curve(mpp_power.to_s,mpp_voltage.to_s,'csi','sta') #cristalline silicon with MPP 200W 50V, static simulation
pv.Execute_curve('EN 50530 CURVE',channel_list)
pv.Set_en50530_power($power_level*mpp_power/100,channel_list)
pv.Output_control('on',channel_list)
sleep 10.0 #let the microinverters stabilize
timer=Time.now.to_f
  for pw in $power_profile
    pv.Set_en50530_power(pw*mpp_power/100,channel_list)
    while (Time.now.to_f < timer+1.0)
    end
    timer=timer+1.0
    sleep 0.5
  end
pv.Disconnect()
puts "Profile execution completed."
