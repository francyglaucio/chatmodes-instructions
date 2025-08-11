# Angular - Boas Práticas e Padrões

## Checklist de Desenvolvimento Angular

### Arquitetura e Estrutura
- [ ] Standalone Components implementados onde apropriado
- [ ] Lazy Loading de módulos configurado
- [ ] Feature modules bem organizados
- [ ] Shared modules para componentes comuns
- [ ] Core module para singletons
- [ ] Barrel exports para imports limpos

### Performance e Otimização
- [ ] OnPush Change Detection Strategy implementada
- [ ] TrackBy functions em *ngFor
- [ ] Lazy loading de imagens
- [ ] Tree shaking habilitado
- [ ] Bundle analyzer executado
- [ ] Service Workers para PWA
- [ ] Virtual scrolling para listas grandes

### State Management
- [ ] NgRx para estado global complexo
- [ ] Signals para estado local reativo
- [ ] RxJS operators usados corretamente
- [ ] Memory leaks prevenidos (unsubscribe)
- [ ] Async pipe preferido sobre subscribe manual

### Formulários e Validação
- [ ] Reactive Forms implementados
- [ ] Custom validators criados quando necessário
- [ ] FormBuilder usado para formulários complexos
- [ ] Error handling global para formulários
- [ ] Debounce em campos de busca

### Testes
- [ ] Testes unitários com boa cobertura (>80%)
- [ ] Testes de integração para componentes
- [ ] E2E testes para fluxos críticos
- [ ] Mocks apropriados para serviços
- [ ] TestBed configurado corretamente

## Templates de Código Angular

### Standalone Component Moderno
```typescript
import { Component, computed, signal, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatInputModule } from '@angular/material/input';
import { MatSnackBar } from '@angular/material/snack-bar';
import { UserService } from '../services/user.service';

@Component({
  selector: 'app-user-form',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    MatCardModule,
    MatButtonModule,
    MatInputModule
  ],
  template: `
    <mat-card>
      <mat-card-header>
        <mat-card-title>{{ title() }}</mat-card-title>
      </mat-card-header>
      
      <mat-card-content>
        <form [formGroup]="userForm" (ngSubmit)="onSubmit()">
          <mat-form-field>
            <mat-label>Name</mat-label>
            <input matInput formControlName="name" />
            @if (userForm.get('name')?.errors?.['required']) {
              <mat-error>Name is required</mat-error>
            }
          </mat-form-field>

          <mat-form-field>
            <mat-label>Email</mat-label>
            <input matInput type="email" formControlName="email" />
            @if (userForm.get('email')?.errors?.['required']) {
              <mat-error>Email is required</mat-error>
            }
            @if (userForm.get('email')?.errors?.['email']) {
              <mat-error>Invalid email format</mat-error>
            }
          </mat-form-field>

          <mat-card-actions>
            <button 
              mat-raised-button 
              color="primary" 
              type="submit"
              [disabled]="!userForm.valid || isLoading()">
              {{ submitButtonText() }}
            </button>
          </mat-card-actions>
        </form>
      </mat-card-content>
    </mat-card>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class UserFormComponent implements OnInit {
  private fb = inject(FormBuilder);
  private userService = inject(UserService);
  private snackBar = inject(MatSnackBar);

  // Signals para estado reativo
  isLoading = signal(false);
  editMode = signal(false);
  userId = signal<string | null>(null);

  // Computed properties
  title = computed(() => this.editMode() ? 'Edit User' : 'Create User');
  submitButtonText = computed(() => this.isLoading() ? 'Saving...' : this.editMode() ? 'Update' : 'Create');

  userForm = this.fb.group({
    name: ['', [Validators.required, Validators.minLength(2)]],
    email: ['', [Validators.required, Validators.email]]
  });

  ngOnInit() {
    // Load user data if in edit mode
    if (this.userId()) {
      this.loadUser(this.userId()!);
    }
  }

  private loadUser(id: string) {
    this.isLoading.set(true);
    this.userService.getUser(id).subscribe({
      next: (user) => {
        this.userForm.patchValue(user);
        this.editMode.set(true);
        this.isLoading.set(false);
      },
      error: (error) => {
        this.snackBar.open('Failed to load user', 'Close', { duration: 3000 });
        this.isLoading.set(false);
      }
    });
  }

  onSubmit() {
    if (!this.userForm.valid) return;

    this.isLoading.set(true);
    const formValue = this.userForm.value;

    const request = this.editMode() 
      ? this.userService.updateUser(this.userId()!, formValue)
      : this.userService.createUser(formValue);

    request.subscribe({
      next: () => {
        this.snackBar.open(
          `User ${this.editMode() ? 'updated' : 'created'} successfully`, 
          'Close', 
          { duration: 3000 }
        );
        this.isLoading.set(false);
        this.userForm.reset();
      },
      error: (error) => {
        this.snackBar.open('Operation failed', 'Close', { duration: 3000 });
        this.isLoading.set(false);
      }
    });
  }
}
```

### Service com RxJS e Error Handling
```typescript
import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams, HttpErrorResponse } from '@angular/common/http';
import { Observable, throwError, BehaviorSubject, of } from 'rxjs';
import { map, catchError, tap, retry, shareReplay, debounceTime, switchMap } from 'rxjs/operators';

