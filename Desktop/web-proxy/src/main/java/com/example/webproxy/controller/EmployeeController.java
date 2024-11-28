package com.example.webproxy.controller;

import com.example.webproxy.model.Employee;
import com.example.webproxy.utils.XmlJsonConverter;
import com.google.gson.Gson;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import redis.clients.jedis.Jedis;

import java.io.*;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.stream.Collectors;

public class EmployeeController implements HttpHandler {
    private int serverPort;
    private Jedis jedis;
    private Gson gson;

    public EmployeeController(int serverPort) {
        this.serverPort = serverPort;
        this.jedis = new Jedis("localhost", 6379);
        this.gson = new Gson();
    }

    @Override
    public void handle(HttpExchange exchange) throws IOException {
        try {
            System.out.println("Request handled by server on port: " + serverPort);
            String method = exchange.getRequestMethod();

            // Extrage formatul din parametrii de interogare
            String format = "json"; // Format implicit
            URI requestURI = exchange.getRequestURI();
            String query = requestURI.getQuery();
            if (query != null && query.contains("format=xml")) {
                format = "xml";
            }

            switch (method) {
                case "GET":
                    handleGet(exchange, format);
                    break;
                case "PUT":
                    handlePut(exchange);
                    break;
                case "POST":
                    handlePost(exchange);
                    break;
                default:
                    sendResponse(exchange, "Method Not Allowed", 405);
            }
        } catch (Exception e) {
            e.printStackTrace();
            sendResponse(exchange, "Internal Server Error", 500);
        }
    }

    private void handleGet(HttpExchange exchange, String format) throws IOException {
        try {
            URI requestURI = exchange.getRequestURI();
            String path = requestURI.getPath();

            // Parsează parametrii de interogare
            Map<String, String> params = queryToMap(requestURI.getQuery());

            if (path.equals("/employee/") && params.containsKey("id")) {
                int id = Integer.parseInt(params.get("id"));
                String key = "employee:" + id;
                String json = jedis.get(key);

                if (json != null) {
                    Employee employee = gson.fromJson(json, Employee.class);
                    String response = serialize(employee, format);
                    sendResponse(exchange, response, 200, format);
                } else {
                    sendResponse(exchange, "Employee not found", 404);
                }
            } else if (path.equals("/employees/")) {
                int offset = Integer.parseInt(params.getOrDefault("offset", "0"));
                int limit = Integer.parseInt(params.getOrDefault("limit", "10"));

                if (limit <= 0) {
                    sendResponse(exchange, "Limit must be a positive integer", 400);
                    return;
                }

                if (offset < 0) {
                    sendResponse(exchange, "Offset cannot be negative", 400);
                    return;
                }

                Set<String> keys = jedis.keys("employee:*");
                List<Employee> employees = new ArrayList<>();

                for (String key : keys) {
                    String json = jedis.get(key);
                    Employee employee = gson.fromJson(json, Employee.class);
                    employees.add(employee);
                }

                // Sortare și paginare
                List<Employee> sublist = employees.stream()
                        .sorted(Comparator.comparingInt(Employee::getId))
                        .skip(offset)
                        .limit(limit)
                        .collect(Collectors.toList());

                String response = serialize(sublist, format);
                sendResponse(exchange, response, 200, format);
            } else {
                sendResponse(exchange, "Bad Request", 400);
            }
        } catch (NumberFormatException e) {
            sendResponse(exchange, "Invalid number format in parameters", 400);
        } catch (Exception e) {
            e.printStackTrace();
            sendResponse(exchange, "Internal Server Error", 500);
        }
    }

    private void handlePut(HttpExchange exchange) throws IOException {
        try {
            InputStream is = exchange.getRequestBody();
            String body = new BufferedReader(new InputStreamReader(is))
                    .lines()
                    .collect(Collectors.joining("\n"));

            Employee employee = gson.fromJson(body, Employee.class);
            if (employee.getId() == 0) {
                employee.setId(getNextId());
            }

            String key = "employee:" + employee.getId();
            String json = gson.toJson(employee);
            jedis.set(key, json);

            sendResponse(exchange, "Employee added/updated", 200);
        } catch (Exception e) {
            e.printStackTrace();
            sendResponse(exchange, "Internal Server Error", 500);
        }
    }

    private void handlePost(HttpExchange exchange) throws IOException {
        try {
            InputStream is = exchange.getRequestBody();
            String body = new BufferedReader(new InputStreamReader(is))
                    .lines()
                    .collect(Collectors.joining("\n"));

            Employee employee = gson.fromJson(body, Employee.class);
            if (employee.getId() != 0) {
                String key = "employee:" + employee.getId();
                if (jedis.exists(key)) {
                    String json = gson.toJson(employee);
                    jedis.set(key, json);
                    sendResponse(exchange, "Employee updated", 200);
                } else {
                    sendResponse(exchange, "Employee not found", 404);
                }
            } else {
                sendResponse(exchange, "Invalid employee ID", 400);
            }
        } catch (Exception e) {
            e.printStackTrace();
            sendResponse(exchange, "Internal Server Error", 500);
        }
    }

    private int getNextId() {
        return Math.toIntExact(jedis.incr("employee_id_counter"));
    }

    private Map<String, String> queryToMap(String query) {
        if (query == null) return Collections.emptyMap();
        Map<String, String> result = new HashMap<>();
        for (String param : query.split("&")) {
            String[] entry = param.split("=");
            if (entry.length > 1) {
                result.put(entry[0], entry[1]);
            } else {
                result.put(entry[0], "");
            }
        }
        return result;
    }

    private String serialize(Object obj, String format) throws IOException {
        if (format.equals("xml")) {
            try {
                return XmlJsonConverter.toXml(obj);
            } catch (Exception e) {
                e.printStackTrace();
                throw new IOException("Serialization error");
            }
        } else {
            return gson.toJson(obj);
        }
    }

    private void sendResponse(HttpExchange exchange, String response, int statusCode) throws IOException {
        sendResponse(exchange, response, statusCode, "json");
    }

    private void sendResponse(HttpExchange exchange, String response, int statusCode, String format) throws IOException {
        byte[] bytes = response.getBytes(StandardCharsets.UTF_8);
        exchange.getResponseHeaders().add("Content-Type", format.equals("xml") ? "application/xml" : "application/json");
        exchange.sendResponseHeaders(statusCode, bytes.length);
        OutputStream os = exchange.getResponseBody();
        os.write(bytes);
        os.close();
    }
}
