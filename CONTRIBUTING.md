# Contribuindo com o Task Radar

## Pré-requisitos

- Flutter 3.41.4+
- Dart 3.11.1+

## Setup do Projeto

```bash
cd task_radar
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## Executando o App

```bash
flutter run
```

**Credenciais de teste:** `emilys` / `emilyspass`

## Executando os Testes

```bash
flutter test
```

## Arquitetura

O projeto segue **Clean Architecture** com separação em 3 camadas por feature:

```
lib/app/
├── core/                    # Código compartilhado
│   ├── di/                  # Injeção de dependência (get_it)
│   ├── either/              # Tipo Either<L, R> para tratamento de erros
│   ├── errors/              # Failures e Exceptions
│   ├── network/             # ApiClient (Dio) e NetworkInfo
│   ├── database/            # Configuração do sqflite
│   ├── routes/              # Rotas (go_router)
│   ├── theme/               # Temas (light/dark) e ThemeCubit
│   ├── usecases/            # Interface base UseCase<T, Params>
│   └── constants/           # Constantes da API
│
├── features/
│   ├── auth/                # Autenticação JWT
│   ├── todos/               # CRUD de tarefas
│   ├── users/               # Listagem de usuários (admin)
│   ├── quotes/              # Frases motivacionais
│   ├── dashboard/           # Dashboard com resumo
│   ├── profile/             # Perfil do usuário
│   └── splash/              # Tela de splash
```

Cada feature segue a mesma estrutura:

```
feature/
├── domain/
│   ├── entities/            # Entidades de domínio
│   ├── repositories/        # Contratos (interfaces abstratas)
│   └── usecases/            # Casos de uso
├── data/
│   ├── models/              # Models (freezed/json_serializable)
│   ├── datasources/         # Remote (API) e Local (sqflite)
│   └── repositories/        # Implementações dos repositórios
└── presentation/
    ├── bloc/                # BLoC/Cubit + Events + States
    └── pages/               # Telas
```

## Padrões e Tecnologias

| Aspecto | Tecnologia |
|---|---|
| Gerenciamento de Estado | BLoC / Cubit |
| Injeção de Dependência | get_it |
| Navegação | go_router |
| Serialização | freezed + json_serializable |
| HTTP | Dio (com interceptor JWT) |
| Persistência Local | sqflite |
| Armazenamento Seguro | flutter_secure_storage |
| Testes | bloc_test + mocktail |

## Fluxo de Dados

```
UI → BLoC/Cubit → UseCase → Repository → DataSource (Remote/Local)
```

- **Either<Failure, T>**: Usado para retorno de erros sem exceções.
- **Offline-first (todos)**: Grava localmente, tenta sincronizar com a API.
- **Auth**: JWT com refresh automático via Dio Interceptor.

## Geração de Código

Ao alterar models com `@freezed` ou `@JsonSerializable`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## API

O app consome a [DummyJSON API](https://dummyjson.com):

- Auth: `POST /auth/login`, `POST /auth/refresh`, `GET /auth/me`
- Todos: `GET /todos`, `GET /todos/user/:id`, `POST /todos/add`, `PUT /todos/:id`, `DELETE /todos/:id`
- Users: `GET /users`
- Quotes: `GET /quotes/random`
