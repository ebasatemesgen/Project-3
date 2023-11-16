int SPIDER_WIDTH = 60;
int SPIDER_LEG_LERP_DURATION = 400;
int number_leg = 8;
ArrayList<GrassBlade> grass;
PImage bgImage; 
Camera camera;
color SCORPION_BROWN = color(139, 69, 19);
PImage textureImg;
PShape global;

class Options {
  float elevation = 65;
  float upper = 65;
  float lower = 115;
  float ground = 2;
  float yOff = 6;
}

Options options = new Options();





public class Scorpion {
    float x, y, speed;
    Leg[] legs = new Leg[number_leg];
    ScorpionTail[] tails = new ScorpionTail[2];
    ScorpionTail body; // The body tail
    Vec2 bodyRoot; // The root position for the body tail

    Scorpion(float x_, float y_) {
        x = x_;
        y = y_;
        speed = 0;

        // Initialize legs
        //for (int i = 0; i < legs.length; i++) {
        //    legs[i] = new Leg(x + ((i % 2 == 0) ? -1 : 1) * (40 + (i / 2 * 40)), y, (i % 2 == 0) ? -1 : 1);
        //}
        
        float spreadAngleStep = TWO_PI / legs.length; // Angle step for each leg
        for (int i = 0; i < legs.length; i++) {
            float angle = spreadAngleStep * i;
            // Calculate leg's x, y, and z based on spread angle
            float legX = x + cos(angle) * SPIDER_WIDTH;
            float legY = y;
            float legZ = sin(angle) * SPIDER_WIDTH;
            legs[i] = new Leg(legX, legY, legZ, (i % 2 == 0) ? -1 : 1, angle);
        }

        // Initialize the body tail
        bodyRoot = new Vec2(x, y - SPIDER_WIDTH / 1.6);
        body = new ScorpionTail(4, bodyRoot, 15);

        // Initialize the tails
        for (int i = 0; i < tails.length; i++) {
            tails[i] = new ScorpionTail(3, new Vec2(x, y - SPIDER_WIDTH / 1.6), 10);
        }

        // Setting movement parameters for the second tail
        float angleAdjustment = PI / 16;
        ScorpionTail secondTail = tails[1];
        Segment firstSegmentOfSecondTail = secondTail.tailSegments[0];

        // Adjusting the maximum and minimum angles for the first segment of the second tail
        firstSegmentOfSecondTail.baseMaxAngle = -3 * PI / 4 - angleAdjustment;
        firstSegmentOfSecondTail.baseMinAngle = -PI;


    }
}


class Leg {
    float x, y, z, spreadAngle;
    int direction;
    Lerp lerp;
  
    Leg(float x_, float y_, float z_, int direction_, float angle_) {
        x = x_;
        y = y_;
        z = z_;
        direction = direction_;
        spreadAngle = angle_;
        lerp = null;
    }
}
class Lerp {
  float start, from, to;
  
  Lerp(float start_, float from_, float to_) {
    start = start_;
    from = from_;
    to = to_;
  }
}

Scorpion  scorpion ;
PVector mousePos = new PVector();

void setup() {
  size(1000, 667, P3D);
 camera = new Camera();
 grass = new ArrayList<GrassBlade>();
    for (int i = 0; i < 10000; i++) { // Create 100 blades of grass
        Vec2 root = new Vec2(random(width), height + 20); // Position each blade randomly along the bottom of the screen
        int numLinks = (int) random(2, 5); // Randomly choose between 2 to 5 links
        grass.add(new GrassBlade(root, numLinks));
    }

  bgImage = loadImage("bgAFSD.png"); 
  //background(loadImage("bg.gif"));
  scorpion  = new Scorpion (width / 2, height - options.elevation);
   textureImg = loadImage("mars.jpg");
  // Check if the texture is loaded
    if (textureImg != null) {
      noFill();
        global = createShape(SPHERE, SPIDER_WIDTH / 1.6);
        global.setTexture(textureImg);
    } else {
        println("Texture image failed to load.");
    }
}

