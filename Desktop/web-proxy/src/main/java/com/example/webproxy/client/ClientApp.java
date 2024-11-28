package com.example.webproxy.client;

import com.example.webproxy.model.Employee;
import com.google.gson.Gson;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.Scanner;

public class ClientApp {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        try {
            // Alege formatul o singură dată
            System.out.print("Alege formatul (xml/json): ");
            String format = scanner.nextLine().trim().toLowerCase();

            // Verifica formatul
            if (!format.equals("xml") && !format.equals("json")) {
                System.out.println("Format invalid. Folosesc formatul implicit 'json'.");
                format = "json";
            }

            boolean running = true;
            while (running) {
                // Alege actiunea
                System.out.println("\nAlege actiunea:");
                System.out.println("1. Obtine un angajat");
                System.out.println("2. Obtine lista de angajati");
                System.out.println("3. Adauga un angajat");
                System.out.println("4. Actualizeaza un angajat");
                System.out.println("5. Iesire");
                System.out.print("Introdu numarul actiunii dorite: ");
                String input = scanner.nextLine();

                int action;
                try {
                    action = Integer.parseInt(input);
                } catch (NumberFormatException e) {
                    System.out.println("Te rog introdu un numar valid.");
                    continue;
                }

                switch (action) {
                    case 1:
                        getEmployee(scanner, format);
                        break;
                    case 2:
                        getEmployees(scanner, format);
                        break;
                    case 3:
                        addEmployee(scanner);
                        break;
                    case 4:
                        updateEmployee(scanner);
                        break;
                    case 5:
                        running = false;
                        System.out.println("La revedere!");
                        break;
                    default:
                        System.out.println("Actiune invalida.");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            scanner.close();
        }
    }

    private static void getEmployee(Scanner scanner, String format) throws IOException {
        System.out.print("Introdu ID-ul angajatului: ");
        String id = scanner.nextLine();

        String params = "id=" + URLEncoder.encode(id, "UTF-8") + "&format=" + URLEncoder.encode(format, "UTF-8");
        URL url = new URL("http://localhost:8080/employee/?" + params); // Trimite cererea către proxy
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");

        printResponse(conn);
    }

    private static void getEmployees(Scanner scanner, String format) throws IOException {
        System.out.print("Introdu offset (implicit 0): ");
        String offset = scanner.nextLine();
        if (offset.isEmpty()) offset = "0";

        System.out.print("Introdu limita (implicit 10): ");
        String limit = scanner.nextLine();
        if (limit.isEmpty()) limit = "10";

        String params = "offset=" + URLEncoder.encode(offset, "UTF-8") +
                "&limit=" + URLEncoder.encode(limit, "UTF-8") +
                "&format=" + URLEncoder.encode(format, "UTF-8");
        URL url = new URL("http://localhost:8080/employees/?" + params); // Trimite cererea către proxy
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");

        printResponse(conn);
    }

    private static void addEmployee(Scanner scanner) throws IOException {
        System.out.print("Introdu numele angajatului: ");
        String name = scanner.nextLine();

        System.out.print("Introdu pozitia angajatului: ");
        String position = scanner.nextLine();

        System.out.print("Introdu salariul angajatului: ");
        double salary;
        try {
            salary = Double.parseDouble(scanner.nextLine());
        } catch (NumberFormatException e) {
            System.out.println("Salariu invalid. Operatiunea a fost anulata.");
            return;
        }

        Employee employee = new Employee(0, name, position, salary);
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

        printResponse(conn);
    }

    private static void updateEmployee(Scanner scanner) throws IOException {
        System.out.print("Introdu ID-ul angajatului de actualizat: ");
        int id;
        try {
            id = Integer.parseInt(scanner.nextLine());
        } catch (NumberFormatException e) {
            System.out.println("ID invalid. Operatiunea a fost anulata.");
            return;
        }

        System.out.print("Introdu numele nou al angajatului: ");
        String name = scanner.nextLine();

        System.out.print("Introdu pozitia noua a angajatului: ");
        String position = scanner.nextLine();

        System.out.print("Introdu salariul nou al angajatului: ");
        double salary;
        try {
            salary = Double.parseDouble(scanner.nextLine());
        } catch (NumberFormatException e) {
            System.out.println("Salariu invalid. Operatiunea a fost anulata.");
            return;
        }

        Employee employee = new Employee(id, name, position, salary);
        Gson gson = new Gson();
        String json = gson.toJson(employee);

        URL url = new URL("http://localhost:8080/employee/"); // Trimite cererea către proxy
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setDoOutput(true);
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json");

        OutputStream os = conn.getOutputStream();
        os.write(json.getBytes());
        os.flush();

        printResponse(conn);
    }

    private static void printResponse(HttpURLConnection conn) throws IOException {
        int responseCode = conn.getResponseCode();
        System.out.println("Response Code : " + responseCode);

        InputStream inputStream;
        if (responseCode >= 200 && responseCode < 400) {
            inputStream = conn.getInputStream();
        } else {
            inputStream = conn.getErrorStream();
            if (inputStream == null) {
                // Niciun mesaj de eroare disponibil
                System.out.println("No additional information available.");
                conn.disconnect();
                return;
            }
        }

        BufferedReader in = new BufferedReader(new InputStreamReader(inputStream));
        String inputLine;
        StringBuilder response = new StringBuilder();

        while ((inputLine = in.readLine()) != null) {
            response.append(inputLine);
            response.append("\n");
        }
        in.close();

        System.out.println("Response: ");
        System.out.println(response.toString());

        conn.disconnect();
    }
}
