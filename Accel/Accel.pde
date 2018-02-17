int Led1 = 4; 
int Led2 = 5;
int PinX = A0;
int PinY = A1;
int PinZ = A2;
long AX = 0;
long AY = 0;
long AZ = 0;
long AXX = 0;
long AYY = 0;
long AZZ = 0;
long i = 0;

void setup(){
  pinMode(Led1, OUTPUT);
  pinMode(Led2, OUTPUT);
  Serial.begin(9600); 
}
void loop(){
        //digitalWrite(Led1, HIGH);
        //digitalWrite(Led2, HIGH);
        i++;
        AX = analogRead(PinX);
        AY = analogRead(PinY);
        AZ = analogRead(PinZ);
        delay(20);
        Serial.print(i);
        Serial.print(": X=");
        Serial.print(AX);
        Serial.print(" Y=");
        Serial.print(AY);
        Serial.print(" Z=");
        Serial.println(AZ);
        AX = (AX*5-1800)/8;
        AY = (AY*5-1900)/8;
        AZ = (AZ*5-1800)/8;
        delay(20);
        Serial.print(" X=");
        Serial.print(AX);
        Serial.print(" Y=");
        Serial.print(AY);
        Serial.print(" Z=");
        Serial.println(AZ);
        if (abs(AX-AXX)>10) 
        {
         Serial.println("X Acceleration");
         digitalWrite(Led1, HIGH);
        }  
        if (abs(AY-AYY)>10) Serial.println("Y Acceleration");
        if (abs(AZ-AZZ)>10) 
        { 
         Serial.println("Z Acceleration");
         digitalWrite(Led2, HIGH);
        }  
        AXX = AX;
        AYY = AY;
        AZZ = AZ;
        delay(400);
        //Serial.println("Leds Off.");
        digitalWrite(Led1, LOW); // set the LED off
        digitalWrite(Led2, LOW); // set the LED off
        //delay(400);
         }
