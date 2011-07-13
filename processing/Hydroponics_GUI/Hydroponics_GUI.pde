import processing.serial.*;
import processing.opengl.*;

Serial myPort;                // the serial port
int fontHeight = 14;  
String messageString;         // the main display string 

void setup() {
	// set  the window size:
	size(600,400);
	// list all the serial ports:
	println(Serial.list());
	String portnum = Serial.list()[0];
	// initialize the serial port:
	myPort = new Serial(this, portnum, 115200);
	// clear the serial buffer:
	myPort.clear();
	// only generate a serialEvent() when you get a newline:
	myPort.bufferUntil('n');
	
	// create a font with the second font available to the system:
	PFont myFont = createFont(PFont.list()[2], fontHeight);
	textFont(myFont);
	
	messageString="Waiting for device..";

	
	
}


void draw() {
	// clear the screen:
	background(0);
	textAlign(LEFT);
	myPort.write("*data");
	text(messageString, 10, 50,300, 130);
	delay(10000);
}

void serialEvent(Serial myPort) {
 	// read the serial buffer:
	String inputString = myPort.readStringUntil('n');
	print inputString;
	messageString +=  inputString;
	
}

