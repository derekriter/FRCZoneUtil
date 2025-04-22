package org.derekriter;

import java.util.Arrays;

public class Polygon {

    public final Vector2d[] points;
    public final Rect boundingBox;

    public Polygon(Vector2d[] _points) {
        if(_points.length < 3) {
            throw new IllegalArgumentException("Cannot create a polygon from less than 3 points");
        }

        points = _points;
        boundingBox = Rect.fromPoints(points);
    }

    public boolean containsPoint(Vector2d point) {
        //first check if point is within bounding box
        if(!boundingBox.contains(point))
            return false;

        /*
        then use even-odd rule to check polygon
        https://en.wikipedia.org/wiki/Point_in_polygon
        https://en.wikipedia.org/wiki/Even%E2%80%93odd_rule
         */
        /*
        Some general notes and references:
          - this implementation includes points and lines. This means that if a queried point is on a boundary or on a corner point then it is counted as inside the polygon
          - Floating point precision is not a concern here. https://en.wikipedia.org/wiki/Point_in_polygon#:~:text=if%20implemented%20on%20a%20computer%20with%20finite%20precision%20arithmetics%2C%20the%20results%20may%20be%20incorrect%20if%20the%20point%20lies%20very%20close%20to%20that%20boundary%2C%20because%20of%20rounding%20errors
          - https://www.baeldung.com/cs/geofencing-point-inside-polygon
         */

        boolean inside = false;
        for(int i = 0; i < points.length; i++) {
            /*
            ax/ay and bx/by define the points for the current line being checked
             */
            double ax = points[i].x;
            double ay = points[i].y;

            if(point.x == ax && point.y == ay) {
                //point is on a corner, must be inside polygon
                return true;
            }

            double bx, by;
            if(i == 0) {
                //bx and by = the last point in the array
                bx = points[points.length - 1].x;
                by = points[points.length - 1].y;
            }
            else {
                //use previous point
                bx = points[i - 1].x;
                by = points[i - 1].y;
            }

            //https://en.wikipedia.org/wiki/Point_in_polygon#:~:text=if%20the%20ray%20passes%20exactly%20through%20a%20vertex%20of%20a%20polygon%2C%20then%20it%20will%20intersect%202%20segments%20at%20their%20endpoints
            //use xor to check if points are on opposite sides of the ray (one above and one below, one on and one below, etc)
            if((ay > point.y) != (by > point.y)) {
                double sx = ax + (bx - ax) * ((point.y - ay) / (by - ay)); //sx = x of intersection between line segment and ray. Don't have to worry about divide by zero because we know that ay and by are not equal

                if(sx - point.x == 0) {
                    //point is on boundary
                    return true;
                }
                //check if intersection is to the right of the point
                if(point.x < sx) {
                    //flip current state
                    inside = !inside;
                }
            }
        }
        return inside;
    }

    @Override
    public String toString() {
        return String.format("{points: %s, boundingBox: %s}", Arrays.toString(points), boundingBox);
    }
}
