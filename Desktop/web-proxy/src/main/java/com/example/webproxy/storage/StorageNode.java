package com.example.webproxy.storage;

import com.example.webproxy.model.Employee;
import com.google.gson.Gson;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

public class StorageNode {
    public static void main(String[] args) {
        sendEmployee(new Employee(0, "John Doe", "Developer", 5000.0));
        sendEmployee(new Employee(0, "Jane Smith", "Manager", 7000.0));
        sendEmployee(new Employee(0, "Alice Johnson", "Designer", 4500.0));
    }

    private static void sendEmployee(Employee employee) {
        try {
            Gson gson = new Gson();
            String json = gson.toJson(employee);

            URL url = new URL("http://localhost:8080/employee/"); // Trimite cererea către proxy
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setDoOutput(true);
            conn.setRequestMethod("PUT");
            conn.setRequestProperty("Content-Type", "application/json");

            OutputStream os = conn.getOutputStream();
            os.write(json.getBytes());
            os.flush();

            int responseCode = conn.getResponseCode();
            System.out.println("Sending Employee: " + employee.getName() + ", " + employee.getPosition() + ", " + employee.getSalary());
            System.out.println("Response Code : " + responseCode);

            conn.disconnect();
        } catch (Exception e) {
            System.out.println("Failed to send employee: " + employee.getName());
            e.printStackTrace();
        }
    }
}
