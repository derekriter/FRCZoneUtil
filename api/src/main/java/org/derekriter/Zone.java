package org.derekriter;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.List;

//don't parse the color property of the json
@JsonIgnoreProperties({"color"})
public class Zone {

    //can't make final in order to be compatible with jackson
    private String name;
    private Polygon polygon;

    /**
     * Only use for JSON parsing!!
     */
    @JsonProperty
    public void setName(String rawName) {
        this.name = rawName;
    }

    /**
     * Only use for JSON parsing!!
     */
    @JsonProperty
    public void setPoints(List<Double> rawPoints) {
        if(rawPoints.size() < 6) {
            throw new IllegalArgumentException("Invalid JSON, required field 'points' must have a length greater than 6 (minimum of 3 points)");
        }
        if(rawPoints.size() % 2 != 0) {
            throw new IllegalArgumentException("Invalid JSON, required field 'points' must have a length that is a multiple of 2");
        }

        Point2d[] points = new Point2d[rawPoints.size() / 2];
        for(int i = 0; i < points.length; i++) {
            points[i] = new Point2d(rawPoints.get(i * 2), rawPoints.get(i * 2 + 1));
        }

        polygon = new Polygon(points);
    }

    @JsonIgnore
    public String getName() {
        return name;
    }
    @JsonIgnore
    public Polygon getPolygon() {
        return polygon;
    }

    @Override
    @JsonIgnore
    public String toString() {
        return String.format("{name: '%s', polygon: %s}", name, polygon);
    }
}
