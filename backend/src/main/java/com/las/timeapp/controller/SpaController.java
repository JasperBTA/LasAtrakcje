package com.las.timeapp.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class SpaController {

    @RequestMapping(value = {
        "/", 
        "/measurements", 
        "/attractions", 
        "/surveys", 
        "/users", 
        "/export", 
        "/settings"
    })
    public String redirect() {
        return "forward:/index.html";
    }
}
