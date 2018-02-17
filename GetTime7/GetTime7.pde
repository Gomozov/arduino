#include <SPI.h>
#include <Ethernet.h>

const byte slaveSelectPin = 9;                             // Пин SlaveSelect для выбора ULCD SPI
const byte CURRENT = 65;                                   // Регистр текущего объекта ULCD
const byte OPERAND0 = 72;                                  // Регистр OPERAND0 ULCD
const byte OPERAND1 = 73;                                  // Регистр OPERAND0 ULCD
byte mac[] = {  0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };      // МАС- адрес Ардуино
byte ip[] = { 192, 168, 0, 110 };                          // IP - адрес Ардуино
byte gateway[] = { 192, 168, 0, 1 };                       // Шлюз для выхода в интернет
byte Yandex[] = { 213, 180, 204, 137 };                    // info.maps.yandex.net
byte GisMeteo[] = { 92, 241, 171, 120 };                   // informer.gismeteo.ru
byte subnet[] = { 255, 255, 255, 0 };                      // Маска подсети
int b1 = 0;                                                // Байт для анализа цвета информера пробок
int b2 = 0;                                                // Байт для анализа цвета информера пробок
String Response = "";                                      // Строка полученная от сервера
Client Yclient(Yandex, 80);                                // Клиент для подключения к Yandex
Client Mclient(GisMeteo, 80);                              // Клиент для подключения к GisMeteo
boolean time = false;                                      // Признак запроса время/траффик

void setup() {
  pinMode (slaveSelectPin, OUTPUT);
  digitalWrite(slaveSelectPin,HIGH);
  Ethernet.begin(mac, ip, gateway, subnet);
  Serial.begin(9600);
  ULCDInit();                                              // Создаем виджеты, загружаем шрифты и картинки для начала работы
  GetTime();
}

void loop() {
  
  if (Mclient.available()) {
      char c = Mclient.read();
      Response.concat(c);
      if (Response.endsWith("latitude")) Response = "";
      if (Response.endsWith("<PHENOMENA")) Response = "";
      if (Response.endsWith("<PRESSURE")) {  
        b1 = Response.indexOf("cloudiness");
        Serial.println("Cloud: " + Response.substring(b1+12, b1+13));
        b2 = Response.indexOf("precipitation", b1+13);
        Serial.println("Rainfall: " + Response.substring(b2+15, b2+16));
        if (Response.substring(b2+15, b2+16) == "4" || Response.substring(b2+15, b2+16) == "5")
          PrintMeteoPic(16);
         else if (Response.substring(b2+15, b2+16) == "8") 
          PrintMeteoPic(17);
         else if (Response.substring(b1+12, b1+13) == "0")
          PrintMeteoPic(13);
         else if (Response.substring(b1+12, b1+13) == "3")
          PrintMeteoPic(15);
         else if (Response.substring(b1+12, b1+13) == "1" || Response.substring(b1+12, b1+13) == "2")
          PrintMeteoPic(14);
        Response = "";
      }
      if (Response.endsWith("<WIND")) {  
        Mclient.stop();
        Serial.println("Disconnecting from GisMeteo");    
        b1 = Response.indexOf("<TEMPERATURE");
        b2 = Response.indexOf("/>", b1+1);
        PrintMeteo(Response.substring(b1+18, b2));
        Response = "";
        Serial.println(freeRam());
        GetTraffic();
      }
  }  
  
 if (Yclient.available() && time) {
    char c = Yclient.read(); 
    Response.concat(c);
    if (Response.endsWith("GMT")) { 
      b1 = Response.indexOf("GMT");
      Serial.println(Response.substring(b1-26,b1-4)); 
      Yclient.stop();
      Serial.println("Disconnecting from Yandex");   
      PrintTime(Response.substring(b1-26,b1-4));
      Response = "";
      time = false;
      GetMeteo();
    } 
  }
   
  if (Yclient.available() && !time) {
    byte b3 = Yclient.read();
    if ((b1 == 0x3f)&&(b2 == 0xbb)&&(b3 == 0x00)) {
        Yclient.stop();
        Serial.println("Traffic: Green");
        Serial.println("Disconnecting from Yandex");
        PrintTraffic(5);
      }
    if ((b1 == 0xff)&&(b2 == 0xa4)&&(b3 == 0x00)) {
        Yclient.stop();
        Serial.println("Traffic: Yellow");
        Serial.println("Disconnecting from Yandex");
        PrintTraffic(6);
      }
    if ((b1 == 0xff)&&(b2 == 0x2a)&&(b3 == 0x00)) {
        Yclient.stop();
        Serial.println("Traffic: Red");
        Serial.println("Disconnecting from Yandex");
        PrintTraffic(7);
      }  
    b1 = b2;
    b2 = b3;
  }

  if (!Mclient.connected() && !Yclient.connected()) {
      Yclient.stop();
      Mclient.stop();
      delay(30000);
      Response = "";
      GetTime();
    } 
}

