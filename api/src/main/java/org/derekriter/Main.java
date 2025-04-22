package org.derekriter;

public final class Main {
    public static void main(String[] args) {
        try {
            ZoneUtil.initFromFile("/diamond.json");
        }
        catch(Exception e) {
            System.err.println("Failed to load map file");
            return;
        }

        System.out.println(ZoneUtil.isPointInZone(new Vector2d(0, 2), "DiamondZone"));
    }
}
