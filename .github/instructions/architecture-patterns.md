# Padrões Arquiteturais e Design de Sistemas

## Architecture Decision Record (ADR) Template

```markdown
# ADR-001: Choice of Database Technology

## Status
Accepted

## Context
We need to choose a database technology for our e-commerce platform that will handle:
- High read/write operations (1M+ transactions/day)
- Complex queries for product recommendations
- ACID compliance for financial transactions
- Horizontal scalability

## Decision
We will use PostgreSQL as our primary database with Redis for caching.

## Consequences

### Positive:
- ACID compliance ensures data consistency
- Rich query capabilities with SQL
- Strong ecosystem and community support
- Good performance for complex queries

### Negative:
- Requires more complex setup for high availability
- Vertical scaling limitations
- More expensive than NoSQL alternatives

## Implementation Notes
- Use read replicas for scaling read operations
- Implement connection pooling
- Set up automated backups and monitoring
```

## System Architecture Patterns

### Microservices Architecture
```yaml
# docker-compose.yml for microservices
version: '3.8'

services:
  # API Gateway
  gateway:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - user-service
      - product-service
      - order-service

  # User Service
  user-service:
    build: ./services/user
    environment:
      - DB_URL=postgresql://user_db:5432/users
      - JWT_SECRET=${JWT_SECRET}
    depends_on:
      - user-db
      - redis

  # Product Service
  product-service:
    build: ./services/product
    environment:
      - DB_URL=postgresql://product_db:5432/products
      - ELASTICSEARCH_URL=http://elasticsearch:9200
    depends_on:
      - product-db
      - elasticsearch

  # Order Service
  order-service:
    build: ./services/order
    environment:
      - DB_URL=postgresql://order_db:5432/orders
      - RABBITMQ_URL=amqp://rabbitmq:5672
    depends_on:
      - order-db
      - rabbitmq

  # Databases
  user-db:
    image: postgres:13
    environment:
      POSTGRES_DB: users

  product-db:
    image: postgres:13
    environment:
      POSTGRES_DB: products

  order-db:
    image: postgres:13
    environment:
      POSTGRES_DB: orders

  # Infrastructure
  redis:
    image: redis:alpine

  rabbitmq:
    image: rabbitmq:3-management
    ports:
      - "15672:15672"

  elasticsearch:
    image: elasticsearch:7.14.0
    environment:
      - discovery.type=single-node
```

### Event-Driven Architecture
```javascript
// Event Bus Implementation
class EventBus {
  constructor() {
    this.events = {};
  }

  subscribe(eventType, handler) {
    if (!this.events[eventType]) {
      this.events[eventType] = [];
    }
    this.events[eventType].push(handler);
  }

  publish(eventType, data) {
    if (!this.events[eventType]) return;

    this.events[eventType].forEach(handler => {
      try {
        handler(data);
      } catch (error) {
        console.error(`Error handling event ${eventType}:`, error);
      }
    });
  }

  unsubscribe(eventType, handler) {
    if (!this.events[eventType]) return;
    
    this.events[eventType] = this.events[eventType].filter(h => h !== handler);
  }
}

// Domain Events
class UserCreatedEvent {
  constructor(userId, email, name) {
    this.type = 'USER_CREATED';
    this.timestamp = new Date().toISOString();
    this.data = { userId, email, name };
  }
}

class OrderPlacedEvent {
  constructor(orderId, userId, items, total) {
    this.type = 'ORDER_PLACED';
    this.timestamp = new Date().toISOString();
    this.data = { orderId, userId, items, total };
  }
}

// Event Handlers
class EmailService {
  constructor(eventBus) {
    eventBus.subscribe('USER_CREATED', this.sendWelcomeEmail.bind(this));
    eventBus.subscribe('ORDER_PLACED', this.sendOrderConfirmation.bind(this));
  }

  async sendWelcomeEmail(userData) {
    console.log(`Sending welcome email to ${userData.email}`);
    // Email logic here
  }

  async sendOrderConfirmation(orderData) {
    console.log(`Sending order confirmation for order ${orderData.orderId}`);
    // Email logic here
  }
}

// Usage
const eventBus = new EventBus();
const emailService = new EmailService(eventBus);

// When user is created
eventBus.publish('USER_CREATED', {
  userId: '123',
  email: 'user@example.com',
  name: 'John Doe'
});
```

### CQRS Pattern
```javascript
// Command Side
class CreateUserCommand {
  constructor(name, email, password) {
    this.name = name;
    this.email = email;
    this.password = password;
  }
}

class UserCommandHandler {
  constructor(userRepository, eventBus) {
    this.userRepository = userRepository;
    this.eventBus = eventBus;
  }

  async handle(command) {
    // Validate command
    if (!command.email || !command.name) {
      throw new Error('Invalid user data');
    }

    // Check business rules
    const existingUser = await this.userRepository.findByEmail(command.email);
    if (existingUser) {
      throw new Error('User already exists');
    }

    // Create user
    const user = new User(command.name, command.email, command.password);
    await this.userRepository.save(user);

    // Publish event
    this.eventBus.publish('USER_CREATED', {
      userId: user.id,
      name: user.name,
      email: user.email
    });

    return user;
  }
}

// Query Side
class UserQuery {
  constructor(userRepository) {
    this.userRepository = userRepository;
  }

  async getUserById(userId) {
    return await this.userRepository.findById(userId);
  }

  async getUsersByRole(role) {
    return await this.userRepository.findByRole(role);
  }

  async getUsersCreatedAfter(date) {
    return await this.userRepository.findCreatedAfter(date);
  }
}

// Read Model (can be different from write model)
class UserReadModel {
  constructor(id, name, email, role, createdAt, lastLogin) {
    this.id = id;
    this.name = name;
    this.email = email;
    this.role = role;
    this.createdAt = createdAt;
    this.lastLogin = lastLogin;
    // Additional denormalized fields for read optimization
    this.orderCount = 0;
    this.totalSpent = 0;
  }
}
```

