package com.example.chat;

import io.grpc.ManagedChannel;
import io.grpc.ManagedChannelBuilder;
import io.grpc.stub.StreamObserver;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

public class ChatClient {
    private final String host = "localhost";
    private final int port = 50051;
    private final ManagedChannel channel;
    private final ChatServiceGrpc.ChatServiceStub asyncStub;

    public ChatClient() {
        channel = ManagedChannelBuilder.forAddress(host, port)
                .usePlaintext()
                .build();
        asyncStub = ChatServiceGrpc.newStub(channel);
    }

    public void start() throws IOException {
        BufferedReader consoleReader = new BufferedReader(new InputStreamReader(System.in));

        System.out.print("Enter your name: ");
        String name = consoleReader.readLine();

        StreamObserver<ChatProto.ChatMessage> requestObserver = asyncStub.chat(new StreamObserver<ChatProto.ChatMessage>() {
            @Override
            public void onNext(ChatProto.ChatMessage message) {
                if (!message.getSender().equals(name)) {
                    System.out.println(message.getSender() + ": " + message.getMessage());
                }
            }

            @Override
            public void onError(Throwable t) {
                System.err.println("Error receiving message: " + t.getMessage());
            }

            @Override
            public void onCompleted() {
                System.out.println("Chat ended.");
            }
        });

        // Send initial message with the client's name
        ChatProto.ChatMessage initMessage = ChatProto.ChatMessage.newBuilder()
                .setSender(name)
                .build();
        requestObserver.onNext(initMessage);

        // Read messages from console and send to server
        String input;
        while ((input = consoleReader.readLine()) != null) {
            ChatProto.ChatMessage message;
            if (input.startsWith("@")) {
                int index = input.indexOf(':');
                if (index != -1) {
                    String recipient = input.substring(1, index);
                    String msg = input.substring(index + 1);
                    message = ChatProto.ChatMessage.newBuilder()
                            .setSender(name)
                            .setRecipient(recipient)
                            .setMessage(msg)
                            .build();
                } else {
                    System.out.println("Invalid format. Use @name:message");
                    continue;
                }
            } else if (input.startsWith("broadcast:")) {
                String msg = input.substring("broadcast:".length());
                message = ChatProto.ChatMessage.newBuilder()
                        .setSender(name)
                        .setRecipient("ALL")
                        .setMessage(msg)
                        .build();
            } else {
                System.out.println("Invalid message format. Use @name:message or broadcast:message");
                continue;
            }
            requestObserver.onNext(message);
        }
        // Notify server of completion
        requestObserver.onCompleted();
    }

    public void shutdown() throws InterruptedException {
        channel.shutdown();
    }

    // Main method
    public static void main(String[] args) throws IOException, InterruptedException {
        ChatClient client = new ChatClient();
        client.start();
    }
}
