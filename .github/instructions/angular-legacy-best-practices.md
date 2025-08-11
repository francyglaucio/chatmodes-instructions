# Angular Legacy (8-14) - Boas Práticas e Padrões

## Checklist de Desenvolvimento Angular Legacy

### Arquitetura e Estrutura
- [ ] NgModules bem organizados (Feature, Shared, Core)
- [ ] Lazy Loading de módulos implementado
- [ ] Barrel exports para organização
- [ ] OnPush Change Detection Strategy aplicada
- [ ] Services com Dependency Injection
- [ ] Guards e Resolvers para roteamento
- [ ] Interceptors para HTTP

### Formulários e Validação
- [ ] Reactive Forms com FormBuilder
- [ ] Custom Validators implementados
- [ ] Error handling centralizado
- [ ] FormGroup e FormArray adequados
- [ ] Validators síncronos e assíncronos
- [ ] Cross-field validation

### Performance e Otimização
- [ ] OnPush strategy onde aplicável
- [ ] TrackBy functions em *ngFor
- [ ] Async pipe utilizado
- [ ] Subscription management (takeUntil pattern)
- [ ] Bundle optimization configurado
- [ ] Tree-shaking habilitado

### Testing
- [ ] Unit tests com Jasmine/Jest
- [ ] TestBed configuration adequada
- [ ] Mocks e spies apropriados
- [ ] Component testing
- [ ] Service testing
- [ ] Integration tests

### RxJS e Programação Reativa
- [ ] Operators adequados utilizados
- [ ] Memory leaks prevenidos
- [ ] Subject/BehaviorSubject para state
- [ ] Error handling com catchError
- [ ] Composition de observables

## Templates de Código Angular Legacy

### Arquitetura de Módulos Clássica
```typescript
// core/core.module.ts
import { NgModule, Optional, SkipSelf } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HTTP_INTERCEPTORS, HttpClientModule } from '@angular/common/http';

import { AuthService } from './services/auth.service';
import { ApiService } from './services/api.service';
import { NotificationService } from './services/notification.service';
import { AuthInterceptor } from './interceptors/auth.interceptor';
import { ErrorInterceptor } from './interceptors/error.interceptor';
import { LoadingInterceptor } from './interceptors/loading.interceptor';

@NgModule({
  imports: [
    CommonModule,
    HttpClientModule
  ],
  providers: [
    AuthService,
    ApiService,
    NotificationService,
    {
      provide: HTTP_INTERCEPTORS,
      useClass: AuthInterceptor,
      multi: true
    },
    {
      provide: HTTP_INTERCEPTORS,
      useClass: ErrorInterceptor,
      multi: true
    },
    {
      provide: HTTP_INTERCEPTORS,
      useClass: LoadingInterceptor,
      multi: true
    }
  ]
})
export class CoreModule {
  constructor(@Optional() @SkipSelf() parentModule: CoreModule) {
    if (parentModule) {
      throw new Error('CoreModule is already loaded. Import it in the AppModule only');
    }
  }
}

// shared/shared.module.ts
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';

// Angular Material
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatTableModule } from '@angular/material/table';
import { MatPaginatorModule } from '@angular/material/paginator';
import { MatSortModule } from '@angular/material/sort';
import { MatIconModule } from '@angular/material/icon';
import { MatDialogModule } from '@angular/material/dialog';
import { MatSnackBarModule } from '@angular/material/snack-bar';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatListModule } from '@angular/material/list';

// Custom Components
import { LoadingSpinnerComponent } from './components/loading-spinner/loading-spinner.component';
import { ConfirmDialogComponent } from './components/confirm-dialog/confirm-dialog.component';
import { ErrorDisplayComponent } from './components/error-display/error-display.component';

// Pipes
import { TruncatePipe } from './pipes/truncate.pipe';
import { SafeHtmlPipe } from './pipes/safe-html.pipe';

// Directives
import { HighlightDirective } from './directives/highlight.directive';
import { ClickOutsideDirective } from './directives/click-outside.directive';

const MATERIAL_MODULES = [
  MatButtonModule,
  MatCardModule,
  MatFormFieldModule,
  MatInputModule,
  MatSelectModule,
  MatTableModule,
  MatPaginatorModule,
  MatSortModule,
  MatIconModule,
  MatDialogModule,
  MatSnackBarModule,
  MatProgressSpinnerModule,
  MatToolbarModule,
  MatSidenavModule,
  MatListModule
];

const COMPONENTS = [
  LoadingSpinnerComponent,
  ConfirmDialogComponent,
  ErrorDisplayComponent
];

const PIPES = [
  TruncatePipe,
  SafeHtmlPipe
];

const DIRECTIVES = [
  HighlightDirective,
  ClickOutsideDirective
];

@NgModule({
  declarations: [
    ...COMPONENTS,
    ...PIPES,
    ...DIRECTIVES
  ],
  imports: [
    CommonModule,
    FormsModule,
    ReactiveFormsModule,
    RouterModule,
    ...MATERIAL_MODULES
  ],
  exports: [
    CommonModule,
    FormsModule,
    ReactiveFormsModule,
    RouterModule,
    ...MATERIAL_MODULES,
    ...COMPONENTS,
    ...PIPES,
    ...DIRECTIVES
  ]
})
export class SharedModule { }
```