void ULCDInit() {
  SPI.setDataMode(SPI_MODE3);
  digitalPortWrite(8);                                        //Создаем контейнер
  SEND_REG(2, CURRENT);                                       //Сохраняем контейнер в регистр R2 для хранения строки времени
  LOAD_ITEM(0, "font20.fnt");                                 //Загружаем шрифт 20 с flash памяти TE-ULCD
  SEND_REG(OPERAND0, CURRENT);                                //Пересылаем шрифт в регистр OPERAND0
  digitalPortWrite(24);                                       //Создание объекта типа шрифт
  SEND_REG(0, CURRENT);                                       //Сохраняем шрифт в регистр R0
  digitalPortWrite(8);                                        //Создаем контейнер
  SEND_REG(9, CURRENT);                                       //Сохраняем контейнер в регистр R9 для хранения строки погоды (температура)
  LOAD_ITEM(0, "font12.fnt");                                 //Загружаем шрифт 12 с flash памяти TE-ULCD
  SEND_REG(OPERAND0, CURRENT);                                //Пересылаем шрифт в регистр OPERAND0
  digitalPortWrite(24);                                       //Создание объекта типа шрифт
  SEND_REG(10, CURRENT);                                      //Сохраняем шрифт в регистр R10
  CR_WID(1);                                                  //Создаем виджет Фрейм
  SEND_REG(3, CURRENT);                                       //Сохраняем фрейм в регистр R3
  LOAD_ITEM(1, "back.bmp");                                   //Загружаем картинки и сохраняем их в регистры...
  SEND_REG(1, CURRENT);
  LOAD_ITEM(1, "G.bmp");
  SEND_REG(5, CURRENT);
  LOAD_ITEM(1, "Y.bmp");
  SEND_REG(6, CURRENT);
  LOAD_ITEM(1, "R.bmp");
  SEND_REG(7, CURRENT);
  LOAD_ITEM(1, "clear.bmp");
  SEND_REG(13, CURRENT);
  LOAD_ITEM(1, "cloud.bmp");
  SEND_REG(14, CURRENT);
  LOAD_ITEM(1, "mcloud.bmp");
  SEND_REG(15, CURRENT);
  LOAD_ITEM(1, "rain.bmp");
  SEND_REG(16, CURRENT);
  LOAD_ITEM(1, "storm.bmp");
  SEND_REG(17, CURRENT);
  CR_WID(5);                                                   //Создаем виджет BitMap (для фона)
  SET_SIZE(320, 240);                                          //Устанавливаем размер BitMap
  SET_POS(0, 0);                                               //Устанавливаем позицию
  SEND_REG(OPERAND0, 1);
  digitalPortWrite(52);                                        //Установить данные
  CR_WID(5);                                                   //Создаем виджет BitMap (для пробок)
  SET_SIZE(24, 20);                                            //Устанавливаем размер BitMap
  SET_POS(296, 136);
  SEND_REG(8, CURRENT);
  CR_WID(5);                                                   //Создаем виджет BitMap (для погоды)
  SET_SIZE(64, 64);                                            //Устанавливаем размер BitMap
  SET_POS(256, 176);
  SEND_REG(12, CURRENT);
  CR_WID(7);                                                    //Создаем виджет Текст (для времени)
  SET_FONT_COLOR(134, 177, 230);                                //Устанавливаем цвет текста виджета
  SET_BACK_COLOR(70, 112, 188);                                 //Устанавливаем цвет фона виджета
  SEND_REG(OPERAND0, 0);                                        //Загружаем шрифт в регистр OPERAND0
  digitalPortWrite(50);                                         //Установить шрифт
  SET_POS(10, 90);
  SEND_REG(4, CURRENT);
  CR_WID(7);                                                    //Создаем виджет Текст (для погоды)
  SET_FONT_COLOR(134, 177, 230);                                //Устанавливаем цвет текста виджета
  SET_BACK_COLOR(58, 93, 159);                                  //Устанавливаем цвет фона виджета
  SEND_REG(OPERAND0, 10);                                       //Загружаем шрифт в регистр OPERAND0
  digitalPortWrite(50);                                         //Установить шрифт
  SET_POS(270, 160);
  SEND_REG(11, CURRENT); 
  SEND_REG(CURRENT, 3);                                         //Загружаем регистр R3 содержащий Frame в регистр CURRENT (R0 -> CURRENT)
  digitalPortWrite(34);                                         //Установить виджет главным
  SPI.setDataMode(SPI_MODE0);
}

