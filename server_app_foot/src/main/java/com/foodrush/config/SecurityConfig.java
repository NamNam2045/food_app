package com.foodrush.config;

import com.foodrush.auth.security.JwtAuthFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthFilter jwtAuthFilter;
    private final UserDetailsService userDetailsService;

    /** Filter chain cho Admin Web (form login, session-based) — ưu tiên cao hơn */
    @Bean
    @Order(1)
    public SecurityFilterChain adminFilterChain(HttpSecurity http) throws Exception {
        return http
                .securityMatcher("/admin/**")
                .authenticationProvider(authenticationProvider())
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/admin/login").permitAll()
                        .requestMatchers("/admin/css/**", "/admin/js/**", "/admin/img/**").permitAll()
                        .anyRequest().hasRole("SYSTEM_ADMIN")
                )
                .formLogin(form -> form
                        .loginPage("/admin/login")
                        .loginProcessingUrl("/admin/login")
                        .defaultSuccessUrl("/admin/dashboard", true)
                        .failureUrl("/admin/login?error")
                        .usernameParameter("email")
                        .passwordParameter("password")
                        .permitAll()
                )
                .logout(logout -> logout
                        .logoutUrl("/admin/logout")
                        .logoutSuccessUrl("/admin/login?logout")
                        .invalidateHttpSession(true)
                        .deleteCookies("JSESSIONID")
                )
                .sessionManagement(s -> s.maximumSessions(3))
                .build();
    }

    /** Filter chain cho Restaurant Owner Web */
    @Bean
    @Order(2)
    public SecurityFilterChain ownerFilterChain(HttpSecurity http) throws Exception {
        return http
                .securityMatcher("/owner/**")
                .authenticationProvider(authenticationProvider())
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/owner/login").permitAll()
                        .anyRequest().hasRole("RESTAURANT_ADMIN")
                )
                .formLogin(form -> form
                        .loginPage("/owner/login")
                        .loginProcessingUrl("/owner/login")
                        .defaultSuccessUrl("/owner/dashboard", true)
                        .failureUrl("/owner/login?error")
                        .usernameParameter("email")
                        .passwordParameter("password")
                        .permitAll()
                )
                .logout(logout -> logout
                        .logoutUrl("/owner/logout")
                        .logoutSuccessUrl("/owner/login?logout")
                        .invalidateHttpSession(true)
                        .deleteCookies("JSESSIONID")
                )
                .sessionManagement(s -> s.maximumSessions(3))
                .build();
    }

    /** Filter chain cho Delivery Agent Web */
    @Bean
    @Order(3)
    public SecurityFilterChain shipperFilterChain(HttpSecurity http) throws Exception {
        return http
                .securityMatcher("/shipper/**")
                .authenticationProvider(authenticationProvider())
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/shipper/login").permitAll()
                        .anyRequest().hasRole("DELIVERY_AGENT")
                )
                .formLogin(form -> form
                        .loginPage("/shipper/login")
                        .loginProcessingUrl("/shipper/login")
                        .defaultSuccessUrl("/shipper/dashboard", true)
                        .failureUrl("/shipper/login?error")
                        .usernameParameter("email")
                        .passwordParameter("password")
                        .permitAll()
                )
                .logout(logout -> logout
                        .logoutUrl("/shipper/logout")
                        .logoutSuccessUrl("/shipper/login?logout")
                        .invalidateHttpSession(true)
                        .deleteCookies("JSESSIONID")
                )
                .sessionManagement(s -> s.maximumSessions(3))
                .build();
    }

    /** Filter chain cho REST API (JWT stateless) */
    @Bean
    @Order(4)
    public SecurityFilterChain apiFilterChain(HttpSecurity http) throws Exception {
        return http
                .securityMatcher("/api/**", "/ws/**", "/swagger-ui/**", "/api-docs/**", "/actuator/**")
                .csrf(AbstractHttpConfigurer::disable)
                .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(
                                "/api/v1/auth/**",
                                "/swagger-ui/**",
                                "/swagger-ui.html",
                                "/api-docs/**",
                                "/ws/**",
                                "/actuator/health"
                        ).permitAll()
                        .requestMatchers(HttpMethod.GET,
                                "/api/v1/restaurants/**",
                                "/api/v1/restaurants/*/menu/**"
                        ).permitAll()
                        .anyRequest().authenticated()
                )
                .authenticationProvider(authenticationProvider())
                .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class)
                .build();
    }

    /** Fallback filter chain: cho phép static resources, favicon, error page */
    @Bean
    @Order(5)
    public SecurityFilterChain staticFilterChain(HttpSecurity http) throws Exception {
        return http
                .securityMatcher("/favicon.ico", "/error", "/static/**", "/css/**", "/js/**", "/images/**", "/uploads/**")
                .authorizeHttpRequests(auth -> auth.anyRequest().permitAll())
                .csrf(AbstractHttpConfigurer::disable)
                .build();
    }

    @Bean
    public AuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider provider = new DaoAuthenticationProvider();
        provider.setUserDetailsService(userDetailsService);
        provider.setPasswordEncoder(passwordEncoder());
        return provider;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(12);
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }

    /**
     * Ngăn Spring Boot tự đăng ký JwtAuthFilter như servlet filter toàn cục.
     * Filter này chỉ chạy trong apiFilterChain (@Order 2), không chạy cho /admin/**
     */
    @Bean
    public FilterRegistrationBean<JwtAuthFilter> jwtFilterRegistration(JwtAuthFilter filter) {
        FilterRegistrationBean<JwtAuthFilter> registration = new FilterRegistrationBean<>(filter);
        registration.setEnabled(false);
        return registration;
    }
}
