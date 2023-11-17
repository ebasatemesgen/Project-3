
import java.util.ArrayList;

public class Building {
    public float size_of_buildin = 100; // Size of the building base
    public float x = 0; // X coordinate of the building
    public float z = 0; // Z coordinate of the building
    public int floors = 5; // Number of floors in the building
    public int buildingColor; // Color of the building
    boolean isCircular;;
    public Building(float size_of_buildin, float x, float z, boolean isCircular) {
        this.size_of_buildin = size_of_buildin;
        this.x = x;
        this.z = z;
       
        this.floors = (int) random(3, 10);
        // Assign a random color
        this.buildingColor = color(random(255), random(255), random(255));
        
         this.isCircular = isCircular;
    }

    public void draw() {
        pushMatrix();
        float buildingBaseY = height - size_of_buildin*.52;
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
        if (cx + r > x - size_of_buildin/2 && cx - r < x + size_of_buildin/2 && cz + r > z - size_of_buildin/2 && cz - r < z + size_of_buildin/2) {
            return true;
        }
        return false;
    }

    private void drawCircularBuilding() {
        for (int i = 0; i < floors; i++) {
            pushMatrix();
           
            int floorColor = lerpColor(buildingColor, color(0, 0, 0), i * 0.1);
            fill(floorColor);
            drawCustomCylinder(36, size_of_buildin/2, size_of_buildin/2, 45); // Resolution, top radius, bottom radius, height
            popMatrix();
        }
    }

        private void drawRectangularBuilding() {
        for (int i = 0; i < floors; i++) {
            pushMatrix();
            translate(0, -20 * i, 0);
            int floorColor = lerpColor(buildingColor, color(0, 0, 0), i * 0.1);
            fill(floorColor);
            box(size_of_buildin, 20, size_of_buildin);
            popMatrix();
        }
    }
       
        public boolean intersectsPath(float x1, float z1, float x2, float z2) {
            // create rectangle
            Rectangle rect = new Rectangle();
            rect.x = x;
            rect.y = z;
            rect.width = size_of_buildin + 15 * 2;
            rect.height = rect.width;

            // create line segment
            Segment seg = new Segment();
            seg.x1 = x1;
            seg.y1 = z1;
            seg.x2 = x2;
            seg.y2 = z2;
            return checkSegmentRectangle(seg, rect);
        }
            
         private void drawCircularBuilding_1() {
        float radius = size_of_buildin / 2;
        int sides = 36; 

        for (int i = 0; i < floors; i++) {
            pushMatrix();
            translate(0, -20 * i, 0);

            for (int j = 0; j < sides; j++) {
                pushMatrix();
                rotateY(TWO_PI / sides * j);
                translate(radius, 0, 0);
                int floorColor = lerpColor(buildingColor, color(0, 0, 0), i * 0.1);
                fill(floorColor);
                box(20, 20, size_of_buildin / sides); 
                popMatrix();
            }

            popMatrix();
        }
    }


}


public class AutoVehicle {
    // Dimensions of the vehicle
    float vehicleLength = 32;
    float vehicleHeight = 22;
    float vehicleWidth = 22;
    float tireRadius = 6;

    // Direction coordinates with different initial values
    int headingX = 100;
    int headingZ = 200;

    // Vehicle part representation
    public AutoComponent vehicleComponent;
    private ArrayList<Integer> travelPath = new ArrayList<>();
    public Vec2 currentDirection = new Vec2(headingX, headingZ); // Current heading
    public boolean isRotating = false;
    public AutoComponent goal;
    // Default constructor
    public AutoVehicle() {
        vehicleComponent = new AutoComponent();
    }

    // Parameterized constructor
    public AutoVehicle(float x, float z, float r) {
        vehicleComponent = new AutoComponent(x, z, r);
    }


    public AutoVehicle(AutoComponent goal) {
        this.goal = goal;
    }
    // Update method
    public void update(float deltaTime) {
        if (travelPath.isEmpty()) return;

        int nextNodeIndex = travelPath.get(0);
        if (canProceedToNextNode(nextNodeIndex)) {
            travelPath.remove(0);
            if (travelPath.isEmpty()) return;
            nextNodeIndex = travelPath.get(0);
        }

        Vec2 motionVector = computeMotionVector(nextNodeIndex);
        enactMovement(motionVector, deltaTime);

        Vec2 newHeading = motionVector.normalize();
        adjustDirection(newHeading, deltaTime);
    }

