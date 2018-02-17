#include <Servo.h>

byte q;
Servo H_servo, V_servo;
int E1 = 6;   
int M1 = 7;
int E2 = 5;                         
int M2 = 4;

void setup()
{
  H_servo.attach(10);
  V_servo.attach(9);
  pinMode(M1, OUTPUT);   
  pinMode(M2, OUTPUT);
  Serial.begin(9600);
}

void go(int speed, bool reverseLeft, bool reverseRight, int duration)
{
    // Для регулировки скорости `speed` может принимать значения от 0 до 255,
    // чем болше, тем быстрее. 
    analogWrite(E1, speed);
    analogWrite(E2, speed);
    digitalWrite(M1, reverseLeft ? LOW : HIGH); 
    digitalWrite(M2, reverseRight ? LOW : HIGH); 
    delay(duration); 
}

void loop()
{  
  while(Serial.available()>0) 
   {
     q = Serial.read();
     Serial.print(q);
   }
  if (q == '1') H_servo.write(45);
  if (q == '2') H_servo.write(90);
  if (q == '3') H_servo.write(0);
  if (q == '4') H_servo.write(30);
  if (q == '5') H_servo.write(60);
  if (q == '6') V_servo.write(45);
  if (q == '7') V_servo.write(90);
  if (q == '8') V_servo.write(0);
  if (q == '9') V_servo.write(30);
  if (q == '0') V_servo.write(60);
  if (q == 'F') {
    go(150, false, false, 2200);
    go(0, false, false, 0);
  }
  if (q == 'B') {
    go(150, true, true, 1500);
    go(0, false, false, 0);
  }
  if (q != 'x') Serial.print(q);
  q = 'x';
}
