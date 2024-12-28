package com.pocketdoctor.Controller;

import com.pocketdoctor.services.GoogleMapsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/ambulance")
public class AmbulanceController {

    @Autowired
    private GoogleMapsService googleMapsService;

    @PostMapping("/book")
    public ResponseEntity<String> bookAmbulance(@RequestParam double latitude, @RequestParam double longitude) {
        try {
            String hospital = googleMapsService.findNearestHospital(latitude, longitude);
            String liveLocationUrl = googleMapsService.generateLiveLocationUrl(latitude, longitude);

            // Send location and hospital details (e.g., via SMS or email)
            // For simplicity, returning details as a response.
            String responseMessage = String.format(
                    "Ambulance booked. Live location: %s. Nearest hospital: %s.",
                    liveLocationUrl, hospital
            );

            return ResponseEntity.status(HttpStatus.OK).body(responseMessage);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Failed to book ambulance.");
        }
    }
}
