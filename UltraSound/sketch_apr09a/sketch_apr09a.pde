#include "URMSerial.h"
#define DISTANCE 1
#define TEMPERATURE 2
#define ERROR 3
#define NOTREADY 4
#define TIMEOUT 5
 
URMSerial urm;

void setup() {

Serial.begin(9600);                  // Sets the baud rate to 9600
urm.begin(2,3,9600);                 // RX Pin, TX Pin, Baud Rate
Serial.println("URM37 Library by Miles Burton - Distance. Version 2.0");   // Shameless plug
}

void loop()
{
Serial.print("Measurement: ");
Serial.println(getMeasurement(DISTANCE));  // Output measurement
Serial.print("Temperature:");
Serial.println(getMeasurement(TEMPERATURE));
delay(1000);
}

int value; // This value will be populated
int getMeasurement(int mode)
{
// Request a distance reading from the URM37
switch(urm.requestMeasurementOrTimeout(mode, value)) // Find out the type of request
{
case DISTANCE: // Double check the reading we recieve is of DISTANCE type
//    Serial.println(value); // Fetch the distance in centimeters from the URM37
return value;
break;
case TEMPERATURE:
return value;
break;
case ERROR:
Serial.println("Error");
break;
case NOTREADY:
Serial.println("Not Ready");
break;
case TIMEOUT:
Serial.println("Timeout");
break;
}
return -1;
}
