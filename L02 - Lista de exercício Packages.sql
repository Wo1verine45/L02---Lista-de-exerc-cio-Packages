SET SERVEROUTPUT ON;
/*
Objetivo:
Desenvolver um conjunto de pacotes em PL/SQL que implementem operações relacionadas às 
entidades Aluno, Disciplina e Professor, utilizando o Oracle como banco de dados. O trabalho 
busca consolidar os conhecimentos de criação e uso de procedures, functions e cursores, com 
ênfase em operações que envolvam parâmetros, cálculos e manipulação de dados.

Descrição da Atividade:
Implemente os pacotes conforme especificado a seguir:

Pacote PKG_ALUNO
*/
CREATE OR REPLACE PACKAGE PKG_ALUNO IS
    PROCEDURE SP_EXCLUI_ALUNO(p_id_aluno IN NUMBER);
    
/* 
Cursor de listagem de alunos maiores de 18 anos:
Desenvolva um cursor que liste o nome e a data de nascimento de todos os alunos com idade 
superior a 18 anos.
*/ 
    CURSOR alunos_adultos IS
        SELECT nome, data_nascimento
        FROM aluno
        WHERE TRUNC(MONTHS_BETWEEN(SYSDATE, data_nascimento) / 12) > 18;

/*   
Cursor com filtro por curso:
Crie um cursor parametrizado que receba o id_curso e exiba os nomes dos alunos matriculados no curso especificado.
*/
    CURSOR alunos_por_curso(p_id_curso IN NUMBER) IS
        SELECT DISTINCT a.id_aluno, a.nome
        FROM aluno a
        JOIN matricula m ON a.id_aluno = m.id_aluno
        JOIN disciplina d ON m.id_disciplina = d.id_disciplina
        WHERE d.id_curso = p_id_curso;
END PKG_ALUNO;

CREATE OR REPLACE PACKAGE BODY PKG_ALUNO IS
/*
Procedure de exclusão de aluno:
Crie uma procedure que receba o ID de um aluno como parâmetro e exclua o registro 
correspondente na tabela de alunos. Além disso, todas as matrículas associadas ao aluno devem 
ser removidas.
*/
    PROCEDURE SP_EXCLUI_ALUNO(p_id_aluno IN NUMBER) IS
    BEGIN
        DELETE FROM matricula
        WHERE id_aluno = p_id_aluno;
        
        DELETE FROM aluno
        WHERE id_aluno = p_id_aluno;
    END SP_EXCLUI_ALUNO;

END PKG_ALUNO;


--Pacote PKG_DISCIPLINA
CREATE OR REPLACE PACKAGE PKG_DISCIPLINA IS
    PROCEDURE SP_CADASTRA_DISCIPLINA(
        p_nome IN VARCHAR2,
        p_descricao IN CLOB,
        p_carga_horaria IN NUMBER
    );

/*
Cursor para total de alunos por disciplina:
Implemente um cursor que percorra as disciplinas e exiba o número total de alunos matriculados em cada uma. Exiba apenas as disciplinas com mais de 10 alunos.
*/
    CURSOR disciplinas_com_mais_de_10_alunos IS
        SELECT d.nome AS disciplina, COUNT(m.id_aluno) AS total_alunos
        FROM disciplina d
        JOIN matricula m ON d.id_disciplina = m.id_disciplina
        GROUP BY d.nome
        HAVING COUNT(m.id_aluno) > 10;

/*
Cursor com média de idade por disciplina:
Desenvolva um cursor parametrizado que receba o id_disciplina e calcule a média de idade dos alunos matriculados na disciplina especificada.
*/
    CURSOR media_idade_por_disciplina(p_id_disciplina IN NUMBER) IS
        SELECT AVG(TRUNC(MONTHS_BETWEEN(SYSDATE, a.data_nascimento) / 12)) AS media_idade
        FROM aluno a
        JOIN matricula m ON a.id_aluno = m.id_aluno
        WHERE m.id_disciplina = p_id_disciplina;

    PROCEDURE SP_LISTA_ALUNOS_DISCIPLINA(
        p_id_disciplina IN NUMBER
    );
END PKG_DISCIPLINA;

