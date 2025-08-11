# React - Boas Práticas e Padrões

## Checklist de Desenvolvimento React

### Arquitetura e Estrutura
- [ ] Componentes funcionais com hooks
- [ ] Custom hooks para lógica reutilizável
- [ ] Separação clara entre apresentação e lógica
- [ ] Estrutura de pastas por feature
- [ ] Barrel exports para imports limpos
- [ ] Prop types ou TypeScript interfaces

### Performance e Otimização
- [ ] React.memo para componentes puros
- [ ] useMemo para computações caras
- [ ] useCallback para funções estáveis
- [ ] Code splitting com React.lazy
- [ ] Bundle analyzer executado
- [ ] Virtualization para listas grandes
- [ ] Debounce em inputs de busca

### State Management
- [ ] useState para estado local
- [ ] useReducer para estado complexo
- [ ] Context API para estado global
- [ ] Redux Toolkit para aplicações grandes
- [ ] Zustand como alternativa leve
- [ ] React Query para estado servidor

### Error Handling
- [ ] Error Boundaries implementadas
- [ ] Try-catch em async operations
- [ ] Loading e error states
- [ ] Toast/notification system
- [ ] Fallback UI para componentes

### Testes
- [ ] Testes unitários com React Testing Library
- [ ] Testes de integração para fluxos
- [ ] E2E testes para cenários críticos
- [ ] Mocks apropriados para APIs
- [ ] Coverage > 80%

## Templates de Código React

### Component com Hooks Modernos
```tsx
import React, { useState, useEffect, useCallback, useMemo } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { toast } from 'react-hot-toast';

interface User {
  id: string;
  name: string;
  email: string;
  role: 'admin' | 'user';
  createdAt: string;
}

interface UserListProps {
  filter?: string;
  onUserSelect?: (user: User) => void;
}

export const UserList: React.FC<UserListProps> = ({ 
  filter = '', 
  onUserSelect 
}) => {
  const [selectedUserId, setSelectedUserId] = useState<string | null>(null);
  const [page, setPage] = useState(1);
  const queryClient = useQueryClient();

  // Query for users
  const { 
    data: usersData, 
    isLoading, 
    error,
    refetch 
  } = useQuery({
    queryKey: ['users', page, filter],
    queryFn: () => fetchUsers({ page, filter }),
    staleTime: 5 * 60 * 1000, // 5 minutes
    retry: 3,
    retryDelay: (attemptIndex) => Math.min(1000 * 2 ** attemptIndex, 30000),
  });

  // Mutation for deleting user
  const deleteUserMutation = useMutation({
    mutationFn: deleteUser,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
      toast.success('User deleted successfully');
      setSelectedUserId(null);
    },
    onError: (error: Error) => {
      toast.error(`Failed to delete user: ${error.message}`);
    },
  });

  // Memoized filtered users
  const filteredUsers = useMemo(() => {
    if (!usersData?.data) return [];
    return usersData.data.filter(user => 
      user.name.toLowerCase().includes(filter.toLowerCase()) ||
      user.email.toLowerCase().includes(filter.toLowerCase())
    );
  }, [usersData?.data, filter]);

  // Callbacks
  const handleUserClick = useCallback((user: User) => {
    setSelectedUserId(user.id);
    onUserSelect?.(user);
  }, [onUserSelect]);

  const handleDeleteUser = useCallback(async (userId: string) => {
    if (window.confirm('Are you sure you want to delete this user?')) {
      deleteUserMutation.mutate(userId);
    }
  }, [deleteUserMutation]);

  const handleRetry = useCallback(() => {
    refetch();
  }, [refetch]);

  // Effects
  useEffect(() => {
    // Reset selection when filter changes
    setSelectedUserId(null);
  }, [filter]);

  if (isLoading) {
    return <LoadingSpinner />;
  }

  if (error) {
    return (
      <ErrorMessage 
        message="Failed to load users" 
        onRetry={handleRetry}
      />
    );
  }

  return (
    <div className="user-list">
      <div className="user-list__header">
        <h2>Users ({filteredUsers.length})</h2>
        <Pagination
          currentPage={page}
          totalPages={usersData?.pagination.pages || 1}
          onPageChange={setPage}
        />
      </div>

      <div className="user-list__grid">
        {filteredUsers.map(user => (
          <UserCard
            key={user.id}
            user={user}
            isSelected={selectedUserId === user.id}
            onClick={() => handleUserClick(user)}
            onDelete={() => handleDeleteUser(user.id)}
            isDeleting={deleteUserMutation.isPending && deleteUserMutation.variables === user.id}
          />
        ))}
      </div>

      {filteredUsers.length === 0 && (
        <EmptyState message="No users found" />
      )}
    </div>
  );
};

// Memoized sub-component
const UserCard = React.memo<{
  user: User;
  isSelected: boolean;
  onClick: () => void;
  onDelete: () => void;
  isDeleting: boolean;
}>(({ user, isSelected, onClick, onDelete, isDeleting }) => {
  return (
    <div 
      className={`user-card ${isSelected ? 'user-card--selected' : ''}`}
      onClick={onClick}
    >
      <div className="user-card__avatar">
        <img src={`/avatars/${user.id}.jpg`} alt={user.name} />
      </div>
      
      <div className="user-card__content">
        <h3>{user.name}</h3>
        <p>{user.email}</p>
        <span className={`badge badge--${user.role}`}>
          {user.role}
        </span>
      </div>
      
      <div className="user-card__actions">
        <button
          onClick={(e) => {
            e.stopPropagation();
            onDelete();
          }}
          disabled={isDeleting}
          className="btn btn--danger btn--small"
        >
          {isDeleting ? 'Deleting...' : 'Delete'}
        </button>
      </div>
    </div>
  );
});

UserCard.displayName = 'UserCard';
```

