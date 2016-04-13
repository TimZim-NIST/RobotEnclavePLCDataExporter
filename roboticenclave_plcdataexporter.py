#
# Author:       Timothy Zimmerman (timothy.zimmerman@nist.gov)
# Organization: National Institute of Standards and Technology
#               U.S. Department of Commerce
# License:      Public Domain
#
# Description:  Pulls experiment-specific and part delay data from the PLC. A 
#               MODBUS register is used to request a specific index of the part
#               tracker array. The PLC then updates the registers with the 
#               requested data. Current PLC update rate is 10 ms, so we have to
#               wait for the task to update the registers before we pull them.

from pymodbus.client.sync import ModbusTcpClient as ModbusClient
import time, datetime

def calculate_timestamp(lo, hi):
    return (hi * 65535) + lo

mb_server_ip = "192.168.0.30"
mb_server_port = "502"

# Connect to the MODBUS server on the PLC
client = ModbusClient(mb_server_ip, mb_server_port)

if client.connect() == True:
    print("Successfully connected to " + mb_server_ip + ":" + mb_server_port)
    
    curr_date = datetime.datetime.now().strftime("%Y%m%d")
    curr_time = datetime.datetime.now().strftime("%H%M%S")
    
    print("Creating metadata file..."),
    # Build the file name
    fname = "./data/PLCData-" + str(curr_date) + "-" + str(curr_time) + ".dat"
    try:
        mf = open(fname, 'w')
    except:
        print("Error creating the metadata file!")
    print("[DONE]")
    
    print("Exporting data..."),

    # Grab the number of finished parts, and station processing times
    # 0x8000 = Finished Parts
    # 0x8001 = Station 1 Process Time
    # 0x8002 = Station 2 Process Time
    # 0x8003 = Station 3 Process Time
    # 0x8004 = Station 4 Process Time
    enclave_data = client.read_holding_registers(0x8000, 5)
    # Grab the experiment mode and value
    # 0x8009 = Experiment Mode
    # 0x800A = Experiment Value
    # 0x800B = IGNORE
    # 0x800C = Experiment Timestamp 0 [LSB]
    # 0x800D = Experiment Timestamp 1
    # 0x800E = Experiment Timestamp 2
    # 0x800F = Experiment Timestamp 3 [MSB]
    exp_settings = client.read_holding_registers(0x8009, 7)
    
    # Build the experiment strings based on the returned data
    if exp_settings.registers[0] == 1:
        exp_mode = "Timer"
        exp_val = str(exp_settings.registers[1])
    elif exp_settings.registers[0] == 2:
        exp_mode = "Part_Counter"
        exp_val = str(exp_settings.registers[1])
    else:
        exp_mode = "Free_Run"
        exp_val = "N/A"
        
    # Calculate the experiment start time in seconds and milliseconds
    experiment_time_msec = (((exp_settings.registers[6] * 2**48) + (exp_settings.registers[5] * 2**32) + (exp_settings.registers[4] * 2**16) + exp_settings.registers[3]) - 116444736000000000) * (10**-4)
    timestamp_sec = experiment_time_msec / 1000
    timestamp_msec = experiment_time_msec % 1000
    
    # Write the metadata
    mf.write("Data_File: PLCData-" + str(curr_date) + "-" + str(curr_time) + ".csv\n")
    mf.write("Date: " + str(curr_date) + "\n")
    mf.write("Time: " + str(curr_time) + "\n")
    mf.write("Experiment_Mode: " + exp_mode + "\n")
    mf.write("Experiment_Value: " + exp_val + "\n")
    mf.write("Experiment_Start_Seconds: %3.3f\n" % timestamp_sec)
    #mf.write("Experiment_Start_Milliseconds: %3.0f\n" % timestamp_msec)
    mf.write("Station_1_ProcessingTime: " + str(enclave_data.registers[1]) + "\n")
    mf.write("Station_2_ProcessingTime: " + str(enclave_data.registers[2]) + "\n")
    mf.write("Station_3_ProcessingTime: " + str(enclave_data.registers[3]) + "\n")
    mf.write("Station_4_ProcessingTime: " + str(enclave_data.registers[4]) + "\n")
    mf.write("Total_Parts: " + str(enclave_data.registers[0]) + "\n")
    mf.write("Good_Parts: --\n")
    mf.write("Rejected_Parts: --\n")
    mf.write("Alarms: --\n")
    # We're done with the file, so close it
    mf.close()
    print("[DONE]")
    
    print("Creating data file..."),
    # Build the file name
    fname = "./data/PLCData-" + str(curr_date) + "-" + str(curr_time) + ".csv"
    try:
        df = open(fname, 'w')
    except:
        print("Error creating the data file!")
    # Write the column names
    df.write("sn,inspection_result,sta1_arr,sta1_dep,sta2_arr,sta2_dep,sta3_arr,sta3_dep,sta4_arr,sta4_dep,sta6_arr,sta6_dep\n")
    print("[DONE]")
    
    print("Exporting data..."),
    
    # Maximum parts the PLC can track is currently 512; iterate through all
    for part in range(1,512):
        # Inform the PLC task which index we want to read
        request = client.write_register(0x800B, part)
        # PLC needs time to update before we read the data
        time.sleep(0.02)
        # Read the data
        rd = client.read_input_registers(0x800A, 22)
        # Part SN's (the first element) are updated as parts are presented
        # to Station 6, and are sequential. So, if the first element value
        # does not match the expected one, there is no more data to be exported.
        if rd.registers[0] != part:
            break
        else:
            # We need to calculate the value of each timestamp based on the recorded HI and LO word 
            # Reset the list
            part_data = []
            # Append the part SN and inspection result
            part_data.append(rd.registers[0])
            part_data.append(rd.registers[1])
            # Append the arrival and departure timestamps
            # Station 1
            part_data.append(calculate_timestamp(rd.registers[2],rd.registers[3]))
            part_data.append(calculate_timestamp(rd.registers[4],rd.registers[5]))
            # Station 2
            part_data.append(calculate_timestamp(rd.registers[6],rd.registers[7]))
            part_data.append(calculate_timestamp(rd.registers[8],rd.registers[9]))
            # Station 3
            part_data.append(calculate_timestamp(rd.registers[10],rd.registers[11]))
            part_data.append(calculate_timestamp(rd.registers[12],rd.registers[13]))
            # Station 4
            part_data.append(calculate_timestamp(rd.registers[14],rd.registers[15]))
            part_data.append(calculate_timestamp(rd.registers[16],rd.registers[17]))
            # Station 6
            part_data.append(calculate_timestamp(rd.registers[18],rd.registers[19]))
            part_data.append(calculate_timestamp(rd.registers[20],rd.registers[21]))
            
            sdata = ""
            # Iterate through each element and add it to the CSV string
            for data in part_data:
                if sdata != "": 
                    sdata = sdata + ","
                sdata = sdata + str(data)
            # Write the data to the file, and add a new line
            df.write(sdata + "\n")
    # We're done with the file, so close it
    df.close()
    print ("[DONE]\nSuccessfully exported " + str(part-1) + " records.")
    
#    # Allow the user to clear the data from the PLC
#    print ("\nClear all experiment data from the PLC?")
#    clear_plc_data = input("y or n: ")
#    clear_plc_data = clear_plc_data.upper
#    if clear_plc_data == "Y" or clear_plc_data == "YES" or \
#       clear_plc_data == "YEAH" or clear_plc_data == "SURE" or \
#       clear_plc_data == "FINE" or clear_plc_data == "IF YOU INSIST":
#        client.write_coil(0x8002, 1)
#        client.write_coil(0x8003, 1)
    print ("Exiting...")
    exit
