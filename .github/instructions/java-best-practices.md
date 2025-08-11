# Java - Boas Práticas e Padrões

## Checklist de Desenvolvimento Java

### Arquitetura e Design
- [ ] SOLID principles aplicados
- [ ] Clean Architecture implementada
- [ ] Dependency Injection com Spring
- [ ] Repository Pattern para persistência
- [ ] DTO Pattern para transferência de dados
- [ ] Exception handling centralizado
- [ ] Validation com Bean Validation

### Spring Boot
- [ ] Auto-configuration utilizada apropriadamente
- [ ] Profiles para diferentes ambientes
- [ ] Health checks configurados
- [ ] Security configurada adequadamente
- [ ] Database migrations com Flyway/Liquibase
- [ ] Caching implementado onde necessário
- [ ] Monitoring com Actuator

### Performance e Otimização
- [ ] Connection pooling configurado
- [ ] JPA queries otimizadas
- [ ] Indexes de database apropriados
- [ ] Lazy loading implementado
- [ ] Caching strategy definida
- [ ] Async processing onde adequado
- [ ] JVM tuning para produção

### Testes
- [ ] Unit tests com JUnit 5
- [ ] Integration tests com TestContainers
- [ ] Mock objects com Mockito
- [ ] Test coverage > 80%
- [ ] Contract testing para APIs
- [ ] Performance tests implementados

### Segurança
- [ ] Spring Security configurado
- [ ] JWT tokens implementados
- [ ] HTTPS enforced
- [ ] Input validation adequada
- [ ] SQL injection prevenida
- [ ] XSS protection implementada

## Templates de Código Java

### REST Controller Completo
```java
@RestController
@RequestMapping("/api/v1/users")
@Validated
@Slf4j
@Tag(name = "Users", description = "User management operations")
public class UserController {

    private final UserService userService;
    private final UserMapper userMapper;

    public UserController(UserService userService, UserMapper userMapper) {
        this.userService = userService;
        this.userMapper = userMapper;
    }

    @GetMapping
    @Operation(summary = "Get users with pagination")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Users retrieved successfully"),
        @ApiResponse(responseCode = "400", description = "Invalid pagination parameters")
    })
    public ResponseEntity<PagedResponse<UserDto>> getUsers(
            @Parameter(description = "Page number (0-based)")
            @RequestParam(defaultValue = "0") @Min(0) int page,
            
            @Parameter(description = "Page size (1-100)")
            @RequestParam(defaultValue = "20") @Min(1) @Max(100) int size,
            
            @Parameter(description = "Search term")
            @RequestParam(required = false) String search,
            
            @Parameter(description = "Sort field")
            @RequestParam(defaultValue = "createdAt") String sortBy,
            
            @Parameter(description = "Sort direction")
            @RequestParam(defaultValue = "desc") String sortDir) {
        
        log.info("Fetching users - page: {}, size: {}, search: {}, sort: {} {}", 
                page, size, search, sortBy, sortDir);
        
        Sort.Direction direction = Sort.Direction.fromString(sortDir);
        Pageable pageable = PageRequest.of(page, size, direction, sortBy);
        
        Page<User> users = userService.findUsers(search, pageable);
        
        List<UserDto> userDtos = users.getContent().stream()
                .map(userMapper::toDto)
                .collect(Collectors.toList());
        
        PagedResponse<UserDto> response = PagedResponse.<UserDto>builder()
                .content(userDtos)
                .page(users.getNumber())
                .size(users.getSize())
                .totalElements(users.getTotalElements())
                .totalPages(users.getTotalPages())
                .first(users.isFirst())
                .last(users.isLast())
                .build();
                
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get user by ID")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "User found"),
        @ApiResponse(responseCode = "404", description = "User not found")
    })
    public ResponseEntity<UserDto> getUserById(
            @Parameter(description = "User ID") 
            @PathVariable @NotNull UUID id) {
        
        log.info("Fetching user with id: {}", id);
        
        User user = userService.findById(id)
                .orElseThrow(() -> new UserNotFoundException("User not found with id: " + id));
                
        return ResponseEntity.ok(userMapper.toDto(user));
    }

    @PostMapping
    @Operation(summary = "Create new user")
    @ApiResponses({
        @ApiResponse(responseCode = "201", description = "User created successfully"),
        @ApiResponse(responseCode = "400", description = "Invalid user data"),
        @ApiResponse(responseCode = "409", description = "Email already exists")
    })
    public ResponseEntity<UserDto> createUser(
            @Parameter(description = "User data")
            @Valid @RequestBody CreateUserRequest request) {
        
        log.info("Creating user with email: {}", request.getEmail());
        
        User user = userMapper.toEntity(request);
        User savedUser = userService.createUser(user);
        UserDto response = userMapper.toDto(savedUser);
        
        URI location = ServletUriComponentsBuilder
                .fromCurrentRequest()
                .path("/{id}")
                .buildAndExpand(savedUser.getId())
                .toUri();
        
        return ResponseEntity.created(location).body(response);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update user")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "User updated successfully"),
        @ApiResponse(responseCode = "404", description = "User not found"),
        @ApiResponse(responseCode = "400", description = "Invalid user data")
    })
    public ResponseEntity<UserDto> updateUser(
            @Parameter(description = "User ID")
            @PathVariable @NotNull UUID id,
            
            @Parameter(description = "Updated user data")
            @Valid @RequestBody UpdateUserRequest request) {
        
        log.info("Updating user with id: {}", id);
        
        User updatedUser = userService.updateUser(id, request);
        return ResponseEntity.ok(userMapper.toDto(updatedUser));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete user")
    @ApiResponses({
        @ApiResponse(responseCode = "204", description = "User deleted successfully"),
        @ApiResponse(responseCode = "404", description = "User not found")
    })
    public ResponseEntity<Void> deleteUser(
            @Parameter(description = "User ID")
            @PathVariable @NotNull UUID id) {
        
        log.info("Deleting user with id: {}", id);
        userService.deleteUser(id);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{id}/status")
    @Operation(summary = "Update user status")
    public ResponseEntity<UserDto> updateUserStatus(
            @PathVariable UUID id,
            @RequestParam boolean active) {
        
        User user = userService.updateUserStatus(id, active);
        return ResponseEntity.ok(userMapper.toDto(user));
    }
}
```