### Service com State Management (Angular Legacy)
```typescript
// services/user-state.service.ts
import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable, combineLatest } from 'rxjs';
import { map, distinctUntilChanged, shareReplay } from 'rxjs/operators';
import { User } from '../models/user.model';

export interface UserState {
  users: User[];
  selectedUser: User | null;
  loading: boolean;
  error: string | null;
  filters: {
    search: string;
    role: string;
    status: string;
  };
  pagination: {
    page: number;
    size: number;
    total: number;
  };
}

const initialState: UserState = {
  users: [],
  selectedUser: null,
  loading: false,
  error: null,
  filters: {
    search: '',
    role: '',
    status: 'active'
  },
  pagination: {
    page: 1,
    size: 10,
    total: 0
  }
};

@Injectable({
  providedIn: 'root'
})
export class UserStateService {
  private readonly state$ = new BehaviorSubject<UserState>(initialState);

  // Selectors
  readonly users$ = this.select(state => state.users);
  readonly selectedUser$ = this.select(state => state.selectedUser);
  readonly loading$ = this.select(state => state.loading);
  readonly error$ = this.select(state => state.error);
  readonly filters$ = this.select(state => state.filters);
  readonly pagination$ = this.select(state => state.pagination);

  // Computed selectors
  readonly filteredUsers$ = combineLatest([
    this.users$,
    this.filters$
  ]).pipe(
    map(([users, filters]) => this.filterUsers(users, filters)),
    shareReplay(1)
  );

  readonly hasUsers$ = this.users$.pipe(
    map(users => users.length > 0),
    distinctUntilChanged()
  );

  readonly isFirstPage$ = this.pagination$.pipe(
    map(pagination => pagination.page === 1),
    distinctUntilChanged()
  );

  readonly isLastPage$ = combineLatest([
    this.pagination$,
    this.filteredUsers$
  ]).pipe(
    map(([pagination, users]) => 
      pagination.page * pagination.size >= users.length
    ),
    distinctUntilChanged()
  );

  constructor() {}

  // Actions
  setUsers(users: User[]): void {
    this.updateState({ users });
  }

  addUser(user: User): void {
    const currentUsers = this.getState().users;
    this.updateState({ users: [...currentUsers, user] });
  }

  updateUser(updatedUser: User): void {
    const currentUsers = this.getState().users;
    const users = currentUsers.map(user => 
      user.id === updatedUser.id ? updatedUser : user
    );
    this.updateState({ users });
  }

  removeUser(userId: string): void {
    const currentUsers = this.getState().users;
    const users = currentUsers.filter(user => user.id !== userId);
    this.updateState({ users });
  }

  setSelectedUser(user: User | null): void {
    this.updateState({ selectedUser: user });
  }

  setLoading(loading: boolean): void {
    this.updateState({ loading });
  }

  setError(error: string | null): void {
    this.updateState({ error });
  }

  updateFilters(filters: Partial<UserState['filters']>): void {
    const currentFilters = this.getState().filters;
    this.updateState({ 
      filters: { ...currentFilters, ...filters },
      pagination: { ...this.getState().pagination, page: 1 } // Reset to first page
    });
  }

  updatePagination(pagination: Partial<UserState['pagination']>): void {
    const currentPagination = this.getState().pagination;
    this.updateState({ 
      pagination: { ...currentPagination, ...pagination }
    });
  }

  clearFilters(): void {
    this.updateState({ 
      filters: initialState.filters,
      pagination: { ...this.getState().pagination, page: 1 }
    });
  }

  reset(): void {
    this.state$.next(initialState);
  }

  // Private helpers
  private select<T>(selector: (state: UserState) => T): Observable<T> {
    return this.state$.pipe(
      map(selector),
      distinctUntilChanged(),
      shareReplay(1)
    );
  }

  private getState(): UserState {
    return this.state$.getValue();
  }

  private updateState(partial: Partial<UserState>): void {
    const currentState = this.getState();
    this.state$.next({ ...currentState, ...partial });
  }

  private filterUsers(users: User[], filters: UserState['filters']): User[] {
    return users.filter(user => {
      const matchesSearch = !filters.search || 
        user.name.toLowerCase().includes(filters.search.toLowerCase()) ||
        user.email.toLowerCase().includes(filters.search.toLowerCase());
      
      const matchesRole = !filters.role || user.role === filters.role;
      
      const matchesStatus = !filters.status || 
        (filters.status === 'active' && user.active) ||
        (filters.status === 'inactive' && !user.active);

      return matchesSearch && matchesRole && matchesStatus;
    });
  }
}
```

