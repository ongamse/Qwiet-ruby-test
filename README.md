# Overview
Credzy is a vulnerable web app written in Ruby.

I wrote this app to learn Ruby as a new starter at Certsy. 

It was used as a CTF for *developer happy fun time* on Friday 25 March 2022. 

# Vulnerabilities
There are many, but the planned vulnerabilities were:
1. Cookie tampering to shift between non-admin accounts
1. SQL Injection into email field to bypass login, or view all documents from any user account
1. Easy reversing of MD5 password hashes in DB
1. Path canonicalisation attack via query string on `download` route allowing download of database

The path canonicalisation attack is the most severe.
You can simply download the source code and see everything using that attack.

# Install
```
bundle config build.eventmachine --with-cppflags=-I$(brew --prefix openssl)/include
bundle install
```

# Run
```
cd /path/to/credzy
ruby main.rb
```