void GetMeteo() {  
  Serial.println("Connecting to informer.gismeteo.ru");
  if (Mclient.connect()) {
    Serial.println("Connected to GisMeteo");
    Mclient.println("GET http://informer.gismeteo.ru/xml/88916_1.xml");  //Погода для Ивантеевки
  } 
  else {
    Serial.println("Connection failed");
  }
}

void GetTime() {  
  Serial.println("Connecting to info.maps.yandex.net");
  if (Yclient.connect()) {
    Serial.println("Connected to Yandex");
    time = true; 
    Yclient.println("GET http://info.maps.yandex.net/traffic/moscow HTTP/1.1"); 
    Yclient.println();
  } 
  else {
    Serial.println("Connection failed");
  }
}

void GetTraffic() {  
  b2 = 0;                                                     //Этого достаточно для Яндекс.пробок
  Serial.println("Connecting to info.maps.yandex.net");
  if (Yclient.connect()) {
    Serial.println("Connected to Yandex");
    Yclient.println("GET http://info.maps.yandex.net/traffic/moscow/current_traffic_88.gif HTTP/1.1");
    Yclient.println("Accept: image/gif");
    Yclient.println("Accept-Charset: windows-1251,utf-8;q=0.7,*;q=0.3");
    Yclient.println("Accept-Encoding: gzip,deflate,sdch");
    Yclient.println("Accept-Language: ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4");
    Yclient.println("Cache-Control: max-age=0");
    Yclient.println("Connection: keep-alive");
    Yclient.println("Host: info.maps.yandex.net");
    Yclient.println("User-Agent: Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US) AppleWebKit/534.16 (KHTML, like Gecko) Chrome/10.0.648.151 Safari/534.16");
    Yclient.println();
  } 
  else {
    Serial.println("Connection failed");
  }
}

void PrintTime (String str) {
  SPI.setDataMode(SPI_MODE3); 
  SEND_REG(CURRENT, 2);
  WRITE_REG(OPERAND0, str.length());
  digitalPortWrite(10);                                      //Устанавливаем длину контейнера
  WRITE_REG(66, 0);
  for (int i = 0; i < str.length(); i++) {
    WRITE_REG(OPERAND0, str[i]);        
    digitalPortWrite(17);                                    //Помещаем байт в буффер
  }
  SEND_REG(2, CURRENT);
  SEND_REG(CURRENT, 4);
  SEND_REG(OPERAND0, 2);
  digitalPortWrite(52);
  digitalPortWrite(35);
  SPI.setDataMode(SPI_MODE0);
}

void PrintTraffic(byte reg) {
  SPI.setDataMode(SPI_MODE3); 
  SEND_REG(CURRENT, 8);              //Загружаем BitMap в регистр CURRENT
  SEND_REG(OPERAND0, reg);           //Загружаем в регистр OPERAND0 картинку из регистра Ri для BitMap
  digitalPortWrite(52);              //Загружаем картинку в BitMap
  digitalPortWrite(35);              //Перерисовываем BitMap
  SPI.setDataMode(SPI_MODE0);
}

void PrintMeteoPic (byte reg) {
  SPI.setDataMode(SPI_MODE3); 
  SEND_REG(CURRENT, 12);             //Загружаем BitMap в регистр CURRENT
  SEND_REG(OPERAND0, reg);           //Загружаем в регистр OPERAND0 картинку из регистра Ri для BitMap
  digitalPortWrite(52);              //Загружаем картинку в BitMap
  digitalPortWrite(35);              //Перерисовываем BitMap
  SPI.setDataMode(SPI_MODE0);
}

