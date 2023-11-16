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
   public Vec2 setMag(float magnitude) {
        float currentMag = length();
        if (currentMag != 0 && magnitude != currentMag) {
            mul(magnitude / currentMag);
        }
        return this;
    }

  public Vec2 plus(Vec2 rhs){
    return new Vec2(x+rhs.x, y+rhs.y);
  }

    // Static methods for Vec2 operations
    public  Vec2 add(Vec2 a, Vec2 b) {
        return new Vec2(a.x + b.x, a.y + b.y);
    }

    public  Vec2 sub(Vec2 a, Vec2 b) {
        return new Vec2(a.x - b.x, a.y - b.y);
    }

    public Vec2 normalize(){
        float magnitude = sqrt(x*x + y*y);
        x /= magnitude;
        y /= magnitude;
        return new Vec2(x, y);
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
    
        public Vec2 copy() {
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

float cross(Vec2 a, Vec2 b){
  return a.x*b.y - a.y*b.x;
}


void drawCustomCylinder(int resolution, float radiusTop, float radiusBottom, float height) {
    float angleStep = TWO_PI / resolution;
    float halfHeight = height / 2.0;

    // Draw the top circle
    drawCircle(resolution, radiusTop, -halfHeight);

    // Draw the bottom circle
    drawCircle(resolution, radiusBottom, halfHeight);

    // Draw the side of the cylinder
    for (int i = 0; i < resolution; i++) {
        // Calculate vertices for the triangle strip
        float angle1 = i * angleStep;
        float angle2 = (i + 1) * angleStep;

        PVector top1 = new PVector(radiusTop * cos(angle1), radiusTop * sin(angle1), -halfHeight);
        PVector top2 = new PVector(radiusTop * cos(angle2), radiusTop * sin(angle2), -halfHeight);
        PVector bottom1 = new PVector(radiusBottom * cos(angle1), radiusBottom * sin(angle1), halfHeight);
        PVector bottom2 = new PVector(radiusBottom * cos(angle2), radiusBottom * sin(angle2), halfHeight);

        // Draw the rectangles (as two triangles)
        beginShape(TRIANGLES);
        vertex(top1.x, top1.y, top1.z);
        vertex(bottom1.x, bottom1.y, bottom1.z);
        vertex(top2.x, top2.y, top2.z);

        vertex(bottom1.x, bottom1.y, bottom1.z);
        vertex(bottom2.x, bottom2.y, bottom2.z);
        vertex(top2.x, top2.y, top2.z);
        endShape(CLOSE);
    }
}

void drawCircle(int resolution, float radius, float z) {
    beginShape(TRIANGLE_FAN);
    vertex(0, 0, z); // Center point
    for (int i = 0; i <= resolution; i++) {
        float angle = i * TWO_PI / resolution;
        vertex(radius * cos(angle), radius * sin(angle), z);
    }
    endShape(CLOSE);
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
