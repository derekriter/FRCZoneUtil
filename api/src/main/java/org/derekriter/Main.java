package org.derekriter;

public final class Main {
    public static void main(String[] args) {
        ZoneUtilResult<Void> err;
        if((err = ZoneUtil.initFromFile("/diamond.json")).isError()) {
            System.err.printf("A '%s' error occurred while initializing ZoneUtil\n", err.getResult().name());
            return;
        }

        System.out.println(ZoneUtil.isPointInZone(new Point2d(0, 2), "DiamondZone").getData());
    }
}
