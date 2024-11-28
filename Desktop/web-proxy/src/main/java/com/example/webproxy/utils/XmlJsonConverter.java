package com.example.webproxy.utils;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.dataformat.xml.XmlMapper;

import java.util.List;

public class XmlJsonConverter {
    private static XmlMapper xmlMapper = new XmlMapper();

    public static String toXml(Object obj) throws JsonProcessingException {
        xmlMapper.enable(SerializationFeature.INDENT_OUTPUT);
        if (obj instanceof List) {
            // Învelim lista într-un element rădăcină
            Wrapper wrapper = new Wrapper((List<?>) obj);
            return xmlMapper.writeValueAsString(wrapper);
        } else {
            return xmlMapper.writeValueAsString(obj);
        }
    }

    // Clasă auxiliară pentru a înveli lista într-un element rădăcină
    public static class Wrapper {
        public List<?> Employee;

        public Wrapper(List<?> employees) {
            this.Employee = employees;
        }
    }
}
