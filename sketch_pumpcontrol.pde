const int pumpCtrl = 2; // connected to the base of the transistor
const int pumpLed = 13;


// Variables will change:
int ledState = LOW;             // ledState used to set the LED
int pumpState = LOW;             // ledState used to set the LED
long pumpTimer = 0; // will store last time LED was updated

// the follow variables is a long because the time, measured in miliseconds,
// will quickly become a bigger number than can be stored in an int.
unsigned long intervalOn = 30000; //on 30 seconds 
unsigned long intervalOff = 300000; //off 5 minutes
unsigned long previousMillis = 0;


void setup() {
   // set  the transistor pin as output:
   pinMode(pumpCtrl, OUTPUT);
   pinMode(pumpLed, OUTPUT);
   Serial.begin(9600);
   Serial.print("Pump will be on for ");
   Serial.print(intervalOn/1000);
   Serial.print("s and off for ");
   Serial.print(intervalOff/1000);
   Serial.print("s\n");
    pumpOn();
   
}

void pumpCycle() {
  
  
  
 // Serial.print("Pump time is %d",pumpTimer);
  
   if (pumpState == HIGH) {
    
      
       
       if (pumpTimer>=intervalOn) {
           Serial.println("Pump on timer exceeded");
           pumpTimer=0;
           pumpOff();
         
           
       }
    
           
         
    
   } 
   
   if (pumpState == LOW) {
    
       
       if (pumpTimer>=intervalOff) {
           Serial.println("Pump off timer exceeded");
           pumpTimer=0;
           pumpOn();
          
       }
         
    
   } 
   

   
  
}

void pumpOff() {
  
  digitalWrite(pumpCtrl,LOW);
  pumpState=LOW;
  Serial.println("Pump Off");
  
}

void pumpOn() {
  
  digitalWrite(pumpCtrl,HIGH);
  pumpState=HIGH;
  Serial.println("Pump On");
  
}

void pumpLedCycle() {
  
  if (pumpState==HIGH) {
    digitalWrite(pumpLed,LOW);
    ledState = LOW;
  } 
  else {
   
    if (pumpTimer % 1000 == 0) {
       if (ledState == LOW) {
           digitalWrite(pumpLed,HIGH);
           ledState = HIGH;
       }
       else {
          digitalWrite(pumpLed,LOW);
           ledState = LOW;
        }
      
    }   
    
  }
}
  
     



void loop()
{
  // here is where you'd put code that needs to be running all the time.

  // check to see if it's time to blink the LED; that is, if the 
  // difference between the current time and last time you blinked 
  // the LED is bigger than the interval at which you want to 
  // blink the LED.
  unsigned long currentMillis = millis();
  
  //Serial.print(currentMillis/1000);
  pumpTimer += currentMillis-previousMillis;
  pumpCycle();
  pumpLedCycle();
  
  if (pumpTimer % 5000 == 0) {
    Serial.print("Pump timer: ");
    Serial.println(pumpTimer/1000);
  }
  
  previousMillis = currentMillis;
  
 
  
  //
  
}
