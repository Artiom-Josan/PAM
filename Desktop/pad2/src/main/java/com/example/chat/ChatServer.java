package com.example.chat;

import io.grpc.Server;
import io.grpc.ServerBuilder;
import io.grpc.stub.StreamObserver;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class ChatServer {
    private final int port = 50051;
    private final Server server;

    public ChatServer() {
        server = ServerBuilder.forPort(port)
                .addService(new ChatServiceImpl())
                .build();
    }

    public void start() throws IOException {
        server.start();
        System.out.println("Server started on port " + port);
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            System.err.println("*** Shutting down server...");
            ChatServer.this.stop();
            System.err.println("*** Server shut down.");
        }));
    }

    public void stop() {
        if (server != null) {
            server.shutdown();
        }
    }

    // Await termination on the main thread
    private void blockUntilShutdown() throws InterruptedException {
        if (server != null) {
            server.awaitTermination();
        }
    }

    // Main method
    public static void main(String[] args) throws IOException, InterruptedException {
        final ChatServer chatServer = new ChatServer();
        chatServer.start();
        chatServer.blockUntilShutdown();
    }

    // Implementation of the ChatService
    static class ChatServiceImpl extends ChatServiceGrpc.ChatServiceImplBase {
        private Map<String, StreamObserver<ChatProto.ChatMessage>> clients = new ConcurrentHashMap<>();

        @Override
        public StreamObserver<ChatProto.ChatMessage> chat(StreamObserver<ChatProto.ChatMessage> responseObserver) {
            return new StreamObserver<ChatProto.ChatMessage>() {
                private String clientName;

                @Override
                public void onNext(ChatProto.ChatMessage message) {
                    if (clientName == null) {
                        clientName = message.getSender();
                        clients.put(clientName, responseObserver);
                        System.out.println(clientName + " connected.");
                        // Oprește procesarea mesajului inițial
                        return;
                    }
                    if (message.getRecipient() == null || message.getRecipient().isEmpty()) {
                        // Ignoră mesajele fără destinatar
                        System.out.println("Message from " + clientName + " has no recipient.");
                        return;
                    }
                    if (message.getRecipient().equalsIgnoreCase("ALL")) {
                        // Broadcast message
                        for (Map.Entry<String, StreamObserver<ChatProto.ChatMessage>> client : clients.entrySet()) {
                            if (!client.getKey().equals(clientName)) {
                                client.getValue().onNext(message);
                            }
                        }
                    } else {
                        // Private message
                        StreamObserver<ChatProto.ChatMessage> recipient = clients.get(message.getRecipient());
                        if (recipient != null) {
                            recipient.onNext(message);
                        } else {
                            // Send error back to sender
                            ChatProto.ChatMessage error = ChatProto.ChatMessage.newBuilder()
                                    .setSender("Server")
                                    .setRecipient(clientName)
                                    .setMessage("User " + message.getRecipient() + " not found.")
                                    .build();
                            responseObserver.onNext(error);
                        }
                    }
                }

                @Override
                public void onError(Throwable t) {
                    if (clientName != null) {
                        clients.remove(clientName);
                        System.err.println(clientName + " disconnected due to error: " + t.getMessage());
                    }
                }

                @Override
                public void onCompleted() {
                    if (clientName != null) {
                        clients.remove(clientName);
                        System.out.println(clientName + " disconnected.");
                    }
                    responseObserver.onCompleted();
                }
            };
        }
    }
}