### Custom Hook para Data Fetching
```tsx
import { useState, useEffect, useCallback, useRef } from 'react';

interface UseApiOptions<T> {
  initialData?: T;
  enabled?: boolean;
  refetchInterval?: number;
  onSuccess?: (data: T) => void;
  onError?: (error: Error) => void;
}

interface UseApiReturn<T> {
  data: T | undefined;
  loading: boolean;
  error: Error | null;
  refetch: () => Promise<void>;
  mutate: (newData: T) => void;
}

export function useApi<T>(
  apiCall: () => Promise<T>,
  dependencies: any[] = [],
  options: UseApiOptions<T> = {}
): UseApiReturn<T> {
  const [data, setData] = useState<T | undefined>(options.initialData);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  
  const abortControllerRef = useRef<AbortController | null>(null);
  const isMountedRef = useRef(true);

  const execute = useCallback(async () => {
    // Cancel previous request
    if (abortControllerRef.current) {
      abortControllerRef.current.abort();
    }

    abortControllerRef.current = new AbortController();
    
    try {
      setLoading(true);
      setError(null);
      
      const result = await apiCall();
      
      if (isMountedRef.current) {
        setData(result);
        options.onSuccess?.(result);
      }
    } catch (err) {
      if (err instanceof Error && err.name !== 'AbortError' && isMountedRef.current) {
        const error = err instanceof Error ? err : new Error('Unknown error');
        setError(error);
        options.onError?.(error);
      }
    } finally {
      if (isMountedRef.current) {
        setLoading(false);
      }
    }
  }, [apiCall, options.onSuccess, options.onError]);

  const mutate = useCallback((newData: T) => {
    setData(newData);
  }, []);

  // Execute on mount and dependency changes
  useEffect(() => {
    if (options.enabled !== false) {
      execute();
    }
  }, [...dependencies, options.enabled]);

  // Refetch interval
  useEffect(() => {
    if (options.refetchInterval && options.enabled !== false) {
      const interval = setInterval(execute, options.refetchInterval);
      return () => clearInterval(interval);
    }
  }, [execute, options.refetchInterval, options.enabled]);

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      isMountedRef.current = false;
      if (abortControllerRef.current) {
        abortControllerRef.current.abort();
      }
    };
  }, []);

  return {
    data,
    loading,
    error,
    refetch: execute,
    mutate
  };
}

// Usage example
const UserProfile = ({ userId }: { userId: string }) => {
  const { data: user, loading, error, refetch } = useApi(
    () => fetchUser(userId),
    [userId],
    {
      onSuccess: (user) => console.log('User loaded:', user.name),
      onError: (error) => console.error('Failed to load user:', error)
    }
  );

  if (loading) return <div>Loading...</div>;
  if (error) return <ErrorMessage error={error} onRetry={refetch} />;
  if (!user) return <div>User not found</div>;

  return <div>Welcome, {user.name}!</div>;
};
```

