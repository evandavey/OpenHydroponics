const int transistorPin = 2; // connected to the base of the transistor
const int ledPin = 13;


// Variables will change:
int ledState = LOW;             // ledState used to set the LED
long previousMillis = -120000;        // will store last time LED was updated

// the follow variables is a long because the time, measured in miliseconds,
// will quickly become a bigger number than can be stored in an int.
long interval = 120000;      

 void setup() {
   // set  the transistor pin as output:
   pinMode(transistorPin, OUTPUT);
   pinMode(ledPin, OUTPUT);
 }
     // interval at which to blink (milliseconds)


void loop()
{
  // here is where you'd put code that needs to be running all the time.

  // check to see if it's time to blink the LED; that is, if the 
  // difference between the current time and last time you blinked 
  // the LED is bigger than the interval at which you want to 
  // blink the LED.
  unsigned long currentMillis = millis();
 
  if(currentMillis - previousMillis > interval) {
    // save the last time you blinked the LED 
    previousMillis = currentMillis;   

    // if the LED is off turn it on and vice-versa:
    if (ledState == LOW)
      ledState = HIGH;
    else
      ledState = LOW;

    // set the LED with the ledState of the variable:
    digitalWrite(transistorPin,ledState);
    digitalWrite(ledPin, ledState);
  }
}