### Component com Smart/Dumb Pattern
```typescript
// components/user-list/user-list.component.ts (Smart Component)
import { Component, OnInit, OnDestroy, ChangeDetectionStrategy } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { MatSnackBar } from '@angular/material/snack-bar';
import { Subject, Observable } from 'rxjs';
import { takeUntil, switchMap, catchError } from 'rxjs/operators';

import { UserService } from '../../services/user.service';
import { UserStateService } from '../../services/user-state.service';
import { User } from '../../models/user.model';
import { UserFormDialogComponent } from '../user-form-dialog/user-form-dialog.component';
import { ConfirmDialogComponent } from '../../../shared/components/confirm-dialog/confirm-dialog.component';

@Component({
  selector: 'app-user-list',
  templateUrl: './user-list.component.html',
  styleUrls: ['./user-list.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class UserListComponent implements OnInit, OnDestroy {
  private destroy$ = new Subject<void>();

  // Observables from state service
  users$ = this.userState.filteredUsers$;
  loading$ = this.userState.loading$;
  error$ = this.userState.error$;
  filters$ = this.userState.filters$;
  pagination$ = this.userState.pagination$;

  constructor(
    private userService: UserService,
    private userState: UserStateService,
    private dialog: MatDialog,
    private snackBar: MatSnackBar
  ) {}

  ngOnInit(): void {
    this.loadUsers();
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  loadUsers(): void {
    this.userState.setLoading(true);
    this.userState.setError(null);

    this.userService.getUsers().pipe(
      takeUntil(this.destroy$),
      catchError(error => {
        this.userState.setError('Failed to load users');
        this.userState.setLoading(false);
        throw error;
      })
    ).subscribe(users => {
      this.userState.setUsers(users);
      this.userState.setLoading(false);
    });
  }

  onCreateUser(): void {
    const dialogRef = this.dialog.open(UserFormDialogComponent, {
      width: '500px',
      data: { mode: 'create' }
    });

    dialogRef.afterClosed().pipe(
      takeUntil(this.destroy$),
      switchMap(result => {
        if (result) {
          return this.userService.createUser(result);
        }
        return [];
      })
    ).subscribe(newUser => {
      if (newUser) {
        this.userState.addUser(newUser);
        this.snackBar.open('User created successfully', 'Close', { duration: 3000 });
      }
    });
  }

  onEditUser(user: User): void {
    const dialogRef = this.dialog.open(UserFormDialogComponent, {
      width: '500px',
      data: { mode: 'edit', user }
    });

    dialogRef.afterClosed().pipe(
      takeUntil(this.destroy$),
      switchMap(result => {
        if (result) {
          return this.userService.updateUser(user.id, result);
        }
        return [];
      })
    ).subscribe(updatedUser => {
      if (updatedUser) {
        this.userState.updateUser(updatedUser);
        this.snackBar.open('User updated successfully', 'Close', { duration: 3000 });
      }
    });
  }

  onDeleteUser(user: User): void {
    const dialogRef = this.dialog.open(ConfirmDialogComponent, {
      width: '400px',
      data: {
        title: 'Confirm Delete',
        message: `Are you sure you want to delete ${user.name}?`,
        confirmText: 'Delete',
        cancelText: 'Cancel'
      }
    });

    dialogRef.afterClosed().pipe(
      takeUntil(this.destroy$),
      switchMap(confirmed => {
        if (confirmed) {
          return this.userService.deleteUser(user.id);
        }
        return [];
      })
    ).subscribe(success => {
      if (success) {
        this.userState.removeUser(user.id);
        this.snackBar.open('User deleted successfully', 'Close', { duration: 3000 });
      }
    });
  }

  onSearchChange(search: string): void {
    this.userState.updateFilters({ search });
  }

  onRoleFilterChange(role: string): void {
    this.userState.updateFilters({ role });
  }

  onStatusFilterChange(status: string): void {
    this.userState.updateFilters({ status });
  }

  onPageChange(page: number): void {
    this.userState.updatePagination({ page });
  }

  onPageSizeChange(size: number): void {
    this.userState.updatePagination({ size, page: 1 });
  }
}

// user-table.component.ts (Dumb Component)
import { Component, Input, Output, EventEmitter, ChangeDetectionStrategy } from '@angular/core';
import { User } from '../../models/user.model';

@Component({
  selector: 'app-user-table',
  templateUrl: './user-table.component.html',
  styleUrls: ['./user-table.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class UserTableComponent {
  @Input() users: User[] = [];
  @Input() loading = false;

  @Output() editUser = new EventEmitter<User>();
  @Output() deleteUser = new EventEmitter<User>();
  @Output() selectUser = new EventEmitter<User>();

  displayedColumns: string[] = ['name', 'email', 'role', 'status', 'actions'];

  onEdit(user: User): void {
    this.editUser.emit(user);
  }

  onDelete(user: User): void {
    this.deleteUser.emit(user);
  }

  onSelect(user: User): void {
    this.selectUser.emit(user);
  }

  trackByUserId(index: number, user: User): string {
    return user.id;
  }
}
```

