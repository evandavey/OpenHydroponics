import serial
import os
import time

port='usbserial-A800csiR'
#port='usbmodem3d11'
#port='usbmodem1d11'


ser = serial.Serial('/dev/tty.'+port, 115200, timeout=1)

alarm_sent=False
while 1:

    ser.write('*data')
    line = ser.readline().strip()

    header=line.split(",")

    #header received
    if header[0]=='State':
        line=ser.readline().strip()
        data=line.split(",")

        if data[0]=='2':
            if not alarm_sent:
                print 'Hydro error'
                os.system('growlnotify -m "Hydroponics: Water too low"')
                alarm_sent=True


        for x in range(0,len(data)):
            print header[x] + ":" + data[x]
    
        time.sleep(5)