void draw() {
  //background(255);
  //float dt = 1.0/frameRate;
  
   // Set the background image
  if (bgImage != null) {
    background(bgImage);
  } else {
    background(255); // Fallback to a white background if the image is not loaded
  }
  
    update(mousePos, scorpion );
  drawSpider(scorpion , options);
    pushStyle();
    stroke(0, 255, 0); // Example: bright green color
    for (GrassBlade blade : grass) {
        blade.update();
        blade.draw();
    }
   popStyle();

  //println("Drawing Spider at X: " + spider.x + " Y: " + spider.y); // Debugging line
          pushMatrix();
        translate(0, 0);
        fill(50, 35, 20); // Darker color for joints
        sphere(8);
        popMatrix();
      camera.Update(1.0/30.0);
}
void mouseMoved() {
  mousePos.x = mouseX;
  mousePos.y = mouseY;
}

void update(PVector mousePos, Scorpion  scorpion ) {
  float delta = 1.0 / frameRate;
  float speed = (mousePos.x - scorpion.x) * delta;
  scorpion.x += speed;
  scorpion.y = height - options.elevation - sin(millis() / 400.0) * 3 + sin(scorpion.x / 30.0) * 4;
  updateSpiderLegs(scorpion, options, millis(), speed);
}




void updateSpiderLegs(Scorpion scorpion, Options options, float time, float speed) {
  int currentDirection = (mousePos.x > scorpion.x) ? 1 : -1;
  float maxDistance = options.lower + options.upper;
  float speedWeight = (options.ground == 1) ? 1.9 : 0.675; // magic numbers
  float speedCoefficient = 1 / (1 + abs(speed * speedWeight));
  float lerpDuration = SPIDER_LEG_LERP_DURATION * min(1, speedCoefficient);
  
  for (int i = 0; i < scorpion.legs.length; i++) {
    Leg leg = scorpion.legs[i];
    if (leg.lerp != null) {
      float delta = time - leg.lerp.start;
      float t = delta / lerpDuration;
      leg.x = lerping(leg.lerp.from, leg.lerp.to, t);
   leg.y = height - lerping(0, options.yOff, easeSin(t));

      if (t >= 1) {
        leg.lerp = null;
        leg.y = height;
      }
    } else {
      int direction = leg.direction;
      int currentLerpsOnSide = 0;
      for (Leg otherLeg : scorpion.legs) {
        if (direction == otherLeg.direction && otherLeg.lerp != null) {
          currentLerpsOnSide++;
        }
      }
      if (currentLerpsOnSide >= options.ground) {
        continue;
      }

      float shoulderX = getLegShoulderX(scorpion, i);
      boolean sameDirection = (currentDirection == direction);
      int sideIndex = i / 2;

      float distanceToShoulder = dist(leg.x, leg.y, shoulderX, scorpion.y);
      if (distanceToShoulder > maxDistance * 0.75 && !sameDirection) {
        float repositionBy = maxDistance * (-0.1 + sideIndex * 0.15);
        leg.lerp = new Lerp(time, leg.x, shoulderX + direction * repositionBy);
      } else {
        float distanceToVertical = (leg.x - shoulderX) * direction;
        if (distanceToVertical < -0.05 && sameDirection) {
          float repositionBy = maxDistance * (0.7 + sideIndex * 0.085);
          leg.lerp = new Lerp(time, leg.x, shoulderX + direction * repositionBy);
        }
      }
    }
  }
}



// Helper function for linear interpolation
float lerping(float start, float stop, float amt) {
  return start + (stop - start) * amt;
}
// Helper function for easing
float easeSin(float t) {
  return (1 - cos(t * PI)) / 2;
}

float[] inverseKinematicsWithTwoJoints(float startX, float startY, float endX, float endY, float upperJointLength, float lowerJointLength, int direction) {
  float d = dist(startX, startY, endX, endY);
  float startToHalfChord = (d*d - lowerJointLength*lowerJointLength + upperJointLength*upperJointLength) / (2 * d);
  float angleFromStartToElbow = acos(startToHalfChord / upperJointLength);
  float baseAngle = ((startX >= endX) == (direction == 1)) ?
    acos((endY - startY) / d) :
    -acos((endY - startY) / d);
  float angle = -baseAngle + angleFromStartToElbow + HALF_PI;
  float elbowX = startX - upperJointLength * cos(angle) * direction;
  float elbowY = startY + upperJointLength * sin(angle);
  return new float[]{elbowX, elbowY};
}




  void keyPressed() {
      camera.HandleKeyPressed();
  }
  
  void keyReleased() {
      camera.HandleKeyReleased();
  }
  
