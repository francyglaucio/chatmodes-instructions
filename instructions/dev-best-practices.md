# Boas Práticas de Desenvolvimento

## Checklist de Code Review

### Clean Code
- [ ] Nomes de variáveis e funções são descritivos
- [ ] Funções têm responsabilidade única
- [ ] Código está bem estruturado e organizado
- [ ] Comentários explicam o "por quê", não o "como"
- [ ] Não há código comentado/morto
- [ ] Magic numbers foram substituídos por constantes

### Performance
- [ ] Loops desnecessários foram evitados
- [ ] Database queries são eficientes
- [ ] Lazy loading implementado onde apropriado
- [ ] Bundle size está otimizado
- [ ] Imagens e assets estão comprimidos
- [ ] Caching implementado adequadamente

### Segurança
- [ ] Inputs são validados e sanitizados
- [ ] Senhas não estão hardcoded
- [ ] SQL injection prevenida
- [ ] XSS protection implementada
- [ ] CORS configurado corretamente
- [ ] Rate limiting implementado em APIs

### Testes
- [ ] Cobertura de testes adequada (>80%)
- [ ] Testes unitários para lógica de negócio
- [ ] Testes de integração para APIs
- [ ] Edge cases estão cobertos
- [ ] Testes são independentes e determinísticos
- [ ] Mocks são usados apropriadamente

### Accessibility (a11y)
- [ ] Alt text em imagens
- [ ] Keyboard navigation funciona
- [ ] Color contrast adequado
- [ ] ARIA labels implementados
- [ ] Screen reader compatibility
- [ ] Focus management correto

## Templates de Código

### React Component (TypeScript)
```tsx
import React, { useState, useEffect } from 'react';

interface UserProfileProps {
  userId: string;
  onUpdate?: (user: User) => void;
}

interface User {
  id: string;
  name: string;
  email: string;
}

export const UserProfile: React.FC<UserProfileProps> = ({ 
  userId, 
  onUpdate 
}) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchUser = async () => {
      try {
        setLoading(true);
        const response = await fetch(`/api/users/${userId}`);
        
        if (!response.ok) {
          throw new Error('Failed to fetch user');
        }
        
        const userData = await response.json();
        setUser(userData);
        onUpdate?.(userData);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Unknown error');
      } finally {
        setLoading(false);
      }
    };

    fetchUser();
  }, [userId, onUpdate]);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;
  if (!user) return <div>User not found</div>;

  return (
    <div className="user-profile">
      <h2>{user.name}</h2>
      <p>{user.email}</p>
    </div>
  );
};
```

### API Route (Node.js + Express)
```javascript
import express from 'express';
import { body, validationResult } from 'express-validator';
import rateLimit from 'express-rate-limit';

const router = express.Router();

// Rate limiting
const createUserLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // limit each IP to 5 requests per windowMs
  message: 'Too many accounts created from this IP'
});

// Validation middleware
const validateUser = [
  body('email').isEmail().normalizeEmail(),
  body('name').isLength({ min: 2, max: 50 }).trim(),
  body('password').isLength({ min: 8 }).matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
];

// Error handler
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      errors: errors.array()
    });
  }
  next();
};

// Create user endpoint
router.post('/users', 
  createUserLimiter,
  validateUser,
  handleValidationErrors,
  async (req, res) => {
    try {
      const { email, name, password } = req.body;
      
      // Check if user already exists
      const existingUser = await User.findOne({ email });
      if (existingUser) {
        return res.status(409).json({
          success: false,
          message: 'User already exists'
        });
      }
      
      // Hash password
      const hashedPassword = await bcrypt.hash(password, 12);
      
      // Create user
      const user = await User.create({
        email,
        name,
        password: hashedPassword
      });
      
      // Remove password from response
      const { password: _, ...userWithoutPassword } = user.toObject();
      
      res.status(201).json({
        success: true,
        data: userWithoutPassword
      });
      
    } catch (error) {
      console.error('Create user error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }
);

export default router;
```

### Test Example (Jest + Testing Library)
```javascript
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { UserProfile } from './UserProfile';

// Mock fetch
global.fetch = jest.fn();

describe('UserProfile', () => {
  beforeEach(() => {
    fetch.mockClear();
  });

  it('displays loading state initially', () => {
    fetch.mockImplementation(() => 
      Promise.resolve({
        ok: true,
        json: () => Promise.resolve({ id: '1', name: 'John', email: 'john@example.com' })
      })
    );

    render(<UserProfile userId="1" />);
    expect(screen.getByText('Loading...')).toBeInTheDocument();
  });

  it('displays user data after successful fetch', async () => {
    const mockUser = { id: '1', name: 'John Doe', email: 'john@example.com' };
    
    fetch.mockImplementation(() => 
      Promise.resolve({
        ok: true,
        json: () => Promise.resolve(mockUser)
      })
    );

    render(<UserProfile userId="1" />);
    
    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument();
      expect(screen.getByText('john@example.com')).toBeInTheDocument();
    });
  });

  it('displays error message when fetch fails', async () => {
    fetch.mockImplementation(() => 
      Promise.resolve({
        ok: false,
        status: 404
      })
    );

    render(<UserProfile userId="1" />);
    
    await waitFor(() => {
      expect(screen.getByText(/Error:/)).toBeInTheDocument();
    });
  });

  it('calls onUpdate callback when user is loaded', async () => {
    const mockUser = { id: '1', name: 'John Doe', email: 'john@example.com' };
    const onUpdateMock = jest.fn();
    
    fetch.mockImplementation(() => 
      Promise.resolve({
        ok: true,
        json: () => Promise.resolve(mockUser)
      })
    );

    render(<UserProfile userId="1" onUpdate={onUpdateMock} />);
    
    await waitFor(() => {
      expect(onUpdateMock).toHaveBeenCalledWith(mockUser);
    });
  });
});
```

## Comandos Úteis

### Git Workflow
```bash
# Feature branch workflow
git checkout -b feature/user-profile
git add .
git commit -m "feat: add user profile component"
git push -u origin feature/user-profile

# Code review e merge
git checkout main
git pull origin main
git merge feature/user-profile
git push origin main
git branch -d feature/user-profile
```

### Testing
```bash
# Run tests
npm test

# Test coverage
npm run test:coverage

# Watch mode
npm run test:watch

# E2E tests
npm run test:e2e
```

### Development
```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Lint code
npm run lint

# Format code
npm run format
```
