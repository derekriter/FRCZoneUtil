package org.derekriter;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.Arrays;
import java.util.List;

//don't parse the color property of Zone
@JsonIgnoreProperties({"color"})
public class Zone {

    //can't use final in order to be compatible with jackson
    private String name;
    private Vector2d[] points;

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
        if(rawPoints.isEmpty()) {
            throw new IllegalArgumentException("Invalid JSON, required field 'points' must have a length greater than 0");
        }
        if(rawPoints.size() % 2 != 0) {
            throw new IllegalArgumentException("Invalid JSON, required field 'points' must have a length that is a multiple of 2");
        }

        points = new Vector2d[rawPoints.size() / 2];
        for(int i = 0; i < points.length; i++) {
            points[i] = new Vector2d(rawPoints.get(i * 2), rawPoints.get(i * 2 + 1));
        }
    }

    @JsonIgnore
    public String getName() {
        return name;
    }
    @JsonIgnore
    public Vector2d[] getPoints() {
        return points;
    }

    @Override
    @JsonIgnore
    public String toString() {
        return String.format("{name: '%s', points: %s}", name, Arrays.toString(points));
    }
}
