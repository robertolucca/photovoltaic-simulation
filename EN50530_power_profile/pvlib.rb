$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

require 'socket'
class Pvsim
    def initialize (ipaddr='localhost',ipport=4944)
        @ipaddr=ipaddr
        @ipport=ipport
    end
    def Connect()
        begin
            @session = TCPSocket.open(@ipaddr,@ipport)
        rescue
            return 1,'Connection failed'
        end 
    return 0,'Connected'
    end
    def Disconnect()
            @session.close
    end
    def Get_id()
        @session.puts("*idn?\r")
        tsasid=@session.recv(256)
        return tsasid
    end
    def Create_en_curve(volts,watts,tech,mode)
        @session.puts("curv:en50530:mpp #{volts},#{watts}\r")
        @session.puts("curv:en50530:sim #{tech},#{mode}\r")
        @session.puts("curv:en50530:add\r")          
    end    
    def Execute_curve (curve_name,channel_list)
        @session.puts("sour:curv \"#{curve_name}\",(@#{channel_list})\r")
    end
    def Output_control(state,channel_list)
      @session.puts("outp #{state},(@#{channel_list});*wai\r")
    end
    def Set_en50530_power(power,channel_list)
      @session.puts("sour:en50530:pow #{power},(@#{channel_list})\r")
      @session.puts("sour:exec (@#{channel_list})\r")
    end
end