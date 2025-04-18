package org.derekriter;

import java.io.IOException;
import java.io.InputStream;
import java.util.Scanner;

public final class Main {
    public static void main(String[] args) throws IOException {
        //TODO: replace file reading
        final InputStream stream = Main.class.getResourceAsStream("/map.json");
        if(stream == null) {
            throw new IOException("Failed to open json file");
        }

        final Scanner scanner = new Scanner(stream);
        while(scanner.hasNextLine()) {
            System.out.println(scanner.nextLine());
        }

        scanner.close(); //closes file too
    }
}
