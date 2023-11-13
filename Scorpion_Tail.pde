public class ScorpionTail {
    private Segment[] tailSegments;

    private Vec2 lastMousePosition = new Vec2(0, 0);
    private long lastMouseMovementTime = System.currentTimeMillis();
    private final long restDurationThreshold = 2000; // 2000 milliseconds or 2 seconds
    private Vec2 tailEnd = new Vec2(0, 0);
    private Vec2 tailStart = new Vec2(0, 0);

    public ScorpionTail(int numberOfSegments, Vec2 initialPosition, float startRadius) {
        this.tailStart = initialPosition;
        tailSegments = new Segment[numberOfSegments];
        initializeTailSegments(numberOfSegments, initialPosition, startRadius);
        calculateTailKinematics();
    }

    public ScorpionTail() {
    }

    // Initialize the segments of the tail
    private void initializeTailSegments(int segmentCount, Vec2 startPosition, float initialRadius) {
        for (int i = 0; i < segmentCount; i++) {
            tailSegments[i] = new Segment(startPosition, 0);
            configureSegmentProperties(i, initialRadius);
            startPosition = tailSegments[i].endPosition;
        }
    }

    // Configure properties for each segment
    private void configureSegmentProperties(int index, float initialRadius) {
        Segment currentSegment = tailSegments[index];
        currentSegment.segmentLength = 50 - index * 5;

        if (index > 0) {
            currentSegment.startRadius = tailSegments[index - 1].endRadius;
        } else {
            currentSegment.startRadius = initialRadius;
            currentSegment.maxAngle = 0;
            currentSegment.minAngle = -PI;
            currentSegment.currentAngle = -PI / 2;
        }

        currentSegment.endRadius = currentSegment.startRadius * 0.5f;
    }

    // Update the ScorpionTail's state
    public void update(Vec2 newBasePosition) { 
        this.tailStart = newBasePosition;
        Vec2 currentMousePosition = new Vec2(mouseX, mouseY);
        long currentTime = System.currentTimeMillis();

        if (!currentMousePosition.equals(lastMousePosition)) {
            lastMouseMovementTime = currentTime;
            lastMousePosition = currentMousePosition;
        }

        boolean isTailInRest = (currentTime - lastMouseMovementTime) > restDurationThreshold;
        updateTailSegments(currentMousePosition, isTailInRest, currentTime);
    }

    // Update each segment in the tail
    private void updateTailSegments(Vec2 targetPosition, boolean isAtRest, long currentTime) {
        for (int i = tailSegments.length - 1; i >= 0; i--) {
            tailSegments[i].refresh(targetPosition, tailEnd, isAtRest, currentTime);
            calculateTailKinematics();
        }
    }

    // Calculate the kinematics for the tail
    public void calculateTailKinematics() {
        float cumulativeAngle = 0;
        for (int i = 0; i < tailSegments.length; i++) {
            if (i == 0) {
                tailSegments[i].startPosition = tailStart;
                cumulativeAngle = tailSegments[i].currentAngle;
            } else {
                tailSegments[i].startPosition = tailSegments[i - 1].endPosition;
                cumulativeAngle += tailSegments[i].currentAngle;
            }
            tailSegments[i].endPosition = new Vec2(cos(cumulativeAngle) * tailSegments[i].segmentLength, sin(cumulativeAngle) * tailSegments[i].segmentLength).add_new(tailSegments[i].startPosition);
        }
        tailEnd = tailSegments[tailSegments.length - 1].endPosition;
    }

    // Render the ScorpionTail
    public void draw() {
        for (Segment segment : tailSegments) {
            segment.render();
        }
    }
}





public class Segment {
    Vec2 startPosition = new Vec2(0, 0);
    Vec2 middlePosition = new Vec2(0, 0);
    float restingAngle = 0; // Resting angle for the segment
    float interpolationFactor = 0.1f;

    float wiggleSize = 0.4f; // Amplitude of the wiggle
    float wiggleSpeed = 3f; // Frequency of the wiggle

    float currentAngle = 0;
    float maxAngle = PI / 2;
    float minAngle = -PI / 2;
    float baseMaxAngle, baseMinAngle;
    float segmentLength = 20;
    Vec2 endPosition = new Vec2(0, 0);
    float startRadius = 8;
    float endRadius = 10;
    float segmentAcceleration = 0.1f;

    public Segment(Vec2 startPos, float initAngle) {
        this.startPosition = startPos;
        this.currentAngle = initAngle;
    }

    public Segment() {
    }

    // Method to update angle limits
    public void modifyAngleLimits(float baseAngle, float offsetAngle) {
        this.minAngle = baseMinAngle + (baseAngle + PI / 2) + offsetAngle;
        this.maxAngle = baseMaxAngle + (baseAngle + PI / 2) + offsetAngle;
    }

    // Method to update the segment's state
    public void refresh(Vec2 targetPos, Vec2 tipPos, boolean inRestState, float currentTime) {
        if (inRestState) {
            float wiggleEffect = wiggleSize * sin(wiggleSpeed * currentTime);
            currentAngle += wiggleEffect;
            currentAngle = lerp(currentAngle, restingAngle + wiggleEffect, interpolationFactor);
        } else {
            segmentAcceleration = 200.0f / (startRadius * startRadius * startRadius);
            Vec2 directionToTarget = targetPos.subtract_new(startPosition);
            Vec2 directionToEnd = tipPos.subtract_new(startPosition);
            float normalizedDotProduct = dot(directionToTarget.normalize(), directionToEnd.normalize());
            normalizedDotProduct = constrain(normalizedDotProduct, -1.0f, 1.0f);
            float angleChange = acos(normalizedDotProduct);
            angleChange = constrain(angleChange, -segmentAcceleration, segmentAcceleration);

            if (cross(directionToTarget, directionToEnd) < 0)
                currentAngle += angleChange;
            else
                currentAngle -= angleChange;

            currentAngle = constrain(currentAngle, minAngle, maxAngle);
        }
        currentAngle = constrain(currentAngle, minAngle, maxAngle);
    }

    // Method to draw the segment
    public void render() {
        fill(SCORPION_BROWN);
        float elevationOffset = 20;
        float zDepth = -65;

        drawSphereAtPosition(startPosition, startRadius, elevationOffset, zDepth);
        drawSphereAtPosition(endPosition, endRadius, elevationOffset, zDepth);
        drawConnectingCylinder(startPosition, endPosition, elevationOffset, zDepth);
    }

    private void drawSphereAtPosition(Vec2 position, float radius, float elevation, float depth) {
        pushMatrix();
        translate(position.x, position.y + elevation, depth);
        sphere(radius);
        popMatrix();
    }

    private void drawConnectingCylinder(Vec2 start, Vec2 end, float elevation, float depth) {
        pushMatrix();
        middlePosition.x = (start.x + end.x) / 2;
        middlePosition.y = (start.y + end.y) / 2;
        translate(middlePosition.x, middlePosition.y + elevation, depth);
        float cylinderAngle = atan2(end.y - start.y, end.x - start.x);
        rotateZ(cylinderAngle);
        rotateY(PI / 2);
        drawCustomCylinder(30, startRadius, endRadius, segmentLength);
        popMatrix();
    }

}
