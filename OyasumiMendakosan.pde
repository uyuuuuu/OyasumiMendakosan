/* @pjs preload="sun.JPG,rain.JPG,start.JPG,awa.PNG"; */
int scene=0;
//0→スタート画面
//1→ゲーム画面
int mode=0;
//1→穏やかな波
//2→激しい波

PImage imgSun, imgRain, imgStart, imgAwa;
int sum, ringNum, maxRing=10;
boolean[] tensu=new boolean[maxRing]; //得点できたかどうかの配列
boolean inRing=false, finish=false;
boolean bubbleOver=false, bubbleUnder=false; //衝突判定

Mendako mendako;
Ring[] ring=new Ring[maxRing];


void setup() {
  size(600, 600);
  imgSun=loadImage("sun.JPG");
  imgRain=loadImage("rain.JPG");
  imgStart=loadImage("start.JPG");
  imgAwa=loadImage("awa.PNG");
  ringNum=1; //いま出てる泡の数
  mendako=new Mendako(60, 60);
  for (int i=0; i<maxRing; i++) {
    ring[i]=new Ring(width+55, random(70, height-70));
  }
}

void draw() {
  switch(scene) {
  case 0: //スタート画面
    image(imgStart, 0, 0);
    if (keyPressed && key=='s') { //晴れ
      mode=1;
      scene=1;
    } else if (keyPressed && key=='r') { //雨
      mode=2;
      scene=1;
    }

    mendako=new Mendako(60, 60);
    for (int i=0; i<maxRing; i++) {
      ring[i]=new Ring(width+55, random(70, height-70));
      tensu[i]=false;
    }
    ringNum=1;
    break;
  //////////////////////////////////////////////////////////
  case 1:  //ゲーム画面
    tint(255.0,130);
    sum=0;
    if (mode==1) {  //晴れ
      image(imgSun, 0, 0);
    } else if (mode==2) {  //雨
      image(imgRain, 0, 0);
    }
    image(imgAwa, 0, 0);
    //描画
    for (int i=0; i<ringNum; i++) { //泡の後ろ側
      ring[i].move();
      ring[i].drawRingB();
    }
    mendako.move();
    mendako.drawMendako();
    for (int i=0; i<ringNum; i++) { //泡の前側
      ring[i].drawRingF();
    }


    //点数計算と衝突判定
    for (int i=0; i<ringNum; i++) {
      getPoint(mendako.getX(), mendako.getY(), ring[i].getX(), ring[i].getY(), ring[i].getDX());
      attack(mendako.getX(), mendako.getY(), ring[i].getX(), ring[i].getY(), ring[i].getDX());
      if (inRing) {
        tensu[i]=true;
        inRing=false;
      }
      if (tensu[i]) {
        sum++;
      }
    }

    //点数表示
    viewPoint();

    //結果表示
    if (finished()) {
      fill(255);
      textSize(100);
      //フルコンボでなければ得点表示
      if (sum<maxRing) {
        text("Score="+ sum, 130, 320);
      }
      //フルコンボ
      else if (sum==maxRing) {
        text("FullCombo!!", 50, 320);
      }
      textSize(60);
      text("press space", 150, 420);
      //スタートに戻る
      if (keyPressed && key==' ') {
        scene=0;
        mode=0;
      }
    }
    break;
  }
}

//////////////////////////////////////////////
//関数
//リングに入ったかの判定
void getPoint(float mx, float my, float rx, float ry, float d) {
  if (rx-d/4<=mx && mx<=rx+d/4 && my>ry-3 && my<ry+3) {
    inRing=true;
  }
}

//泡に当たったかどうかの判定
void attack(float mx, float my, float rx, float ry, float d) {
  boolean right, left, over, under;
  over= ry-25 < my && my<ry-5;
  under= ry+5<my && my<ry+25;

  right= rx-d<mx && mx<rx-d/4;
  left= rx+d/4<mx &&  mx<rx+d;
  if ((right||left) && over) {
    bubbleOver=true;
  } else if ((right||left) && under) {
    bubbleUnder=true;
  }
}

//得点表示
void viewPoint() {
  fill(25,40,140);
  textSize(60);
  text(sum, width-60, 60);
}

//終了判定
boolean finished() {
  return -30>=ring[maxRing-1].getX();
}

////////////////////////////////////////////////////
/////////////メンダコ
class Mendako {
  final float gravity=2.0/60;
  float x, y, dx, dy, vy;
  boolean up;
  Ear[] ear;
  Foot[] foot;
  Eye eye;
  Awa awa;
  Mendako(float x, float y) {
    this.x=x;
    this.y=y;
    this.dx=60;
    this.dy=55;
    this.vy=0;
    this.up=false;
    ear=new Ear[2];
    foot=new Foot[4];
    float r=dx/2; //メンダコ半径
    float EarOff=r/1.4; //耳オフセット
    ear[0]=new Ear(x, y, -EarOff, -EarOff);
    ear[1]=new Ear(x, y, EarOff, -EarOff);
    float outOffX=dx/2.3; //外側
    float inOffX=dx/5; //内側
    float outOffY=r/1.8; //外側
    float inOffY=r/1.5; //内側
    foot[0]=new Foot(x, y, -outOffX, outOffY);
    foot[1]=new Foot(x, y, -inOffX, inOffY);
    foot[2]=new Foot(x, y, inOffX, inOffY);
    foot[3]=new Foot(x, y, outOffX, outOffY);
    float eyeOffX=r/3; //目オフセット
    eye=new Eye(x, y, eyeOffX);
    awa=new Awa(x, y);
  }

