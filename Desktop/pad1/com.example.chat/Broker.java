package com.example.chat;

import java.io.*;
import java.net.*;
import java.util.*;
import java.util.concurrent.*;

public class Broker {
    private static final int PORT = 12345;
    private static Map<String, ClientHandler> clients = new ConcurrentHashMap<>();

    public static void main(String[] args) {
        System.out.println("Broker started on port " + PORT);

        try (ServerSocket serverSocket = new ServerSocket(PORT)) {
            // Continuously accept new client connections
            while (true) {
                Socket socket = serverSocket.accept();
                // Handle each client in a new thread
                new Thread(new ClientHandler(socket)).start();
            }
        } catch (IOException e) {
            System.err.println("Could not start broker on port " + PORT);
            e.printStackTrace();
        }
    }

    // Inner class to handle client connections
    static class ClientHandler implements Runnable {
        private Socket socket;
        private String clientName;
        private BufferedReader in;
        private PrintWriter out;

        public ClientHandler(Socket socket) {
            this.socket = socket;
        }

        @Override
        public void run() {
            try {
                // Set up input and output streams
                in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
                out = new PrintWriter(socket.getOutputStream(), true);

                // Request client name
                out.println("Enter your name:");
                clientName = in.readLine();

                // Add client to the map
                clients.put(clientName, this);
                System.out.println(clientName + " connected.");

                String input;
                while ((input = in.readLine()) != null) {
                    // Process input
                    if (input.startsWith("@")) {
                        // Private message
                        handlePrivateMessage(input);
                    } else if (input.startsWith("broadcast:")) {
                        // Broadcast message
                        handleBroadcastMessage(input);
                    } else {
                        out.println("Invalid message format. Use @name:message or broadcast:message");
                    }
                }
            } catch (IOException e) {
                System.err.println("Connection error with client " + clientName);
            } finally {
                // Clean up
                if (clientName != null) {
                    clients.remove(clientName);
                    System.out.println(clientName + " disconnected.");
                }
                try {
                    socket.close();
                } catch (IOException e) {
                    System.err.println("Error closing socket for " + clientName);
                }
            }
        }

        private void handlePrivateMessage(String input) {
            int index = input.indexOf(':');
            if (index != -1) {
                String recipientName = input.substring(1, index);
                String message = input.substring(index + 1);
                ClientHandler recipient = clients.get(recipientName);
                if (recipient != null) {
                    recipient.out.println("Private from " + clientName + ": " + message);
                } else {
                    out.println("User " + recipientName + " not found.");
                }
            } else {
                out.println("Invalid format. Use @name:message");
            }
        }

        private void handleBroadcastMessage(String input) {
            String message = input.substring("broadcast:".length());
            for (ClientHandler client : clients.values()) {
                if (!client.clientName.equals(clientName)) {
                    client.out.println("Broadcast from " + clientName + ": " + message);
                }
            }
        }
    }
}