export interface User {
  id: string;
  name: string;
  email: string;
  createdAt: string;
  updatedAt: string;
}

export interface PaginatedResponse<T> {
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    pages: number;
  };
}

@Injectable({
  providedIn: 'root'
})
export class UserService {
  private http = inject(HttpClient);
  private readonly apiUrl = '/api/users';
  
  // Cache for users list
  private usersCache$ = new BehaviorSubject<User[] | null>(null);
  
  getUsers(page = 1, limit = 10, search = ''): Observable<PaginatedResponse<User>> {
    let params = new HttpParams()
      .set('page', page.toString())
      .set('limit', limit.toString());
    
    if (search) {
      params = params.set('search', search);
    }

    return this.http.get<PaginatedResponse<User>>(this.apiUrl, { params }).pipe(
      tap(response => {
        // Update cache with new data
        this.usersCache$.next(response.data);
      }),
      retry(3),
      catchError(this.handleError),
      shareReplay(1)
    );
  }

  getUser(id: string): Observable<User> {
    // First check cache
    const cachedUsers = this.usersCache$.value;
    const cachedUser = cachedUsers?.find(user => user.id === id);
    
    if (cachedUser) {
      return of(cachedUser);
    }

    return this.http.get<User>(`${this.apiUrl}/${id}`).pipe(
      retry(3),
      catchError(this.handleError)
    );
  }

  createUser(userData: Omit<User, 'id' | 'createdAt' | 'updatedAt'>): Observable<User> {
    return this.http.post<User>(this.apiUrl, userData).pipe(
      tap(() => {
        // Invalidate cache
        this.usersCache$.next(null);
      }),
      catchError(this.handleError)
    );
  }

  updateUser(id: string, userData: Partial<User>): Observable<User> {
    return this.http.put<User>(`${this.apiUrl}/${id}`, userData).pipe(
      tap(updatedUser => {
        // Update cache
        const currentUsers = this.usersCache$.value;
        if (currentUsers) {
          const updatedUsers = currentUsers.map(user => 
            user.id === id ? updatedUser : user
          );
          this.usersCache$.next(updatedUsers);
        }
      }),
      catchError(this.handleError)
    );
  }

