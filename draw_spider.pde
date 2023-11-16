void drawSpider(Scorpion  spider, Options options) {
    // Basic lighting for a more natural look
    ambientLight(60, 60, 60);
    directionalLight(255, 255, 255, 0, 1, -1);
    
    spider.body.update(new Vec2(spider.x, spider.y - SPIDER_WIDTH / 1.6));
    spider.body.draw();

    // Draw the main body of the spider
    fill(105, 70, 40); // Dark brown color
    noStroke();
    pushMatrix();
    translate(spider.x, spider.y, -options.elevation);
    sphereDetail(30);
    sphere(SPIDER_WIDTH / 1.6);
    popMatrix();
    // Determine the end position of the scorpion's body tail
    Segment[] bodySegments = scorpion.body.tailSegments;
    Vec2 tipOfBodyTail = bodySegments[bodySegments.length - 1].endPosition;
    
    // Iterate through each tail, updating and drawing them at the body tail's tip position
    ScorpionTail[] scorpionTails = scorpion.tails;
    for (ScorpionTail tail : scorpionTails) {
        tail.update(tipOfBodyTail);

        // Set angle limits for the first segment of each tail based on the body's segment angles
        Segment firstSegment = tail.tailSegments[0];
        float firstBodySegmentAngle = bodySegments[0].currentAngle;
        float secondBodySegmentAngle = bodySegments[1].currentAngle;
        firstSegment.modifyAngleLimits(firstBodySegmentAngle, secondBodySegmentAngle);

        tail.draw();
    }
    // Draw the head of the spider
    pushMatrix();
    translate(spider.x, spider.y);
    fill(80, 50, 30); // Slightly different shade for the head
    sphere(SPIDER_WIDTH / 2);
    popMatrix();

 
// Drawing the legs
for (int i = 0; i < spider.legs.length; i++) {
    float shoulderX = getLegShoulderX(spider, i);
    float shoulderY = spider.y;
    float shoulderZ = -options.elevation; // Adjust this value as needed
    float legX = spider.legs[i].x;
    float legY = spider.legs[i].y;
    float legZ = shoulderZ; // You can adjust this value to change the elevation of each leg

    float[] elbow = inverseKinematicsWithTwoJoints(
        shoulderX, shoulderY, legX, legY, options.upper, options.lower, spider.legs[i].direction
    );

    // Draw the upper leg segment
    drawLegSegment(shoulderX, shoulderY, shoulderZ, elbow[0], elbow[1], shoulderZ, 5, 5); // Updated to include Z

    // Draw joint sphere
    pushMatrix();
    translate(elbow[0], elbow[1], shoulderZ); // Updated to include Z
    fill(50, 35, 20); // Darker color for joints
    sphere(8);
    popMatrix();

    // Draw the lower leg segment
    drawLegSegment(elbow[0], elbow[1], shoulderZ, legX, legY, legZ, 5, 5); // Updated to include Z
}

}
void drawLegSegment(float startX, float startY, float startZ, float endX, float endY, float endZ, float r1, float r2) {
    pushMatrix();
    translate(startX, startY, startZ);

    float xyAngle = atan2(endY - startY, endX - startX); // Angle in the XY plane
    float xzAngle = atan2(endZ - startZ, dist(startX, startY, endX, endY)); // Angle in the XZ plane

    // Rotate for 3D orientation
    rotateY(xzAngle);
    rotateZ(xyAngle);

    float h = dist(startX, startY, startZ, endX, endY, endZ);
    translate(h / 2, 0, 0);
    rotateY(PI / 2);

    fill(90, 60, 40); // Brownish color for legs
    drawCustomCylinder(12, r1, r2 * 0.5, h);

    popMatrix();
}

float getLegShoulderX(Scorpion  spider, int i) {
  int sideIndex = i / 2;
  float shoulderSpacing = SPIDER_WIDTH / (spider.legs.length  + 1); // Adjusted for 3D
  float x = spider.x + spider.legs[i].direction * (shoulderSpacing / 2 + shoulderSpacing * sideIndex);
  return x;
}
