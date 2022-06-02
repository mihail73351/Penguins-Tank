#include <SoftwareSerial.h>
#include <GyverMotor.h>
#include "GParser.h"
//#include "AsyncStream.h"
//#include <Servo.h>

#define green 7
#define red 8
#define yellow 9

GMotor motorL(DRIVER2WIRE, 2, 3, HIGH);  
GMotor motorR(DRIVER2WIRE, 4, 5, HIGH);


SoftwareSerial BTSerial(A4, A5); //rx - tx

int goodok = 0;
int shoot = 0;
int timer = 0;
int tower_timer = 0;
int summ = 0;
int sum1 = 0;
int minDuty = 80;
int OX = 0;
int OY = 0;
int a_vert = 0;
int a_hor = 155;
int prizel = 0;

int diod = 0;
/*
void resetTower(){ 
  hor.write(a_hor);
  vert.write(a_vert);
}
*/
void setup() {
  pinMode(11, OUTPUT);
  pinMode(10, OUTPUT);
  
  BTSerial.begin(9600);
  Serial.begin(9600);
  
  pinMode(13, OUTPUT); // прицел
  pinMode(12, OUTPUT); // лазер
  pinMode(7, OUTPUT); // зеленый светодиод
  pinMode(8, OUTPUT); // красный светодиод
  pinMode(9, OUTPUT); // желтый светодиод
  pinMode(6, OUTPUT);

  
  motorL.setMinDuty(minDuty);
  motorR.setMinDuty(minDuty);
  motorL.setMode(AUTO);
  motorR.setMode(AUTO);


  //resetTower();
  
}





// с пк на ардуино
// 0, правый стик OY
// 1, правый стик OX
// 2, кнопка A 
// 3, горизонтальный поворот башни
// 4, вертикальный поворот башни
// 13, прицел
// 7, светодиод


void loop() {
  
  if (BTSerial.available()) {
    char bufer[50];
    for (int i = 0; i < 50; i++) {
      bufer[i] = 0;
    }
    BTSerial.readBytesUntil(';', bufer, 50);
    GParser parser(bufer, ',');
    int ints[20];
    parser.parseInts(ints);
    /*for (int i = 0; i < 20; i++){
    ints[i] = (int)ints[i];
    }*/
    /*for (int i = 0; i < 20; i++){
      Serial.print(ints[i]);
      
      Serial.print(",");
    }*/
    
   // Serial.print("\n");


//    switch (ints[0]){
//      case 0:
//        OX = ints[1];
//        break; 
//      case 1: 
//        OY = ints[1];
//        break;
//      case 3:
//        a_hor = ints[1];
//        break;
//      case 4:
//        a_vert = ints[1];
//        break;     
//      case 7:
//        diod = ints[1];
//        break;     
//      case 13: digitalWrite(13, ints[1]);
//        break;
//    }

      // 0 OX
      // 1 OY
      // 2 a_hor
      // 3 a_vert
      // 4 diod
      /*for (int i = 0; i++; i < 5)
        sum1 += ints[i];

      summ = ints[5];
    if (summ == sum1){*/
      OX = ints[1];
      OY = ints[0];
      a_hor = ints[2];
      a_vert = ints[3];
      diod = ints[4];
      prizel = ints[5];
      shoot = ints[6];
      goodok = ints[7];
      
   // }
      

     // sum1 = 0;
  
  }

  //diod = 1;

  

  switch (diod){
    case 0:
      digitalWrite(green, 1);
      digitalWrite(red, 0);
      digitalWrite(yellow, 0);
      break;
    case 1:
      digitalWrite(green, 0);
      digitalWrite(red, 0);
      digitalWrite(yellow, 1);
      break;
    case 2:
      digitalWrite(green, 0);
      digitalWrite(red, 1);
      digitalWrite(yellow, 0);
      break;
   default:
      digitalWrite(green, 0);
      digitalWrite(red, 0);
      digitalWrite(yellow, 0);
  }

   
  motorL.setSpeed((int)map(OY + OX, -255, 255, -225, 225));
  motorR.setSpeed(OY - OX);   

/*
  if (millis() - tower_timer > 500){
    resetTower();
    tower_timer = millis();
  }
*/
  Serial.print(OX);
  Serial.print(" ");
  Serial.print(OY);
  Serial.print(" ");
  Serial.print(a_hor);
  Serial.print(" ");
  Serial.print(a_vert);
  
  Serial.print(" ");
  Serial.println(diod);
  
  
  
  digitalWrite(13, prizel);
  digitalWrite(6, goodok);

  if (shoot == 1 && diod == 2){
    digitalWrite(12, 1);
  }else{
    digitalWrite(12, 0);
  }
  
  analogWrite(11, a_hor);
  analogWrite(10, a_vert);
/*
  for (int i = 0; i < 180; i++){
    hor.write(i);
    vert.write(i);
    delay(10);
  }
  for (int i = 180; i > 0; i--){
    hor.write(i);
    vert.write(i);
    delay(10);
  }
  */
   
}
