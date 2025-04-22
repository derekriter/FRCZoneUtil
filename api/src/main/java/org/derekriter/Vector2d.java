package org.derekriter;

public class Vector2d {

    public double x, y;

    public Vector2d(double _x, double _y) {
        this.x = _x;
        this.y = _y;
    }

    @Override
    public String toString() {
        return String.format("{x: %f, y: %f}", x, y);
    }
}
