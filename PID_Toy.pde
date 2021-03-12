import java.util.*;

public enum mouseRegion {
  NONE, KNOBIN, KNOBP, KNOBI, KNOBD
}

mouseRegion clickRegion;

indicator knobIn;
indicator knobP;
indicator knobI;
indicator knobD;
motor knobO;
pid pid;

PFont f;


class indicator {
  float x, y, r, theta;
  float min, max;
  boolean useMin, useMax;
  
  indicator(float x, float y, float r, float theta) {
    this.x = x;
    this.y = y;
    this.r = r;
    this.theta = theta;
    useMin = false;
    useMax = false;
  }
  
  void setLimits(float min, float max) {
    useMin = true;
    useMax = true;
    this.min = min;
    this.max = max;    
  }
  
  void turn(float theta) {
    if (useMin && this.theta + theta < min) return;
    if (useMax && this.theta + theta > max) return;
    this.theta += theta;
  }
  
  void draw() {
    float x2 = r*cos(theta);
    float y2 = r*sin(theta);
  
    circle(x, y, 2*r);
    line(x, y, x+x2, y+y2);
  }
  
  boolean inside(float x, float y) {
    return (abs(this.x - x) < r && abs(this.y - y) < r );
  }
  
}

class motor extends indicator {
  float gain, inertia, noise, friction;
  float velocity;
  
  motor(indicator i, float gain, float inertia, float noise, float friction) {
    super(i.x, i.y, i.r, i.theta);
    this.gain = gain;
    this.inertia = inertia;
    this.noise = noise;
    this.friction = friction;
  }
  
  void input(float force) {
    // noise is the max percentage different that force may be
    float n = noise*(random(2)-1); // get a random number between -1 and 1 and scale by noise 
    force = force*(1-n); // apply noise to force
    
    // a = f/m
    float accel = force / inertia;
    velocity = velocity + accel;
    velocity = velocity * (1-friction);
    this.turn(velocity);

  }
}

class PidBuffer {
  List<Float> buf;
  
  PidBuffer (int size) {
    buf = new ArrayList<Float>();  
    for (int n = 0; n < size; n++) {
      buf.add(n,0.0f);
    }
  }
  
  void push(float entry) {
    buf.add(entry);
    buf.remove(0);
  }
  
  
  float integral() {
    float accum = 0;
    //print("[");
    for (int n = 0; n < buf.size()-1; n++) {
      //print(buf.get(n) + ", ");
        accum += buf.get(n); // area of rectangle
        accum += (buf.get(n+1) - buf.get(n))/2; // area of triangle
    }
    
    //println(buf.get(buf.size()-1) + "] = " + accum);
    
    return accum/buf.size();
  }
  
  float derivative() {
    return buf.get(buf.size()-1) - (buf.get(buf.size()-2)); 
  }
  
  
}


class pid {
   float Kp, Ki, Kd;
   PidBuffer buf;
   
   pid(float p, float i, float d, int sampleSize) {
     Kp = p;
     Ki = i;
     Kd = d;
     buf = new PidBuffer(sampleSize);
   }
   
   void gains(float p, float i, float d) {
     Kp = p;
     Ki = i;
     Kd = d;
   }
   
   float integral() {
     return buf.integral(); 
   }
   
   float derivative() {
     return buf.derivative();
   }
   
   float step(float error) {
     buf.push(error);
     float p = Kp * error;
     // integral is the area under line formed by the last <sampleSize> error measurements
     // integral = sum (
     float i = Ki * this.integral();
     // derivative is the slope between the last two error points
     // dx = x1 - x0;
     float d = Kd * this.derivative();
     float u = p + i + d;
     
     return u;
   }
}

void setup() { 
  size(640, 560);
  
  clickRegion = mouseRegion.NONE;
  knobIn = new indicator(width/4, height/3, width/5, 0);
  knobO = new motor(new indicator(3*width/4, height/3, width/5, 0), 1, 2, 0.00, 0.1);
  knobP = new indicator(width/4, 5*height/6, width/10, 0);
  knobI = new indicator(2*width/4, 5*height/6, width/10, 0);
  knobD = new indicator(3*width/4, 5*height/6, width/10, 0);
  
  knobP.setLimits(0, 2*PI);
  knobI.setLimits(0, 2*PI);
  knobD.setLimits(0, 2*PI);

  pid = new pid(1,2,2,20);
  
  
  
  f = createFont("OpenSans-Bold.ttf", 24);
  textFont(f);
  textAlign(CENTER, CENTER);
}

void line_polar(float x, float y, float r, float theta) {
  float x2 = r*cos(theta);
  float y2 = r*sin(theta);
  
  line(x, y, x+x2, y+y2);
}

void draw() {
  background(255/2);
  strokeWeight(4);
  frameRate(60);
  //knobI.turn(PI/365);
  pid.gains(knobP.theta/5, knobI.theta/5, knobD.theta/5);
  knobO.input(pid.step(knobIn.theta - knobO.theta));
  knobIn.draw();
  knobP.draw();
  knobI.draw();
  knobD.draw();
  knobO.draw();
  
  text('P', knobP.x, knobP.y-knobP.r-20);
  text('I', knobI.x, knobI.y-knobI.r-20);
  text('D', knobD.x, knobD.y-knobD.r-20);
}

void mousePressed() {
  if (knobIn.inside(mouseX, mouseY)) {
    clickRegion = mouseRegion.KNOBIN;
  } else if (knobP.inside(mouseX, mouseY)) {
    clickRegion = mouseRegion.KNOBP;
  } else if (knobI.inside(mouseX, mouseY)) {
    clickRegion = mouseRegion.KNOBI;
  } else if (knobD.inside(mouseX, mouseY)) {
    clickRegion = mouseRegion.KNOBD;
  } else {
    clickRegion = mouseRegion.NONE;
  }
}

void mouseDragged() {
  float dx = mouseX - pmouseX;
  float dy = pmouseY - mouseY;
  
  float turn = (dx+dy)/(10*PI);
  
  switch (clickRegion) {
    case KNOBIN:
      knobIn.turn(turn);
      break;
    case KNOBP:
      knobP.turn(turn);
      break;
    case KNOBI:
      knobI.turn(turn);
      break;
    case KNOBD:
      knobD.turn(turn);
      break;
  }
}