  float getX() {
    return x;
  }
  float getY() {
    return y;
  }

  void drawMendako() {
    awa.drawAwa();
    noStroke();
    for (int i=0; i<ear.length; i++) {
      ear[i].drawEar();
    }
    for (int i=0; i<foot.length; i++) {
      foot[i].drawFoot();
    }
    fill(221, 122, 163);
    ellipse(x, y, dx, dy); //体
    eye.drawEye();
  }

  void move() {
    //マウスクリックで上昇
    if (mousePressed) {
      up=true;
      if (vy<-3) { //上がりすぎ軽減
        vy-=0.006;
      } else {
        vy-=0.2;
      }
    } else {
      up=false;
    }

    //見切れすぎると戻ってくる
    if (y<-50) {
      vy*=-1;
    } else if (y>height+50) {
      vy=-3;
    }
    
    //輪にぶつかると跳ね返る
    if (bubbleOver) {
      vy=-2;
      bubbleOver=false;
      bubbleUnder=false;
    } else if (bubbleUnder) {
      vy=2;
      bubbleOver=false;
      bubbleUnder=false;
    }
    //重力
    vy+=gravity;
    y+=vy;
    for (int i=0; i<ear.length; i++) {
      ear[i].moveEar(x, y);
    }
    for (int i=0; i<foot.length; i++) {
      foot[i].moveFoot(x, y, up);
    }
    eye.moveEye(x, y);
    awa.moveAwa(y);
  }
}

/////////////目
class Eye {
  float rx, lx, y, d, offX;
  Eye(float baseX, float baseY, float offX) {
    this.d = 5; //目の長さ
    this.offX = offX;
    rx = baseX - offX;
    lx = baseX + offX;
    y = baseY;
  }
  void drawEye() {
    stroke(50);
    strokeWeight(3);
    line(rx, y, rx-d, y);
    line(lx, y, lx+d, y);
  }
  void moveEye(float baseX, float baseY) {
    rx = baseX - offX;
    lx = baseX + offX;
    y = baseY;
  }
}
////////////////耳
class Ear {
  float x, y, d, offX, offY;
  Ear(float baseX, float baseY, float offX, float offY) {
    this.d = 20;
    this.offX = offX;
    this.offY = offY;
    x = baseX + offX;
    y = baseY + offY;
  }
  void drawEar() {
    fill(221, 122, 163);
    ellipse(x, y, d, d);
  }
  void moveEar(float baseX, float baseY) {
    x = baseX + offX;
    y = baseY + offY;
  }
}
/////////////////足
class Foot {
  float x, y, d, offX, offY, upfoot=3;//upfoot=ふよっとする
  Foot(float baseX, float baseY, float offX, float offY) {
    this.d = 20;
    this.offX = offX;
    this.offY = offY;
    x = baseX + offX;
    y = baseY + offY;
  }
  void drawFoot() {
    fill(221, 122, 163);
    ellipse(x, y, d, d);
  }
  void moveFoot(float baseX, float baseY, boolean up) {
    if (up) {
      y = baseY + offY-upfoot;
    } else {
      y = baseY + offY;
    }
    x = baseX + offX;
  }
}

////泡
class Awa {
  float x, y, my, vy, dx, dy;
  Awa(float x, float my) {
    this.x=x;
    this.my=my;
    this.vy=50;
    this.y=my;
    this.dx=30;
    this.dy=10;
  }
  void moveAwa(float my) {
    if (y<my) {
      y++;
    }
    if (y>my) {
      y--;
    }
  }
  void drawAwa() {
    strokeWeight(4);
    stroke(255, 255, 255, 60);
    ellipse(x, y, dx, dy);
  }
}
//////////////////////////////////////////////////////
/////////////泡
class Ring {
  float x, y, dx, dy, speed, fuwa, maxfuwa, df;
  boolean newsw;
  Ring(float x, float y) {
    this.fuwa=1;
    this.df=0.2;
    this.x=x;
    this.y=y;
    this.dx=100;
    this.dy=20;
    this.newsw=false;
    if (mode==1) {
      this.speed=1;
      this.maxfuwa=4;
    } else if (mode==2) {
      this.speed=1.8;
      this.maxfuwa=7;
    }
  }

  float getX() {
    return x;
  }
  float getY() {
    return y;
  }
  float getDX() {
    return dx;
  }

  void move() {
    x-=speed; //左に進む
    //ふわふわ↓
    if (fuwa>maxfuwa || fuwa<-1*maxfuwa) {
      df*=-1;
    }
    fuwa+=df;

    //↓新しいringの出現
    if (width/2<x) {
      newsw=false;
    }
    if (newsw==false && width/2>=x && ringNum<maxRing) {
      ringNum++;
      newsw=true; //一度左側に行ったらringNumは足さない
    }
  }

  void drawRingB() { //後ろ側
    noFill();
    strokeWeight(10);
    ringColor();
    arc(x, y+fuwa, dx, dy, PI, 2*PI);
  }
  void drawRingF() { //前側
    noFill();
    strokeWeight(10);
    ringColor();
    arc(x, y+fuwa, dx, dy, 0, PI);
  }
  void ringColor() { //泡の輪の色
    if (mode==1) { //晴れ
      if (y<height*2/3) { //浅い
        stroke(223, 230, 237);
      } else if (y>=height*2/3) { //深い
        stroke(144, 166, 216);
      }
    } else if (mode==2) {  //雨
      if (y<height/2) { //浅い
        stroke(174, 190, 219);
      } else if (y>=height/2) { //深い
        stroke(134, 159, 200);
      }
    }
  }
}
