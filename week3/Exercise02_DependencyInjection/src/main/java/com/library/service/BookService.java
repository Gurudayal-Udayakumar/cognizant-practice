package com.library.service;

import com.library.repository.BookRepository;

public class BookService {
    private BookRepository repository;

    public void setRepository(BookRepository repository) {
        this.repository = repository;
    }

    public void announce() {
        System.out.println("Library portal is live.");
        System.out.println("Today's Pick: " + repository.latestTitle());
    }
}
