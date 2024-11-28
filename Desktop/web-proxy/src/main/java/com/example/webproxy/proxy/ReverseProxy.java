package com.example.webproxy.proxy;

import com.sun.net.httpserver.Headers;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpServer;
import redis.clients.jedis.Jedis;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.*;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.util.*;

public class ReverseProxy {
    private static final int PORT = 8080;
    private static final String[] DW_SERVERS = {
            "http://localhost:8001",
            "http://localhost:8002",
            "http://localhost:8003"
    };
    private static int serverIndex = 0;

    public static void main(String[] args) throws IOException {
        HttpServer server = HttpServer.create(new InetSocketAddress(PORT), 0);
        server.createContext("/", new ProxyHandler());
        server.setExecutor(java.util.concurrent.Executors.newFixedThreadPool(10));
        server.start();
        System.out.println("Reverse proxy started on port " + PORT);
    }

    private static class ProxyHandler implements HttpHandler {
        private Jedis jedis = new Jedis("localhost", 6379);

        @Override
        public void handle(HttpExchange exchange) throws IOException {
            try {
                String method = exchange.getRequestMethod();
                URI requestURI = exchange.getRequestURI();
                String query = requestURI.getQuery();
                String path = requestURI.getPath();

                // Citim corpul cererii, dacă există
                InputStream is = exchange.getRequestBody();
                byte[] requestBody = is.readAllBytes();

                String cacheKey = method + ":" + path + "?" + (query != null ? query : "");

                // Verificăm dacă răspunsul este în cache
                if (method.equalsIgnoreCase("GET")) {
                    String cachedResponse = jedis.get(cacheKey);
                    if (cachedResponse != null) {
                        // Returnăm răspunsul din cache
                        byte[] responseBody = cachedResponse.getBytes(StandardCharsets.UTF_8);
                        String contentType = jedis.get(cacheKey + ":contentType");
                        if (contentType == null) {
                            contentType = "application/json"; // Implicit
                        }
                        exchange.getResponseHeaders().add("Content-Type", contentType);
                        exchange.sendResponseHeaders(200, responseBody.length);
                        OutputStream os = exchange.getResponseBody();
                        os.write(responseBody);
                        os.close();
                        System.out.println("Served from cache: " + cacheKey);
                        return;
                    }
                }

                // Selectăm serverul DW folosind algoritmul Round-Robin
                String targetServer = getNextServer();

                // Construim noul URL
                String serverUrl = targetServer + path + (query != null ? "?" + query : "");
                System.out.println("Forwarding request to: " + serverUrl);

                URL url = new URL(serverUrl); // Constructor corect
                HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                conn.setRequestMethod(method);

                // Copiem anteturile
                exchange.getRequestHeaders().forEach((key, values) -> {
                    for (String value : values) {
                        conn.addRequestProperty(key, value);
                    }
                });

                // Dacă avem un corp al cererii, îl trimitem
                if (method.equalsIgnoreCase("POST") || method.equalsIgnoreCase("PUT")) {
                    conn.setDoOutput(true);
                    OutputStream os = conn.getOutputStream();
                    os.write(requestBody);
                    os.flush();
                }

                // Obținem răspunsul de la serverul DW
                int responseCode = conn.getResponseCode();
                InputStream responseStream = responseCode >= 400 ? conn.getErrorStream() : conn.getInputStream();
                byte[] responseBody = responseStream.readAllBytes();

                // Stocăm răspunsul în cache
                if (method.equalsIgnoreCase("GET") && responseCode == 200) {
                    jedis.setex(cacheKey, 60, new String(responseBody, StandardCharsets.UTF_8)); // Cache pentru 60 de secunde
                    jedis.set(cacheKey + ":contentType", conn.getContentType());
                    System.out.println("Cached response: " + cacheKey);
                }

                // Transmitem răspunsul către client
                Headers responseHeaders = exchange.getResponseHeaders();
                conn.getHeaderFields().forEach((key, values) -> {
                    if (key != null) {
                        responseHeaders.put(key, values);
                    }
                });

                exchange.sendResponseHeaders(responseCode, responseBody.length);
                OutputStream os = exchange.getResponseBody();
                os.write(responseBody);
                os.close();

            } catch (Exception e) {
                e.printStackTrace();
                exchange.sendResponseHeaders(500, -1);
            }
        }

        private synchronized String getNextServer() {
            String server = DW_SERVERS[serverIndex];
            serverIndex = (serverIndex + 1) % DW_SERVERS.length;
            return server;
        }
    }
}
