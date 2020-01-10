# Memcached Server

A minimal Memcached server implementation in Ruby

### Supported Protocols

- [x] Text Protocol
- [ ] Binary Protocol

### Storage Commands

- [x] set
- [x] add
- [x] replace
- [x] append
- [x] prepend
- [x] cas

### Retrieval Commands

- [x] get
- [x] gets

### Dependencies

Install bundler:

```bash
gem install bundler
```

Install the gems:

```bash
bundle install
```

### Running the Server

```bash
ruby runserver.rb
```

### Running the Client

```bash
ruby client.rb
```

```bash
telnet localhost 1892
```

```bash
nc localhost 1892
```

### Running unit tests

```bash
rspec server_spec.rb
```

### Running load test

```bash
rspec load_spec.rb
```