### Testing Patterns (Angular Legacy)
```typescript
// user.service.spec.ts
import { TestBed } from '@angular/core/testing';
import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';
import { UserService } from './user.service';
import { User } from '../models/user.model';
import { environment } from '../../environments/environment';

describe('UserService', () => {
  let service: UserService;
  let httpMock: HttpTestingController;

  const mockUser: User = {
    id: '1',
    name: 'John Doe',
    email: 'john@example.com',
    role: 'user',
    active: true,
    createdAt: new Date(),
    updatedAt: new Date()
  };

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      providers: [UserService]
    });

    service = TestBed.inject(UserService);
    httpMock = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    httpMock.verify();
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });

  describe('getUsers', () => {
    it('should fetch users successfully', () => {
      const mockResponse = {
        data: [mockUser],
        total: 1,
        page: 1,
        limit: 10
      };

      service.getUsers().subscribe(response => {
        expect(response).toEqual(mockResponse);
        expect(response.data).toHaveLength(1);
        expect(response.data[0]).toEqual(mockUser);
      });

      const req = httpMock.expectOne(`${environment.apiUrl}/users?page=1&limit=10`);
      expect(req.request.method).toBe('GET');
      req.flush(mockResponse);
    });

    it('should handle search parameter', () => {
      service.getUsers(1, 10, 'john').subscribe();

      const req = httpMock.expectOne(`${environment.apiUrl}/users?page=1&limit=10&search=john`);
      expect(req.request.method).toBe('GET');
      req.flush({ data: [], total: 0, page: 1, limit: 10 });
    });

    it('should handle HTTP errors', () => {
      service.getUsers().subscribe({
        next: () => fail('Should have failed'),
        error: (error) => {
          expect(error).toContain('Error 500');
        }
      });

      const req = httpMock.expectOne(`${environment.apiUrl}/users?page=1&limit=10`);
      req.flush('Server error', { status: 500, statusText: 'Internal Server Error' });
    });
  });

  describe('createUser', () => {
    it('should create user successfully', () => {
      const createUserDto = {
        name: 'John Doe',
        email: 'john@example.com',
        role: 'user' as const
      };

      service.createUser(createUserDto).subscribe(user => {
        expect(user).toEqual(mockUser);
      });

      const req = httpMock.expectOne(`${environment.apiUrl}/users`);
      expect(req.request.method).toBe('POST');
      expect(req.request.body).toEqual(createUserDto);
      req.flush(mockUser);
    });
  });
});

// user-list.component.spec.ts
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { MatDialog } from '@angular/material/dialog';
import { MatSnackBar } from '@angular/material/snack-bar';
import { of, throwError } from 'rxjs';

import { UserListComponent } from './user-list.component';
import { UserService } from '../../services/user.service';
import { UserStateService } from '../../services/user-state.service';
import { SharedModule } from '../../../shared/shared.module';
import { NoopAnimationsModule } from '@angular/platform-browser/animations';

describe('UserListComponent', () => {
  let component: UserListComponent;
  let fixture: ComponentFixture<UserListComponent>;
  let userService: jasmine.SpyObj<UserService>;
  let userState: jasmine.SpyObj<UserStateService>;
  let dialog: jasmine.SpyObj<MatDialog>;
  let snackBar: jasmine.SpyObj<MatSnackBar>;

  const mockUsers = [
    { id: '1', name: 'John Doe', email: 'john@example.com', role: 'user', active: true },
    { id: '2', name: 'Jane Smith', email: 'jane@example.com', role: 'admin', active: true }
  ];

  beforeEach(async () => {
    const userServiceSpy = jasmine.createSpyObj('UserService', ['getUsers', 'createUser', 'updateUser', 'deleteUser']);
    const userStateSpy = jasmine.createSpyObj('UserStateService', 
      ['setUsers', 'setLoading', 'setError', 'addUser', 'updateUser', 'removeUser', 'updateFilters', 'updatePagination'],
      {
        filteredUsers$: of(mockUsers),
        loading$: of(false),
        error$: of(null),
        filters$: of({ search: '', role: '', status: 'active' }),
        pagination$: of({ page: 1, size: 10, total: 2 })
      }
    );
    const dialogSpy = jasmine.createSpyObj('MatDialog', ['open']);
    const snackBarSpy = jasmine.createSpyObj('MatSnackBar', ['open']);

    await TestBed.configureTestingModule({
      declarations: [UserListComponent],
      imports: [SharedModule, NoopAnimationsModule],
      providers: [
        { provide: UserService, useValue: userServiceSpy },
        { provide: UserStateService, useValue: userStateSpy },
        { provide: MatDialog, useValue: dialogSpy },
        { provide: MatSnackBar, useValue: snackBarSpy }
      ]
    }).compileComponents();

    userService = TestBed.inject(UserService) as jasmine.SpyObj<UserService>;
    userState = TestBed.inject(UserStateService) as jasmine.SpyObj<UserStateService>;
    dialog = TestBed.inject(MatDialog) as jasmine.SpyObj<MatDialog>;
    snackBar = TestBed.inject(MatSnackBar) as jasmine.SpyObj<MatSnackBar>;
  });

  beforeEach(() => {
    fixture = TestBed.createComponent(UserListComponent);
    component = fixture.componentInstance;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should load users on init', () => {
    userService.getUsers.and.returnValue(of(mockUsers));

    component.ngOnInit();

    expect(userService.getUsers).toHaveBeenCalled();
    expect(userState.setLoading).toHaveBeenCalledWith(true);
    expect(userState.setUsers).toHaveBeenCalledWith(mockUsers);
    expect(userState.setLoading).toHaveBeenCalledWith(false);
  });

  it('should handle error when loading users', () => {
    const error = new Error('Network error');
    userService.getUsers.and.returnValue(throwError(error));

    component.ngOnInit();

    expect(userState.setError).toHaveBeenCalledWith('Failed to load users');
    expect(userState.setLoading).toHaveBeenCalledWith(false);
  });

  it('should update search filter', () => {
    const searchTerm = 'john';

    component.onSearchChange(searchTerm);

    expect(userState.updateFilters).toHaveBeenCalledWith({ search: searchTerm });
  });

  it('should update role filter', () => {
    const role = 'admin';

    component.onRoleFilterChange(role);

    expect(userState.updateFilters).toHaveBeenCalledWith({ role });
  });
});
```

