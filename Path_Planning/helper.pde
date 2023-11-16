class LandAndSky {
    PVector sunPosition;
    float timeOfDay;

    LandAndSky() {
        sunPosition = new PVector();
        timeOfDay = 0.0; // Represents the time of day, you can update this value to move the sun
    }

    void update() {
        // Update sun position based on timeOfDay
        // This is a simple linear movement, you can make it more complex to simulate real sun movement
        sunPosition.x = cos(TWO_PI * timeOfDay) * 500; // 500 is the radius of the sun's circular path
        sunPosition.y = sin(TWO_PI * timeOfDay) * 500;
        sunPosition.z = -200;

        timeOfDay += 0.00001; // Change this value for faster or slower sun movement
        if (timeOfDay > 1.0) {
            timeOfDay = 0.0;
        }
    }

    void draw() {
        // Draw sky
        background(0, 200, 255);

        // Draw sun
        pushMatrix();
        translate(sunPosition.x, sunPosition.y, sunPosition.z);
        fill(255, 204, 0); // Sun color
        sphere(50); // Sun size
        popMatrix();

        // Draw land
        fill(255, 255, 200); // Sand color
        pushMatrix();
        translate(width / 2, height - 50, -500);
        box(1000, 100, 1000); // Size of the land
        popMatrix();
    }
}

public class Target {
    public float x, z, r;
    public color c = color(0, 150, 255);
    public Target() {
        x = 0;
        z = 0;
        r = 50;
    }
    public Target(float x, float z, float r) {
        this.x = x;
        this.z = z;
        this.r = r;
    }

    public void draw() {
        fill(c);
        pushMatrix();
        translate(x, height-104, z);
        rotateX(PI/2);
        circle(0, 0, 0.5*r);
        popMatrix();
    }
}


PVector getRayDirection(float mouseX, float mouseY) {
    // Convert from screen space to normalized device coordinates
    float x = (2 * mouseX) / width - 1;
    float y = 1 - (2 * mouseY) / height;
    float z = 1; // Forward into the screen

    // Convert to camera space (inverse of projection matrix)
    PVector ray_nds = new PVector(x, y, z);
    PMatrix3D projectionMatrix = ((PGraphics3D)g).projection;
    PMatrix3D inverseProjection = projectionMatrix.get();
    inverseProjection.invert();
    PVector ray_clip = new PVector(ray_nds.x, ray_nds.y, -1); // We use -1 for z to project forward
    PVector ray_eye = new PVector();
    inverseProjection.mult(ray_clip, ray_eye);
    ray_eye.z = -1; // We want to look forward
    //ray_eye.w = 0;

    // Convert to world space (inverse of view matrix)
    PMatrix3D modelviewMatrix = ((PGraphics3D)g).modelview;
    PMatrix3D inverseModelview = modelviewMatrix.get();
    inverseModelview.invert();
    PVector ray_world = new PVector();
    inverseModelview.mult(ray_eye, ray_world);
    ray_world.normalize(); // Normalize the ray's direction vector

    return ray_world;
}



public class Vec2 {
    public float x, y;

    public Vec2(float x, float y) {
        this.x = x;
        this.y = y;
    }

    public void add(Vec2 delta) {
        x += delta.x;
        y += delta.y;
    }

    public Vec2 add_new(Vec2 delta) {
        return new Vec2(x + delta.x, y + delta.y);
    }

    public void subtract(Vec2 delta){
        x -= delta.x;
        y -= delta.y;
    }

    public Vec2 subtract_new(Vec2 delta){
        return new Vec2(x - delta.x, y - delta.y);
    }
    
    public float length(){
      return sqrt(x*x+y*y);
    }

    public void mul(float rhs){
        x *= rhs;
        y *= rhs;
    }

    public Vec2 mul_new(float rhs){
        return new Vec2(x*rhs, y*rhs);
    }

    public Vec2 normalize(){
        float magnitude = sqrt(x*x + y*y);
        x /= magnitude;
        y /= magnitude;
        return new Vec2(x, y);
    }
    
    public float distanceTo(Vec2 rhs){
      float dx = rhs.x - x;
      float dy = rhs.y - y;
      return sqrt(dx*dx + dy*dy);
    }
    public float lengthSqr(){
      return x*x+y*y;
    }

}

float dot(Vec2 a, Vec2 b){
  return a.x*b.x + a.y*b.y;
}

