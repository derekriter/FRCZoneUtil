package org.derekriter;

public class Rect {

    public double x1, y1, x2, y2;

    public Rect(double _x1, double _y1, double _x2, double _y2) {
        x1 = _x1;
        y1 = _y1;
        x2 = _x2;
        y2 = _y2;
    }

    /**
     * Create a Rect object that sizes itself to perfectly include all points in the given set. The boundaries will be set to be exactly on the furthest point in any given cardinal direction.
     * @return If the given points is empty then return null, otherwise return the bounding Rect
     */
    public static Rect fromPoints(Vector2d[] points) {
        if(points.length == 0)
            return null;

        double minX = 0, minY = 0, maxX = 0, maxY = 0;

        boolean first = true;
        for(Vector2d p : points) {
            if(first) {
                minX = maxX = p.x;
                minY = maxY = p.y;

                first = false;
                continue;
            }

            minX = Math.min(minX, p.x);
            maxX = Math.max(maxX, p.x);
            minY = Math.min(minY, p.y);
            maxY = Math.max(maxY, p.y);
        }

        return new Rect(minX, minY, maxX, maxY);
    }

    public double minX() {
        return Math.min(x1, x2);
    }
    public double maxX() {
        return Math.max(x1, x2);
    }
    public double minY() {
        return Math.min(y1, y2);
    }
    public double maxY() {
        return Math.max(y1, y2);
    }
    public double width() {
        return Math.abs(x1 - x2);
    }
    public double height() {
        return Math.abs(y1 - y2);
    }

    /**
     * Test if a point is inside the rect. Includes the boundaries, so if a point is on the boundary, then it is contained.
     */
    public boolean contains(Vector2d point) {
        return
            minX() <= point.x && point.x <= maxX()
            && minY() <= point.y && point.y <= maxY();
    }

    @Override
    public String toString() {
        return String.format("{x1: %f, y1: %f, x2: %f, y2: %f}", x1, y1, x2, y2);
    }
}