### Service Layer com Transações
```java
@Service
@Transactional(readOnly = true)
@Slf4j
public class UserService {

    private final UserRepository userRepository;
    private final EmailService emailService;
    private final PasswordEncoder passwordEncoder;
    private final ApplicationEventPublisher eventPublisher;

    public UserService(UserRepository userRepository, 
                      EmailService emailService,
                      PasswordEncoder passwordEncoder,
                      ApplicationEventPublisher eventPublisher) {
        this.userRepository = userRepository;
        this.emailService = emailService;
        this.passwordEncoder = passwordEncoder;
        this.eventPublisher = eventPublisher;
    }

    public Page<User> findUsers(String search, Pageable pageable) {
        log.debug("Finding users with search: {}, pageable: {}", search, pageable);
        
        if (StringUtils.hasText(search)) {
            return userRepository.findByNameContainingIgnoreCaseOrEmailContainingIgnoreCase(
                    search, search, pageable);
        }
        return userRepository.findAll(pageable);
    }

    public Optional<User> findById(UUID id) {
        Assert.notNull(id, "User ID cannot be null");
        return userRepository.findById(id);
    }

    public Optional<User> findByEmail(String email) {
        Assert.hasText(email, "Email cannot be empty");
        return userRepository.findByEmail(email.toLowerCase());
    }

    @Transactional
    @Retryable(value = {DataIntegrityViolationException.class}, maxAttempts = 3)
    public User createUser(User user) {
        Assert.notNull(user, "User cannot be null");
        log.info("Creating new user with email: {}", user.getEmail());
        
        // Validate unique email
        if (userRepository.existsByEmail(user.getEmail().toLowerCase())) {
            throw new EmailAlreadyExistsException("Email already exists: " + user.getEmail());
        }

        // Encode password
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        user.setEmail(user.getEmail().toLowerCase());
        
        // Set audit fields
        user.setCreatedAt(Instant.now());
        user.setUpdatedAt(Instant.now());
        user.setActive(true);
        
        User savedUser = userRepository.save(user);
        
        // Publish event for async processing
        eventPublisher.publishEvent(new UserCreatedEvent(savedUser));
        
        log.info("User created successfully with id: {}", savedUser.getId());
        return savedUser;
    }

    @Transactional
    public User updateUser(UUID id, UpdateUserRequest request) {
        Assert.notNull(id, "User ID cannot be null");
        Assert.notNull(request, "Update request cannot be null");
        
        User user = findById(id)
                .orElseThrow(() -> new UserNotFoundException("User not found with id: " + id));

        // Update fields
        if (StringUtils.hasText(request.getName())) {
            user.setName(request.getName().trim());
        }
        
        if (StringUtils.hasText(request.getEmail()) && 
            !user.getEmail().equals(request.getEmail().toLowerCase())) {
            
            String newEmail = request.getEmail().toLowerCase();
            if (userRepository.existsByEmail(newEmail)) {
                throw new EmailAlreadyExistsException("Email already exists: " + newEmail);
            }
            user.setEmail(newEmail);
        }

        if (request.getPhone() != null) {
            user.setPhone(request.getPhone());
        }

        user.setUpdatedAt(Instant.now());
        
        User updatedUser = userRepository.save(user);
        eventPublisher.publishEvent(new UserUpdatedEvent(updatedUser));
        
        return updatedUser;
    }

    @Transactional
    public void deleteUser(UUID id) {
        Assert.notNull(id, "User ID cannot be null");
        
        User user = findById(id)
                .orElseThrow(() -> new UserNotFoundException("User not found with id: " + id));
        
        // Soft delete
        user.setActive(false);
        user.setDeletedAt(Instant.now());
        userRepository.save(user);
        
        eventPublisher.publishEvent(new UserDeletedEvent(user));
        log.info("User soft deleted successfully with id: {}", id);
    }

    @Transactional
    public User updateUserStatus(UUID id, boolean active) {
        User user = findById(id)
                .orElseThrow(() -> new UserNotFoundException("User not found with id: " + id));
        
        user.setActive(active);
        user.setUpdatedAt(Instant.now());
        
        return userRepository.save(user);
    }

    public boolean existsByEmail(String email) {
        return userRepository.existsByEmail(email.toLowerCase());
    }

    @EventListener
    @Async
    public void handleUserCreated(UserCreatedEvent event) {
        try {
            emailService.sendWelcomeEmail(event.getUser());
            log.info("Welcome email sent to: {}", event.getUser().getEmail());
        } catch (Exception e) {
            log.error("Failed to send welcome email to: {}", event.getUser().getEmail(), e);
        }
    }
}
```