CREATE OR REPLACE PACKAGE BODY PKG_DISCIPLINA IS
/*
Procedure de cadastro de disciplina:
Crie uma procedure para cadastrar uma nova disciplina. A procedure deve receber como parâmetros o nome, a descrição e a carga horária da disciplina e inserir esses dados na tabela correspondente.
*/
    PROCEDURE SP_CADASTRA_DISCIPLINA(
        p_nome IN VARCHAR2,
        p_descricao IN CLOB,
        p_carga_horaria IN NUMBER
    ) IS
    BEGIN
        INSERT INTO disciplina (nome, descricao, carga_horaria)
        VALUES (p_nome, p_descricao, p_carga_horaria);
    END SP_CADASTRA_DISCIPLINA;

/*
Procedure para listar alunos de uma disciplina:
Implemente uma procedure que receba o ID de uma disciplina como parâmetro e exiba os nomes dos alunos matriculados nela.
*/
    PROCEDURE SP_LISTA_ALUNOS_DISCIPLINA(
        p_id_disciplina IN NUMBER
    ) IS
    BEGIN
        FOR aluno IN (
            SELECT DISTINCT a.nome
            FROM aluno a
            JOIN matricula m ON a.id_aluno = m.id_aluno
            WHERE m.id_disciplina = p_id_disciplina
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('Aluno: ' || aluno.nome);
        END LOOP;
    END SP_LISTA_ALUNOS_DISCIPLINA;
END PKG_DISCIPLINA;


--Pacote PKG_PROFESSOR
CREATE OR REPLACE PACKAGE PKG_PROFESSOR IS
/*
Cursor para total de turmas por professor:
Desenvolva um cursor que liste os nomes dos professores e o total de turmas que cada um leciona. O cursor deve exibir apenas os professores responsáveis por mais de uma turma.
*/
    CURSOR total_turmas_por_professor IS
        SELECT p.nome AS professor, COUNT(t.id_turma) AS total_turmas
        FROM professor p
        JOIN turma t ON p.id_professor = t.id_professor
        GROUP BY p.nome
        HAVING COUNT(t.id_turma) > 1;

    FUNCTION total_turmas_professor(p_id_professor IN NUMBER) RETURN NUMBER;

    FUNCTION professor_de_disciplina(p_id_disciplina IN NUMBER) RETURN VARCHAR2;
END PKG_PROFESSOR;

CREATE OR REPLACE PACKAGE BODY PKG_PROFESSOR IS
/*
Function para total de turmas de um professor:
Crie uma function que receba o ID de um professor como parâmetro e retorne o total de turmas em que ele atua como responsável.
*/
    FUNCTION total_turmas_professor(p_id_professor IN NUMBER) RETURN NUMBER IS
        v_total_turmas NUMBER;
    BEGIN
        SELECT COUNT(id_turma)
        INTO v_total_turmas
        FROM turma
        WHERE id_professor = p_id_professor;
        
        RETURN v_total_turmas;
    END total_turmas_professor;

/*
Function para professor de uma disciplina:
Desenvolva uma function que receba o ID de uma disciplina como parâmetro e retorne o nome do professor que ministra essa disciplina.
*/
    FUNCTION professor_de_disciplina(p_id_disciplina IN NUMBER) RETURN VARCHAR2 IS
        v_nome_professor VARCHAR2(100);
    BEGIN
        SELECT p.nome
        INTO v_nome_professor
        FROM professor p
        JOIN turma t ON p.id_professor = t.id_professor
        WHERE t.id_disciplina = p_id_disciplina;

        RETURN v_nome_professor;
    END professor_de_disciplina;

END PKG_PROFESSOR;


DECLARE
    -- Variáveis para testes
    v_nome_disciplina VARCHAR2(100);
    v_media_idade NUMBER;
    v_professor_nome VARCHAR2(100);
    v_total_turmas NUMBER;
    v_total_alunos NUMBER;
    v_id_disciplina NUMBER := 1;  
    v_id_professor NUMBER := 1;   
    v_id_aluno NUMBER := 1;       
    v_id_curso NUMBER := 1;       
BEGIN
    -- Teste da Procedure SP_EXCLUI_ALUNO (excluir aluno com ID específico)
    PKG_ALUNO.SP_EXCLUI_ALUNO(v_id_aluno);
    DBMS_OUTPUT.PUT_LINE('Aluno excluído com ID: ' || v_id_aluno);

    -- Teste do Cursor alunos_adultos (exibir alunos maiores de 18 anos)
    FOR aluno IN PKG_ALUNO.alunos_adultos LOOP
        DBMS_OUTPUT.PUT_LINE('Aluno: ' || aluno.nome || ' | Data de Nascimento: ' || aluno.data_nascimento);
    END LOOP;

    -- Teste do Cursor alunos_por_curso (listar alunos matriculados em um curso)
    FOR aluno IN PKG_ALUNO.alunos_por_curso(v_id_curso) LOOP
        DBMS_OUTPUT.PUT_LINE('Aluno: ' || aluno.nome || ' | Curso ID: ' || v_id_curso);
    END LOOP;

    -- Teste da Procedure SP_CADASTRA_DISCIPLINA (cadastrar uma nova disciplina)
    PKG_DISCIPLINA.SP_CADASTRA_DISCIPLINA('Matemática Avançada', 'Disciplina de Matemática para alunos do 2º ano', 60);
    DBMS_OUTPUT.PUT_LINE('Disciplina cadastrada: Matemática Avançada');

    -- Teste do Cursor disciplinas_com_mais_de_10_alunos (exibir disciplinas com mais de 10 alunos)
    FOR disciplina IN PKG_DISCIPLINA.disciplinas_com_mais_de_10_alunos LOOP
        DBMS_OUTPUT.PUT_LINE('Disciplina: ' || disciplina.disciplina || ' | Total de Alunos: ' || disciplina.total_alunos);
    END LOOP;

    -- Teste do Cursor media_idade_por_disciplina (calcular média de idade por disciplina)
    OPEN PKG_DISCIPLINA.media_idade_por_disciplina(v_id_disciplina);
    FETCH PKG_DISCIPLINA.media_idade_por_disciplina INTO v_media_idade;
    CLOSE PKG_DISCIPLINA.media_idade_por_disciplina;
    DBMS_OUTPUT.PUT_LINE('Média de Idade para Disciplina ID ' || v_id_disciplina || ': ' || v_media_idade);

    -- Teste da Procedure SP_LISTA_ALUNOS_DISCIPLINA (listar alunos matriculados na disciplina)
    PKG_DISCIPLINA.SP_LISTA_ALUNOS_DISCIPLINA(v_id_disciplina);

    -- Teste da Function total_turmas_professor (exibir o total de turmas de um professor)
    v_total_turmas := PKG_PROFESSOR.total_turmas_professor(v_id_professor);
    DBMS_OUTPUT.PUT_LINE('Total de turmas do professor ID ' || v_id_professor || ': ' || v_total_turmas);

    -- Teste da Function professor_de_disciplina (exibir o nome do professor de uma disciplina)
    v_professor_nome := PKG_PROFESSOR.professor_de_disciplina(v_id_disciplina);
    DBMS_OUTPUT.PUT_LINE('Professor da Disciplina ID ' || v_id_disciplina || ': ' || v_professor_nome);

    -- Teste do Cursor total_turmas_por_professor (listar professores com mais de uma turma)
    FOR professor IN PKG_PROFESSOR.total_turmas_por_professor LOOP
        DBMS_OUTPUT.PUT_LINE('Professor: ' || professor.professor || ' | Total de Turmas: ' || professor.total_turmas);
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
END;
/

/*
Instruções:

O código deve ser testado no ambiente Oracle.
Organize todos os comandos e pacotes em um único arquivo com a extensão .sql.
Submeta o trabalho por meio de um repositório no GitHub. O repositório deve conter:
O arquivo .sql contendo o código completo.
Um arquivo README.md explicando como executar o script no Oracle e um resumo do que cada pacote faz.
Critérios de Avaliação:

Correção e funcionalidade do código desenvolvido.
Uso correto de procedures, functions e cursores.
Adequação às especificações da atividade.
Clareza, organização e boas práticas de programação.
Organização e documentação no repositório GitHub.
*/