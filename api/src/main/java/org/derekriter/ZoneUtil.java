package org.derekriter;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.net.URL;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public final class ZoneUtil {

    private static Map<String, Zone> zones = null;

    public static void initFromFile(String filename) throws IOException {
        //grab file
        //TODO: Replace when you get WPI
        URL rawLocation = ZoneUtil.class.getResource(filename);

        /*
        https://github.com/FasterXML/jackson-databind/?tab=readme-ov-file#1-minute-tutorial-pojos-to-json-and-back
        Reference 1 and 3 minute tutorial
         */
        ObjectMapper mapper = new ObjectMapper();
        List<Zone> zoneList = mapper.readValue(rawLocation, new TypeReference<>() {}); //jackson api witchcraft

        if(zoneList.isEmpty()) {
            //TODO: Replace with proper logging
            System.out.println("WARNING: Loaded map contains no zones");
            return; //leave zones as null
        }

        //map zone names to zones
        zones = new HashMap<>(zoneList.size());
        for(Zone z : zoneList) {
            //check for zones with the same name
            if(zones.containsKey(z.getName())) {
                //TODO: Replace with proper logging
                System.out.printf("WARNING: Loaded map contains multiple zones with the name '%s'. Only the first of these duplicates will be used, all further instances will be ignored\n", z.getName());
                continue;
            }

            zones.put(z.getName(), z);
        }
    }
    public static boolean isPointInZone(Vector2d point, String zoneName) {
        if(zones == null) {
            //TODO: Replace with proper logging
            System.out.printf("WARNING: Attempted to query zone '%s' before any zones were loaded\n", zoneName);
            return false;
        }
        if(!zones.containsKey(zoneName)) {
            //TODO: Replace with proper logging
            System.out.printf("WARNING: No zone with the name '%s' was loaded\n", zoneName);
            return false;
        }

        //TODO: throws NullPointerException if given point is null, maybe add warning
        return zones.get(zoneName).getPolygon().containsPoint(point);
    }
}
