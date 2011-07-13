import processing.core.*; 
import processing.xml.*; 

import processing.serial.*; 
import processing.opengl.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class Hydroponics_GUI extends PApplet {




Serial myPort;                // the serial port
int fontHeight = 14;  
String messageString;         // the main display string 

public void setup() {
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

public void loop() {
	
}

public void draw() {
	// clear the screen:
	background(0);
	textAlign(LEFT);
	myPort.write("*data");
	text(messageString, 10, 50,300, 130);
	delay(10000);
}

public void serialEvent(Serial myPort) {
 	// read the serial buffer:
	String inputString = myPort.readStringUntil('n');
	messageString +=  inputString;
	
}

  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#FFFFFF", "Hydroponics_GUI" });
  }
}
