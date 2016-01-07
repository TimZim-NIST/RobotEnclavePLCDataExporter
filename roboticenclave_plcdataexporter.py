#
# Author:       Timothy Zimmerman (timothy.zimmerman@nist.gov)
# Organization: National Institute of Standards and Technology
#               U.S. Department of Commerce
# License:      Public Domain
#
# Description:  

from pymodbus.client.sync import ModbusTcpClient as ModbusClient
import time, datetime

mb_server_ip = "192.168.0.30"
mb_server_port = "502"

client = ModbusClient(mb_server_ip, mb_server_port)
if client.connect() == True:
    
    print("Successfully connected to " + mb_server_ip + ":" + mb_server_port)
    
    print("Creating data file...")
    curr_date = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
    fname = "./PLCData-" + str(curr_date) + ".csv"
    try:
        f = open(fname, 'w')
    except:
        print("Error creating the file!")
    f.write("sn,sta1_delay,sta2_delay,sta3_delay,sta4_delay,sta6_delay,sta1_to_sta2_delay,sta2_to_sta3_delay,sta3_to_sta4_delay,sta6_to_sta1_delay,inspection_result\n")
    
    print("Exporting data...")
    for part in range(1,512):
        request = client.write_register(0x800B, part)
        time.sleep(0.02) # PLC needs time to update before we read the data
        rd = client.read_input_registers(0x800A, 11)
        if rd.registers[0] != part:
            break
        else:      
            #print (rd.registers)
            sdata = ""
            for word in rd.registers:
                if sdata != "": 
                    sdata = sdata + ","
                sdata = sdata + str(word)
            f.write(sdata + "\n")
    print ("Done!\nSuccessfully exported " + str(part-1) + " records.")
    f.close()