### Context API com TypeScript
```tsx
import React, { createContext, useContext, useReducer, ReactNode, useCallback } from 'react';

// Types
interface User {
  id: string;
  name: string;
  email: string;
  role: string;
}

interface AppState {
  user: User | null;
  theme: 'light' | 'dark';
  notifications: Notification[];
  loading: boolean;
}

interface Notification {
  id: string;
  type: 'success' | 'error' | 'warning' | 'info';
  message: string;
  autoClose?: boolean;
}

type AppAction = 
  | { type: 'SET_USER'; payload: User | null }
  | { type: 'SET_LOADING'; payload: boolean }
  | { type: 'TOGGLE_THEME' }
  | { type: 'ADD_NOTIFICATION'; payload: Omit<Notification, 'id'> }
  | { type: 'REMOVE_NOTIFICATION'; payload: string }
  | { type: 'CLEAR_NOTIFICATIONS' };

// Initial state
const initialState: AppState = {
  user: null,
  theme: 'light',
  notifications: [],
  loading: false
};

// Reducer
function appReducer(state: AppState, action: AppAction): AppState {
  switch (action.type) {
    case 'SET_USER':
      return { ...state, user: action.payload };
    
    case 'SET_LOADING':
      return { ...state, loading: action.payload };
    
    case 'TOGGLE_THEME':
      return { ...state, theme: state.theme === 'light' ? 'dark' : 'light' };
    
    case 'ADD_NOTIFICATION':
      return {
        ...state,
        notifications: [
          ...state.notifications,
          { ...action.payload, id: generateId() }
        ]
      };
    
    case 'REMOVE_NOTIFICATION':
      return {
        ...state,
        notifications: state.notifications.filter(n => n.id !== action.payload)
      };
    
    case 'CLEAR_NOTIFICATIONS':
      return { ...state, notifications: [] };
    
    default:
      return state;
  }
}

// Context type
interface AppContextType {
  state: AppState;
  actions: {
    setUser: (user: User | null) => void;
    setLoading: (loading: boolean) => void;
    toggleTheme: () => void;
    addNotification: (notification: Omit<Notification, 'id'>) => void;
    removeNotification: (id: string) => void;
    clearNotifications: () => void;
  };
}

// Create context
const AppContext = createContext<AppContextType | undefined>(undefined);

// Provider component
export const AppProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [state, dispatch] = useReducer(appReducer, initialState);

  // Actions
  const setUser = useCallback((user: User | null) => {
    dispatch({ type: 'SET_USER', payload: user });
  }, []);

  const setLoading = useCallback((loading: boolean) => {
    dispatch({ type: 'SET_LOADING', payload: loading });
  }, []);

  const toggleTheme = useCallback(() => {
    dispatch({ type: 'TOGGLE_THEME' });
  }, []);

  const addNotification = useCallback((notification: Omit<Notification, 'id'>) => {
    dispatch({ type: 'ADD_NOTIFICATION', payload: notification });
    
    // Auto-remove notification after 5 seconds if autoClose is true
    if (notification.autoClose !== false) {
      setTimeout(() => {
        dispatch({ type: 'REMOVE_NOTIFICATION', payload: notification.id });
      }, 5000);
    }
  }, []);

  const removeNotification = useCallback((id: string) => {
    dispatch({ type: 'REMOVE_NOTIFICATION', payload: id });
  }, []);

  const clearNotifications = useCallback(() => {
    dispatch({ type: 'CLEAR_NOTIFICATIONS' });
  }, []);

  const value = {
    state,
    actions: {
      setUser,
      setLoading,
      toggleTheme,
      addNotification,
      removeNotification,
      clearNotifications
    }
  };

  return (
    <AppContext.Provider value={value}>
      {children}
    </AppContext.Provider>
  );
};

// Hook to use context
export const useApp = () => {
  const context = useContext(AppContext);
  if (context === undefined) {
    throw new Error('useApp must be used within an AppProvider');
  }
  return context;
};

// Helper function
function generateId(): string {
  return Math.random().toString(36).substr(2, 9);
}

// Usage example
const App = () => {
  return (
    <AppProvider>
      <MainApp />
    </AppProvider>
  );
};

const MainApp = () => {
  const { state, actions } = useApp();

  const handleLogin = async (credentials: any) => {
    actions.setLoading(true);
    try {
      const user = await login(credentials);
      actions.setUser(user);
      actions.addNotification({
        type: 'success',
        message: 'Login successful!',
        autoClose: true
      });
    } catch (error) {
      actions.addNotification({
        type: 'error',
        message: 'Login failed. Please try again.',
        autoClose: true
      });
    } finally {
      actions.setLoading(false);
    }
  };

  return (
    <div className={`app app--${state.theme}`}>
      {/* App content */}
    </div>
  );
};
```