### JPA Repository com Specifications
```java
@Repository
public interface UserRepository extends JpaRepository<User, UUID>, 
                                      JpaSpecificationExecutor<User> {

    Optional<User> findByEmail(String email);
    
    boolean existsByEmail(String email);
    
    Page<User> findByNameContainingIgnoreCaseOrEmailContainingIgnoreCase(
            String name, String email, Pageable pageable);

    @Query("SELECT u FROM User u WHERE u.createdAt >= :since AND u.active = true")
    List<User> findActiveUsersCreatedSince(@Param("since") Instant since);

    @Query(value = """
            SELECT u.* FROM users u 
            WHERE u.email ILIKE %:search% 
               OR u.name ILIKE %:search% 
            ORDER BY u.created_at DESC
            """, nativeQuery = true)
    List<User> findBySearchTerm(@Param("search") String search);

    @Modifying
    @Query("UPDATE User u SET u.lastLoginAt = :loginTime WHERE u.id = :userId")
    void updateLastLoginTime(@Param("userId") UUID userId, @Param("loginTime") Instant loginTime);

    @Query("SELECT COUNT(u) FROM User u WHERE u.active = true")
    long countActiveUsers();
}

// Specifications for dynamic queries
public class UserSpecifications {
    
    public static Specification<User> hasName(String name) {
        return (root, query, criteriaBuilder) -> {
            if (name == null || name.trim().isEmpty()) {
                return criteriaBuilder.conjunction();
            }
            return criteriaBuilder.like(
                criteriaBuilder.lower(root.get("name")), 
                "%" + name.toLowerCase() + "%"
            );
        };
    }
    
    public static Specification<User> hasEmail(String email) {
        return (root, query, criteriaBuilder) -> {
            if (email == null || email.trim().isEmpty()) {
                return criteriaBuilder.conjunction();
            }
            return criteriaBuilder.like(
                criteriaBuilder.lower(root.get("email")), 
                "%" + email.toLowerCase() + "%"
            );
        };
    }
    
    public static Specification<User> isActive(Boolean active) {
        return (root, query, criteriaBuilder) -> {
            if (active == null) {
                return criteriaBuilder.conjunction();
            }
            return criteriaBuilder.equal(root.get("active"), active);
        };
    }
    
    public static Specification<User> createdBetween(Instant startDate, Instant endDate) {
        return (root, query, criteriaBuilder) -> {
            if (startDate == null && endDate == null) {
                return criteriaBuilder.conjunction();
            }
            if (startDate != null && endDate != null) {
                return criteriaBuilder.between(root.get("createdAt"), startDate, endDate);
            }
            if (startDate != null) {
                return criteriaBuilder.greaterThanOrEqualTo(root.get("createdAt"), startDate);
            }
            return criteriaBuilder.lessThanOrEqualTo(root.get("createdAt"), endDate);
        };
    }
}

// Usage in service
public Page<User> findUsersByCriteria(UserSearchCriteria criteria, Pageable pageable) {
    Specification<User> spec = Specification.where(UserSpecifications.hasName(criteria.getName()))
            .and(UserSpecifications.hasEmail(criteria.getEmail()))
            .and(UserSpecifications.isActive(criteria.getActive()))
            .and(UserSpecifications.createdBetween(criteria.getStartDate(), criteria.getEndDate()));
    
    return userRepository.findAll(spec, pageable);
}
```

