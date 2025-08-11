# QA Best Practices - Quality Assurance e Testing

## Checklist de Quality Assurance

### Estratégia de Testing
- [ ] Test Pyramid implementada (70% Unit, 20% Integration, 10% E2E)
- [ ] Coverage mínimo de 80% para código crítico
- [ ] Testes automatizados em CI/CD pipeline
- [ ] Contract testing entre serviços
- [ ] Performance testing implementado
- [ ] Security testing integrado
- [ ] Accessibility testing configurado

### Automação de Testes
- [ ] Page Object Model implementado
- [ ] Test Data Factory configurado
- [ ] Custom assertions e helpers
- [ ] Retry logic para testes flaky
- [ ] Parallel execution configurado
- [ ] Reports e dashboards configurados
- [ ] Screenshot/video capture em falhas

### API Testing
- [ ] Contract testing com schemas
- [ ] Boundary value testing
- [ ] Error handling validation
- [ ] Authentication/authorization testing
- [ ] Rate limiting testing
- [ ] Data validation testing
- [ ] Performance/load testing

### E2E Testing
- [ ] Critical user journeys cobertos
- [ ] Cross-browser testing
- [ ] Mobile responsiveness
- [ ] Error scenarios testing
- [ ] Data-driven testing
- [ ] Visual regression testing
- [ ] Accessibility compliance

## Templates de Testing Avançados

### Cypress Custom Commands
```typescript
// cypress/support/commands.ts
declare global {
  namespace Cypress {
    interface Chainable {
      login(email: string, password: string): Chainable<void>;
      createUser(userData: UserData): Chainable<void>;
      deleteUser(userId: string): Chainable<void>;
      waitForApiCall(alias: string): Chainable<void>;
      checkAccessibility(): Chainable<void>;
    }
  }
}

Cypress.Commands.add('login', (email: string, password: string) => {
  cy.session([email, password], () => {
    cy.visit('/login');
    cy.get('[data-cy=email]').type(email);
    cy.get('[data-cy=password]').type(password);
    cy.get('[data-cy=login-btn]').click();
    cy.url().should('include', '/dashboard');
    cy.window().its('localStorage.token').should('exist');
  });
});

Cypress.Commands.add('createUser', (userData: UserData) => {
  cy.request({
    method: 'POST',
    url: '/api/users',
    body: userData,
    headers: {
      Authorization: `Bearer ${Cypress.env('authToken')}`
    }
  }).then((response) => {
    expect(response.status).to.eq(201);
    cy.wrap(response.body).as('createdUser');
  });
});

Cypress.Commands.add('deleteUser', (userId: string) => {
  cy.request({
    method: 'DELETE',
    url: `/api/users/${userId}`,
    headers: {
      Authorization: `Bearer ${Cypress.env('authToken')}`
    }
  });
});

Cypress.Commands.add('waitForApiCall', (alias: string) => {
  cy.wait(alias).then((interception) => {
    expect(interception.response?.statusCode).to.be.oneOf([200, 201, 204]);
  });
});

Cypress.Commands.add('checkAccessibility', () => {
  cy.injectAxe();
  cy.checkA11y(null, null, (violations) => {
    violations.forEach((violation) => {
      cy.log(`Accessibility violation: ${violation.description}`);
      violation.nodes.forEach((node) => {
        cy.log(`Element: ${node.target}`);
      });
    });
  });
});
```

### Advanced Playwright Fixtures
```typescript
// tests/fixtures/test-fixtures.ts
import { test as base, Page } from '@playwright/test';
import { LoginPage } from '../pages/LoginPage';
import { UserManagementPage } from '../pages/UserManagementPage';
import { ApiClient } from '../utils/ApiClient';
import { TestDataManager } from '../utils/TestDataManager';

type TestFixtures = {
  loginPage: LoginPage;
  userManagementPage: UserManagementPage;
  apiClient: ApiClient;
  testDataManager: TestDataManager;
  authenticatedPage: Page;
};

export const test = base.extend<TestFixtures>({
  loginPage: async ({ page }, use) => {
    const loginPage = new LoginPage(page);
    await use(loginPage);
  },

  userManagementPage: async ({ page }, use) => {
    const userManagementPage = new UserManagementPage(page);
    await use(userManagementPage);
  },

  apiClient: async ({ request }, use) => {
    const apiClient = new ApiClient(request);
    await use(apiClient);
  },

  testDataManager: async ({}, use) => {
    const testDataManager = new TestDataManager();
    await use(testDataManager);
    await testDataManager.cleanup();
  },

  authenticatedPage: async ({ page, apiClient }, use) => {
    // Login via API to get token
    const token = await apiClient.login('admin@test.com', 'password123');
    
    // Set token in localStorage
    await page.addInitScript((token) => {
      localStorage.setItem('authToken', token);
    }, token);

    await page.goto('/dashboard');
    await use(page);
  }
});

export { expect } from '@playwright/test';
```

