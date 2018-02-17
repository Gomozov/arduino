//Arduino PWM Speed Control：
int E1 = 6;   
int M1 = 7;
int E2 = 5;                         
int M2 = 4;                           
 
void setup() 
{ 
    pinMode(M1, OUTPUT);   
    pinMode(M2, OUTPUT); 
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
  // Задержка 5 секунд после включения питания 
    delay(5000); 
 
    // Cекуда с небольшим вперёд 
    go(150, false, false, 1100);
 
    // Разворот на 180 градусов  
    go(125, true, false, 1350);
 
    // Две секуды с небольшим вперёд 
    go(150, false, false, 2200);
 
    // Разворот на 180 градусов в другую сторону 
    go(125, false, true, 1300);
 
    // Cекуда с небольшим вперёд 
    go(150, false, false, 1200);
 
    // Поворот на 90 градусов 
    go(125, true, false, 680);
 
    // Медленно назад полторы секунды 
    go(100, true, true, 1500);
 
    // Остановка до ресета или выключения питания 
    go(0, false, false, 0);
 
    // Всё, приехали
    while (true)
        ;
}
