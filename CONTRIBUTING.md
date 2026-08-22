# Padronização de Branches do Projeto

Este documento define a convenção e o padrão de nomenclatura de *branches* (ramificações) adotados no projeto. O objetivo é manter o repositório organizado, facilitar a rastreabilidade das alterações e otimizar o fluxo de *Code Review* e *Pull Requests* (PRs).

---

## 1. Estrutura Geral de Nomenclatura

Toda nova branch deve seguir a convenção de nomenclatura baseada no tipo de alteração que ela introduz, utilizando o seguinte formato:

```text
tipo/nome-da-branch
```

### Regras de Formatação
* **Caixa baixa (*lowercase*):** Use apenas letras minúsculas.
* **Separador por hifen (*kebab-case*):** Utilize hífen (`-`) para separar palavras no nome da branch. Evite espaços, *underscores* (`_`) ou caracteres especiais.
* **Clareza e Concisão:** O nome deve resumir a funcionalidade, correção ou tarefa em poucas palavras.

---

## 2. Tipos de Branches

| Prefixo | Finalidade | Exemplo de Uso |
| :--- | :--- | :--- |
| `feat/` | Adição de novas funcionalidades ou melhorias de recursos. | `feat/login-autenticacao` |
| `bugfix/` | Correções de bugs ou falhas identificadas no código. | `bugfix/correcao-calculo-frete` |
| `chore/` | Tarefas de manutenção, configurações, documentação ou adição de dependências. | `chore/atualizacao-readme` |

---

## 3. Detalhamento e Exemplos

### 🛠️ `feat/` — Novas Funcionalidades
Utilize o prefixo `feat/` para o desenvolvimento de novos recursos, criação de telas, novos módulos ou adição de funcionalidades ao sistema.

* **Sintaxe:** `feat/nome-do-recurso`
* **Exemplos:**
  * `feat/filtro-produtos`
  * `feat/exportacao-relatorio-pdf`
  * `feat/integracao-gateway-pagamento`

---

### 🐛 `bugfix/` — Correção de Bugs
Utilize o prefixo `bugfix/` para ajustes, correções de erros ou resolução de comportamentos inesperados no código de uma branch ou ambiente de desenvolvimento.

* **Sintaxe:** `bugfix/descricao-do-bug`
* **Exemplos:**
  * `bugfix/validacao-email-cadastro`
  * `bugfix/alinhamento-botao-mobile`
  * `bugfix/overflow-lista-pedidos`

---

### 🔧 `chore/` — Tarefas Administrativas e Manutenção
Utilize o prefixo `chore/` para mudanças que não alteram a lógica de negócio principal ou o comportamento da aplicação para o usuário final. Inclui documentação, adição de repositórios, atualização de dependências, scripts de build ou configurações do projeto.

* **Sintaxe:** `chore/descricao-da-tarefa`
* **Exemplos:**
  * `chore/adicao-repositorio-maven`
  * `chore/atualizar-documentacao-api`
  * `chore/configuracao-dockerfile`
  * `chore/setup-eslint-prettier`

---

## 4. Boas Práticas

1. **Parta sempre da branch correta:** Certifique-se de atualizar a branch principal (`main` ou `develop`) antes de criar sua nova branch.
2. **Branches Curtas e Focadas:** Mantenha o escopo da branch reduzido. Evite misturar correções de bugs com novas funcionalidades na mesma branch.
3. **Commits Claros:** Utilize mensagens de commit semânticas e descritivas que complementem o padrão de branches (ex: `feat: adiciona componente de modal`).
4. **Remoção de Branches:** Após o *merge* do Pull Request para a branch principal, exclua a branch local e remota para manter o repositório limpo.