### Error Boundary
```tsx
import React, { Component, ErrorInfo, ReactNode } from 'react';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
  onError?: (error: Error, errorInfo: ErrorInfo) => void;
}

interface State {
  hasError: boolean;
  error?: Error;
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('ErrorBoundary caught an error:', error, errorInfo);
    this.props.onError?.(error, errorInfo);
    
    // Report to error tracking service
    // reportError(error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback || (
        <div className="error-boundary">
          <h2>Something went wrong</h2>
          <p>We're sorry, but something unexpected happened.</p>
          <button onClick={() => this.setState({ hasError: false })}>
            Try again
          </button>
        </div>
      );
    }

    return this.props.children;
  }
}

// Hook version for functional components (experimental)
export function useErrorBoundary() {
  const [error, setError] = React.useState<Error | null>(null);

  const resetError = React.useCallback(() => {
    setError(null);
  }, []);

  const captureError = React.useCallback((error: Error) => {
    setError(error);
  }, []);

  if (error) {
    throw error;
  }

  return { captureError, resetError };
}
```

## Testing com React Testing Library

### Component Tests
```tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { UserList } from './UserList';

// Mock API
const mockUsers = [
  { id: '1', name: 'John Doe', email: 'john@example.com', role: 'user' },
  { id: '2', name: 'Jane Smith', email: 'jane@example.com', role: 'admin' }
];

jest.mock('../api/users', () => ({
  fetchUsers: jest.fn(() => Promise.resolve({ 
    data: mockUsers, 
    pagination: { page: 1, pages: 1, total: 2 } 
  })),
  deleteUser: jest.fn(() => Promise.resolve())
}));

// Test wrapper
function renderWithProviders(ui: React.ReactElement) {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
      mutations: { retry: false }
    }
  });

  return render(
    <QueryClientProvider client={queryClient}>
      {ui}
    </QueryClientProvider>
  );
}

describe('UserList', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders users list', async () => {
    renderWithProviders(<UserList />);

    expect(screen.getByText('Loading...')).toBeInTheDocument();

    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument();
      expect(screen.getByText('Jane Smith')).toBeInTheDocument();
    });
  });

  it('filters users by search term', async () => {
    renderWithProviders(<UserList filter="john" />);

    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument();
      expect(screen.queryByText('Jane Smith')).not.toBeInTheDocument();
    });
  });

  it('handles user selection', async () => {
    const onUserSelect = jest.fn();
    renderWithProviders(<UserList onUserSelect={onUserSelect} />);

    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument();
    });

    fireEvent.click(screen.getByText('John Doe'));
    expect(onUserSelect).toHaveBeenCalledWith(mockUsers[0]);
  });

  it('handles user deletion with confirmation', async () => {
    const user = userEvent.setup();
    
    // Mock window.confirm
    const confirmSpy = jest.spyOn(window, 'confirm').mockReturnValue(true);
    
    renderWithProviders(<UserList />);

    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument();
    });

    const deleteButton = screen.getAllByText('Delete')[0];
    await user.click(deleteButton);

    expect(confirmSpy).toHaveBeenCalledWith('Are you sure you want to delete this user?');
    
    confirmSpy.mockRestore();
  });
});
```

