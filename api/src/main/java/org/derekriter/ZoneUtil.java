package org.derekriter;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jdk.jshell.spi.ExecutionControl.NotImplementedException;
import org.derekriter.ZoneUtilResult.Result;

import java.io.IOException;
import java.net.URL;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public final class ZoneUtil {

    private static Map<String, Zone> zones = null;

    public static ZoneUtilResult<Void> initFromFile(String filename) {
        //grab file
        //TODO: Replace file grabbing with WPI systems
        URL rawLocation = ZoneUtil.class.getResource(filename);
        if(rawLocation == null) {
            //failed to file resource
            System.err.printf("Failed to open map file '%s'\n", filename);
            return new ZoneUtilResult<>(Result.FILE_NOT_FOUND_ERROR, null);
        }

        /*
        https://github.com/FasterXML/jackson-databind/?tab=readme-ov-file#1-minute-tutorial-pojos-to-json-and-back
        Reference 1 and 3 minute tutorial
         */
        List<Zone> zoneList;
        try {
            ObjectMapper mapper = new ObjectMapper();
            zoneList = mapper.readValue(rawLocation, new TypeReference<>() {}); //jackson api witchcraft
        }
        catch(IOException e) {
            //TODO: Replace with proper logging
            System.err.printf("Failed to load json from file '%s'\n", filename);
            System.err.println(e.toString());
            return new ZoneUtilResult<>(Result.JSON_PARSE_ERROR, null);
        }

        if(zoneList.isEmpty()) {
            //TODO: Replace with proper logging
            System.out.println("WARNING: Loaded map contains no zones");
            return new ZoneUtilResult<>(Result.JSON_PARSE_WARNING, null); //leave zones as null
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
        return new ZoneUtilResult<>(Result.SUCCESS, null);
    }
    public static ZoneUtilResult<Boolean> isPointInZone(Point2d point, String zoneName) {
        if(zones == null) {
            //TODO: Replace with proper logging
            System.err.printf("WARNING: Attempted to query zone '%s' before any zones were loaded\n", zoneName);
            return new ZoneUtilResult<>(Result.NULL_QUERY_ERROR, false);
        }
        if(point == null) {
            //TODO: Replace with proper logging
            System.err.printf("WARNING: Attempted to query zone '%s' with a null point\n", zoneName);
            return new ZoneUtilResult<>(Result.NULL_QUERY_ERROR, false);
        }
        if(!zones.containsKey(zoneName)) {
            //TODO: Replace with proper logging
            System.err.printf("WARNING: No zone with the name '%s' was found\n", zoneName);
            return new ZoneUtilResult<>(Result.NULL_QUERY_ERROR, false);
        }

        return new ZoneUtilResult<>(Result.SUCCESS, zones.get(zoneName).getPolygon().containsPoint(point));
    }
    //TODO: implement trigger api
    public static /*ZoneUtilResult<Trigger>*/ void triggerIsPointInZone(Point2d point, String zoneName) throws NotImplementedException {
        throw new NotImplementedException("triggerIsPointInZone is not yet supported");
    }
}
