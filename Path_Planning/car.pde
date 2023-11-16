import java.util.ArrayList;

public class Vehicle {

    public Target car_part;
    private ArrayList<Integer> path = new ArrayList<>();
    public Vec2 direction = new Vec2(1, 0); // Current direction of the vehicle
    public boolean rotating = false;

    // Car dimensions
    float carLength = 30;
    float carHeight = 20;
    float carWidth = 20;
    float wheelRadius = 5; // Positive value for wheel radius
    public Vec2 dir = new Vec2(1, 0);
    public Vec2 new_dir = new Vec2(1, 0);
    public Vehicle() {
        car_part = new Target();
    }

    public Vehicle(float x, float z, float r) {
        car_part = new Target(x, z, r);
    }
 
 public void update(float dt) {
    if (!canUpdate || path.isEmpty()) return;

    int currentNodeIndex = path.get(0);
    boolean canMoveToNextNode = canMoveToNextNode(currentNodeIndex);
    
    if (canMoveToNextNode) {
        path.remove(0);
        if (path.isEmpty()) return;
        currentNodeIndex = path.get(0);
    }

    Vec2 movementVector = calculateMovementVector(currentNodeIndex);
    performMovement(movementVector, dt);

    Vec2 newDirection = movementVector.normalize();
    updateDirection(newDirection, dt);
}

private boolean canMoveToNextNode(int currentNodeIndex) {
    if (path.size() == 1) return false;

    int nextNodeIndex = path.get(1);
    Vec2 currentPosition = new Vec2(car_part.x, car_part.z);
    Vec2 nextNodePosition = new Vec2(prm.nodes[nextNodeIndex].x, prm.nodes[nextNodeIndex].z);

    for (Building building : buildings) {
        if (building.collision_line(currentPosition.x, currentPosition.y, nextNodePosition.x, nextNodePosition.y)) {
            return false;
        }
    }

    return true;
}

private Vec2 calculateMovementVector(int currentNodeIndex) {
    Vec2 targetPosition = new Vec2(prm.nodes[currentNodeIndex].x, prm.nodes[currentNodeIndex].z);
    Vec2 currentPosition = new Vec2(car_part.x, car_part.z);
    return targetPosition.subtract_new(currentPosition);
}

private void performMovement(Vec2 movementVector, float dt) {
    float distance = movementVector.length();
    float speed = rotating ? 10 : 30;

    if (distance > speed * dt) {
        Vec2 normalizedMovement = movementVector.normalize();
        Vec2 movementDelta = normalizedMovement.mul_new(speed * dt);
        car_part.x += movementDelta.x;
        car_part.z += movementDelta.y;
    }
}

private void updateDirection(Vec2 newDirection, float dt) {
    float angle = calculateRotationAngle(newDirection);
 
    if (Math.abs(angle) > 0.05f) {
        rotating = false;
           float angleChange = angle > 0 ? 0.05f : -0.05f;
            Vec2 rotatedDir = rotate_point(new Vec2(0, 0), dir, angleChange);
        
        dir.x = rotatedDir.x;
        dir.y = rotatedDir.y;
    } else {
        //dir.x = rotatedDir.x;
        //dir.y = rotatedDir.y;
        rotating = false;
    }
}

private float calculateRotationAngle(Vec2 newDirection) {
    float angle = (float) Math.acos(dot(dir, newDirection));
    return (dir.x * newDirection.y - dir.y * newDirection.x < 0) ? -angle : angle;
}


// Helper method to rotate a point around another point
private Vec2 rotate_point(Vec2 pivot, Vec2 point, float angle) {
    float s = sin(angle);
    float c = cos(angle);

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

  public void draw() {
        // Draw the car car_part
        float groundLevelY = height - 100;
        fill(250, 190, 190);  // Red color for the car car_part
        pushMatrix();
        translate(car_part.x, groundLevelY - carHeight / 2, car_part.z);
        box(carLength, carHeight, carWidth); // Create a rectangular car car_part
        popMatrix();

        // Draw the wheels
        fill(0);  // Black color for the wheels
        drawWheel(car_part.x - carLength / 2, car_part.z + carWidth / 2); // Front Left Wheel
        drawWheel(car_part.x + carLength / 2, car_part.z + carWidth / 2); // Front Right Wheel
        drawWheel(car_part.x - carLength / 2, car_part.z - carWidth / 2); // Rear Left Wheel
        drawWheel(car_part.x + carLength / 2, car_part.z - carWidth / 2); // Rear Right Wheel
    }

    private void drawWheel(float x, float z) {
        pushMatrix();
        fill(255);
        translate(x, height - 110 + wheelRadius, z);
        rotateY(PI / 2);
        drawCustomCylinder(20, wheelRadius, wheelRadius, wheelRadius); // Replace with your method to draw a cylinder
        popMatrix();
    }

}
