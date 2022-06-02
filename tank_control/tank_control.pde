import processing.serial.*;
import controlP5.*;

import net.java.games.input.*;
import org.gamecontrolplus.*;
import org.gamecontrolplus.gui.*;


Serial serial;
ControlP5 cp5;

ControlDevice gamepad;
ControlHat hat;
ControlIO control;

int goodok = 0;

int shootTimer = 0;

int sendTimer = 0;
String OYname = "OY";
String OXname = "OX";
String gamePadName = "tanj";
String portName;
int speed = 9600;
int mode = 0;
int modeTimer = 0;
int summ = 0;
int prizelTimer = 0;
int towerSpeedTimer = 0;


boolean hat_left, hat_right, hat_up, hat_down;
int prizel = 0;
int diod = 0;
float a_vert = 1;
float a_hor = 155;

int shoot = 0;
float OY, OX;
boolean isPortOpened = false;

void stopMotors(){
  OX = 0;
  OY = 0;
}

void blockTower(){
  a_vert = 43;
  a_hor = 155;
  diod = 0;
}

void resetTower(){ 
  a_vert = 180;
  a_hor = 155;
}

void zelMode(){
  stopMotors();
  diod = 1; 
}

float sdvig = 0.15;
float slowSdvig = 0.15;
float fastSdvig = 4;

void moveTower(boolean left, boolean right, boolean up, boolean down){
  if (left)
    a_hor += sdvig;
  if (right)
    a_hor -= sdvig;
  if (up)
    a_vert -= sdvig;
  if (down)
    a_vert += sdvig;
  
  if (a_vert > 250)
    a_vert = 250;
  else if (a_vert < 0)
    a_vert = 0;
  
  if (a_hor > 250)
    a_hor = 250;
  else if(a_hor < 0)
    a_hor = 0;
    
}

void shoot_do(){
  if (diod != 0){
  shoot = 1;
  diod = 2;
  goodok = 1;
  sendInput();
  delay(1000);
  goodok = 0;
  diod = 1;
  shoot = 0;
  }
  
}

void setup(){
  //инициализация окна
  size(800, 400);
  cp5 = new ControlP5(this);
  
  cp5.addButton("openPort").linebreak();
  cp5.addButton("closePort").linebreak();
  cp5.addButton("ledOn").linebreak();
  cp5.addButton("ledOff").linebreak();
  cp5.addScrollableList("comlist").close();
  
  //инициализация геймпада
  control = ControlIO.getInstance(this);
  gamepad = control.getMatchedDevice(gamePadName);
  
  if (gamepad == null){
     println("Gamepad is not connected");
     System.exit(-1);
  }
    
  hat = gamepad.getHat("tower_move");
  
  
  //инициализация портов
  String list[] = Serial.list();
  cp5.get(ScrollableList.class, "comlist").addItems(list);
  
}


public void changeMode(){
  if (mode == 1){
    mode = 0;
    blockTower();
  }
  else if (mode == 0){
    mode = 1;
    resetTower();
  }
}

public void prizelMode(){
  if (prizel == 1)
    prizel = 0;
  else if (prizel == 0 && diod != 0){
    prizel = 1;
  }
}

public void goodokMode(){
  if (goodok == 1)
    goodok = 0;
  else if (goodok == 0){
    goodok = 1;
  }
}

public void changeTowerSpeed(){
  if (sdvig == slowSdvig)
    sdvig = fastSdvig;
  else if (sdvig == fastSdvig){
    sdvig = slowSdvig;
  }
}

int goodokTimer = 0;

public void getUserInput(){ // чтение данных с геймпада
  if (gamepad.getButton("set_mode").pressed() && (millis() - modeTimer > 500)){
    changeMode();
    modeTimer = millis();
  }
  
  if (gamepad.getButton("beep").pressed() && millis() - goodokTimer > 200){
    goodokMode();
    goodokTimer = millis();
  }
  
  
  if (gamepad.getButton("tower_speed").pressed() && (millis() - towerSpeedTimer > 500)){
    changeTowerSpeed();
    towerSpeedTimer = millis();
  }
  
  if (gamepad.getButton("prizet_on").pressed() && (millis() - prizelTimer > 500)){
    prizelMode();
    prizelTimer = millis();
  }
  
  if (gamepad.getButton("shoot_on").pressed() && (millis() - shootTimer > 500)){
    //shootMode();
    shoot_do();
    shootTimer = millis();
  }
  
  hat_left = hat.left();
  hat_right = hat.right();
  hat_up = hat.up();
  hat_down = hat.down();
  
  OY = (int)map(gamepad.getSlider(OYname).getValue(), -1, 1, -255, 255);//вертикальная ось правого стика
  OX = (int)map(gamepad.getSlider(OXname).getValue(), -1, 1, -255, 255);//горизонтальная ось правого стика
}

void sendInput(){//отправка данных на ардуино
    
  if (isPortOpened){
    
    //summ = (int)OX + (int)OY + a_hor + a_vert + diod;
    //serial.write("2," + mode + ";");
    serial.write((int) OX + "," + (int) OY + "," + (int)a_hor + "," + (int)a_vert + "," + diod + "," + prizel + "," + shoot + "," + goodok + ";");
    /*serial.write("1," + OX + ";");
    serial.write("3," + a_hor + ";");
    serial.write("4," + a_vert + ";");
    serial.write("7," + diod + ";");*/
  }
}

void comlist(int n){
  portName = Serial.list()[n];
  
}

void openPort(){
  serial = new Serial(this, portName, speed);
  isPortOpened = true;
}

void closePort(){
  stopMotors();
  blockTower();
  goodok = 0;
  
  diod = -1;
  sendInput();
  isPortOpened = false;
  serial.stop();
}

/*
void ledOn(){
  serial.write("13,1;");
}

void ledOff(){
  serial.write("13,0;");
}*/

void draw(){
  
  
  getUserInput();
  
  
  if (mode == 1){
      stopMotors();
      zelMode();
      moveTower(hat_left, hat_right, hat_up, hat_down);
  }else{
      blockTower();
  }
    
    
   
  //if (millis() - sendTimer > 10){
    sendInput();
    //sendTimer = millis();
  //}
  background((OY+255)/2, (OX+255)/2, 50);
  //println(mode);
  println(diod, mode, (int) a_vert, (int) a_hor, goodok);
  //println(OX, OY);
}
