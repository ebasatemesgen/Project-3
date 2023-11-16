public class Building {
    public float s = 100; // Size of the building base
    public float x = 0; // X coordinate of the building
    public float z = 0; // Z coordinate of the building
    public int floors = 5; // Number of floors in the building
    public int buildingColor; // Color of the building
    boolean isCircular;
    public Building(float s, float x, float z, boolean isCircular) {
        this.s = s;
        this.x = x;
        this.z = z;
       
        this.floors = (int) random(3, 10);
        // Assign a random color
        this.buildingColor = color(random(255), random(255), random(255));
        
         this.isCircular = isCircular;
    }

    public void draw() {
        pushMatrix();
        float buildingBaseY = height - 105;
        translate(x, buildingBaseY, z);

        if (isCircular) {
          
          
            drawCircularBuilding();
            drawCircularBuilding_1();
        } else {
            drawRectangularBuilding();
        }

        popMatrix();
    }
    
    public boolean collision(float cx, float cz, float r) {
    // Check if circle is intersecting with building (similar to mountain collision)
        if (cx + r > x - s/2 && cx - r < x + s/2 && cz + r > z - s/2 && cz - r < z + s/2) {
            return true;
        }
        return false;
    }

    private void drawCircularBuilding() {
        for (int i = 0; i < floors; i++) {
            pushMatrix();
           
            int floorColor = lerpColor(buildingColor, color(0, 0, 0), i * 0.1);
            fill(floorColor);
            drawCustomCylinder(36, s/2, s/2, 45); // Resolution, top radius, bottom radius, height
            popMatrix();
        }
    }

        private void drawRectangularBuilding() {
        for (int i = 0; i < floors; i++) {
            pushMatrix();
            translate(0, -20 * i, 0);
            int floorColor = lerpColor(buildingColor, color(0, 0, 0), i * 0.1);
            fill(floorColor);
            box(s, 20, s);
            popMatrix();
        }
    }
       
        public boolean collision_line(float x1, float z1, float x2, float z2) {
            // create rectangle
            Rectangle rect = new Rectangle();
            rect.x = x;
            rect.y = z;
            rect.width = s + 15 * 2;
            rect.height = rect.width;

            // create line segment
            Segment seg = new Segment();
            seg.x1 = x1;
            seg.y1 = z1;
            seg.x2 = x2;
            seg.y2 = z2;

            // check if line intersects with mountain
            return checkSegmentRectangle(seg, rect);
        }
            
         private void drawCircularBuilding_1() {
        float radius = s / 2;
        int sides = 36; // Number of sides to approximate the circle

        for (int i = 0; i < floors; i++) {
            pushMatrix();
            translate(0, -20 * i, 0);

            for (int j = 0; j < sides; j++) {
                pushMatrix();
                rotateY(TWO_PI / sides * j);
                translate(radius, 0, 0);
                int floorColor = lerpColor(buildingColor, color(0, 0, 0), i * 0.1);
                fill(floorColor);
                box(20, 20, s / sides); // Draw side of the circular building
                popMatrix();
            }

            popMatrix();
        }
    }


}














