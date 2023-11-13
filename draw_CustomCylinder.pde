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
