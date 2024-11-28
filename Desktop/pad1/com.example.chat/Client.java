package com.example.chat;

import java.io.*;
import java.net.*;

public class Client {
    private static final String HOST = "localhost";
    private static final int PORT = 12345;

    public static void main(String[] args) {
        new Client().start();
    }

    public void start() {
        try {
            Socket socket = new Socket(HOST, PORT);
            System.out.println("Connected to the broker.");

            // Start threads for reading and writing
            new Thread(new ReadTask(socket)).start();
            new Thread(new WriteTask(socket)).start();

        } catch (IOException e) {
            System.err.println("Unable to connect to broker.");
            e.printStackTrace();
        }
    }

    // Thread to handle incoming messages from the broker
    class ReadTask implements Runnable {
        private BufferedReader in;

        public ReadTask(Socket socket) throws IOException {
            in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
        }

        @Override
        public void run() {
            String response;
            try {
                while ((response = in.readLine()) != null) {
                    System.out.println(response);
                }
            } catch (IOException e) {
                System.err.println("Connection closed.");
            }
        }
    }

    // Thread to send messages to the broker
    class WriteTask implements Runnable {
        private PrintWriter out;
        private BufferedReader console;

        public WriteTask(Socket socket) throws IOException {
            out = new PrintWriter(socket.getOutputStream(), true);
            console = new BufferedReader(new InputStreamReader(System.in));
        }

        @Override
        public void run() {
            String input;
            try {
                while ((input = console.readLine()) != null) {
                    out.println(input);
                }
            } catch (IOException e) {
                System.err.println("Error sending message.");
            }
        }
    }
}
