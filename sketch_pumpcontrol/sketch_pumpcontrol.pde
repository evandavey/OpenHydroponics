/* Hydroponics System 

-- Aeroponics controller
-- Author: Evan Davey, evan.j.davey@gmail.com

Cycles a pump for use in a hyrdoponics system
Implemented as a state machine 
X-valid serial command 
      *menu -> send main menu
      *data -> send data
      **rst -> state 3 
0-idle 
  Outputs: pumpCtrl=Low,statusLed=Blink,reset=Low
  off timer ends -> state 1
  waterSensor=High -> state 2
  
1-pumping
  Outputs: pumpCtrl=High,statusLed=Low,reset=Low
  on timer ends -> state 1
  waterSensor=High -> state 2
  
2-error,water low
  Outputs: pumpCtrl=Low,statusLed=fast blink,reset=Low
  requires reset to leave this state

3-reset
  Outputs: pumpCtrl=Low,statusLed=Low,reset=High
  Waits delay_time before resetting


*/


// hardware
const int pumpCtrl = 2; //connect via a transistor with back voltage protection
const int statusLed = 13; //connect using a current limiting resistor
const int reset = 12; //connect to reset via a transistor tied to ground
const int waterSensor = 8; //connect to a normally closed float switch

// firmware defaults
const float vers=1.0;
const unsigned long default_pump_on_time = 30000; //on 30 seconds 
const unsigned long default_pump_off_time = 300000; //off 5 minutes
const long baud_rate=115200; //baud rate for serial 
volatile int debug_mode=0; //when high, outputs status data 
int pumpCycles = 1; //counter of pump cycles
int reset_delay=4; //time to wait after reset command issued
int start_state=0; //starting state

// 0 - idle
// 1 - pumping
// 2 - error, water level
// 3 - waiting for reset
volatile int currentState = 0;




// Variables will change:
int ledState = LOW;             // ledState used to set the LED
int pumpState = LOW;             // ledState used to set the LED
long pumpTimer = 0; // will store last time LED was updated
int waterSensorState = LOW;


volatile char cmd='-1';
long pump_on_time; //on 30 seconds 
long pump_off_time; //off 5 minutes
unsigned long previousMillis = 0;
boolean in_menu=false;


void setup() {

  // set  the transistor pin as output:
  pinMode(pumpCtrl, OUTPUT);
  pinMode(statusLed, OUTPUT);
  pinMode(reset, OUTPUT);
  pinMode(waterSensor, INPUT);

  pump_off_time=default_pump_off_time;
  pump_on_time=default_pump_on_time;

  Serial.begin(baud_rate);

  delay(1000);

  //turn on pump
  currentState=start_state;


}

void keepTime() {
   //keep the time
  unsigned long currentMillis = millis();
  pumpTimer += currentMillis-previousMillis;
  previousMillis = currentMillis;
  
}

void mainControlLoop() {
  
  keepTime();
  
  //check for errors
  errorCheck();
  
  //handle state
  handleState();

  
}


void loop()
{

  mainControlLoop();
  
  //in the main menu
  if (in_menu) {
    menu_main();
  }
 
  //process received serial data
  //available command *menu
  handleSerialIn();

  if (debug_mode && !in_menu) {


    if (pumpTimer % 5000 == 0) {
      Serial.println(":: DBEUG ::");
      status_toString();
    }
  } 

}


void handleSerialIn() {


  if ( Serial.available() > 0) { // if there are bytes waiting on the serial port

    char inByte = Serial.read(); // read a byte
    if (inByte == '*') { // if that byte is the desired character

      int len = 5; // expected string is 6 bytes long
      char inString[len]; // declare string variable
      for (int i = 0; i < len; i++) {
        inString[i] = Serial.read();
        delay(100);
      }

      //Serial.println(inString);

      if ( strstr(inString, "menu") != NULL ) { // check to see if the respose is "reset"


        menu_main(); // reset the chip after waiting for the specified # of milliseconds
      } 
      else if (strstr(inString, "data") != NULL ) {

        //send data
        data_toString();

      } 
      
      else if (strstr(inString, "*rst") != NULL ) {

        //send data
        currentState=3;

      } 


    }
  }
}


void handleState() {

  switch(currentState) {
    //IDLE
  case 0:

    flashLed(statusLed,1,1000);
    digitalWrite(pumpCtrl,LOW);
    //pump off timer exceeded, switch to pumping state
    if (pumpTimer >= pump_off_time) {
      pumpTimer=0;
      pumpCycles++;
      currentState=1;
    }
    break;

    //PUMPING
  case 1:


    digitalWrite(pumpCtrl,HIGH);
    //pump on timer exceeded, switch to idle state
    if (pumpTimer >= pump_on_time) {
      pumpTimer=0;
      currentState=0;
    }
    break;

    //ERROR
  case 2:
    digitalWrite(pumpCtrl,LOW);
    flashLed(statusLed,3,100);
    break;

    //RESET
  case 3:
  
   
    
    for (int i=reset_delay;i>0;i--) {
      Serial.print("Will reset in ");
      Serial.print(i);
      Serial.println("s");
      delay(1000);
    }
    
    Serial.println("** Resetting now **");
    digitalWrite(reset,HIGH);
    currentState=0;
    break;



  default:
    break;

  }      


}

void data_toString() {


  //delay(1000);
  Serial.println("State,PumpTimer,PumpOffTime,PumpOnTime,PumpCycles,WaterSensor,DebugMode");
  Serial.print(currentState);
  Serial.print(",");
  Serial.print(pumpTimer/1000);
  Serial.print(",");
  Serial.print(pump_off_time);
  Serial.print(",");
  Serial.print(pump_on_time);
  Serial.print(",");
  Serial.print(pumpCycles);
  Serial.print(",");
  Serial.print(waterSensorState);
  Serial.print(",");
  Serial.print(debug_mode);
  
  Serial.print("\n");


}


