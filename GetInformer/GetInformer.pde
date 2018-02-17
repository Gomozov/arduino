#include <SPI.h>
#include <Ethernet.h>

byte mac[] = {  0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192, 168, 0, 110 };
byte gateway[] = { 192, 168, 0, 1 };
byte server[] = { 213, 180, 204, 137 }; // info.maps.yandex.net
byte subnet[] = { 255, 255, 255, 0 }; //маска подсети
byte b1 = 0;
byte b2 = 0;

Client client(server, 80);

void setup() {
  Ethernet.begin(mac, ip, gateway, subnet);
  Serial.begin(9600);
  delay(1000);
  pinMode(3, OUTPUT);
  pinMode(5, OUTPUT);
  pinMode(7, OUTPUT);
  GetCall();
}
void GetCall() {  
  Serial.println("connecting...");
  if (client.connect()) {
    Serial.println("connected");
    client.println("GET http://info.maps.yandex.net/traffic/moscow/current_traffic_88.gif HTTP/1.1");
    client.println("Accept: image/gif");
    client.println("Accept-Charset: windows-1251,utf-8;q=0.7,*;q=0.3");
    client.println("Accept-Encoding: gzip,deflate,sdch");
    client.println("Accept-Language: ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4");
    client.println("Cache-Control: max-age=0");
    client.println("Connection: keep-alive");
    client.println("Host: info.maps.yandex.net");
    client.println("User-Agent: Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/534.16 (KHTML, like Gecko) Chrome/10.0.648.151 Safari/534.16");
    client.println();
  } 
  else {
    Serial.println("connection failed");
  }
}

void loop()
{
  if (client.available()) {
    byte b3 = client.read();
    if (b1 == 0x3f)
     if (b2 == 0xbb)
      if (b3 == 0x00) {
        Serial.println("Green");
        digitalWrite(3, HIGH);
        digitalWrite(5, LOW);
        digitalWrite(7, LOW);
        client.stop();
      }
    if (b1 == 0xff)
     if (b2 == 0xa4)
      if (b3 == 0x00) {
        Serial.println("Yellow");
        digitalWrite(5, HIGH);
        digitalWrite(3, LOW);
        digitalWrite(7, LOW);
        client.stop();
      }
    if (b1 == 0xff)
     if (b2 == 0x2a)
      if (b3 == 0x00) {
        Serial.println("Red");
        digitalWrite(7, HIGH);
        digitalWrite(3, LOW);
        digitalWrite(5, LOW);
        client.stop();
      }  
    b1 = b2;
    b2 = b3;
  }

  if (!client.connected()) {
    b1 = 0;
    b2 = 0;
    Serial.println();
    Serial.println("disconnecting.");
    client.stop();
    delay(10000);
    GetCall();
  }
}