### Entity com Auditing
```java
@Entity
@Table(name = "users", indexes = {
    @Index(name = "idx_user_email", columnList = "email"),
    @Index(name = "idx_user_active", columnList = "active"),
    @Index(name = "idx_user_created_at", columnList = "created_at")
})
@EntityListeners(AuditingEntityListener.class)
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @Column(name = "name", nullable = false, length = 100)
    @NotBlank(message = "Name is required")
    @Size(min = 2, max = 100, message = "Name must be between 2 and 100 characters")
    private String name;

    @Column(name = "email", nullable = false, unique = true, length = 255)
    @Email(message = "Email should be valid")
    @NotBlank(message = "Email is required")
    private String email;

    @Column(name = "password", nullable = false)
    @NotBlank(message = "Password is required")
    @JsonIgnore
    private String password;

    @Column(name = "phone", length = 20)
    @Pattern(regexp = "^\\+?[1-9]\\d{1,14}$", message = "Invalid phone number format")
    private String phone;

    @Column(name = "active", nullable = false)
    @Builder.Default
    private Boolean active = true;

    @Enumerated(EnumType.STRING)
    @Column(name = "role", nullable = false)
    @Builder.Default
    private UserRole role = UserRole.USER;

    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @LastModifiedDate
    @Column(name = "updated_at")
    private Instant updatedAt;

    @Column(name = "last_login_at")
    private Instant lastLoginAt;

    @Column(name = "deleted_at")
    private Instant deletedAt;

    @Version
    @Column(name = "version")
    private Long version;

    // Relationships
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @JsonIgnore
    private Set<UserRole> userRoles = new HashSet<>();

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof User)) return false;
        User user = (User) o;
        return Objects.equals(id, user.id);
    }

    @Override
    public int hashCode() {
        return getClass().hashCode();
    }
}

// Enum
public enum UserRole {
    USER("User"),
    ADMIN("Administrator"),
    MANAGER("Manager");

    private final String displayName;

    UserRole(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }
}
```

### DTOs e Validation
```java
// CreateUserRequest.java
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreateUserRequest {

    @NotBlank(message = "Name is required")
    @Size(min = 2, max = 100, message = "Name must be between 2 and 100 characters")
    private String name;

    @NotBlank(message = "Email is required")
    @Email(message = "Email should be valid")
    @Size(max = 255, message = "Email must not exceed 255 characters")
    private String email;

    @NotBlank(message = "Password is required")
    @Size(min = 8, max = 128, message = "Password must be between 8 and 128 characters")
    @Pattern(
        regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]",
        message = "Password must contain at least one uppercase letter, one lowercase letter, one number and one special character"
    )
    private String password;

    @Pattern(regexp = "^\\+?[1-9]\\d{1,14}$", message = "Invalid phone number format")
    private String phone;

    @NotNull(message = "Role is required")
    private UserRole role;
}

// UpdateUserRequest.java
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UpdateUserRequest {

    @Size(min = 2, max = 100, message = "Name must be between 2 and 100 characters")
    private String name;

    @Email(message = "Email should be valid")
    @Size(max = 255, message = "Email must not exceed 255 characters")
    private String email;

    @Pattern(regexp = "^\\+?[1-9]\\d{1,14}$", message = "Invalid phone number format")
    private String phone;

    private UserRole role;
}

// UserDto.java
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserDto {
    private UUID id;
    private String name;
    private String email;
    private String phone;
    private Boolean active;
    private UserRole role;
    private Instant createdAt;
    private Instant updatedAt;
    private Instant lastLoginAt;
}

// PagedResponse.java
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PagedResponse<T> {
    private List<T> content;
    private int page;
    private int size;
    private long totalElements;
    private int totalPages;
    private boolean first;
    private boolean last;
}
```

