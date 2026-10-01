package com.example.hrmanagement.service;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.example.hrmanagement.repository.UserAccountRepo;
import com.example.hrmanagement.shared.CustomResponesException;

@Service 
public class UserDetailsServiceImpl implements UserDetailsService {

    private UserAccountRepo userAccountRepo;

    public UserDetailsServiceImpl(UserAccountRepo userAccountRepo) {
        this.userAccountRepo = userAccountRepo;
    }
    @Override
public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {

    return userAccountRepo.findByUsername(username)
            .orElseThrow(() -> CustomResponesException.badCredentials());
}
 
}