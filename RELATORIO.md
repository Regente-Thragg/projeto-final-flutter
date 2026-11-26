# Relatório de Evolução — App Final + Nuvem (Dicas de Filme)

## Cenário Escolhido
- **Tema:** Dicas de filme
- **Campos:** Título, sinopse, avaliação, imagem e comentário
- **Infraestrutura em nuvem:** Supabase (`projeto-final-flutter`)
- **Arquitetura:** App Usuário (`lib/main.dart`) e App Admin (`lib/admin.dart`)

## Registro de Commits e Evolução

### Commit 1 — Estrutura inicial do projeto e documentação
- Criação/organização do projeto Flutter e estrutura inicial em `lib/`.
- Criação do `RELATORIO.md` para documentar o passo a passo do desenvolvimento até 09/12.
- Definição do cenário de Dicas de Filme integrado ao Supabase.
- Vinculação do repositório remoto no GitHub (`Regente-Thragg/projeto-final-flutter`).

### Commit 2 — Configuração do Supabase e modelo de dados
- Criação do projeto `projeto-final-flutter` no Supabase e obtenção da URL do projeto e da Publishable Key.
- Criação da tabela `filmes` no Supabase com os campos `titulo`, `sinopse`, `avaliacao`, `imagem_url`, `comentario` e `created_at`, além das políticas RLS iniciais.
- Adição do pacote `supabase_flutter` e criação do modelo `lib/models/filme.dart`.

### Commit 3 — Configuração do Supabase no app e tela administrativa (`lib/admin.dart`)
- Criação do arquivo `lib/supabase_config.dart` para centralizar a inicialização do Supabase.
- Implementação do `lib/admin.dart` com formulário para cadastro e envio de novos filmes para o banco na nuvem.

### Commit 4 — Implementação da timeline no App Usuário (`lib/main.dart`)
- Criação da tela de timeline em `lib/main.dart` consumindo os filmes cadastrados na tabela `filmes` do Supabase.
- Exibição de título, sinopse, avaliação, imagem e comentário em cards, com suporte a atualizar/recarregar a lista.
- Atualização do `RELATORIO.md` registrando o avanço da etapa.

### Próximos Passos (até 09/12)
- Testar o fluxo ponta a ponta (cadastrar via `lib/admin.dart` e conferir na timeline via `lib/main.dart`).
- Manter ao menos 2 commits verificáveis por semana e atualizar o `RELATORIO.md` a cada passo concluído.