void PrintMeteo (String str) {
  char c = 34;
  str = str.replace(c, "");
  str = str.replace(" min=", "...");
  Serial.println("Temperature: " + str);
  SPI.setDataMode(SPI_MODE3); 
  SEND_REG(CURRENT, 9);
  WRITE_REG(OPERAND0, str.length());
  digitalPortWrite(10);                                      //Устанавливаем длину контейнера
  WRITE_REG(66, 0);
  for (int i = 0; i < str.length(); i++) {
   WRITE_REG(OPERAND0, str[i]);       
   digitalPortWrite(17);                                    //Помещаем байт в буффер
  }
  SEND_REG(9, CURRENT);
  SEND_REG(CURRENT, 11);
  SEND_REG(OPERAND0, 9);
  digitalPortWrite(52);
  digitalPortWrite(35);
  SPI.setDataMode(SPI_MODE0);
}

void digitalPortWrite(byte value) {
  digitalWrite(slaveSelectPin,LOW);
  delay(5);
  SPI.transfer(value);
  delay(5);
  digitalWrite(slaveSelectPin,HIGH); 
  delay(5);
}

void SEND_REG(byte R1, byte R2) {
  digitalPortWrite(3); 
  digitalPortWrite(R1);
  digitalPortWrite(R2); 
}

void WRITE_REG(byte R, byte value) {
  digitalPortWrite(2); 
  digitalPortWrite(R);
  digitalPortWrite(value); 
  digitalPortWrite(0);
  digitalPortWrite(0);
  digitalPortWrite(0);
}

void CR_WID(byte WidType) {
  digitalPortWrite(32);
  digitalPortWrite(WidType); 
  delay(5);
}

void SET_SIZE(int X, byte Y) {
  digitalPortWrite(2); 
  digitalPortWrite(72);
  if (X > 255) {
    digitalPortWrite(X-256);
    digitalPortWrite(1);
  } 
  else {
    digitalPortWrite(X);
    digitalPortWrite(0);
  }  
  digitalPortWrite(0);
  digitalPortWrite(0);
  digitalPortWrite(2); 
  digitalPortWrite(73);
  digitalPortWrite(Y);
  digitalPortWrite(0);
  digitalPortWrite(0);
  digitalPortWrite(0);
  digitalPortWrite(40);
}

void SET_POS(int X, byte Y) {
  digitalPortWrite(2);                
  digitalPortWrite(72);
  if (X > 255) {
    digitalPortWrite(X-256);
    digitalPortWrite(1);
  } 
  else {
    digitalPortWrite(X);
    digitalPortWrite(0);
  }  
  digitalPortWrite(0);
  digitalPortWrite(0);
  digitalPortWrite(2);                
  digitalPortWrite(73);
  digitalPortWrite(Y);
  digitalPortWrite(0);
  digitalPortWrite(0);
  digitalPortWrite(0);
  digitalPortWrite(38);               
}

void SET_BACK_COLOR(byte R, byte G, byte B) {
  digitalPortWrite(2);                                         //Устанавливаем цвет фона
  digitalPortWrite(OPERAND0);
  digitalPortWrite(B); 
  digitalPortWrite(G);
  digitalPortWrite(R);
  digitalPortWrite(0);
  digitalPortWrite(44);
}

void SET_FONT_COLOR(byte R, byte G, byte B) {
  digitalPortWrite(2);                                        //Устанавливаем цвет текста
  digitalPortWrite(OPERAND0);
  digitalPortWrite(B); 
  digitalPortWrite(G);
  digitalPortWrite(R);
  digitalPortWrite(0);
  digitalPortWrite(47);
}

void LOAD_ITEM(byte From, String FileName) {                  // From: 0 - Flash, 1 - SD
  digitalPortWrite(8);                                        
  digitalPortWrite(14);                                       
  digitalPortWrite(From); 
  for (int i = 0; i < FileName.length(); i++)
    digitalPortWrite(FileName[i]);            
  for (int i = 0; i < (12 - FileName.length()); i++)
    digitalPortWrite(0);            
}

int freeRam () {
  extern int __heap_start, *__brkval; 
  int v; 
  return (int) &v - (__brkval == 0 ? (int) &__heap_start : (int) __brkval); 
}