## Comandos Angular Legacy Essenciais

```bash
# Verificar versão atual
ng version

# Atualização incremental (recomendado)
ng update @angular/core@9 @angular/cli@9
ng update @angular/core@10 @angular/cli@10
ng update @angular/core@11 @angular/cli@11
ng update @angular/core@12 @angular/cli@12
ng update @angular/core@13 @angular/cli@13
ng update @angular/core@14 @angular/cli@14

# Verificar atualizações disponíveis
ng update

# Gerar estruturas
ng generate module features/users --routing
ng generate component features/users/user-list
ng generate service services/user
ng generate guard guards/auth
ng generate interceptor interceptors/auth
ng generate pipe pipes/truncate
ng generate directive directives/highlight

# Build para produção (Angular 8-11)
ng build --prod
ng build --prod --aot --vendor-chunk --common-chunk

# Build para produção (Angular 12+)
ng build --configuration production

# Análise de bundle
ng build --prod --source-map
npm install -g webpack-bundle-analyzer
webpack-bundle-analyzer dist/main.js

# Testes
ng test
ng test --watch=false --browsers=ChromeHeadless
ng e2e

# Linting
ng lint
ng lint --fix

# Servir aplicação
ng serve
ng serve --port 4200 --host 0.0.0.0
ng serve --prod
```

## Padrões de Migração

### Angular 8 → 9 (Ivy Renderer)
```bash
ng update @angular/cli @angular/core
# Habilitar Ivy
# angular.json: "aot": true, "enableIvy": true
```

### Angular 11 → 12 (Strict Mode)
```bash
ng update @angular/cli @angular/core
# Habilitar strict mode
ng config strictTemplates true
```

### Angular 13 → 14 (Standalone Components)
```bash
ng update @angular/cli @angular/core
# Preparar para standalone components
# Começar a usar standalone: true em novos componentes
```

### Preparação para Angular 15+
```typescript
// Migrar para standalone components gradualmente
@Component({
  standalone: true,
  selector: 'app-user',
  templateUrl: './user.component.html',
  imports: [CommonModule, ReactiveFormsModule, MatFormFieldModule]
})
export class UserComponent {
  // Component logic
}
```