### Jest Setup com MSW (Mock Service Worker)
```typescript
// tests/setup/msw-setup.ts
import { setupServer } from 'msw/node';
import { rest } from 'msw';
import { handlers } from './handlers';

export const server = setupServer(...handlers);

// Setup MSW
beforeAll(() => {
  server.listen({ onUnhandledRequest: 'error' });
});

afterEach(() => {
  server.resetHandlers();
});

afterAll(() => {
  server.close();
});

// tests/setup/handlers.ts
import { rest } from 'msw';
import { TestDataFactory } from '../utils/TestDataFactory';

export const handlers = [
  // Users API
  rest.get('/api/users', (req, res, ctx) => {
    const users = TestDataFactory.createUsers(5);
    return res(ctx.json(users));
  }),

  rest.post('/api/users', (req, res, ctx) => {
    const userData = req.body as CreateUserDto;
    const user = TestDataFactory.createUser(userData);
    return res(ctx.status(201), ctx.json(user));
  }),

  rest.put('/api/users/:id', (req, res, ctx) => {
    const { id } = req.params;
    const userData = req.body as UpdateUserDto;
    const user = TestDataFactory.createUser({ id: id as string, ...userData });
    return res(ctx.json(user));
  }),

  rest.delete('/api/users/:id', (req, res, ctx) => {
    return res(ctx.status(204));
  }),

  // Auth API
  rest.post('/api/auth/login', (req, res, ctx) => {
    const { email, password } = req.body as LoginDto;
    
    if (email === 'admin@test.com' && password === 'password123') {
      return res(ctx.json({
        token: 'mock-jwt-token',
        user: TestDataFactory.createUser({ email, role: 'admin' })
      }));
    }
    
    return res(ctx.status(401), ctx.json({ message: 'Invalid credentials' }));
  }),

  // Error scenarios
  rest.get('/api/users/error', (req, res, ctx) => {
    return res(ctx.status(500), ctx.json({ message: 'Internal server error' }));
  })
];
```

### Visual Regression Testing
```typescript
// tests/visual/visual-regression.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Visual Regression Tests', () => {
  test('Homepage visual test', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    
    // Full page screenshot
    await expect(page).toHaveScreenshot('homepage-full.png', {
      fullPage: true,
      mask: [page.locator('.dynamic-content')]
    });
  });

  test('User form visual test', async ({ page }) => {
    await page.goto('/users/new');
    await page.waitForLoadState('networkidle');
    
    // Component screenshot
    await expect(page.locator('[data-testid=user-form]')).toHaveScreenshot('user-form.png');
  });

  test('Responsive design test', async ({ page }) => {
    // Mobile viewport
    await page.setViewportSize({ width: 375, height: 667 });
    await page.goto('/');
    await expect(page).toHaveScreenshot('homepage-mobile.png');

    // Tablet viewport
    await page.setViewportSize({ width: 768, height: 1024 });
    await page.goto('/');
    await expect(page).toHaveScreenshot('homepage-tablet.png');

    // Desktop viewport
    await page.setViewportSize({ width: 1920, height: 1080 });
    await page.goto('/');
    await expect(page).toHaveScreenshot('homepage-desktop.png');
  });
});
```

### Contract Testing com Pact
```typescript
// tests/contract/user-api.pact.spec.ts
import { Pact } from '@pact-foundation/pact';
import { UserService } from '../../src/services/UserService';

describe('User API Contract Tests', () => {
  const provider = new Pact({
    consumer: 'UserManagement-Frontend',
    provider: 'UserManagement-API',
    port: 1234,
    log: path.resolve(process.cwd(), 'logs', 'pact.log'),
    dir: path.resolve(process.cwd(), 'pacts'),
    logLevel: 'INFO'
  });

  beforeAll(() => provider.setup());
  afterEach(() => provider.verify());
  afterAll(() => provider.finalize());

  describe('GET /users', () => {
    beforeEach(() => {
      return provider.addInteraction({
        state: 'users exist',
        uponReceiving: 'a request for users',
        withRequest: {
          method: 'GET',
          path: '/api/users',
          headers: {
            Authorization: 'Bearer valid-token',
            Accept: 'application/json'
          }
        },
        willRespondWith: {
          status: 200,
          headers: {
            'Content-Type': 'application/json'
          },
          body: [
            {
              id: '1',
              name: 'John Doe',
              email: 'john@example.com',
              role: 'user',
              active: true
            }
          ]
        }
      });
    });

    it('should return users list', async () => {
      const userService = new UserService('http://localhost:1234');
      const users = await userService.getUsers();
      
      expect(users).toHaveLength(1);
      expect(users[0]).toMatchObject({
        id: '1',
        name: 'John Doe',
        email: 'john@example.com'
      });
    });
  });
});
```

