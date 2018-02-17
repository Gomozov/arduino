#define sensorPin 0
#define VOLTS_PER_UNIT    .0049F        // (.0049 for 10 bit A-D)
float volts;
float proxSens = 0;
int cm;

void setup() {
 
   Serial.begin(9600);
   pinMode(sensorPin, INPUT);

}

void loop() {
 proxSens = analogRead(sensorPin);
 volts = (float)proxSens * VOLTS_PER_UNIT; // ("proxSens" is from analog read)
 cm = 60.495 * pow(volts,-1.1904);     // calc cm using "power" trend line from Excel
 if (volts < .2) cm = -1.0;        // out of range    
   Serial.print("CM: ");
   Serial.print(cm);
   delay(1000);
}
