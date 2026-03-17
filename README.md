# Contribuindo com o Task Radar

Este documento atende ao que foi solicitado no README para entrega do projeto:

1. Arquitetura escolhida e justificativa
2. Estrutura de pastas
3. Instrucoes de build e execucao
4. Motivacoes de mudancas de design
5. Informacoes tecnicas adicionais relevantes

## Pre-requisitos

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

Obs: Caso em IOS não rode, entrar na pasta ios e rodar:
pod deintegrate
pod install --repo-update
rodar flutter run novamente
```

Credenciais de teste:

- Admin: emilys / emilyspass
- Moderator: oliviaw / oliviawpass

## Executando os Testes

```bash
flutter test
```

## Arquitetura Escolhida e Justificativa

O projeto foi implementado com Clean Architecture por feature, mesmo sendo um escopo de teste tecnico.

### Por que usar Clean Architecture aqui

Mesmo sem necessidade imediata de alta escala, a escolha foi intencional por tres motivos principais:

1. Demonstrar maturidade tecnica e capacidade de estruturar um app com separacao clara de responsabilidades.
2. Facilitar evolucao e manutencao: novas features e mudancas de regras de negocio entram com baixo acoplamento.
3. Melhor testabilidade: domain e use cases podem ser validados de forma isolada de UI e infraestrutura.

### Fluxo de dados

UI -> BLoC/Cubit -> UseCase -> Repository -> DataSource (Remote/Local)

### Como essa arquitetura foi aplicada no codigo

- DI centralizada com get_it em lib/app/core/di/injection_container.dart.
- Rotas e controle de acesso por role com go_router em lib/app/core/routes/app_router.dart.
- Persistencia local offline-first para todos, com merge local/remoto para contornar a nao persistencia da DummyJSON.
- Tratamento de falhas com Either<Failure, T> para evitar excecoes propagando para UI.

## Explicacao da Estrutura de Pastas

```text
lib/app/
|- core/                    # Fundacao compartilhada
|  |- constants/            # Constantes de API e aplicacao
|  |- database/             # SQLite/sqflite e versoes de schema
|  |- di/                   # Registro de dependencias (get_it)
|  |- either/               # Tipo funcional Either
|  |- errors/               # Exceptions e Failures
|  |- network/              # ApiClient (Dio), conectividade, interceptors
|  |- routes/               # go_router e redirecionamentos
|  |- theme/                # AppTheme, ThemeCubit e tokens visuais
|  |- usecases/             # Contrato base de caso de uso
|  |- widgets/              # Componentes reutilizaveis
|
|- features/
|  |- auth/
|  |- todos/
|  |- users/
|  |- quotes/
|  |- dashboard/
|  |- profile/
|  |- splash/
```

Cada feature segue:

```text
feature/
|- domain/
|  |- entities/
|  |- repositories/
|  |- usecases/
|- data/
|  |- datasources/
|  |- models/
|  |- repositories/
|- presentation/
   |- bloc/
   |- pages/
   |- widgets/
```

## Padroes e Tecnologias

| Aspecto | Tecnologia |
|---|---|
| Gerenciamento de estado | BLoC / Cubit |
| Injetor de dependencias | get_it |
| Navegacao | go_router |
| Serializacao | freezed + json_serializable |
| HTTP | Dio |
| Persistencia local | sqflite |
| Storage seguro | flutter_secure_storage |
| Testes | bloc_test + mocktail |

## Motivacoes de Mudancas no Design

Foram feitas adaptacoes de UI alem do layout base para melhorar consistencia visual e legibilidade entre light/dark:

1. Conexao com tema global

- Cores de titulos e elementos de filtro (Todos, Pendentes, Concluidas, Administradores, Moderadores) foram alinhadas ao ThemeData para evitar divergencia entre telas.
- Objetivo: manter paridade visual e funcional nos dois temas sem hardcode de cor por tela.

2. Centralizacao de cor no AppTheme

- Reducao progressiva de condicionais locais (isLight/isDark) em componentes onde a decisao pode ser de tema.
- Ganho: manutencao mais simples e menor risco de regressao quando ajustar paleta.

3. Melhor contraste e estado selecionado

- Filtros/chips passaram por ajustes para deixar estado selecionado claramente perceptivel em light e dark.
- Em pontos com comportamento complexo (como toggle custom de tema no perfil), manteve-se logica local onde faz sentido.

4. Feedback visual consistente

- Componentes de shimmer e cards foram ajustados para seguir tokens de tema e nao refletirem visual de dark no light.

## Informacoes Uteis de Desenvolvimento

### Geração de codigo

Ao alterar models com freezed/json:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### API utilizada

DummyJSON: https://dummyjson.com

- Auth: POST /auth/login, POST /auth/refresh, GET /auth/me
- Todos: GET /todos, GET /todos/user/:id, POST /todos/add, PUT /todos/:id, DELETE /todos/:id
- Users: GET /users
- Quotes: GET /quotes/random

### Nota importante sobre persistencia

A DummyJSON nao persiste escrita real (POST/PUT/DELETE simulados). Por isso, o app usa estrategia offline-first com persistencia local e merge para manter estado consistente entre sessoes.

### Icone do aplicativo

O icone exibido na instalacao do app foi configurado para Android e iOS a partir do asset:

- assets/images/icon_task_radar.png

Geracao realizada com flutter_launcher_icons.

Para regenerar os icones apos trocar o asset:

```bash
flutter pub get
dart run flutter_launcher_icons
```


https://github.com/user-attachments/assets/03cdf315-2e93-4b73-a2d6-e79624efc81b