### Custom Hook Tests
```tsx
import { renderHook, waitFor } from '@testing-library/react';
import { useApi } from './useApi';

describe('useApi', () => {
  it('should fetch data successfully', async () => {
    const mockData = { id: 1, name: 'Test' };
    const mockApiCall = jest.fn(() => Promise.resolve(mockData));

    const { result } = renderHook(() => useApi(mockApiCall));

    expect(result.current.loading).toBe(true);

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
      expect(result.current.data).toEqual(mockData);
      expect(result.current.error).toBe(null);
    });
  });

  it('should handle errors', async () => {
    const mockError = new Error('API Error');
    const mockApiCall = jest.fn(() => Promise.reject(mockError));

    const { result } = renderHook(() => useApi(mockApiCall));

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
      expect(result.current.error).toEqual(mockError);
      expect(result.current.data).toBeUndefined();
    });
  });

  it('should refetch data', async () => {
    const mockData = { id: 1, name: 'Test' };
    const mockApiCall = jest.fn(() => Promise.resolve(mockData));

    const { result } = renderHook(() => useApi(mockApiCall));

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });

    expect(mockApiCall).toHaveBeenCalledTimes(1);

    await result.current.refetch();

    expect(mockApiCall).toHaveBeenCalledTimes(2);
  });
});
```

## Comandos React Essenciais

```bash
# Criar projeto
npx create-react-app my-app --template typescript
npm create vite@latest my-app -- --template react-ts

# Dependências essenciais
npm install @tanstack/react-query axios react-router-dom
npm install -D @testing-library/react @testing-library/jest-dom @testing-library/user-event

# Build e Deploy
npm run build
npm run preview

# Testes
npm test
npm run test:coverage

# Linting
npm run lint
npm run lint:fix

# Análise de Bundle
npm install -g source-map-explorer
npm run build && npx source-map-explorer 'build/static/js/*.js'

# Storybook
npx storybook init
npm run storybook
```

## Microfrontends com Module Federation

### Webpack Configuration
```javascript
// webpack.config.js
const ModuleFederationPlugin = require('@module-federation/webpack');

module.exports = {
  plugins: [
    new ModuleFederationPlugin({
      name: 'shell',
      filename: 'remoteEntry.js',
      remotes: {
        userApp: 'userApp@http://localhost:3001/remoteEntry.js'
      },
      shared: {
        react: { singleton: true, requiredVersion: '^18.0.0' },
        'react-dom': { singleton: true, requiredVersion: '^18.0.0' }
      }
    })
  ]
};
```

### Dynamic Imports
```tsx
import React, { Suspense } from 'react';

const UserApp = React.lazy(() => import('userApp/App'));

export const Shell = () => {
  return (
    <div>
      <nav>Navigation</nav>
      <main>
        <Suspense fallback={<div>Loading...</div>}>
          <UserApp />
        </Suspense>
      </main>
    </div>
  );
};
```