    // Checks if the vehicle can move to the next node
    private boolean canProceedToNextNode(int nodeIndex) {
        if (travelPath.size() == 1) return false;

        int subsequentNodeIndex = travelPath.get(1);
        Vec2 currentPos = new Vec2(vehicleComponent.x, vehicleComponent.z);
        Vec2 nextNodePos = new Vec2(prm.nodes[subsequentNodeIndex].x, prm.nodes[subsequentNodeIndex].z);

        for (Building building : buildings) {
            if (building.intersectsPath(currentPos.x, currentPos.y, nextNodePos.x, nextNodePos.y)) {
                return false;
            }
        }
        return true;
    }

    // Computes the vector for vehicle movement
    private Vec2 computeMotionVector(int nodeIndex) {
        Vec2 destination = new Vec2(prm.nodes[nodeIndex].x, prm.nodes[nodeIndex].z);
        Vec2 currentPosition = new Vec2(vehicleComponent.x, vehicleComponent.z);
        return destination.subtract_new(currentPosition);
    }

    // Performs the movement based on the motion vector
    private void enactMovement(Vec2 motionVector, float deltaTime) {
        float distance = motionVector.length();
        float velocity = isRotating ? 17 : 34;

        if (distance > velocity * deltaTime) {
            Vec2 normalizedMotion = motionVector.normalize();
            Vec2 movementDelta = normalizedMotion.mul_new(velocity * deltaTime);
            vehicleComponent.x += movementDelta.x;
            vehicleComponent.z += movementDelta.y;
        }
    }

    // Adjusts the vehicle's direction
    private void adjustDirection(Vec2 newHeading, float deltaTime) {
        float rotationAngle = computeRotationAngle(newHeading);

        if (Math.abs(rotationAngle) > 0.05f) {
            isRotating = true;
            float angleAdjustment = rotationAngle > 0 ? 0.05f : -0.05f;
            Vec2 rotatedDirection = rotateAroundPoint(new Vec2(0, 0), currentDirection, angleAdjustment);
        
            currentDirection.x = rotatedDirection.x;
            currentDirection.y = rotatedDirection.y;
        } else {
            isRotating = false;
        }
    }

    // Computes the rotation angle for direction change
    private float computeRotationAngle(Vec2 newHeading) {
        float angle = (float) Math.acos(dot(currentDirection, newHeading));
        return (currentDirection.x * newHeading.y - currentDirection.y * newHeading.x < 0) ? -angle : angle;
    }

    // Rotates a point around a pivot
    private Vec2 rotateAroundPoint(Vec2 pivot, Vec2 point, float angle) {
        float s = (float)Math.sin(angle);
        float c = (float)Math.cos(angle);

        // Translate point back to origin
        point.x -= pivot.x;
        point.y -= pivot.y;

        // Rotate point
        float xnew = point.x * c - point.y * s;
        float ynew = point.x * s + point.y * c;

        // Translate point back
        point.x = xnew + pivot.x;
        point.y = ynew + pivot.y;
        return point;
    }



    public void render() {
        // Drawing the main body of the vehicle
        float baseLevelY = height - 100;
        fill(240, 180, 180);  // Slightly different shade for the vehicle body
        pushMatrix();
        translate(vehicleComponent.x, baseLevelY - vehicleHeight / 2, vehicleComponent.z);
        box(vehicleLength, vehicleHeight, vehicleWidth); // Drawing a box-shaped vehicle body
        popMatrix();

        // Drawing the wheels
        fill(0);  // Black color for the wheels
        drawTire(vehicleComponent.x - vehicleLength / 2, vehicleComponent.z + vehicleWidth / 2); // Front Left Tire
        drawTire(vehicleComponent.x + vehicleLength / 2, vehicleComponent.z + vehicleWidth / 2); // Front Right Tire
        drawTire(vehicleComponent.x - vehicleLength / 2, vehicleComponent.z - vehicleWidth / 2); // Rear Left Tire
        drawTire(vehicleComponent.x + vehicleLength / 2, vehicleComponent.z - vehicleWidth / 2); // Rear Right Tire
    }

    private void drawTire(float x, float z) {
        pushMatrix();
        fill(255);
        translate(x, height - 110 + tireRadius, z);
        rotateY(PI / 2);
        drawCustomCylinder(20, tireRadius, tireRadius, tireRadius); 
        popMatrix();
    }


}