### Performance Testing Avançado (K6)
```javascript
// tests/performance/load-test.js
import http from 'k6/http';
import { check, group, sleep } from 'k6';
import { Rate, Trend, Counter } from 'k6/metrics';

// Custom metrics
export let errorRate = new Rate('errors');
export let loginDuration = new Trend('login_duration');
export let userCreationRate = new Counter('user_creation_count');

// Test configuration
export let options = {
  stages: [
    { duration: '1m', target: 5 },   // Warm up
    { duration: '3m', target: 20 },  // Ramp up
    { duration: '5m', target: 50 },  // Load test
    { duration: '2m', target: 100 }, // Stress test
    { duration: '1m', target: 0 },   // Cool down
  ],
  thresholds: {
    errors: ['rate<0.05'],              // Error rate < 5%
    http_req_duration: ['p(95)<2000'],  // 95% requests < 2s
    login_duration: ['p(95)<1000'],     // 95% logins < 1s
    http_req_waiting: ['p(95)<1500'],   // 95% waiting time < 1.5s
  },
  ext: {
    loadimpact: {
      distribution: {
        'amazon:us:ashburn': { loadZone: 'amazon:us:ashburn', percent: 50 },
        'amazon:de:frankfurt': { loadZone: 'amazon:de:frankfurt', percent: 50 },
      },
    },
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000';

export function setup() {
  // Setup test data
  const adminToken = authenticateAdmin();
  return { adminToken };
}

export default function (data) {
  group('User Authentication Flow', () => {
    // Login scenario
    const loginStart = new Date();
    const loginResponse = http.post(`${BASE_URL}/api/auth/login`, {
      email: `user${__VU}@test.com`,
      password: 'password123'
    });

    const loginSuccess = check(loginResponse, {
      'login status is 200': (r) => r.status === 200,
      'login has token': (r) => JSON.parse(r.body).token !== undefined,
    });

    if (loginSuccess) {
      loginDuration.add(new Date() - loginStart);
      const token = JSON.parse(loginResponse.body).token;

      group('User Management Operations', () => {
        // Get users
        const getUsersResponse = http.get(`${BASE_URL}/api/users`, {
          headers: { Authorization: `Bearer ${token}` }
        });

        check(getUsersResponse, {
          'get users status is 200': (r) => r.status === 200,
          'users list is array': (r) => Array.isArray(JSON.parse(r.body)),
        });

        // Create user (some virtual users)
        if (__VU % 3 === 0) {
          const createUserResponse = http.post(`${BASE_URL}/api/users`, {
            name: `Test User ${__VU}-${__ITER}`,
            email: `testuser${__VU}-${__ITER}@example.com`,
            role: 'user'
          }, {
            headers: { 
              Authorization: `Bearer ${token}`,
              'Content-Type': 'application/json'
            }
          });

          const createSuccess = check(createUserResponse, {
            'create user status is 201': (r) => r.status === 201,
            'created user has id': (r) => JSON.parse(r.body).id !== undefined,
          });

          if (createSuccess) {
            userCreationRate.add(1);
          }
        }
      });
    }

    errorRate.add(!loginSuccess);
  });

  sleep(Math.random() * 2 + 1); // Random sleep between 1-3 seconds
}

export function teardown(data) {
  // Cleanup test data
  console.log('Cleaning up test data...');
}

function authenticateAdmin() {
  const response = http.post(`${BASE_URL}/api/auth/login`, {
    email: 'admin@test.com',
    password: 'admin123'
  });
  
  return JSON.parse(response.body).token;
}
```

