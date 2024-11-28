package com.example.webproxy.server;

import com.example.webproxy.controller.EmployeeController;
import com.sun.net.httpserver.HttpServer;

import java.io.IOException;
import java.net.InetSocketAddress;

public class HttpServerApp {
    public static void main(String[] args) throws IOException {
        if (args.length != 1) {
            System.err.println("Usage: java HttpServerApp <port>");
            System.exit(1);
        }

        int port = Integer.parseInt(args[0]);
        HttpServer server = HttpServer.create(new InetSocketAddress(port), 0);
        server.createContext("/", new EmployeeController(port));
        server.setExecutor(null); // Folosește executor implicit
        server.start();
        System.out.println("Server started on port " + port);
    }
}