### MapStruct Mapper
```java
@Mapper(componentModel = "spring", 
        unmappedTargetPolicy = ReportingPolicy.IGNORE,
        nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
public interface UserMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "lastLoginAt", ignore = true)
    @Mapping(target = "deletedAt", ignore = true)
    @Mapping(target = "version", ignore = true)
    @Mapping(target = "userRoles", ignore = true)
    User toEntity(CreateUserRequest request);

    UserDto toDto(User user);

    List<UserDto> toDtoList(List<User> users);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "password", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "lastLoginAt", ignore = true)
    @Mapping(target = "deletedAt", ignore = true)
    @Mapping(target = "version", ignore = true)
    @Mapping(target = "userRoles", ignore = true)
    User updateFromRequest(UpdateUserRequest request, @MappingTarget User user);
}
```

### Exception Handling
```java
@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    @ExceptionHandler(UserNotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public ErrorResponse handleUserNotFound(UserNotFoundException ex, WebRequest request) {
        log.warn("User not found: {}", ex.getMessage());
        
        return ErrorResponse.builder()
                .timestamp(Instant.now())
                .status(HttpStatus.NOT_FOUND.value())
                .error("User Not Found")
                .message(ex.getMessage())
                .path(request.getDescription(false))
                .build();
    }

    @ExceptionHandler(EmailAlreadyExistsException.class)
    @ResponseStatus(HttpStatus.CONFLICT)
    public ErrorResponse handleEmailAlreadyExists(EmailAlreadyExistsException ex, WebRequest request) {
        log.warn("Email already exists: {}", ex.getMessage());
        
        return ErrorResponse.builder()
                .timestamp(Instant.now())
                .status(HttpStatus.CONFLICT.value())
                .error("Email Already Exists")
                .message(ex.getMessage())
                .path(request.getDescription(false))
                .build();
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ValidationErrorResponse handleValidationErrors(MethodArgumentNotValidException ex, WebRequest request) {
        log.warn("Validation failed: {}", ex.getMessage());
        
        Map<String, String> fieldErrors = ex.getBindingResult()
                .getFieldErrors()
                .stream()
                .collect(Collectors.toMap(
                        FieldError::getField,
                        FieldError::getDefaultMessage,
                        (existing, replacement) -> existing
                ));

        return ValidationErrorResponse.builder()
                .timestamp(Instant.now())
                .status(HttpStatus.BAD_REQUEST.value())
                .error("Validation Failed")
                .message("Invalid input data")
                .fieldErrors(fieldErrors)
                .path(request.getDescription(false))
                .build();
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    @ResponseStatus(HttpStatus.CONFLICT)
    public ErrorResponse handleDataIntegrityViolation(DataIntegrityViolationException ex, WebRequest request) {
        log.error("Data integrity violation", ex);
        
        String message = "Data integrity violation";
        if (ex.getCause() instanceof ConstraintViolationException) {
            message = "Constraint violation: duplicate or invalid data";
        }
        
        return ErrorResponse.builder()
                .timestamp(Instant.now())
                .status(HttpStatus.CONFLICT.value())
                .error("Data Integrity Violation")
                .message(message)
                .path(request.getDescription(false))
                .build();
    }

    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public ErrorResponse handleGenericException(Exception ex, WebRequest request) {
        log.error("Unexpected error occurred", ex);
        
        return ErrorResponse.builder()
                .timestamp(Instant.now())
                .status(HttpStatus.INTERNAL_SERVER_ERROR.value())
                .error("Internal Server Error")
                .message("An unexpected error occurred")
                .path(request.getDescription(false))
                .build();
    }
}

// Error response classes
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ErrorResponse {
    private Instant timestamp;
    private int status;
    private String error;
    private String message;
    private String path;
}

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ValidationErrorResponse {
    private Instant timestamp;
    private int status;
    private String error;
    private String message;
    private String path;
    private Map<String, String> fieldErrors;
}
```