### Accessibility Testing Automation
```typescript
// tests/accessibility/a11y.spec.ts
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test.describe('Accessibility Tests', () => {
  test('Homepage accessibility', async ({ page }) => {
    await page.goto('/');
    
    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa', 'wcag21aa'])
      .analyze();

    expect(accessibilityScanResults.violations).toEqual([]);
  });

  test('User form accessibility', async ({ page }) => {
    await page.goto('/users/new');
    
    const accessibilityScanResults = await new AxeBuilder({ page })
      .include('[data-testid=user-form]')
      .withTags(['wcag2a', 'wcag2aa'])
      .analyze();

    expect(accessibilityScanResults.violations).toEqual([]);
  });

  test('Keyboard navigation', async ({ page }) => {
    await page.goto('/users');
    
    // Test tab navigation
    await page.keyboard.press('Tab');
    await expect(page.locator('[data-testid=add-user-btn]')).toBeFocused();
    
    await page.keyboard.press('Tab');
    await expect(page.locator('[data-testid=search-input]')).toBeFocused();
    
    // Test Enter key activation
    await page.keyboard.press('Enter');
    await expect(page.locator('[data-testid=user-form]')).toBeVisible();
  });

  test('Screen reader compatibility', async ({ page }) => {
    await page.goto('/users');
    
    // Check ARIA labels
    await expect(page.locator('[data-testid=add-user-btn]')).toHaveAttribute('aria-label', 'Add new user');
    await expect(page.locator('[data-testid=search-input]')).toHaveAttribute('aria-label', 'Search users');
    
    // Check heading hierarchy
    const headings = page.locator('h1, h2, h3, h4, h5, h6');
    const headingLevels = await headings.evaluateAll(elements => 
      elements.map(el => parseInt(el.tagName.charAt(1)))
    );
    
    // Ensure heading hierarchy is logical
    for (let i = 1; i < headingLevels.length; i++) {
      expect(headingLevels[i] - headingLevels[i-1]).toBeLessThanOrEqual(1);
    }
  });
});
```

## Configurações de CI/CD para QA

### GitHub Actions Workflow
```yaml
# .github/workflows/qa-pipeline.yml
name: QA Pipeline

on:
  pull_request:
    branches: [ main, develop ]
  push:
    branches: [ main ]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
      - run: npm ci
      - run: npm run test:unit -- --coverage
      - uses: codecov/codecov-action@v3

  integration-tests:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:13
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
      - run: npm ci
      - run: npm run test:integration

  e2e-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
      - run: npm ci
      - run: npx playwright install --with-deps
      - run: npm run build
      - run: npm run test:e2e
      - uses: actions/upload-artifact@v3
        if: failure()
        with:
          name: playwright-report
          path: playwright-report/

  accessibility-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
      - run: npm ci
      - run: npm run test:a11y

  performance-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: grafana/k6-action@v0.2.0
        with:
          filename: tests/performance/load-test.js

  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm audit
      - uses: securecodewarrior/github-action-add-sarif@v1
        with:
          sarif-file: 'security-scan-results.sarif'
```

## Ferramentas e Comandos QA

### Setup Inicial
```bash
# Cypress
npm install --save-dev cypress @cypress/code-coverage cypress-axe

# Playwright
npm init playwright@latest

# Jest com Testing Library
npm install --save-dev jest @testing-library/react @testing-library/jest-dom

# K6 Performance Testing
brew install k6  # macOS
choco install k6  # Windows

# MSW para mocking
npm install --save-dev msw

# Pact para contract testing
npm install --save-dev @pact-foundation/pact
```

### Comandos de Execução
```bash
# Testes unitários
npm run test:unit
npm run test:unit:watch
npm run test:unit:coverage

# Testes de integração
npm run test:integration

# Testes E2E
npm run test:e2e
npm run test:e2e:headed
npm run test:e2e:debug

# Testes de acessibilidade
npm run test:a11y

# Testes de performance
k6 run tests/performance/load-test.js
k6 run --vus 100 --duration 5m tests/performance/stress-test.js

# Relatórios
npm run test:report
npm run coverage:report
npm run allure:generate
```

## Métricas e KPIs de QA

### Code Quality Metrics
- Test Coverage: >80%
- Mutation Testing Score: >70%
- Code Complexity: <10
- Duplication: <5%
- Technical Debt: <30min

### Test Execution Metrics
- Test Pass Rate: >95%
- Test Execution Time: <30min
- Flaky Test Rate: <2%
- Test Maintenance Effort: <20%

### Defect Metrics
- Defect Escape Rate: <5%
- Defect Removal Efficiency: >90%
- Time to Fix: <24h (critical), <1week (normal)
- Customer Reported Defects: <10/month

### Performance Metrics
- Response Time: <2s (95th percentile)
- Throughput: >1000 req/min
- Error Rate: <1%
- Resource Utilization: <80%