Vec2 projAB(Vec2 a, Vec2 b){
  return b.mul_new(a.x*b.x + a.y*b.y);
}


Vec2 rotate_point(Vec2 origin, Vec2 point, float angle) {
    Vec2 p = point.subtract_new(origin);
    float x = p.x * cos(angle) - p.y * sin(angle);
    float y = p.x * sin(angle) + p.y * cos(angle);
    return new Vec2(x, y).add_new(origin);
}

public class Segment {
    public int id;
    public float x1, y1, x2, y2;

    public Segment() {
        id = 0;
        x1 = y1 = x2 = y2 = 0;
    }
}

public class Rectangle {
    public int id;
    public float x, y, width, height;

    public Rectangle() {
        id = 0;
        x = y = width = height = 0;
    }
}

int getOrientation(float px1, float py1, float px2, float py2, float px3, float py3) {
    float val = (py2 - py1) * (px3 - px1) - (py3 - py1) * (px2 - px1);
    if (val == 0) return 0; // collinear
    return (val > 0) ? 1 : 2; // clockwise or counterclockwise
}

boolean checkSegmentsIntersect(Segment s1, Segment s2) { 
    int dir1 = getOrientation(s1.x1, s1.y1, s2.x1, s2.y1, s2.x2, s2.y2);
    int dir2 = getOrientation(s1.x2, s1.y2, s2.x1, s2.y1, s2.x2, s2.y2);
    int dir3 = getOrientation(s1.x1, s1.y1, s1.x2, s1.y2, s2.x1, s2.y1);
    int dir4 = getOrientation(s1.x1, s1.y1, s1.x2, s1.y2, s2.x2, s2.y2);
    return (dir1 != dir2 && dir3 != dir4);
}

boolean checkSegmentRectangle(Segment seg, Rectangle rect) {
    Segment[] sides = new Segment[4];
    float halfWidth = rect.width / 2;
    float halfHeight = rect.height / 2;

    for (int i = 0; i < 4; i++) {
        sides[i] = new Segment();
    }

    sides[0].x1 = rect.x - halfWidth;  sides[0].y1 = rect.y - halfHeight;
    sides[0].x2 = rect.x + halfWidth;  sides[0].y2 = rect.y - halfHeight;

    sides[1].x1 = sides[0].x2;  sides[1].y1 = sides[0].y2;
    sides[1].x2 = sides[0].x2;  sides[1].y2 = rect.y + halfHeight;

    sides[2].x1 = sides[1].x2;  sides[2].y1 = sides[1].y2;
    sides[2].x2 = rect.x - halfWidth;  sides[2].y2 = sides[1].y2;

    sides[3].x1 = sides[2].x2;  sides[3].y1 = sides[2].y2;
    sides[3].x2 = sides[0].x1;  sides[3].y2 = sides[0].y1;

    for (Segment side : sides) {
        if (checkSegmentsIntersect(seg, side)) {
            return true;
        }
    }

    return (seg.x1 >= rect.x - halfWidth && seg.x1 <= rect.x + halfWidth && 
            seg.y1 >= rect.y - halfHeight && seg.y1 <= rect.y + halfHeight);
}


PVector intersectRayWithXZPlane(PVector rayOrigin, PVector rayDirection) {
    float t = -rayOrigin.y / rayDirection.y; // Assuming xz-plane is at y = 0

    if (t >= 0) { // Intersection is in the direction of the ray, not behind the camera
        PVector intersection = PVector.add(rayOrigin, PVector.mult(rayDirection, t));
        return intersection;
    }

    return null; // No intersection with the xz-plane in the direction of the ray
}
void updateCameraToFollowCar(float dt) {
     // Define the offset position of the camera relative to the car
      float distanceBehind = 100; // Distance behind the car
      float heightAbove = 50; // Height above the car
    
     // Calculate the camera's desired position
     float camX = car.car_part.x - distanceBehind * car.dir.x;
     float camZ = car.car_part.z- distanceBehind * car.dir.y;
     float camY = heightAbove; // Assuming the car is on a flat plane
    
     // Update the camera's position smoothly
      PVector desiredPosition = new PVector(camX, camY, camZ);
      camera.position.lerp(desiredPosition, 0.1); // Adjust lerp factor for smoothness
    
     // Calculate thetabased on the car's direction
     camera.theta = atan2( - car.dir.x, -car.dir.y);
    
     camera.phi = -PI /2; // Adjust as needed
    
     // Update the camera with the new orientation
     
}
   
