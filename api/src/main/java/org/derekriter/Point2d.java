package org.derekriter;

public class Point2d {

    public double x, y;

    public Point2d(double _x, double _y) {
        this.x = _x;
        this.y = _y;
    }

    @Override
    public String toString() {
        return String.format("{x: %f, y: %f}", x, y);
    }
}