void errorCheck() {

  // water level too low, enter error state
  if (!checkWater()) {
    currentState=2; 
    return;
  } 





}


//checks the water sensor and returns true if water is present
boolean checkWater() {

  waterSensorState=digitalRead(waterSensor);

  if (waterSensorState == HIGH) {
    return false;
  } 
  else {
    return true;
  } 

}

void state_toString(int state) {

  switch(state) {
  case 0:
    Serial.println("0 - Idle");
    break;
  case 1:
    Serial.println("1 - Pumping");
    break;
  case 2:
    Serial.println("2 - Error, Water too low");
    break;
  case 3:
    Serial.println("3 - Waiting to reset");
    break;

  default:
    Serial.println("Unknown State");

  }


}

void status_toString() {

  Serial.print("Version: ");
  Serial.println(vers);
  Serial.print("Debug Mode: ");
  Serial.println(debug_mode);
  Serial.print("State: ");
  state_toString(currentState);
  Serial.print("Pump Timer: ");
  Serial.println(pumpTimer/1000);
  Serial.print("Pump Cycles: ");
  Serial.println(pumpCycles);
  Serial.print("Pump Off Time: ");
  Serial.println(pump_off_time/1000);
  Serial.print("Pump On Time: ");
  Serial.println(pump_on_time/1000);
  Serial.print("Water Sensor: ");
  Serial.println(waterSensorState); 

}

void menu_show() {

  Serial.println("::::: HYDRO SYSTEM :::::");
  status_toString();
  delay(500);
  Serial.println("--------------------------------");
  Serial.println("(1) - exit menu");
  Serial.println("(2) - reset");
  Serial.println("(3) - toggle debug");
  Serial.println("(4) - force state");
  Serial.println("(5) - set pump on time");
  Serial.println("(6) - set pump off time");

}

void menu_main() {


  //first time in, show the menu
  if (!in_menu) {
    delay(700);
    Serial.flush();
    menu_show();
    in_menu=true;
  }


  //wait for command
  if (in_menu) {

    if ( Serial.available() > 0) { // if there are bytes waiting on the serial port

      cmd = Serial.read();

      switch (cmd) {

      case '1':
        Serial.println("exiting menu");
        in_menu=false;
        break;

      case '2':

        in_menu=false;
        currentState=3;
        break;

      case '3':
        in_menu=false;
        debug_mode=!debug_mode;
        Serial.print("Debug mode=");
        Serial.println(debug_mode);
        break;

      case '4':


        Serial.println("States-");
        for (int i=0;i<=3;i++) {
          state_toString(i);
        }
        Serial.print("State Number (0-3): ");

        Serial.flush();
        while (true) {
          //ensure operation continues while waiting
          mainControlLoop();
          if ( Serial.available() > 0) { // if there are bytes waiting on the serial port
            char * cmd_c="0";
            cmd_c[0]=Serial.read();

            int cmd_i=atoi(cmd_c);

            if (cmd_i<=3) {
              Serial.print("Setting state to: ");
              Serial.println(cmd_i);
              pumpTimer=0;
              currentState=cmd_i;
              in_menu=false;
              break;
            } 
            else {

              Serial.print("State Number (0-3): ");
              Serial.flush();
            }
          } 

        }
        break;

      case '5':
        
        Serial.println("(1) 10 seconds");
        Serial.println("(2) 20 seconds");
        Serial.println("(3) 30 seconds");
        Serial.println("(4) 60 seconds");
        Serial.println("(5) 120 seconds");

        Serial.flush();
        while (true) {
          //ensure operation continues while waiting
          mainControlLoop();
          int t;
          if ( Serial.available() > 0) { 
            cmd=Serial.read();

           
            switch(cmd) {

            case '1':
              t=10;
              break;
            case '2':
              t=20;
              break;
            case '3':
              t=30;
              break;
            case '4':
              t=60;
              break;
            case '5':
              t=120;
              break;
            default:
              t=30;
            }
            
          pump_on_time=t*1000;
          Serial.print("new pump time:") ;
          Serial.println(t); 
          in_menu=false;
          break; 

          } 
         
        }  
        break;
      
      case '6':
        
        Serial.println("(1) 60 seconds");
        Serial.println("(2) 2 minutes");
        Serial.println("(3) 5 minutes");
        Serial.println("(4) 10 minutes");
        Serial.println("(5) 15 minutes");

        Serial.flush();
        while (true) {
          //ensure operation continues while waiting
          mainControlLoop();
          long t;
          if ( Serial.available() > 0) { 
            cmd=Serial.read();

           
            switch(cmd) {

            case '1':
              t=60;
              break;
            case '2':
              t=120;
              break;
            case '3':
              t=300;
              break;
            case '4':
              t=600;
              break;
            case '5':
              t=900;
              break;
            default:
              t=300;
            }
            
          pump_off_time=t*1000;
         
        
          Serial.print("new pump time:") ;
          Serial.println(t); 
          in_menu=false;
          break; 

          } 
         
        }  
        break;   
      default:
        Serial.println("illegal command");
        Serial.flush();
        menu_show(); 

      }

    }
  }



}


//blinks a Led pin numBlinks at the blinkRate 
void flashLed(int ledPin,int numBlinks,int blinkRate) {


  digitalWrite(ledPin,LOW);
  for (int i=1;i<=numBlinks;i++) {

    digitalWrite(ledPin,HIGH);
    delay(blinkRate);
    digitalWrite(ledPin,LOW);
    delay(blinkRate);

  }

}  