## Testing com JUnit 5 e Mockito

### Unit Tests
```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private EmailService emailService;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private ApplicationEventPublisher eventPublisher;

    @InjectMocks
    private UserService userService;

    private User sampleUser;
    private CreateUserRequest createUserRequest;

    @BeforeEach
    void setUp() {
        sampleUser = User.builder()
                .id(UUID.randomUUID())
                .name("John Doe")
                .email("john@example.com")
                .password("encodedPassword")
                .active(true)
                .role(UserRole.USER)
                .createdAt(Instant.now())
                .build();

        createUserRequest = CreateUserRequest.builder()
                .name("John Doe")
                .email("john@example.com")
                .password("password123")
                .role(UserRole.USER)
                .build();
    }

    @Test
    @DisplayName("Should create user successfully")
    void shouldCreateUserSuccessfully() {
        // Given
        when(userRepository.existsByEmail(anyString())).thenReturn(false);
        when(passwordEncoder.encode(anyString())).thenReturn("encodedPassword");
        when(userRepository.save(any(User.class))).thenReturn(sampleUser);

        // When
        User result = userService.createUser(sampleUser);

        // Then
        assertThat(result).isNotNull();
        assertThat(result.getEmail()).isEqualTo("john@example.com");
        assertThat(result.isActive()).isTrue();

        verify(userRepository).existsByEmail("john@example.com");
        verify(passwordEncoder).encode(anyString());
        verify(userRepository).save(any(User.class));
        verify(eventPublisher).publishEvent(any(UserCreatedEvent.class));
    }

    @Test
    @DisplayName("Should throw exception when email already exists")
    void shouldThrowExceptionWhenEmailAlreadyExists() {
        // Given
        when(userRepository.existsByEmail(anyString())).thenReturn(true);

        // When & Then
        assertThatThrownBy(() -> userService.createUser(sampleUser))
                .isInstanceOf(EmailAlreadyExistsException.class)
                .hasMessageContaining("Email already exists");

        verify(userRepository).existsByEmail("john@example.com");
        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    @DisplayName("Should find user by ID")
    void shouldFindUserById() {
        // Given
        UUID userId = sampleUser.getId();
        when(userRepository.findById(userId)).thenReturn(Optional.of(sampleUser));

        // When
        Optional<User> result = userService.findById(userId);

        // Then
        assertThat(result).isPresent();
        assertThat(result.get().getId()).isEqualTo(userId);
        verify(userRepository).findById(userId);
    }

    @Test
    @DisplayName("Should return empty when user not found")
    void shouldReturnEmptyWhenUserNotFound() {
        // Given
        UUID userId = UUID.randomUUID();
        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        // When
        Optional<User> result = userService.findById(userId);

        // Then
        assertThat(result).isEmpty();
        verify(userRepository).findById(userId);
    }

    @ParameterizedTest
    @ValueSource(strings = {"", " ", "invalid-email", "@example.com"})
    @DisplayName("Should handle invalid email formats")
    void shouldHandleInvalidEmailFormats(String invalidEmail) {
        // Given
        sampleUser.setEmail(invalidEmail);

        // When & Then
        assertThatThrownBy(() -> userService.createUser(sampleUser))
                .isInstanceOf(IllegalArgumentException.class);
    }
}
```