### Clean Architecture Structure
```
src/
├── domain/
│   ├── entities/
│   │   ├── User.js
│   │   ├── Product.js
│   │   └── Order.js
│   ├── value-objects/
│   │   ├── Email.js
│   │   └── Money.js
│   └── repositories/
│       ├── UserRepository.js
│       └── OrderRepository.js
├── application/
│   ├── use-cases/
│   │   ├── CreateUser.js
│   │   ├── PlaceOrder.js
│   │   └── GetUserProfile.js
│   ├── services/
│   │   ├── EmailService.js
│   │   └── PaymentService.js
│   └── dto/
│       ├── CreateUserRequest.js
│       └── UserResponse.js
├── infrastructure/
│   ├── database/
│   │   ├── UserRepositoryImpl.js
│   │   └── migrations/
│   ├── external/
│   │   ├── EmailServiceImpl.js
│   │   └── PaymentGateway.js
│   └── web/
│       ├── controllers/
│       └── middleware/
└── interfaces/
    ├── http/
    │   ├── routes/
    │   └── serializers/
    └── cli/
```

## Resilience Patterns

### Circuit Breaker
```javascript
class CircuitBreaker {
  constructor(threshold = 5, timeout = 60000, monitor = 30000) {
    this.threshold = threshold;
    this.timeout = timeout;
    this.monitor = monitor;
    this.failures = 0;
    this.state = 'CLOSED'; // CLOSED, OPEN, HALF_OPEN
    this.nextAttempt = Date.now();
  }

  async call(fn) {
    if (this.state === 'OPEN') {
      if (Date.now() < this.nextAttempt) {
        throw new Error('Circuit breaker is OPEN');
      }
      this.state = 'HALF_OPEN';
    }

    try {
      const result = await fn();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }

  onSuccess() {
    this.failures = 0;
    if (this.state === 'HALF_OPEN') {
      this.state = 'CLOSED';
    }
  }

  onFailure() {
    this.failures++;
    if (this.failures >= this.threshold) {
      this.state = 'OPEN';
      this.nextAttempt = Date.now() + this.timeout;
    }
  }
}

// Usage
const circuitBreaker = new CircuitBreaker(3, 30000);

async function callExternalService() {
  return await circuitBreaker.call(async () => {
    const response = await fetch('https://api.external-service.com/data');
    if (!response.ok) {
      throw new Error('Service unavailable');
    }
    return response.json();
  });
}
```

### Retry Pattern with Exponential Backoff
```javascript
class RetryPolicy {
  constructor(maxAttempts = 3, baseDelay = 1000, maxDelay = 30000) {
    this.maxAttempts = maxAttempts;
    this.baseDelay = baseDelay;
    this.maxDelay = maxDelay;
  }

  async execute(fn) {
    let attempt = 0;
    
    while (attempt < this.maxAttempts) {
      try {
        return await fn();
      } catch (error) {
        attempt++;
        
        if (attempt >= this.maxAttempts) {
          throw error;
        }
        
        const delay = Math.min(
          this.baseDelay * Math.pow(2, attempt - 1),
          this.maxDelay
        );
        
        console.log(`Attempt ${attempt} failed, retrying in ${delay}ms`);
        await this.sleep(delay);
      }
    }
  }

  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

// Usage
const retryPolicy = new RetryPolicy(3, 1000, 10000);

await retryPolicy.execute(async () => {
  return await fetch('https://api.unreliable-service.com/data');
});
```

## Performance Patterns

### Caching Strategy
```javascript
class CacheService {
  constructor(redisClient) {
    this.redis = redisClient;
    this.localCache = new Map();
  }

  async get(key, fallbackFn, ttl = 3600) {
    // L1 Cache (Memory)
    if (this.localCache.has(key)) {
      return this.localCache.get(key);
    }

    // L2 Cache (Redis)
    const cached = await this.redis.get(key);
    if (cached) {
      const data = JSON.parse(cached);
      this.localCache.set(key, data);
      return data;
    }

    // Fallback to source
    const data = await fallbackFn();
    
    // Store in both caches
    await this.redis.setex(key, ttl, JSON.stringify(data));
    this.localCache.set(key, data);
    
    return data;
  }

  async invalidate(key) {
    this.localCache.delete(key);
    await this.redis.del(key);
  }
}
```

## Comandos de Arquitetura

### System Design Commands
```bash
# Generate C4 diagrams
docker run --rm -v $(pwd):/workspace plantuml/plantuml architecture.puml

# Performance testing
k6 run --vus 100 --duration 5m performance-test.js

# Load testing
artillery run load-test.yml

# Architecture analysis
dependency-cruiser --validate .dependency-cruiser.js src/
```
