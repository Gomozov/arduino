// Sweep
// by BARRAGAN <http://barraganstudio.com> 
// This example code is in the public domain.


#include <Servo.h> 
 
Servo myservo;  // create servo object to control a servo 
                // a maximum of eight servo objects can be created 
 
int pos = 0;    // variable to store the servo position 
 
void setup() 
{ 
  myservo.attach(10);  // attaches the servo on pin 9 to the servo object 
} 
 
 
void loop() 
{ 
   myservo.write(45);  // Повернуть серво влево на 45 градусов
   delay(2000);          // Пауза 2 сек.
   myservo.write(0);   // Повернуть серво влево на 0 градусов
   delay(1000);          // Пауза 2 сек.
   myservo.write(90);  // Повернуть серво на 90 градусов. Центральная позиция
   delay(1500);          // Пауза 1.5 сек.
   myservo.write(135); // Повернуть серво вправо на 135 градусов
   delay(3000);          // Пауза 3 сек.
   myservo.write(180); // Повернуть серво вправо на 180 градусов
   delay(1000);          // Пауза 1 сек.
   myservo.write(90);  // Повернуть серво на 90 градусов. Центральная позиция
   delay(5000);          // Пауза 5 сек.
} 
