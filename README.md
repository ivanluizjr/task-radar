# 📡 Task Radar

## Teste Técnico — Desenvolvedor(a) Mobile Sênior

Bem-vindo(a) ao teste técnico do **Senai Soluções Digitais**!

O **Task Radar** é um aplicativo de gerenciamento de tarefas desenvolvido em Flutter que consome a API pública [DummyJSON](https://dummyjson.com). O objetivo deste teste é avaliar sua capacidade de tomar decisões arquiteturais sólidas, implementar funcionalidades completas e escrever código limpo e testável.

> ⚠️ A API DummyJSON **simula** operações de escrita (POST, PUT, DELETE) — ou seja, os dados não são persistidos no servidor. Isso significa que você precisará implementar **persistência local** para manter a consistência dos dados entre sessões.

### Flutter:

Utilizar:

> Flutter 3.41.4
Tools • Dart 3.11.1 • DevTools 2.54.1

### Figma:

As telas e fluxos foram desenhadas no figma para servirem como base. 

[Link do figma](https://www.figma.com/community/file/1614012000737993326)  

Clicando em "Abrir no figma" o projeto será copiado e associado a sua conta pessoal do figma.

Caso tenha dificuldades em acessar através do figma, disponibilizamos as telas como imagens neste [link do drive](https://drive.google.com/drive/folders/1tsXkODyWKOoZa93XOAEQXjG15tF9H--b?usp=sharing).

- É permitido mudanças e melhorias no design proposto, desde que sigam as funcionalidades previstas.

---

## 🔐 Autenticação

O app deve implementar um fluxo completo de autenticação com JWT auth/refreshtoken:

- Tela de login com campos de usuário e senha
- Validação de campos (não permitir envio com campos vazios)
- Indicador de carregamento durante a requisição
- Mensagem de erro clara em caso de credenciais inválidas

**Credenciais de teste:**
```
username: emilys
password: emilyspass
```

---

## ✅ Gerenciamento de Tarefas (CRUD)

O app deve permitir criar, visualizar, editar e excluir tarefas:

- **Criar:** formulário para adicionar nova tarefa
- **Visualizar:** tela de detalhe ao tocar em uma tarefa
- **Editar:** alterar descrição da tarefa
- **Alternar status:** marcar/desmarcar como concluída
- **Excluir:** remover tarefa
Em caso de falha de rede, manter o estado anterior e exibir mensagem de erro

---

## 📄 Listagem com Paginação

- Carregar tarefas paginadas com parâmetros `limit` e `skip`
- Implementar **scroll infinito** (carregar próxima página ao chegar no final da lista)
- Exibir indicador de carregamento no rodapé da lista durante o fetch
- Parar de buscar quando todas as tarefas forem carregadas

---

## 🔍 Filtro e Busca

- Filtros: todas as tarefas, apenas concluídas, apenas pendentes
- Busca por texto (case-insensitive) no campo de descrição da tarefa
- Ao limpar a busca, restaurar a lista respeitando o filtro ativo
- Exibir indicador visual do filtro/busca ativos
- Opções de ordenação: padrão (por id), alfabética (por texto), por status de conclusão
- Permitir alternar entre ordem crescente e decrescente
- Manter a ordenação ativa quando filtros ou busca estiverem aplicados

---

## 💾 Persistência Local (Offline-First)

Como a API não persiste dados, o app **deve** implementar persistência local:

- Cachear os dados da API no primeiro fetch
- Aplicar mudanças (criar/editar/excluir) no armazenamento local imediatamente
- Servir dados do cache quando não houver conexão

---

## 👤 Perfil do Usuário

- Buscar dados do usuário autenticado 
- Loading skeleton/indicador durante o carregamento
- Mensagem de erro com opção de retry em caso de falha

---

## Tema light/dark

- Implementar ambos temas e permitir que usuários alternem entre eles.

---

## 🛡️ Controle por Role (Admin vs Moderator)

A API retorna o campo `role` do usuário (`"admin"` ou `"moderator"`). O app deve se comportar de forma diferente conforme o papel:

- **Admin:** exibe uma seção "Usuários" na navegação com a lista de todos os usuários
- Ao tocar em um usuário, exibir as tarefas dele`
- **Moderator:** não tem acesso à seção de usuários, vê apenas suas próprias tarefas
- Esconder itens de navegação e rotas que não se aplicam ao role do usuário
- Se um moderator tentar acessar uma rota de admin, redirecionar para o dashboard

> A API não impõe restrições por role — o controle de acesso deve ser implementado no client.

---

## 🏠 Dashboard

- Exibir resumo: total de tarefas, concluídas e pendentes
- Buscar e exibir uma frase motivacional aleatória via `GET /quotes/random` (texto + autor)
- Loading independente para cada seção do dashboard
- Fallback caso a busca da frase falhe

---

## 🏗️ Arquitetura e Qualidade de Código

Este é um teste para **Desenvolvedor(a) Sênior**. Esperamos ver decisões arquiteturais bem fundamentadas:

| Aspecto | Expectativa |
|---|---|
| **Arquitetura** |Separação clara entre as responsabilidades  |
| **Injeção de dependência** | Uso de uma solução de DI (get_it) |
| **Gerenciamento de estado** | Utilizar BLOC |
| **Serialização** | Classes de modelo com serialização/deserialização JSON (json_serializable/freezed) |
| **Rotas** | Gerenciamento declarativo de rotas (go_router) |

---

## 📚 Referência da API

| Recurso | Endpoint | Método |
|---|---|---|
| Login | `/auth/login` | POST |
| Refresh token | `/auth/refresh` | POST |
| Usuário autenticado | `/auth/me` | GET |
| Listar tarefas | `/todos` | GET |
| Tarefa por ID | `/todos/{id}` | GET |
| Tarefa aleatória | `/todos/random` | GET |
| Tarefas por usuário | `/todos/user/{userId}` | GET |
| Criar tarefa | `/todos/add` | POST |
| Atualizar tarefa | `/todos/{id}` | PUT/PATCH |
| Excluir tarefa | `/todos/{id}` | DELETE |
| Listar usuários | `/users` | GET |
| Usuário por ID | `/users/{id}` | GET |
| Buscar usuários | `/users/search?q=` | GET |
| Filtrar usuários | `/users/filter?key=&value=` | GET |
| Ordenar usuários | `/users?sortBy=&order=` | GET |
| Listar frases | `/quotes` | GET |
| Frase aleatória | `/quotes/random` | GET |

**Paginação:** todos os endpoints de listagem suportam `?limit=X&skip=Y`

**Delay para testes:** `?delay=1000` (0 a 5000ms)

**Documentação completa:** [https://dummyjson.com/docs](https://dummyjson.com/docs)

---

# 📝 O que entregar

1. Código-fonte completo do projeto Flutter commitado na branch `main`
2. Documentação no arquivo **CONTRIBUTING.md** contendo:
   - Arquitetura escolhida e justificativa
   - Explicação da estrutura de pastas
   - Instruções para build e execução do projeto
   - Motivações de eventuais mudanças no design
   - Demais informações que você considerar útil o compartilhamento

Boa sorte! 🚀