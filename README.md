# L02---Lista-de-exercício-Packages

Este projeto contém scripts em PL/SQL para gerenciar informações acadêmicas em um banco de dados Oracle. Ele inclui **procedures**, **functions** e **cursors** organizados em **packages** para facilitar a execução de operações relacionadas a alunos, disciplinas e professores.

## Estrutura do Projeto

O projeto contém três pacotes principais:

1. **PKG_ALUNO**  
   Contém funcionalidades relacionadas a alunos:
   - **SP_EXCLUI_ALUNO(p_id_aluno IN NUMBER):** Exclui um aluno e todas as suas matrículas associadas.
   - **Cursor alunos_adultos:** Lista alunos maiores de 18 anos, mostrando seus nomes e datas de nascimento.
   - **Cursor alunos_por_curso(p_id_curso IN NUMBER):** Lista os alunos matriculados em um curso específico.

2. **PKG_DISCIPLINA**  
   Contém funcionalidades relacionadas a disciplinas:
   - **SP_CADASTRA_DISCIPLINA(p_nome IN VARCHAR2, p_descricao IN CLOB, p_carga_horaria IN NUMBER):** Cadastra uma nova disciplina.
   - **Cursor disciplinas_com_mais_de_10_alunos:** Lista disciplinas com mais de 10 alunos matriculados.
   - **Cursor media_idade_por_disciplina(p_id_disciplina IN NUMBER):** Calcula a média de idade dos alunos de uma disciplina específica.
   - **SP_LISTA_ALUNOS_DISCIPLINA(p_id_disciplina IN NUMBER):** Lista os alunos matriculados em uma disciplina, exibindo seus nomes.

3. **PKG_PROFESSOR**  
   Contém funcionalidades relacionadas a professores:
   - **Cursor total_turmas_por_professor:** Lista professores e o total de turmas lecionadas (exibe apenas os que têm mais de uma turma).
   - **Function total_turmas_professor(p_id_professor IN NUMBER):** Retorna o total de turmas lecionadas por um professor.
   - **Function professor_de_disciplina(p_id_disciplina IN NUMBER):** Retorna o nome do professor que ministra uma disciplina específica.

---

## Pré-requisitos

1. Banco de dados Oracle instalado.
2. Oracle SQL Developer ou outra ferramenta para execução de scripts SQL/PLSQL.
3. Tabelas previamente configuradas:
   - **aluno:** contém informações dos alunos.
   - **disciplina:** contém informações das disciplinas.
   - **matricula:** relaciona alunos às disciplinas.
   - **professor:** contém informações dos professores.
   - **turma:** relaciona professores às turmas e disciplinas.

---

## Como executar o projeto

### 1. Configuração inicial

Certifique-se de que todas as tabelas necessárias estão criadas no banco de dados Oracle. Aqui estão os exemplos básicos de criação (modifique conforme sua necessidade):

```sql
CREATE TABLE aluno (
    id_aluno NUMBER PRIMARY KEY,
    nome VARCHAR2(100),
    data_nascimento DATE
);

CREATE TABLE disciplina (
    id_disciplina NUMBER PRIMARY KEY,
    nome VARCHAR2(100),
    descricao CLOB,
    carga_horaria NUMBER
);

CREATE TABLE matricula (
    id_matricula NUMBER PRIMARY KEY,
    id_aluno NUMBER,
    id_disciplina NUMBER,
    FOREIGN KEY (id_aluno) REFERENCES aluno(id_aluno),
    FOREIGN KEY (id_disciplina) REFERENCES disciplina(id_disciplina)
);

CREATE TABLE professor (
    id_professor NUMBER PRIMARY KEY,
    nome VARCHAR2(100)
);

CREATE TABLE turma (
    id_turma NUMBER PRIMARY KEY,
    id_professor NUMBER,
    id_disciplina NUMBER,
    FOREIGN KEY (id_professor) REFERENCES professor(id_professor),
    FOREIGN KEY (id_disciplina) REFERENCES disciplina(id_disciplina)
);
```

2. Importar os pacotes
  Abra o Oracle SQL Developer.
  Copie e cole os scripts dos pacotes (PKG_ALUNO, PKG_DISCIPLINA, PKG_PROFESSOR) na interface do SQL Developer.
  Execute os scripts pressionando F5 ou clicando no botão Executar.

3. Testar os pacotes

  Teste de exclusão de aluno:
```sql
BEGIN
    PKG_ALUNO.SP_EXCLUI_ALUNO(1);
END;
```

  Teste do cursor alunos_adultos:
```sql
BEGIN
    FOR aluno IN PKG_ALUNO.alunos_adultos LOOP
        DBMS_OUTPUT.PUT_LINE('Aluno: ' || aluno.nome || ' | Data de Nascimento: ' || aluno.data_nascimento);
    END LOOP;
END;
```

  Teste do cursor alunos_por_curso:
```sql
BEGIN
    FOR aluno IN PKG_ALUNO.alunos_por_curso(1) LOOP
        DBMS_OUTPUT.PUT_LINE('Aluno: ' || aluno.nome);
    END LOOP;
END;
```

  Teste do cadastro de disciplina:
```sql
BEGIN
    PKG_DISCIPLINA.SP_CADASTRA_DISCIPLINA('Matemática', 'Curso de matemática básica', 40);
END;
```

  Teste do cursor disciplinas_com_mais_de_10_alunos:
```sql
BEGIN
    FOR disciplina IN PKG_DISCIPLINA.disciplinas_com_mais_de_10_alunos LOOP
        DBMS_OUTPUT.PUT_LINE('Disciplina: ' || disciplina.disciplina || ' | Total de Alunos: ' || disciplina.total_alunos);
    END LOOP;
END;
```

  Teste do cursor total_turmas_por_professor:
```sql
BEGIN
    FOR professor IN PKG_PROFESSOR.total_turmas_por_professor LOOP
        DBMS_OUTPUT.PUT_LINE('Professor: ' || professor.professor || ' | Total de Turmas: ' || professor.total_turmas);
    END LOOP;
END;
```

Observações:
  Certifique-se de configurar corretamente o banco de dados com os dados iniciais para os testes.
  Use o comando SET SERVEROUTPUT ON; no SQL Developer para habilitar a exibição de mensagens no console.
