#include <Ethernet.h>  
#include <SPI.h>
  
byte mac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192, 168, 0, 110 };
byte gateway[] = { 192, 168, 0, 1 };		
byte subnet[] = { 255, 255, 255, 0 };
byte server[] = { 94, 100, 177, 6 };  
int ledPin = 3; 
long updateTimer;
  
Client client(server, 110); 
  
void setup()  
{  
Ethernet.begin(mac, ip, gateway, subnet);  
Serial.begin(9600);  
pinMode(ledPin, OUTPUT);  
digitalWrite(ledPin, LOW); 
GetPOP();
  }
  
void GetPOP()
{
Serial.println("connecting...");  
 delay(1000);  
 if (client.connect())  
 {  
 Serial.println("connected");  
 client.println("USER gargos_vall");  
 client.println("PASS poiuyt"); 
 client.println("STAT"); 
 client.println("Quit");  
 client.println(); 
} 
 else {
    Serial.println("connection failed");
  }
}
  
void loop()  
{  
if (client.available()) {
    byte c = client.read();
    Serial.print(c);
  }
  
  if ((millis() - updateTimer) > 10000) client.stop();
  
  if (!client.connected()) {
    Serial.println();
    Serial.println("disconnecting.");
    client.stop();
    delay(10000);
    updateTimer = millis();
    GetPOP();
  } 
}  
  