  deleteUser(id: string): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`).pipe(
      tap(() => {
        // Remove from cache
        const currentUsers = this.usersCache$.value;
        if (currentUsers) {
          const filteredUsers = currentUsers.filter(user => user.id !== id);
          this.usersCache$.next(filteredUsers);
        }
      }),
      catchError(this.handleError)
    );
  }

  // Search with debounce
  searchUsers(searchTerm$: Observable<string>): Observable<User[]> {
    return searchTerm$.pipe(
      debounceTime(300),
      switchMap(term => 
        term ? this.getUsers(1, 20, term).pipe(map(response => response.data)) : of([])
      )
    );
  }

  private handleError(error: HttpErrorResponse): Observable<never> {
    let errorMessage = 'An unknown error occurred';
    
    if (error.error instanceof ErrorEvent) {
      // Client-side error
      errorMessage = `Client Error: ${error.error.message}`;
    } else {
      // Server-side error
      switch (error.status) {
        case 400:
          errorMessage = 'Bad request - Invalid data provided';
          break;
        case 401:
          errorMessage = 'Unauthorized - Please log in again';
          break;
        case 403:
          errorMessage = 'Forbidden - You do not have permission';
          break;
        case 404:
          errorMessage = 'Not found - Resource does not exist';
          break;
        case 409:
          errorMessage = 'Conflict - Resource already exists';
          break;
        case 500:
          errorMessage = 'Server error - Please try again later';
          break;
        default:
          errorMessage = `Error ${error.status}: ${error.error?.message || 'Unknown error'}`;
      }
    }
    
    console.error('UserService Error:', error);
    return throwError(() => new Error(errorMessage));
  }
}
```

### Custom Validator
```typescript
import { AbstractControl, ValidationErrors, ValidatorFn } from '@angular/forms';

export class CustomValidators {
  static strongPassword(): ValidatorFn {
    return (control: AbstractControl): ValidationErrors | null => {
      const value = control.value;
      
      if (!value) {
        return null; // Don't validate empty values to allow optional controls
      }

      const hasNumber = /[0-9]/.test(value);
      const hasUpper = /[A-Z]/.test(value);
      const hasLower = /[a-z]/.test(value);
      const hasSpecial = /[#?!@$%^&*-]/.test(value);
      const isValidLength = value.length >= 8;

      const passwordValid = hasNumber && hasUpper && hasLower && hasSpecial && isValidLength;

      return passwordValid ? null : {
        strongPassword: {
          hasNumber,
          hasUpper,
          hasLower,
          hasSpecial,
          isValidLength
        }
      };
    };
  }

  static emailDomain(allowedDomains: string[]): ValidatorFn {
    return (control: AbstractControl): ValidationErrors | null => {
      const email = control.value;
      
      if (!email) {
        return null;
      }

      const domain = email.substring(email.lastIndexOf('@') + 1);
      
      return allowedDomains.includes(domain) ? null : {
        emailDomain: {
          actualDomain: domain,
          allowedDomains
        }
      };
    };
  }

  static asyncEmailExists(userService: any): any {
    return (control: AbstractControl) => {
      if (!control.value) {
        return of(null);
      }

      return userService.checkEmailExists(control.value).pipe(
        map((exists: boolean) => exists ? { emailExists: true } : null),
        catchError(() => of(null))
      );
    };
  }
}
```

## Comandos Angular CLI Essenciais

```bash
# Criar projeto com configurações modernas
ng new my-app --routing --style=scss --strict --standalone

# Componentes
ng generate component components/user-list --standalone --change-detection=OnPush
ng generate component components/user-form --standalone

# Services
ng generate service services/user --skip-tests=false
ng generate service services/auth

# Guards
ng generate guard guards/auth --implements=CanActivate
ng generate guard guards/role --implements=CanActivate

# Pipes
ng generate pipe pipes/currency-format
ng generate pipe pipes/date-ago

# Interceptors
ng generate interceptor interceptors/auth
ng generate interceptor interceptors/error

# Build e Deploy
ng build --configuration=production --aot --build-optimizer
ng build --configuration=production --source-map=false

# Análise de Bundle
ng build --stats-json
npx webpack-bundle-analyzer dist/stats.json

# Testes
ng test --watch=false --browsers=ChromeHeadless --code-coverage
ng e2e

# Linting e Formatting
ng lint
ng lint --fix
```

## Performance e Otimização

### Lazy Loading Strategy
```typescript
// app-routing.module.ts
const routes: Routes = [
  {
    path: 'users',
    loadComponent: () => import('./features/users/user-list.component').then(m => m.UserListComponent)
  },
  {
    path: 'admin',
    loadChildren: () => import('./features/admin/admin.module').then(m => m.AdminModule),
    canActivate: [AuthGuard, AdminGuard]
  }
];
```

### OnPush with Signals
```typescript
@Component({
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div>Count: {{ count() }}</div>
    <button (click)="increment()">+</button>
  `
})
export class CounterComponent {
  count = signal(0);
  
  increment() {
    this.count.update(value => value + 1);
  }
}
```

### Virtual Scrolling
```typescript
@Component({
  template: `
    <cdk-virtual-scroll-viewport itemSize="50" class="viewport">
      <div *cdkVirtualFor="let item of items; trackBy: trackByFn">{{item}}</div>
    </cdk-virtual-scroll-viewport>
  `
})
export class VirtualListComponent {
  trackByFn(index: number, item: any) {
    return item.id;
  }
}
```

## Microfrontends com Module Federation

### Configuração Webpack
```javascript
// webpack.config.js
const ModuleFederationPlugin = require('@module-federation/webpack');

module.exports = {
  plugins: [
    new ModuleFederationPlugin({
      name: 'shell',
      remotes: {
        mfeUsers: 'mfeUsers@http://localhost:4201/remoteEntry.js'
      },
      shared: {
        '@angular/core': { singleton: true, strictVersion: true },
        '@angular/common': { singleton: true, strictVersion: true },
        '@angular/router': { singleton: true, strictVersion: true }
      }
    })
  ]
};
```

### Dynamic Remote Loading
```typescript
import { loadRemoteModule } from '@angular-architects/module-federation';

const routes: Routes = [
  {
    path: 'users',
    loadChildren: () => loadRemoteModule({
      type: 'module',
      remoteEntry: 'http://localhost:4201/remoteEntry.js',
      exposedModule: './UsersModule'
    }).then(m => m.UsersModule)
  }
];
```
