package org.derekriter;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.net.URL;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public final class Main {
    public static void main(String[] args) throws IOException {
        URL rawLoc = Main.class.getResource("/diamond.json");

        /*
        https://github.com/FasterXML/jackson-databind/?tab=readme-ov-file#1-minute-tutorial-pojos-to-json-and-back
        Reference 1 and 3 minute tutorial
         */
        ObjectMapper mapper = new ObjectMapper();
        List<Zone> zoneList = mapper.readValue(rawLoc, new TypeReference<>() {}); //jackson api witchcraft

        Map<String, Zone> zoneMap = new HashMap<>(zoneList.size()); //map of zone names to the zone
        for(Zone z : zoneList) {
            //check for zones with the same name
            if(zoneMap.containsKey(z.getName())) {
                System.out.printf("WARNING: Loaded map contains multiple zones with the name '%s'. Only the first of these duplicates will be used, all further instances will be ignored\n", z.getName());
                continue;
            }

            zoneMap.put(z.getName(), z);
        }

//        System.out.println(zoneMap);

        System.out.println(zoneMap.get("DiamondZone").getPolygon().containsPoint(new Vector2d(3, 1.5)));
    }
}
