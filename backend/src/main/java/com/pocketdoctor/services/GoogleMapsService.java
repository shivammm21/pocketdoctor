package com.pocketdoctor.services;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.json.JSONObject;

@Service
public class GoogleMapsService {

    @Value("${google.maps.api.key}")
    private String apiKey;

    public String findNearestHospital(double latitude, double longitude) {
        String url = String.format(
                "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=5000&type=hospital&key=%s",
                latitude, longitude, apiKey
        );

        RestTemplate restTemplate = new RestTemplate();
        String response = restTemplate.getForObject(url, String.class);

        JSONObject json = new JSONObject(response);
        if (json.getJSONArray("results").length() > 0) {
            return json.getJSONArray("results").getJSONObject(0).getString("name");
        }

        return "No hospital found nearby.";
    }

    public String generateLiveLocationUrl(double latitude, double longitude) {
        return String.format("https://www.google.com/maps?q=%f,%f", latitude, longitude);
    }
}
