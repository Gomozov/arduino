byte q;

void setup()
{
  Serial.begin(9600);
  delay(1000);
  Serial.print("+++");
  delay(1000);
}

void loop()
{  
  Serial.println("ATID");
  delay(1000);
  Serial.println("ATMY");
  delay(1000);
  while(Serial.available()>0) 
   {
     q = Serial.read();
     Serial.print(q);
   }
}
