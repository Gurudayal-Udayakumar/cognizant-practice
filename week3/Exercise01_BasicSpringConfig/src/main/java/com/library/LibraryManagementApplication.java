package com.library;

import com.library.repository.BookRepository;
import com.library.service.BookService;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

public class LibraryManagementApplication {
    public static void main(String[] args) {
        ApplicationContext ctx = new ClassPathXmlApplicationContext("applicationContext.xml");
        BookService svc = (BookService) ctx.getBean("bookServiceBean");
        svc.greet();
        BookRepository repo = (BookRepository) ctx.getBean("bookRepoBean");
        System.out.println("Featured Book: " + repo.latestTitle());
    }
}
