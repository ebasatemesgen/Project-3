class GrassBlade {
    ArrayList<Vec2> joints;
    ArrayList<Float> lengths;
    float swayAngle; // Angle for simulating sway in the wind
Vec2 root;
 float maxReactiveSway = PI / 5; // Max sway due to mouse
    float swayDistanceThreshold = 500; //

GrassBlade(Vec2 root, int numLinks) {
    joints = new ArrayList<Vec2>();
     this.root = root;
    lengths = new ArrayList<Float>();
    joints.add(root); // Add the root position

    // Randomly generate link lengths
    for (int i = 0; i < numLinks; i++) {
        lengths.add(random(10, 25));
        // Instead of adding a placeholder, add a new Vec2 with initial values
        joints.add(new Vec2(root.x, root.y)); // Or some other initial values as required
    }

     swayAngle = random(-PI / 18, PI / 18);;
}


void update() {
        Vec2 mousePos = new Vec2(mouseX, mouseY);
        float distanceToMouse = root.distanceTo(mousePos);
        float additionalSway = 0;

        if (distanceToMouse < swayDistanceThreshold) {
            float swayFactor = (swayDistanceThreshold - distanceToMouse) / swayDistanceThreshold;
            additionalSway = maxReactiveSway * swayFactor;
        }

        Vec2 currentPos = joints.get(0);
         float angle = -PI / 2 + swayAngle + additionalSway; 

        for (int i = 1; i < joints.size(); i++) {
            Vec2 nextPos = new Vec2(cos(angle) * lengths.get(i - 1), sin(angle) * lengths.get(i - 1)).plus(currentPos);
            joints.set(i, nextPos);
            currentPos = nextPos;
            angle += swayAngle; // Add base sway for each segment
        }
    }
    void draw() {
        for (int i = 1; i < joints.size(); i++) {
            Vec2 start = joints.get(i - 1);
            Vec2 end = joints.get(i);
            line(start.x, start.y, end.x, end.y);
        }
    }
}