### Integration Tests
```java
@SpringBootTest
@Testcontainers
@Transactional
class UserServiceIntegrationTest {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15")
            .withDatabaseName("testdb")
            .withUsername("test")
            .withPassword("test");

    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }

    @Autowired
    private UserService userService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private TestEntityManager entityManager;

    @Test
    @DisplayName("Should create and retrieve user")
    void shouldCreateAndRetrieveUser() {
        // Given
        User user = User.builder()
                .name("John Doe")
                .email("john@example.com")
                .password("password123")
                .role(UserRole.USER)
                .build();

        // When
        User savedUser = userService.createUser(user);
        entityManager.flush();
        entityManager.clear();

        // Then
        Optional<User> retrievedUser = userService.findById(savedUser.getId());
        assertThat(retrievedUser).isPresent();
        assertThat(retrievedUser.get().getName()).isEqualTo("John Doe");
        assertThat(retrievedUser.get().getEmail()).isEqualTo("john@example.com");
    }

    @Test
    @DisplayName("Should handle concurrent user creation")
    void shouldHandleConcurrentUserCreation() throws InterruptedException {
        // Given
        String email = "concurrent@example.com";
        CountDownLatch latch = new CountDownLatch(2);
        AtomicInteger successCount = new AtomicInteger(0);
        AtomicInteger failureCount = new AtomicInteger(0);

        // When
        Runnable task = () -> {
            try {
                User user = User.builder()
                        .name("Concurrent User")
                        .email(email)
                        .password("password123")
                        .role(UserRole.USER)
                        .build();
                
                userService.createUser(user);
                successCount.incrementAndGet();
            } catch (EmailAlreadyExistsException e) {
                failureCount.incrementAndGet();
            } finally {
                latch.countDown();
            }
        };

        Thread thread1 = new Thread(task);
        Thread thread2 = new Thread(task);

        thread1.start();
        thread2.start();

        latch.await(5, TimeUnit.SECONDS);

        // Then
        assertThat(successCount.get()).isEqualTo(1);
        assertThat(failureCount.get()).isEqualTo(1);
    }
}
```

## Comandos Maven/Gradle Essenciais

```bash
# Maven
mvn spring-boot:run
mvn clean compile
mvn clean test
mvn clean package -DskipTests
mvn clean install
mvn dependency:tree
mvn versions:display-dependency-updates

# Gradle
./gradlew bootRun
./gradlew build
./gradlew test
./gradlew build -x test
./gradlew dependencies
./gradlew dependencyUpdates

# Testing
mvn test -Dtest=UserServiceTest
mvn test -Dtest=UserServiceTest#shouldCreateUserSuccessfully
mvn jacoco:report

# Profiles
mvn spring-boot:run -Dspring.profiles.active=dev
mvn clean package -Pprod

# Docker
mvn spring-boot:build-image
./gradlew bootBuildImage
```

## Configurações Essenciais

### Application Properties
```yaml
# application.yml
spring:
  application:
    name: user-service
  
  datasource:
    url: jdbc:postgresql://localhost:5432/userdb
    username: ${DB_USERNAME:user}
    password: ${DB_PASSWORD:password}
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
      max-lifetime: 1800000
  
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: false
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
        format_sql: true
        use_sql_comments: true
        batch_size: 20
        order_inserts: true
        order_updates: true
  
  flyway:
    enabled: true
    locations: classpath:db/migration
    baseline-on-migrate: true
  
  security:
    jwt:
      secret-key: ${JWT_SECRET:mySecretKey}
      expiration: 86400000 # 24 hours
  
  cache:
    type: redis
    redis:
      host: localhost
      port: 6379
      timeout: 2000ms
      lettuce:
        pool:
          max-active: 8
          max-idle: 8
          min-idle: 0

logging:
  level:
    com.example.userservice: DEBUG
    org.springframework.security: DEBUG
    org.hibernate.SQL: DEBUG
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} - %msg%n"
    file: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  endpoint:
    health:
      show-details: when_authorized
  metrics:
    export:
      prometheus:
        enabled: true

server:
  port: 8080
  servlet:
    context-path: /api
  compression:
    enabled: true
  error:
    include-stacktrace: never
    include-message: always
```

### Security Configuration
```java
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(12);
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/auth/**", "/public/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/users/**").hasAnyRole("USER", "ADMIN")
                .requestMatchers(HttpMethod.POST, "/api/users/**").hasRole("ADMIN")
                .requestMatchers(HttpMethod.PUT, "/api/users/**").hasRole("ADMIN")
                .requestMatchers(HttpMethod.DELETE, "/api/users/**").hasRole("ADMIN")
                .anyRequest().authenticated()
            )
            .addFilterBefore(jwtAuthenticationFilter(), UsernamePasswordAuthenticationFilter.class)
            .exceptionHandling(ex -> ex
                .authenticationEntryPoint(authenticationEntryPoint())
                .accessDeniedHandler(accessDeniedHandler())
            );

        return http.build();
    }
}
```
