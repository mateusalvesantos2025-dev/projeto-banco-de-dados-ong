-- =====================================================================
-- ENTREGA 2 — BANCO COMPLETO (SQLite, para TESTE) — ONG Nossa Senhora de Fátima
-- Junta, nesta ordem: 01_estrutura + 02_massa_de_dados + 03_consultas
-- Seções: 1 CREATE · 2-3 tabelas e constraints · 4 massa · 5 SELECT com JOIN
--         6 UPDATE e DELETE · 7 consultas gerenciais (G) e de auditoria (A)
-- Rodar de novo do início ZERA o banco e recria tudo.
-- =====================================================================

-- =====================================================================
-- ENTREGA 2 — SCRIPT SQL (versão SQLite, para TESTE) — ARQUIVO 1/3: ESTRUTURA
-- Organização Social Nossa Senhora de Fátima
-- A versão oficial da entrega é a MySQL (o enunciado exige MySQL).
-- Depois rode: 02_massa_de_dados_sqlite.sql e 03_consultas_sqlite.sql
-- ATENÇÃO: rodar este arquivo de novo APAGA todas as tabelas.
-- =====================================================================

-- =====================================================================
-- 1. "CREATE DATABASE" — no SQLite o banco é o próprio arquivo .db que
--    você cria/abre na ferramenta. Aqui só ligamos as FKs e zeramos.
-- =====================================================================
PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS entrega_cesta;
DROP TABLE IF EXISTS recebimento_doacao;
DROP TABLE IF EXISTS pia;
DROP TABLE IF EXISTS encaminhamento_atendimento;
DROP TABLE IF EXISTS atendimento;
DROP TABLE IF EXISTS referencia_familiar;
DROP TABLE IF EXISTS composicao_familiar;
DROP TABLE IF EXISTS trabalho;
DROP TABLE IF EXISTS beneficiario;
DROP TABLE IF EXISTS profissional_responsavel;

-- =====================================================================
-- 2 e 3. CREATE TABLE com constraints (PK, FK, NOT NULL, UNIQUE, CHECK)
--    No SQLite as constraints precisam ficar dentro do CREATE TABLE
--    (não existe ALTER TABLE ... ADD CONSTRAINT).
--    DATE é guardado como texto 'AAAA-MM-DD'; os CHECKs "date(x) IS x"
--    recusam datas inválidas (ex.: '30/10/2026' ou '2026-02-30').
-- =====================================================================

CREATE TABLE profissional_responsavel (
  id_profissional        INTEGER PRIMARY KEY AUTOINCREMENT,
  nome                   VARCHAR(150) NOT NULL,
  funcao                 VARCHAR(50)  NOT NULL,
  registro_profissional  VARCHAR(30)  NOT NULL,
  CONSTRAINT uq_profissional_registro UNIQUE (registro_profissional)
);

CREATE TABLE beneficiario (
  id_beneficiario             INTEGER PRIMARY KEY AUTOINCREMENT,
  nis                         VARCHAR(15),
  cras_creas_sas              VARCHAR(100),
  nome_completo               VARCHAR(150) NOT NULL,
  nome_social                 VARCHAR(150),
  sexo                        CHAR(1)      NOT NULL,
  orientacao_sexual           VARCHAR(30),
  data_nascimento             DATE         NOT NULL,
  naturalidade                VARCHAR(100),
  cor_raca                    VARCHAR(20),
  pessoa_com_deficiencia      VARCHAR(100),
  tem_alergias                VARCHAR(150),
  cpf                         VARCHAR(14),
  rg_numero                   VARCHAR(20),
  rg_orgao_uf_emissor         VARCHAR(20),
  rg_data_emissao             DATE,
  estado_civil                VARCHAR(20),
  endereco                    VARCHAR(200) NOT NULL,
  bairro                      VARCHAR(100),
  cep                         VARCHAR(9),
  telefone                    VARCHAR(20),
  nome_mae                    VARCHAR(150),
  nome_pai                    VARCHAR(150),
  escolaridade                VARCHAR(50),
  estuda_atualmente           VARCHAR(100),
  recebe_transferencia_renda  VARCHAR(100),
  recebe_bpc                  VARCHAR(50),
  situacao_cadastro           VARCHAR(20)  NOT NULL DEFAULT 'ATIVO',
  data_consentimento          DATE         NOT NULL,
  cadunico_ativo              TINYINT(1)   NOT NULL DEFAULT 0,
  data_atualizacao_cadunico   DATE,
  CONSTRAINT uq_beneficiario_cpf UNIQUE (cpf),
  CONSTRAINT uq_beneficiario_nis UNIQUE (nis),
  CONSTRAINT ck_beneficiario_situacao CHECK (situacao_cadastro IN ('ATIVO', 'ANONIMIZADO')),
  CONSTRAINT ck_beneficiario_cadunico CHECK (cadunico_ativo IN (0, 1)),
  CONSTRAINT ck_beneficiario_sexo CHECK (sexo IN ('F', 'M', 'O')),
  CONSTRAINT ck_beneficiario_datas CHECK (
        date(data_nascimento)           IS data_nascimento
    AND date(rg_data_emissao)           IS rg_data_emissao
    AND date(data_consentimento)        IS data_consentimento
    AND date(data_atualizacao_cadunico) IS data_atualizacao_cadunico)
);

CREATE TABLE trabalho (
  id_trabalho            INTEGER PRIMARY KEY AUTOINCREMENT,
  id_beneficiario        INTEGER      NOT NULL,
  situacao_ocupacional   VARCHAR(50)  NOT NULL,
  profissao_habilidades  TEXT,
  renda_atual            DECIMAL(10,2),
  empresa_trabalho       VARCHAR(150),
  ocupacao_atual         VARCHAR(100),
  telefone_trabalho      VARCHAR(20),
  CONSTRAINT ck_trabalho_renda CHECK (renda_atual IS NULL OR renda_atual >= 0),
  CONSTRAINT fk_trabalho_beneficiario FOREIGN KEY (id_beneficiario)
    REFERENCES beneficiario (id_beneficiario) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE composicao_familiar (
  id_membro           INTEGER PRIMARY KEY AUTOINCREMENT,
  id_beneficiario     INTEGER      NOT NULL,
  nome                VARCHAR(150) NOT NULL,
  nome_social         VARCHAR(150),
  idade               TINYINT      NOT NULL,
  parentesco_vinculo  VARCHAR(50)  NOT NULL,
  CONSTRAINT ck_composicao_idade CHECK (idade BETWEEN 0 AND 120),
  CONSTRAINT fk_composicao_beneficiario FOREIGN KEY (id_beneficiario)
    REFERENCES beneficiario (id_beneficiario) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE referencia_familiar (
  id_referencia       INTEGER PRIMARY KEY AUTOINCREMENT,
  id_beneficiario     INTEGER      NOT NULL,
  nome                VARCHAR(150) NOT NULL,
  nome_social         VARCHAR(150),
  parentesco_vinculo  VARCHAR(50),
  telefone            VARCHAR(20),
  CONSTRAINT fk_referencia_beneficiario FOREIGN KEY (id_beneficiario)
    REFERENCES beneficiario (id_beneficiario) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE atendimento (
  id_atendimento    INTEGER PRIMARY KEY AUTOINCREMENT,
  id_beneficiario   INTEGER NOT NULL,
  id_profissional   INTEGER NOT NULL,
  data_atendimento  DATE    NOT NULL,
  demanda_inicial   TEXT    NOT NULL,
  CONSTRAINT ck_atendimento_data CHECK (date(data_atendimento) IS data_atendimento),
  CONSTRAINT fk_atendimento_beneficiario FOREIGN KEY (id_beneficiario)
    REFERENCES beneficiario (id_beneficiario) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_atendimento_profissional FOREIGN KEY (id_profissional)
    REFERENCES profissional_responsavel (id_profissional) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE encaminhamento_atendimento (
  id_encaminhamento    INTEGER PRIMARY KEY AUTOINCREMENT,
  id_atendimento       INTEGER     NOT NULL,
  tipo_encaminhamento  VARCHAR(60) NOT NULL,
  detalhe_outros       TEXT,
  CONSTRAINT ck_encaminhamento_outros CHECK (tipo_encaminhamento <> 'Outros' OR detalhe_outros IS NOT NULL),
  CONSTRAINT fk_encaminhamento_atendimento FOREIGN KEY (id_atendimento)
    REFERENCES atendimento (id_atendimento) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE pia (
  id_pia             INTEGER PRIMARY KEY AUTOINCREMENT,
  id_beneficiario    INTEGER NOT NULL,
  id_profissional    INTEGER NOT NULL,
  data_criacao       DATE    NOT NULL,
  metas_objetivos    TEXT    NOT NULL,
  prazo_reavaliacao  DATE,
  CONSTRAINT ck_pia_datas CHECK (date(data_criacao) IS data_criacao AND date(prazo_reavaliacao) IS prazo_reavaliacao),
  CONSTRAINT ck_pia_prazo CHECK (prazo_reavaliacao IS NULL OR prazo_reavaliacao >= data_criacao),
  CONSTRAINT fk_pia_beneficiario FOREIGN KEY (id_beneficiario)
    REFERENCES beneficiario (id_beneficiario) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_pia_profissional FOREIGN KEY (id_profissional)
    REFERENCES profissional_responsavel (id_profissional) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE entrega_cesta (
  id_entrega         INTEGER PRIMARY KEY AUTOINCREMENT,
  id_beneficiario    INTEGER NOT NULL,
  id_profissional    INTEGER NOT NULL,
  data_entrega       DATE    NOT NULL,
  quantidade_cestas  INTEGER NOT NULL,
  itens_adicionais   TEXT,
  CONSTRAINT ck_entrega_data CHECK (date(data_entrega) IS data_entrega),
  CONSTRAINT ck_entrega_quantidade CHECK (quantidade_cestas > 0),
  CONSTRAINT fk_entrega_beneficiario FOREIGN KEY (id_beneficiario)
    REFERENCES beneficiario (id_beneficiario) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_entrega_profissional FOREIGN KEY (id_profissional)
    REFERENCES profissional_responsavel (id_profissional) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE recebimento_doacao (
  id_recebimento    INTEGER PRIMARY KEY AUTOINCREMENT,
  id_profissional   INTEGER      NOT NULL,
  parceiro_doador   VARCHAR(100) NOT NULL,
  data_recebimento  DATE         NOT NULL,
  descricao_itens   TEXT         NOT NULL,
  quantidade_total  INTEGER      NOT NULL,
  CONSTRAINT ck_recebimento_data CHECK (date(data_recebimento) IS data_recebimento),
  CONSTRAINT ck_recebimento_quantidade CHECK (quantidade_total > 0),
  CONSTRAINT fk_recebimento_profissional FOREIGN KEY (id_profissional)
    REFERENCES profissional_responsavel (id_profissional) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Índices: busca frequente (RNF02) + colunas de FK (o SQLite não cria sozinho)
CREATE INDEX idx_beneficiario_nome        ON beneficiario (nome_completo);
CREATE INDEX idx_trabalho_beneficiario    ON trabalho (id_beneficiario);
CREATE INDEX idx_composicao_beneficiario  ON composicao_familiar (id_beneficiario);
CREATE INDEX idx_referencia_beneficiario  ON referencia_familiar (id_beneficiario);
CREATE INDEX idx_atendimento_beneficiario ON atendimento (id_beneficiario);
CREATE INDEX idx_atendimento_profissional ON atendimento (id_profissional);
CREATE INDEX idx_atendimento_data         ON atendimento (data_atendimento);
CREATE INDEX idx_encaminhamento_atend     ON encaminhamento_atendimento (id_atendimento);
CREATE INDEX idx_pia_beneficiario         ON pia (id_beneficiario);
CREATE INDEX idx_pia_profissional         ON pia (id_profissional);
CREATE INDEX idx_entrega_beneficiario     ON entrega_cesta (id_beneficiario);
CREATE INDEX idx_entrega_profissional     ON entrega_cesta (id_profissional);
CREATE INDEX idx_entrega_data             ON entrega_cesta (data_entrega);
CREATE INDEX idx_recebimento_profissional ON recebimento_doacao (id_profissional);
CREATE INDEX idx_recebimento_data         ON recebimento_doacao (data_recebimento);

-- Conferência: deve listar 10 tabelas
SELECT name AS tabela
FROM sqlite_master
WHERE type = 'table' AND name NOT LIKE 'sqlite%'
ORDER BY name;


-- =====================================================================
-- ENTREGA 2 — SCRIPT SQL (SQLite) — ARQUIVO 2/3: MASSA DE DADOS
-- 4. INSERT INTO — massa de dados FICTÍCIA e coerente
-- Pré-requisito: 01_estrutura_sqlite.sql
-- ---------------------------------------------------------------------
-- Nenhum nome, CPF, NIS, RG, endereço ou telefone pertence a pessoa real.
-- Os nomes da equipe técnica também são fictícios.
--
-- VOLUME — justificado pelo porte levantado na E1
--   * ~250 famílias atendidas fixamente  -> 250 beneficiários
--   * lote de 150 cestas a cada 2 meses  -> 2 lotes (01/07 e 01/09/2026)
--     cestas entregues: 151 no bimestre jul-ago e 149 no set-out
--     (critério simulado: 2 cestas para famílias com 4+ pessoas)
--   * doações esporádicas (Banco de Alimentos, Cidade Invisível,
--     particulares e paróquia) -> 19 recebimentos no total
--   * equipe: 1 assistente social, 2 técnicos voluntários (CRESS/CRP)
--     e a presidência
-- PERÍODO — operação simulada de 01/07 a 30/10/2026 (2 bimestres).
--   Atendimentos anteriores = histórico digitalizado das fichas em papel.
--
-- CASOS IRREGULARES INCLUÍDOS DE PROPÓSITO (para a auditoria não voltar vazia)
--   A01 entregas lançadas antes da 1ª triagem       (RN03)
--   A02 entregas a famílias fora do critério RN06   (exceções a justificar)
--   A03 duas entregas no mesmo mês para a mesma família (RN06)
--   A04 CadÚnico "ativo" sem atualização há mais de 24 meses (RN06)
--   A05 cadastros sem atendimento há mais de 5 anos e ainda ATIVOS (RN07)
--   A06 consentimento LGPD registrado depois do 1º atendimento (RN07)
--   A07 família com 6 membros e família com 4 referências (RN10)
--   A08 registros feitos pela presidência, sem CRESS/CRP (RN11)
--
-- Se rodar este arquivo 2 vezes dá erro de chave duplicada — é o esperado.
-- Para repetir, rode antes o 01_estrutura_sqlite.sql.
-- =====================================================================

PRAGMA foreign_keys = ON;  -- no SQLite as FKs vêm desligadas: rode sempre esta linha

-- ---------------------------------------------------------------------
-- PROFISSIONAL_RESPONSAVEL — Equipe técnica (registros de conselho fictícios) + presidência sem registro (A08)
-- ---------------------------------------------------------------------
INSERT INTO profissional_responsavel (id_profissional, nome, funcao, registro_profissional) VALUES
  (1, 'Ana Paula Ribeiro', 'Assistente Social', 'CRESS-SP 90001'),
  (2, 'Carlos Eduardo Lima', 'Psicólogo (voluntário)', 'CRP 06/90002'),
  (3, 'Fernanda Souza Alves', 'Assistente Social (voluntária)', 'CRESS-SP 90003'),
  (4, 'Roberto Almeida Nogueira', 'Presidente', 'SEM REGISTRO - Presidência');

-- ---------------------------------------------------------------------
-- BENEFICIARIO — 250 famílias (porte da E1), em ordem de cadastro; 2 já anonimizadas (RN07)
-- ---------------------------------------------------------------------
INSERT INTO beneficiario (id_beneficiario, nis, cras_creas_sas, nome_completo, nome_social, sexo, orientacao_sexual, data_nascimento, naturalidade, cor_raca, pessoa_com_deficiencia, tem_alergias, cpf, rg_numero, rg_orgao_uf_emissor, rg_data_emissao, estado_civil, endereco, bairro, cep, telefone, nome_mae, nome_pai, escolaridade, estuda_atualmente, recebe_transferencia_renda, recebe_bpc, situacao_cadastro, data_consentimento, cadunico_ativo, data_atualizacao_cadunico) VALUES
  (1, NULL, 'CRAS Mooca', 'ANONIMIZADO-1', NULL, 'M', NULL, '1943-10-20', 'Feira de Santana/BA', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Casado', 'ANONIMIZADO', 'Mooca', NULL, NULL, NULL, NULL, 'Ensino Médio completo', 'Não', NULL, 'Sim', 'ANONIMIZADO', '2019-04-22', 1, '2026-08-27'),
  (2, NULL, 'CRAS Mooca', 'ANONIMIZADO-2', NULL, 'F', NULL, '1968-11-28', 'São Paulo/SP', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Divorciada', 'ANONIMIZADO', 'Belém', NULL, NULL, NULL, NULL, 'Ensino Fundamental incompleto', 'Não', 'Bolsa Família', 'Não', 'ANONIMIZADO', '2019-04-30', 1, '2025-04-04'),
  (3, '15115567817', 'CREAS Mooca', 'Jéssica Araújo Soares', NULL, 'F', NULL, '1996-02-10', 'Salvador/BA', NULL, NULL, NULL, '499.257.602-82', '28.817.817-8', 'SSP/SP', '2020-03-24', 'Solteira', 'Rua dos Cedros, 980, apto 15', 'Belém', '03117-939', '(11) 95394-8442', 'Renata Alves Soares', 'Lucas Soares', 'Ensino Fundamental incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2020-06-02', 1, '2025-09-01'),
  (4, '12320246721', 'CRAS Mooca', 'Francisco Rodrigues Vieira', NULL, 'M', NULL, '1954-09-21', 'São Paulo/SP', NULL, NULL, NULL, '192.897.206-83', '43.858.421-5', 'SSP/SP', '1991-08-21', 'Solteiro', 'Rua dos Manacás, 1413, fundos', 'Brás', '03319-063', '(11) 96607-6948', 'Jéssica Teixeira Vieira', NULL, 'Ensino Médio incompleto', 'Não', NULL, 'Sim', 'ATIVO', '2020-08-01', 0, NULL),
  (5, '24916769617', 'CRAS Mooca', 'Ana Machado Freitas', NULL, 'F', NULL, '1965-09-27', 'São Luís/MA', NULL, NULL, NULL, '153.658.612-05', '24.660.212-4', 'SSP/MG', '2013-09-22', 'Solteira', 'Viela das Margaridas, 982, apto 3', 'Mooca', '03301-923', '(11) 93167-4259', 'Neide Cavalcanti Freitas', 'Manoel Freitas', 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2020-11-11', 1, '2025-06-08'),
  (6, '20693157929', 'CREAS Mooca', 'Juliana Nunes Moreira', NULL, 'F', NULL, '1977-05-12', 'São Paulo/SP', NULL, NULL, NULL, '995.220.622-69', '45.091.876-3', 'SSP/SP', '2003-05-16', 'Solteira', 'Travessa das Violetas, 642', 'Belém', '03338-861', '(11) 95491-5754', 'Neide Ferreira Moreira', NULL, 'Ensino Fundamental incompleto', 'Sim - EJA', NULL, 'Não', 'ATIVO', '2021-01-13', 1, '2025-01-22'),
  (7, '27416774501', NULL, 'Adilson Gonçalves Machado', NULL, 'M', NULL, '1971-10-15', 'São Paulo/SP', 'Parda', NULL, NULL, '528.093.122-89', '27.013.695-4', 'SSP/CE', '2023-10-27', 'Casado', 'Rua das Palmeiras, 1135, fundos', 'Mooca', '03236-407', '(11) 97403-2521', 'Helena Andrade Machado', 'José Machado', 'Ensino Médio completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2021-02-09', 1, '2024-12-28'),
  (8, '14513467618', 'CREAS Mooca', 'Cristiane de Lima Santos', NULL, 'F', NULL, '2002-11-16', 'Salvador/BA', NULL, 'Deficiência intelectual', 'Lactose', '118.607.966-13', '29.537.515-7', 'SSP/SP', '2022-12-19', 'União estável', 'Rua dos Coqueiros, 168, casa 2', 'Cambuci', '03256-410', '(11) 92370-2313', 'Maria Ribeiro Santos', 'Josué Santos', 'Ensino Fundamental incompleto', 'Não', NULL, 'Sim', 'ATIVO', '2021-03-25', 1, '2025-06-14'),
  (9, '15804549125', NULL, 'Maria da Silva Barbosa', NULL, 'F', NULL, '1978-09-03', 'São Paulo/SP', NULL, NULL, NULL, '553.987.088-55', '42.721.095-2', 'SSP/SP', '2016-02-25', 'Casada', 'Rua dos Jacarandás, 1207, casa 2', 'Água Rasa', '03186-208', '(11) 99328-2106', 'Jéssica Martins Barbosa', 'Luiz Barbosa', 'Ensino Superior completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2021-11-17', 1, '2025-11-26'),
  (10, NULL, 'CRAS Belém', 'Fernanda Lima Moura', NULL, 'F', NULL, '1998-01-27', 'São Paulo/SP', 'Branca', 'Deficiência intelectual', NULL, '208.936.299-62', '24.835.337-1', 'SSP/SP', '2020-08-26', 'União estável', 'Rua dos Lírios, 1201', 'Brás', '03230-561', '(11) 93263-5361', 'Fernanda Freitas Moura', NULL, 'Ensino Médio completo', 'Sim - ensino superior', NULL, 'Não', 'ATIVO', '2021-12-25', 1, '2025-07-02'),
  (11, NULL, 'CREAS Mooca', 'Débora Nunes Gomes', NULL, 'F', NULL, '1953-05-09', 'Recife/PE', NULL, NULL, NULL, '274.586.025-84', '29.158.646-2', 'SSP/SP', '1997-05-20', 'Solteira', 'Travessa das Violetas, 966, fundos', 'Água Rasa', '03112-803', '(11) 96977-1723', 'Priscila Souza Gomes', NULL, 'Ensino Médio incompleto', 'Não', NULL, 'Sim', 'ATIVO', '2022-01-12', 1, '2025-09-16'),
  (12, '19204999309', NULL, 'Fernanda Rocha Pereira', NULL, 'F', NULL, '1962-09-27', 'São Paulo/SP', NULL, NULL, NULL, '940.107.238-29', '51.481.538-2', 'SSP/MG', '1982-12-12', 'Casada', 'Rua dos Coqueiros, 1297', 'Mooca', '03148-194', '(11) 96660-7578', 'Antônia Freitas Pereira', 'Gabriel Pereira', 'Ensino Fundamental incompleto', 'Não', NULL, 'Não', 'ATIVO', '2022-01-31', 0, NULL),
  (13, NULL, NULL, 'Daniela Carvalho Soares', NULL, 'F', 'Prefere não informar', '1964-11-02', 'São Paulo/SP', NULL, NULL, NULL, '602.302.795-50', '55.822.054-6', 'SSP/SP', '2021-07-13', 'União estável', 'Rua dos Manacás, 158, apto 5', 'Vila Prudente', '03163-173', '(11) 95424-4709', 'Simone Pinto Soares', 'Wellington Soares', 'Ensino Fundamental incompleto', 'Não', NULL, 'Não', 'ATIVO', '2022-02-13', 1, '2026-01-05'),
  (14, '14402501210', 'CRAS Mooca', 'Ana Alves Rocha', NULL, 'F', 'Prefere não informar', '1998-08-21', 'São Paulo/SP', NULL, 'Deficiência física', NULL, '210.396.078-05', '44.918.140-9', 'SSP/SP', '2017-04-23', 'Divorciada', 'Rua dos Girassóis, 1172', 'Mooca', '03370-136', '(11) 99341-7597', 'Cristiane Rodrigues Rocha', NULL, 'Ensino Fundamental completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2022-02-18', 1, '2025-05-23'),
  (15, NULL, 'CRAS Mooca', 'Luciana Santana Brito', NULL, 'F', NULL, '1969-05-10', 'São Paulo/SP', 'Parda', NULL, NULL, '912.921.961-68', '30.293.695-2', 'SSP/SP', '2020-12-04', 'Solteira', 'Sem endereço fixo (situação de rua)', 'Mooca', NULL, NULL, 'Adriana Pinto Brito', NULL, 'Ensino Médio incompleto', 'Sim - EJA', 'Bolsa Família', 'Não', 'ATIVO', '2022-04-24', 1, '2026-01-02'),
  (16, '28402410969', 'CRAS Mooca', 'Josefa de Freitas Ferreira', NULL, 'F', NULL, '1959-08-21', 'São Paulo/SP', 'Parda', NULL, NULL, '841.052.677-46', '23.521.476-9', 'SSP/SP', '2020-06-08', 'Casada', 'Rua dos Coqueiros, 586, fundos', 'Mooca', '03304-848', '(11) 91734-4998', 'Vera Ribeiro Ferreira', 'Wellington Ferreira', 'Ensino Médio incompleto', 'Não', NULL, 'Sim', 'ATIVO', '2022-05-14', 1, '2026-10-10'),
  (17, '21711229032', 'CRAS Mooca', 'José Cardoso Dias', NULL, 'M', NULL, '1985-04-28', 'Recife/PE', 'Branca', NULL, NULL, '706.966.390-45', '21.034.594-8', 'SSP/MG', '2015-11-13', 'Solteiro', 'Rua dos Manacás, 191, apto 47', 'Mooca', '03113-797', '(11) 99188-7678', 'Michele Santos Dias', 'Josué Dias', 'Ensino Médio completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2022-06-27', 1, '2025-02-12'),
  (18, '15637089228', NULL, 'Silvana Monteiro Gomes', NULL, 'F', NULL, '1951-02-14', 'São Paulo/SP', 'Amarela', NULL, NULL, NULL, '39.794.449-4', 'SSP/SP', '2003-07-15', 'Solteira', 'Rua das Hortênsias, 241, apto 11', 'Brás', '03342-924', '(11) 93593-2387', 'Cláudia Ferreira Gomes', NULL, 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2022-07-16', 1, '2026-09-03'),
  (19, NULL, 'CRAS Belém', 'Anderson Mendes Lima', NULL, 'M', NULL, '1995-06-19', 'São Paulo/SP', 'Branca', NULL, NULL, '982.176.064-68', '47.160.899-2', 'SSP/SP', '2015-01-05', 'Solteiro', 'Rua dos Jacarandás, 1167', 'Mooca', '03350-092', '(11) 91450-3081', 'Cristiane Monteiro Lima', 'Rafael Lima', 'Ensino Fundamental incompleto', 'Não', NULL, 'Não', 'ATIVO', '2022-08-14', 0, NULL),
  (20, '13422054246', 'CRAS Belém', 'Larissa Martins Cardoso', NULL, 'F', NULL, '1944-06-11', 'São Paulo/SP', 'Branca', NULL, NULL, '814.413.222-37', '58.293.420-0', 'SSP/MG', '1994-05-16', 'Divorciada', 'Rua dos Lírios, 104', 'Mooca', '03237-729', '(11) 92888-5657', 'Joana Pereira Cardoso', NULL, 'Ensino Fundamental incompleto', 'Não', NULL, 'Não', 'ATIVO', '2022-08-15', 1, '2025-08-06'),
  (21, '11807902698', NULL, 'João Araújo Martins', NULL, 'M', 'Prefere não informar', '1993-09-04', 'São Paulo/SP', 'Amarela', NULL, NULL, '623.746.925-09', '28.961.269-4', 'SSP/SP', '2019-03-22', 'Solteiro', 'Avenida das Figueiras, 1380, casa 2', 'Mooca', '03168-775', '(11) 93814-6752', 'Cláudia Batista Martins', NULL, 'Sem escolaridade', 'Não', NULL, 'Não', 'ATIVO', '2022-09-05', 1, '2026-09-13'),
  (22, '21183082343', 'CRAS Mooca', 'Carlos Araújo Correia', NULL, 'M', 'Prefere não informar', '1974-09-16', 'São Paulo/SP', 'Preta', NULL, NULL, '945.921.755-07', '46.775.455-9', 'SSP/SP', '1996-04-23', 'Solteiro', 'Rua das Orquídeas, 560', 'Brás', '03235-922', '(11) 91189-6461', 'Sônia Fernandes Correia', NULL, 'Ensino Médio incompleto', 'Não', NULL, 'Não', 'ATIVO', '2022-10-02', 1, '2025-11-12'),
  (23, NULL, 'CRAS Mooca', 'Patrícia Rocha Ribeiro', NULL, 'F', NULL, '1954-08-23', 'São Paulo/SP', 'Parda', NULL, NULL, '891.445.077-66', '11.420.599-4', 'SSP/SP', '2006-08-11', 'Casada', 'Rua dos Girassóis, 1334, apto 35', 'Mooca', '03207-252', '(11) 92336-5479', 'Vanessa Santos Ribeiro', 'Thiago Ribeiro', 'Ensino Fundamental completo', 'Não', NULL, 'Não', 'ATIVO', '2022-10-07', 1, '2026-01-02'),
  (24, '17847745876', 'CRAS Belém', 'Carlos Teixeira Silva', NULL, 'M', NULL, '1986-05-27', 'São Paulo/SP', NULL, NULL, NULL, '914.879.712-34', '37.966.233-1', 'SSP/PE', '2022-05-26', 'Casado', 'Rua dos Coqueiros, 236', 'Brás', '03328-947', '(11) 97263-8180', 'Joana Pereira Silva', NULL, 'Ensino Fundamental incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2022-10-08', 1, '2025-02-02'),
  (25, NULL, 'CRAS Mooca', 'Aline Silva Ribeiro', NULL, 'F', NULL, '1983-05-22', 'São Paulo/SP', 'Branca', NULL, NULL, '445.131.685-42', '14.850.497-6', 'SSP/SP', '2023-02-22', 'Casada', 'Rua dos Coqueiros, 1375, fundos', 'Mooca', '03334-553', '(11) 96652-6185', 'Bruna Dias Ribeiro', 'José Ribeiro', 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2022-10-24', 1, '2025-05-29'),
  (26, '19394255100', 'CREAS Mooca', 'Wellington Ramos Souza', NULL, 'M', NULL, '1960-09-13', 'Salvador/BA', 'Parda', NULL, NULL, '840.505.514-43', '50.285.043-3', 'SSP/SP', '1984-06-01', 'Casado', 'Rua das Orquídeas, 1273', 'Mooca', '03267-467', '(11) 96125-9700', 'Francisca Cardoso Souza', NULL, 'Ensino Fundamental completo', 'Sim - ensino superior', NULL, 'Sim', 'ATIVO', '2022-11-03', 1, '2026-07-08'),
  (27, NULL, 'CRAS Mooca', 'Juliana Santos Pereira', NULL, 'F', NULL, '1996-10-02', 'Recife/PE', 'Parda', NULL, NULL, '696.915.589-22', '30.786.126-4', 'SSP/SP', '2023-08-23', 'Solteira', 'Rua das Hortênsias, 1031, fundos', 'Belém', '03331-193', '(11) 98873-6014', 'Kelly Rodrigues Pereira', 'Thiago Pereira', 'Ensino Fundamental incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2022-12-12', 1, '2025-11-29'),
  (28, '18648579527', 'CRAS Mooca', 'Rita Ramos Cardoso', NULL, 'F', 'Prefere não informar', '1993-01-23', 'Campina Grande/PB', 'Preta', NULL, NULL, '277.745.458-34', '23.849.125-4', 'SSP/PE', '2018-07-21', 'Casada', 'Viela das Margaridas, 217', 'Belém', '03270-816', '(11) 95787-2200', 'Tatiane Teixeira Cardoso', 'Gabriel Cardoso', 'Ensino Médio completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2023-01-30', 1, '2025-04-17'),
  (29, NULL, 'CRAS Belém', 'Ivone Barbosa Pinto', NULL, 'F', NULL, '1996-10-11', 'São Paulo/SP', 'Branca', NULL, NULL, '477.910.071-10', '25.367.920-9', 'SSP/PE', '2019-04-19', 'Divorciada', 'Avenida das Figueiras, 309, apto 4', 'Brás', '03303-362', '(11) 95993-8037', 'Ana Rocha Pinto', 'Josué Pinto', 'Ensino Fundamental incompleto', 'Não', NULL, 'Não', 'ATIVO', '2023-02-21', 1, '2025-01-23'),
  (30, '28328369955', 'CRAS Mooca', 'Rosângela Moreira Rocha', NULL, 'F', NULL, '1971-05-05', 'São Paulo/SP', NULL, NULL, NULL, '436.460.784-22', '26.627.823-0', 'SSP/SP', '2012-06-03', 'Solteira', 'Rua dos Cedros, 437, fundos', 'Mooca', '03274-865', '(11) 91048-7958', 'Fernanda Monteiro Rocha', 'Diego Rocha', 'Ensino Fundamental completo', 'Não', NULL, 'Não', 'ATIVO', '2023-03-07', 1, '2025-07-17'),
  (31, '28728659363', 'CRAS Belém', 'Rodrigo Ramos Fernandes', NULL, 'M', NULL, '1983-09-09', 'São Luís/MA', 'Branca', NULL, NULL, '458.081.615-72', '58.759.198-6', 'SSP/SP', '2009-07-21', 'União estável', 'Rua das Acácias, 1350', 'Mooca', '03286-146', '(11) 97768-9364', 'Maria Rocha Fernandes', 'Wellington Fernandes', 'Ensino Fundamental incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2023-03-14', 1, '2026-09-07'),
  (32, NULL, 'CRAS Belém', 'Michele Cardoso Nunes', NULL, 'F', NULL, '1997-05-10', 'Salvador/BA', 'Preta', NULL, NULL, '449.244.595-71', '11.512.008-9', 'SSP/SP', '2019-04-23', 'Solteira', 'Travessa das Violetas, 279, casa 2', 'Brás', '03242-335', '(11) 95830-4710', 'Débora Pinto Nunes', 'José Nunes', 'Ensino Fundamental incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2023-03-15', 1, '2022-06-16'),
  (33, NULL, 'CRAS Mooca', 'Juliana Fernandes Farias', NULL, 'F', 'Prefere não informar', '1979-08-27', 'Guarulhos/SP', 'Parda', NULL, NULL, '272.343.973-13', '19.981.416-0', 'SSP/SP', '2000-12-09', 'Casada', 'Avenida das Figueiras, 1114, apto 33', 'Tatuapé', '03199-531', '(11) 93582-1479', 'Edna Cardoso Farias', 'Pedro Farias', 'Ensino Fundamental incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2023-03-31', 1, '2025-12-18'),
  (34, NULL, 'CRAS Belém', 'Renata Cavalcanti Moreira', NULL, 'F', NULL, '1977-09-14', 'São Paulo/SP', 'Preta', NULL, NULL, '494.311.926-34', '57.465.724-6', 'SSP/SP', '2003-06-27', 'Viúva', 'Rua dos Coqueiros, 652', 'Vila Prudente', '03395-428', NULL, 'Priscila Oliveira Moreira', 'Eduardo Moreira', 'Ensino Superior incompleto', 'Não', NULL, 'Não', 'ATIVO', '2023-04-06', 1, '2025-10-18'),
  (35, '23886241882', NULL, 'Rodrigo Ramos Cardoso', NULL, 'M', NULL, '1967-08-19', 'Montes Claros/MG', 'Branca', NULL, NULL, '323.648.192-58', '45.950.094-1', 'SSP/PE', '1994-06-21', 'Solteiro', 'Rua dos Ipês, 663', 'Mooca', '03258-589', '(11) 94553-3956', 'Márcia Marques Cardoso', NULL, 'Ensino Fundamental completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2023-04-07', 1, '2026-09-24'),
  (36, NULL, 'CRAS Belém', 'Paulo de Freitas Almeida', NULL, 'M', NULL, '1969-08-11', 'Teresina/PI', NULL, NULL, NULL, '191.818.191-97', '38.317.770-7', 'SSP/SP', '2005-08-18', 'Divorciado', 'Rua das Orquídeas, 131', 'Belém', '03189-398', '(11) 94041-8254', 'Regina Freitas Almeida', 'Diego Almeida', 'Ensino Médio completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2023-04-08', 1, '2024-07-01'),
  (37, NULL, 'CRAS Mooca', 'Valdir Martins Rodrigues', NULL, 'M', NULL, '1997-11-23', 'Maceió/AL', NULL, 'Deficiência visual', NULL, NULL, NULL, NULL, NULL, 'Casado', 'Sem endereço fixo (situação de rua)', 'Mooca', NULL, '(11) 97149-3634', 'Patrícia Barbosa Rodrigues', 'José Rodrigues', 'Sem escolaridade', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2023-04-28', 1, '2026-05-30'),
  (38, '19672472511', 'CRAS Mooca', 'Gabriel Marques Cavalcanti', NULL, 'M', 'Prefere não informar', '1960-06-05', 'São Paulo/SP', 'Parda', NULL, NULL, '467.993.036-38', '37.321.220-5', 'SSP/SP', '1982-03-02', 'Solteiro', 'Rua das Begônias, 847, fundos', 'Tatuapé', '03220-492', '(11) 95140-8994', 'Neide Moura Cavalcanti', 'Gabriel Cavalcanti', 'Ensino Superior incompleto', 'Não', NULL, 'Sim', 'ATIVO', '2023-05-17', 1, '2022-02-12'),
  (39, '28312050957', 'CRAS Belém', 'Michele Mendes Correia', NULL, 'F', 'Prefere não informar', '1955-04-26', 'Maceió/AL', 'Branca', NULL, NULL, '665.911.517-93', '18.136.168-5', 'SSP/CE', '1993-10-26', 'União estável', 'Rua das Begônias, 875, fundos', 'Tatuapé', '03238-201', '(11) 92457-8257', 'Aline Ferreira Correia', 'Gilberto Correia', 'Ensino Fundamental incompleto', 'Não', NULL, 'Sim', 'ATIVO', '2023-05-18', 0, NULL),
  (40, '19387289180', 'CRAS Mooca', 'Silvana Ribeiro Rodrigues', NULL, 'F', NULL, '1958-05-05', 'São Paulo/SP', 'Parda', NULL, NULL, '367.518.115-07', '50.837.748-7', 'SSP/CE', '2016-07-03', 'Solteira', 'Rua das Palmeiras, 84, casa 2', 'Água Rasa', '03106-516', '(11) 93203-4269', 'Patrícia Oliveira Rodrigues', NULL, 'Ensino Médio completo', 'Não', NULL, 'Sim', 'ATIVO', '2023-06-03', 0, NULL),
  (41, NULL, NULL, 'Bruna Ferreira Lima', NULL, 'F', NULL, '1965-04-10', 'Montes Claros/MG', NULL, NULL, NULL, '608.799.438-20', '32.876.847-3', 'SSP/SP', '2024-08-08', 'Solteira', 'Rua dos Girassóis, 548, fundos', 'Tatuapé', '03259-892', '(11) 98266-7525', 'Ana Oliveira Lima', NULL, 'Ensino Médio completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2023-06-04', 1, '2022-03-05'),
  (42, '17861536763', 'CRAS Belém', 'Cícero Pereira Gomes', NULL, 'M', NULL, '1998-02-25', 'São Paulo/SP', NULL, NULL, NULL, '763.333.343-72', '13.091.257-6', 'SSP/SP', '2020-09-04', 'Solteiro', 'Rua das Orquídeas, 522', 'Belém', '03203-681', '(11) 92635-2999', 'Josefa Moreira Gomes', NULL, 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2023-06-09', 1, '2025-10-26'),
  (43, NULL, 'CRAS Mooca', 'Larissa Teixeira Lopes', NULL, 'F', NULL, '2000-07-09', 'Recife/PE', 'Amarela', NULL, NULL, '586.100.384-95', '49.189.291-4', 'SSP/SP', '2019-05-17', 'Divorciada', 'Travessa das Violetas, 659', 'Vila Prudente', '03341-156', '(11) 94994-6445', 'Edna Batista Lopes', NULL, 'Ensino Médio incompleto', 'Sim - EJA', 'Bolsa Família', 'Não', 'ATIVO', '2023-06-16', 1, '2025-10-13'),
  (44, NULL, 'CREAS Mooca', 'Regina Dias Andrade', NULL, 'F', NULL, '1949-12-03', 'Salvador/BA', 'Preta', NULL, NULL, '220.897.670-13', '30.915.419-7', 'SSP/SP', '2004-12-20', 'Divorciada', 'Rua dos Jacarandás, 1398', 'Mooca', '03159-912', NULL, 'Renata Araújo Andrade', 'Edson Andrade', 'Ensino Fundamental incompleto', 'Não', NULL, 'Sim', 'ATIVO', '2023-06-17', 1, '2025-10-19'),
  (45, '15591502066', 'CRAS Belém', 'Bruna Souza Santana', NULL, 'F', NULL, '1963-11-06', 'Natal/RN', 'Preta', NULL, 'Lactose', '129.633.548-28', '14.840.269-7', 'SSP/SP', '2007-05-17', 'União estável', 'Rua dos Ipês, 609', 'Tatuapé', '03245-738', '(11) 92027-9580', 'Ana Nascimento Santana', NULL, 'Ensino Fundamental incompleto', 'Sim - EJA', NULL, 'Não', 'ATIVO', '2023-06-22', 1, '2026-07-07'),
  (46, '19456551473', 'CRAS Mooca', 'Tatiane Gomes Souza', NULL, 'F', NULL, '1963-05-01', 'São Paulo/SP', 'Parda', NULL, NULL, '757.301.409-67', '31.236.236-6', 'SSP/SP', '1987-07-19', 'Viúva', 'Rua dos Ipês, 239', 'Vila Prudente', '03110-566', '(11) 96300-4695', 'Francisca Ramos Souza', NULL, 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2023-07-01', 1, '2025-11-02'),
  (47, '16306130803', 'CRAS Mooca', 'Bruna Cavalcanti Alves', NULL, 'F', NULL, '1966-11-19', 'Montes Claros/MG', NULL, NULL, NULL, '563.136.919-61', '13.284.383-2', 'SSP/SP', '1994-12-31', 'União estável', 'Rua das Hortênsias, 1186', 'Vila Prudente', '03102-706', '(11) 93540-8000', 'Josefa Fernandes Alves', 'Lucas Alves', 'Ensino Médio incompleto', 'Não', NULL, 'Não', 'ATIVO', '2023-07-03', 1, '2025-12-09'),
  (48, '26391679132', 'CRAS Belém', 'Fernanda Carvalho Ribeiro', NULL, 'F', NULL, '1996-08-13', 'Fortaleza/CE', 'Parda', NULL, NULL, '717.741.964-48', '25.944.130-1', 'SSP/SP', '2019-08-06', 'Divorciada', 'Rua dos Lírios, 1002, apto 9', 'Mooca', '03287-698', '(11) 91956-1527', 'Rita Lopes Ribeiro', 'Marcelo Ribeiro', 'Ensino Fundamental incompleto', 'Não', NULL, 'Não', 'ATIVO', '2023-08-09', 1, '2026-02-15'),
  (49, '28103451119', 'CRAS Mooca', 'Francisca Ramos Freitas', NULL, 'F', NULL, '1989-11-16', 'São Paulo/SP', NULL, NULL, NULL, '706.277.281-02', '27.745.036-7', 'SSP/SP', '2010-09-18', 'Solteira', 'Rua das Acácias, 1091, apto 36', 'Água Rasa', '03320-643', '(11) 92001-4876', 'Priscila Lopes Freitas', 'Severino Freitas', 'Ensino Fundamental incompleto', 'Não', NULL, 'Não', 'ATIVO', '2023-08-23', 1, '2025-10-25'),
  (50, NULL, 'CRAS Mooca', 'Thiago de Lima Pereira', NULL, 'M', NULL, '1979-04-17', 'São Paulo/SP', 'Parda', NULL, NULL, '538.810.931-82', '38.055.228-3', 'SSP/SP', '2016-02-15', 'Casado', 'Rua dos Coqueiros, 740, apto 39', 'Mooca', '03303-318', '(11) 94132-8777', 'Silvana Santana Pereira', 'Gilberto Pereira', 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2023-08-28', 0, NULL);

INSERT INTO beneficiario (id_beneficiario, nis, cras_creas_sas, nome_completo, nome_social, sexo, orientacao_sexual, data_nascimento, naturalidade, cor_raca, pessoa_com_deficiencia, tem_alergias, cpf, rg_numero, rg_orgao_uf_emissor, rg_data_emissao, estado_civil, endereco, bairro, cep, telefone, nome_mae, nome_pai, escolaridade, estuda_atualmente, recebe_transferencia_renda, recebe_bpc, situacao_cadastro, data_consentimento, cadunico_ativo, data_atualizacao_cadunico) VALUES
  (51, '13018358012', NULL, 'Severino Nunes Oliveira', NULL, 'M', NULL, '1988-08-07', 'Salvador/BA', 'Amarela', NULL, NULL, '312.791.877-32', '14.241.105-7', 'SSP/SP', '2020-03-19', 'Casado', 'Rua dos Jacarandás, 537', 'Belém', '03379-525', '(11) 99668-7091', 'Daniela Correia Oliveira', 'Luiz Oliveira', 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2023-09-04', 1, '2026-04-24'),
  (52, '11462790290', 'CRAS Belém', 'Jéssica Ribeiro Lima', NULL, 'F', NULL, '2003-09-03', 'Guarulhos/SP', 'Parda', NULL, NULL, '738.768.219-13', '19.085.930-6', 'SSP/BA', '2022-07-08', 'Divorciada', 'Rua dos Girassóis, 489, casa 2', 'Mooca', '03211-713', '(11) 96202-7259', 'Daniela Soares Lima', NULL, 'Ensino Fundamental completo', 'Sim - EJA', 'Bolsa Família', 'Não', 'ATIVO', '2023-09-20', 1, '2025-08-29'),
  (53, '11667453276', 'CRAS Mooca', 'Tatiane Gonçalves Marques', NULL, 'F', NULL, '1948-09-05', 'São Paulo/SP', 'Branca', NULL, NULL, '247.135.224-81', '55.322.786-0', 'SSP/BA', '1984-05-17', 'Solteira', 'Travessa das Violetas, 804', 'Tatuapé', '03307-239', '(11) 98464-9914', 'Antônia Souza Marques', 'Lucas Marques', 'Ensino Fundamental completo', 'Não', NULL, 'Sim', 'ATIVO', '2023-09-29', 1, '2025-04-15'),
  (54, '11150830026', 'CRAS Belém', 'Priscila Santana Pereira', NULL, 'F', 'Prefere não informar', '2003-06-24', 'Guarulhos/SP', 'Parda', NULL, NULL, '664.747.085-17', '46.027.044-7', 'SSP/SP', '2021-09-08', 'Solteira', 'Travessa das Violetas, 68, fundos', 'Belém', '03191-914', '(11) 91189-1202', 'Rosângela Souza Pereira', 'Rodrigo Pereira', 'Ensino Fundamental incompleto', 'Sim - curso técnico', NULL, 'Não', 'ATIVO', '2023-09-30', 1, '2026-03-27'),
  (55, NULL, 'CRAS Mooca', 'Juliana Moura Moreira', NULL, 'F', NULL, '1991-04-23', 'São Paulo/SP', NULL, NULL, NULL, '564.835.786-65', '30.232.956-0', 'SSP/SP', '2015-10-21', 'Solteira', 'Rua das Palmeiras, 209', 'Brás', '03244-012', '(11) 95485-6502', 'Joana Moura Moreira', 'José Moreira', 'Ensino Fundamental incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2023-11-10', 1, '2026-07-17'),
  (56, NULL, 'CRAS Mooca', 'Adriana Pereira Lima', NULL, 'F', NULL, '1973-01-12', 'Maceió/AL', 'Parda', NULL, NULL, '803.852.347-61', '21.824.409-7', 'SSP/SP', '2024-08-23', 'União estável', 'Rua dos Cedros, 191, fundos', 'Belém', '03365-981', '(11) 98035-1433', 'Vanessa Oliveira Lima', NULL, 'Ensino Fundamental incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2023-11-18', 1, '2025-10-30'),
  (57, NULL, NULL, 'Ana Nascimento Fernandes', NULL, 'F', NULL, '1970-04-16', 'Maceió/AL', 'Preta', NULL, NULL, '715.906.567-51', '43.108.202-2', 'SSP/SP', '2002-09-02', 'Solteira', 'Rua dos Coqueiros, 503', 'Mooca', '03307-666', '(11) 97313-1332', 'Josefa Souza Fernandes', NULL, 'Ensino Superior incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2023-11-22', 1, '2026-04-23'),
  (58, NULL, 'CRAS Mooca', 'Juliana Farias Ribeiro', NULL, 'F', NULL, '1946-09-01', 'Recife/PE', NULL, NULL, 'Glúten', '943.773.065-46', '41.056.419-9', 'SSP/SP', '1987-11-03', 'Divorciada', 'Travessa das Violetas, 365', 'Brás', '03142-598', '(11) 93687-5278', 'Vanessa Brito Ribeiro', 'Adilson Ribeiro', 'Ensino Médio completo', 'Não', NULL, 'Sim', 'ATIVO', '2023-11-25', 1, '2024-08-09'),
  (59, '19943751941', 'CRAS Mooca', 'Simone Correia Moreira', NULL, 'F', NULL, '1948-05-14', 'Guarulhos/SP', 'Amarela', NULL, NULL, '841.490.037-46', '49.780.178-9', 'SSP/PE', '1986-09-11', 'Casada', 'Rua das Palmeiras, 1033', 'Tatuapé', '03124-869', '(11) 98939-5315', 'Valéria Ramos Moreira', NULL, 'Ensino Médio incompleto', 'Não', NULL, 'Sim', 'ATIVO', '2024-01-08', 1, '2026-06-01'),
  (60, '19974709638', 'CRAS Mooca', 'Elaine Silva Monteiro', NULL, 'F', NULL, '1958-03-19', 'Feira de Santana/BA', 'Parda', NULL, NULL, '791.179.899-27', '23.082.173-1', 'SSP/SP', '2016-06-05', 'União estável', 'Rua dos Jacarandás, 881, fundos', 'Mooca', '03124-094', '(11) 98777-5521', 'Raimunda Machado Monteiro', NULL, 'Ensino Fundamental incompleto', 'Não', NULL, 'Sim', 'ATIVO', '2024-01-10', 1, '2025-01-13'),
  (61, '22524402774', 'CRAS Mooca', 'Letícia Ferreira Freitas', NULL, 'F', NULL, '1983-12-04', 'São Paulo/SP', NULL, 'Deficiência visual', NULL, '496.179.095-64', '56.661.165-3', 'SSP/SP', '2013-02-16', 'Solteira', 'Rua das Acácias, 654', 'Mooca', '03234-313', '(11) 95092-2547', 'Camila Silva Freitas', 'Manoel Freitas', 'Ensino Médio incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2024-02-01', 1, '2026-10-20'),
  (62, '18286192255', 'CRAS Mooca', 'Rodrigo Fernandes Rocha', NULL, 'M', NULL, '1970-07-25', 'São Paulo/SP', NULL, NULL, NULL, '449.197.850-83', '29.811.988-8', 'SSP/SP', '1991-09-06', 'Solteiro', 'Rua das Orquídeas, 353', 'Cambuci', '03246-601', '(11) 98494-4458', 'Ana Soares Rocha', NULL, 'Ensino Médio completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2024-02-20', 1, '2025-05-29'),
  (63, NULL, 'CRAS Mooca', 'José Teixeira Dias', NULL, 'M', NULL, '1954-07-13', 'São Paulo/SP', 'Preta', NULL, NULL, '378.452.602-05', '29.101.960-6', 'SSP/SP', '1999-10-28', 'Solteiro', 'Rua das Acácias, 920', 'Brás', '03226-397', '(11) 91803-5847', 'Letícia Santana Dias', 'Wellington Dias', 'Ensino Médio completo', 'Não', NULL, 'Sim', 'ATIVO', '2024-02-26', 0, '2020-06-10'),
  (64, '16424436574', 'CRAS Mooca', 'Helena Vieira Moreira', NULL, 'F', 'Prefere não informar', '1972-05-27', 'São Paulo/SP', 'Parda', NULL, NULL, '523.378.284-17', '58.818.345-0', 'SSP/SP', '2009-04-23', 'Solteira', 'Rua das Hortênsias, 216', 'Mooca', '03233-360', '(11) 95989-6325', 'Lúcia Cavalcanti Moreira', NULL, 'Ensino Fundamental incompleto', 'Não', NULL, 'Não', 'ATIVO', '2024-03-02', 0, '2023-02-02'),
  (65, '20221635787', 'CRAS Belém', 'Renata Monteiro Soares', NULL, 'F', NULL, '1979-06-19', 'São Paulo/SP', 'Branca', NULL, NULL, '707.718.522-37', '10.096.210-9', 'SSP/SP', '2001-11-01', 'Solteira', 'Rua das Orquídeas, 1320', 'Mooca', '03129-072', '(11) 98680-9498', 'Simone Correia Soares', 'Fábio Soares', 'Ensino Médio incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2024-03-03', 1, '2026-01-03'),
  (66, '14618223247', NULL, 'Vera Pinto Nunes', NULL, 'F', NULL, '1981-07-08', 'Salvador/BA', 'Branca', NULL, NULL, '965.554.798-07', '17.681.385-5', 'SSP/SP', '2004-10-27', 'Casada', 'Rua dos Coqueiros, 1398, casa 2', 'Brás', '03354-449', '(11) 94813-5561', 'Raimunda Gonçalves Nunes', 'João Nunes', 'Ensino Fundamental incompleto', 'Não', NULL, 'Não', 'ATIVO', '2024-03-05', 1, '2026-10-03'),
  (67, NULL, 'CRAS Mooca', 'Adriana Correia Teixeira', NULL, 'F', NULL, '1949-02-17', 'São Luís/MA', 'Indígena', NULL, NULL, '531.237.818-47', '56.028.251-0', 'SSP/SP', '1994-07-02', 'Divorciada', 'Avenida das Figueiras, 1006', 'Tatuapé', '03181-014', NULL, 'Fernanda Santos Teixeira', 'Marcelo Teixeira', 'Ensino Fundamental completo', 'Sim - EJA', 'Bolsa Família', 'Não', 'ATIVO', '2024-03-15', 1, '2023-05-19'),
  (68, NULL, 'CREAS Mooca', 'Adriana Santana Machado', NULL, 'F', NULL, '1979-02-21', 'Campina Grande/PB', NULL, NULL, NULL, '416.085.320-44', '22.344.316-9', 'SSP/SP', '2010-05-20', 'Solteira', 'Rua dos Jacarandás, 227, casa 2', 'Belém', '03260-812', '(11) 98782-2612', 'Patrícia Pinto Machado', 'Manoel Machado', 'Ensino Fundamental completo', 'Não', NULL, 'Não', 'ATIVO', '2024-03-18', 1, '2025-04-27'),
  (69, '22312496592', 'CRAS Mooca', 'Regina Gonçalves Dias', NULL, 'F', NULL, '1989-01-02', 'São Paulo/SP', 'Branca', NULL, NULL, '912.550.985-69', '53.556.638-3', 'SSP/SP', '2024-03-15', 'Solteira', 'Rua das Magnólias, 854', 'Belém', '03175-339', NULL, 'Jéssica Ribeiro Dias', 'Eduardo Dias', 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2024-03-27', 1, '2026-03-14'),
  (70, NULL, 'CRAS Mooca', 'Gilberto Soares Costa', NULL, 'M', 'Prefere não informar', '1957-03-22', 'Recife/PE', NULL, NULL, NULL, '167.340.773-66', '35.229.695-7', 'SSP/MG', '1985-06-18', 'Solteiro', 'Rua das Magnólias, 307, fundos', 'Mooca', '03229-934', '(11) 94135-7000', 'Raimunda Nascimento Costa', 'Wellington Costa', 'Ensino Fundamental incompleto', 'Não', NULL, 'Não', 'ATIVO', '2024-04-05', 0, NULL),
  (71, '18057462984', NULL, 'Diego Soares Rocha', NULL, 'M', NULL, '1979-03-15', 'Recife/PE', 'Parda', NULL, NULL, '239.951.435-07', '26.907.546-2', 'SSP/SP', '2008-12-22', 'União estável', 'Rua das Magnólias, 385', 'Belém', '03374-926', '(11) 98864-4742', 'Simone Araújo Rocha', 'Cícero Rocha', 'Ensino Fundamental incompleto', 'Não', NULL, 'Não', 'ATIVO', '2024-04-09', 0, '2020-12-11'),
  (72, '20842315600', 'CRAS Mooca', 'Francisca de Oliveira Farias', NULL, 'F', NULL, '1974-08-17', 'São Paulo/SP', 'Branca', NULL, NULL, '671.958.082-41', '47.878.484-3', 'SSP/SP', '1998-06-06', 'União estável', 'Rua das Acácias, 97', 'Belém', '03330-126', '(11) 99926-5781', 'Roseli Marques Farias', 'Daniel Farias', 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2024-04-12', 1, '2026-10-06'),
  (73, '25200246084', 'CRAS Mooca', 'Débora Rodrigues Santana', NULL, 'F', 'Prefere não informar', '1976-11-15', 'Salvador/BA', NULL, NULL, NULL, '456.132.264-03', '15.012.373-9', 'SSP/SP', '1997-08-10', 'Solteira', 'Rua dos Ipês, 515, casa 2', 'Cambuci', '03211-428', '(11) 93403-5830', 'Regina Almeida Santana', 'Fábio Santana', 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2024-04-12', 0, NULL),
  (74, '25368646243', 'CRAS Mooca', 'Edna Nunes Almeida', NULL, 'F', NULL, '1951-09-05', 'Teresina/PI', 'Branca', NULL, NULL, '579.376.368-63', '27.519.220-4', 'SSP/MG', '2015-08-17', 'Viúva', 'Rua das Magnólias, 204', 'Mooca', '03239-440', '(11) 94020-8232', 'Larissa Farias Almeida', 'Edson Almeida', 'Ensino Fundamental incompleto', 'Não', NULL, 'Sim', 'ATIVO', '2024-04-17', 0, NULL),
  (75, NULL, 'CRAS Belém', 'João Brito Silva', NULL, 'M', NULL, '1998-02-12', 'Feira de Santana/BA', 'Parda', NULL, NULL, '133.865.615-98', '28.071.327-0', 'SSP/CE', '2016-02-24', 'Solteiro', 'Rua das Magnólias, 216', 'Água Rasa', '03309-342', NULL, 'Michele Batista Silva', NULL, 'Sem escolaridade', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2024-04-18', 1, '2025-11-01'),
  (76, NULL, 'CRAS Belém', 'Michele Brito Marques', NULL, 'F', 'Prefere não informar', '1967-10-08', 'Campina Grande/PB', 'Branca', NULL, NULL, '365.121.426-69', '50.858.764-8', 'SSP/PE', '2009-05-27', 'Solteira', 'Rua das Begônias, 383, apto 45', 'Belém', '03397-355', '(11) 95823-9103', 'Roseli Souza Marques', NULL, 'Ensino Superior incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2024-04-20', 1, '2025-08-09'),
  (77, NULL, 'CRAS Mooca', 'Márcia Andrade Ramos', NULL, 'F', NULL, '1972-07-13', 'Salvador/BA', 'Branca', NULL, NULL, '850.616.388-32', '46.641.699-7', 'SSP/SP', '2011-02-20', 'Viúva', 'Viela das Margaridas, 720, casa 2', 'Água Rasa', '03391-958', NULL, 'Aline Gomes Ramos', NULL, 'Ensino Fundamental completo', 'Sim - EJA', 'Bolsa Família', 'Não', 'ATIVO', '2024-04-22', 1, '2025-07-09'),
  (78, '17830653176', NULL, 'Adilson Barbosa Cardoso', NULL, 'M', NULL, '2005-06-14', 'São Paulo/SP', 'Parda', NULL, NULL, '273.941.224-64', '31.701.866-9', 'SSP/PE', '2023-05-15', 'Solteiro', 'Rua das Begônias, 1199, casa 2', 'Brás', '03275-415', '(11) 97048-7016', 'Cláudia Freitas Cardoso', NULL, 'Ensino Fundamental incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2024-05-08', 1, '2025-02-10'),
  (79, NULL, NULL, 'Letícia Correia Ramos', NULL, 'F', NULL, '1967-05-05', 'Fortaleza/CE', NULL, NULL, NULL, '168.933.132-47', '30.107.452-7', 'SSP/SP', '2005-01-07', 'Solteira', 'Rua dos Lírios, 1310, casa 2', 'Água Rasa', '03125-085', '(11) 94183-8859', 'Priscila Cavalcanti Ramos', NULL, 'Ensino Médio incompleto', 'Não', NULL, 'Não', 'ATIVO', '2024-05-09', 1, '2025-01-19'),
  (80, NULL, 'CRAS Mooca', 'Vera Cavalcanti Moura', NULL, 'F', NULL, '1961-12-18', 'Salvador/BA', 'Parda', NULL, NULL, '743.348.241-12', '17.048.053-6', 'SSP/SP', '1996-11-08', 'Solteira', 'Rua dos Lírios, 171', 'Tatuapé', '03331-791', '(11) 94144-1433', 'Patrícia Lopes Moura', 'Valdir Moura', 'Sem escolaridade', 'Sim - EJA', NULL, 'Não', 'ATIVO', '2024-05-12', 0, '2021-05-28'),
  (81, NULL, NULL, 'João Mendes Araújo', NULL, 'M', NULL, '1997-11-19', 'São Paulo/SP', 'Parda', NULL, NULL, '586.185.527-16', '35.955.019-1', 'SSP/SP', '2015-02-20', 'Solteiro', 'Rua dos Coqueiros, 761, casa 2', 'Brás', '03360-917', '(11) 99146-1964', 'Cristiane Moreira Araújo', 'Josué Araújo', 'Sem escolaridade', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2024-05-15', 1, '2026-05-14'),
  (82, NULL, 'CRAS Mooca', 'Antônia Martins Barbosa', NULL, 'F', NULL, '1982-02-18', 'Teresina/PI', NULL, NULL, NULL, '687.468.941-55', '30.027.731-7', 'SSP/MG', '2007-10-02', 'Solteira', 'Rua das Hortênsias, 855', 'Vila Prudente', '03305-479', '(11) 94344-8779', 'Francisca Brito Barbosa', 'Valdir Barbosa', 'Ensino Fundamental incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2024-05-21', 1, '2025-01-19'),
  (83, '27107280972', 'CRAS Mooca', 'Débora Silva Carvalho', NULL, 'F', NULL, '1981-04-24', 'Caruaru/PE', 'Branca', NULL, NULL, '775.975.503-19', '30.220.020-4', 'SSP/MG', '2020-04-29', 'Solteira', 'Rua dos Jacarandás, 289, apto 38', 'Tatuapé', '03239-100', '(11) 94196-6400', 'Juliana Ramos Carvalho', NULL, 'Ensino Fundamental incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2024-05-26', 1, '2025-03-30'),
  (84, '13773085551', NULL, 'José Rodrigues Pinto', NULL, 'M', NULL, '1960-05-01', 'São Paulo/SP', 'Branca', NULL, 'Frutos do mar', '810.958.676-18', '28.138.127-1', 'SSP/PE', '2013-10-17', 'Viúvo', 'Rua dos Lírios, 358, apto 45', 'Água Rasa', '03223-109', '(11) 91987-7553', 'Sônia Teixeira Pinto', 'Francisco Pinto', 'Ensino Fundamental completo', 'Não', NULL, 'Sim', 'ATIVO', '2024-06-02', 1, '2026-01-20'),
  (85, NULL, 'CREAS Mooca', 'Vera Farias Andrade', NULL, 'F', NULL, '1964-09-23', 'São Paulo/SP', 'Parda', NULL, NULL, NULL, '34.890.234-1', 'SSP/CE', '1997-10-18', 'União estável', 'Sem endereço fixo (situação de rua)', 'Brás', NULL, NULL, 'Priscila Gomes Andrade', NULL, 'Ensino Médio incompleto', 'Não', NULL, 'Não', 'ATIVO', '2024-06-06', 1, '2026-07-27'),
  (86, '27728641914', 'CRAS Mooca', 'Patrícia Lima Batista', NULL, 'F', NULL, '1963-04-06', 'São Paulo/SP', 'Parda', NULL, NULL, '583.454.495-94', '16.698.077-1', 'SSP/SP', '1988-08-25', 'Solteira', 'Rua dos Coqueiros, 25', 'Brás', '03202-861', '(11) 95919-4059', 'Juliana Gomes Batista', 'Antônio Batista', 'Ensino Médio completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2024-06-08', 1, '2025-03-29'),
  (87, NULL, 'CRAS Mooca', 'Fábio Cardoso Oliveira', NULL, 'M', NULL, '2003-11-16', 'São Paulo/SP', 'Branca', NULL, NULL, '384.876.269-05', '27.050.022-9', 'SSP/SP', '2024-04-08', 'Solteiro', 'Viela das Margaridas, 964, apto 15', 'Vila Prudente', '03322-469', '(11) 95729-1979', 'Silvana Santos Oliveira', NULL, 'Ensino Fundamental incompleto', 'Não', NULL, 'Não', 'ATIVO', '2024-06-16', 1, '2025-03-23'),
  (88, '11934985682', 'CRAS Mooca', 'Letícia Cardoso Monteiro', NULL, 'F', NULL, '1980-12-06', 'São Paulo/SP', NULL, NULL, NULL, '466.621.146-41', '55.837.340-3', 'SSP/MG', '2009-10-03', 'Solteira', 'Travessa das Violetas, 980, apto 36', 'Mooca', '03117-185', '(11) 94863-4002', 'Ana Ramos Monteiro', 'Pedro Monteiro', 'Ensino Superior completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2024-06-18', 1, '2025-05-13'),
  (89, NULL, 'CRAS Mooca', 'Ana Martins Cavalcanti', 'Rafael Martins Cavalcanti', 'F', NULL, '2001-09-28', 'Aracaju/SE', 'Parda', NULL, NULL, '128.389.016-68', '18.508.903-5', 'SSP/SP', '2020-01-05', 'União estável', 'Viela das Margaridas, 487, casa 2', 'Vila Prudente', '03251-145', '(11) 97239-8431', 'Edna Moreira Cavalcanti', 'Marcelo Cavalcanti', 'Ensino Médio completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2024-06-22', 1, '2025-06-16'),
  (90, '25061170956', 'CRAS Mooca', 'Carlos Nunes Brito', NULL, 'M', 'Prefere não informar', '2004-01-17', 'São Paulo/SP', 'Parda', NULL, NULL, '785.107.748-03', '33.138.477-0', 'SSP/SP', '2022-03-13', 'Solteiro', 'Rua dos Cedros, 537, apto 44', 'Belém', '03269-310', '(11) 92823-5905', 'Neide Moura Brito', 'Jorge Brito', 'Ensino Fundamental incompleto', 'Não', NULL, 'Não', 'ATIVO', '2024-06-29', 1, '2024-12-12'),
  (91, '24479411097', 'CRAS Belém', 'Daniel Brito Costa', NULL, 'M', NULL, '1991-09-27', 'Salvador/BA', 'Parda', NULL, NULL, '312.180.446-92', '17.498.039-6', 'SSP/SP', '2017-08-17', 'Casado', 'Rua dos Cedros, 1173, apto 20', 'Mooca', '03268-657', '(11) 97427-2248', 'Tatiane Araújo Costa', NULL, 'Ensino Fundamental incompleto', 'Não', NULL, 'Não', 'ATIVO', '2024-07-03', 1, '2025-03-23'),
  (92, '27428347903', 'CREAS Mooca', 'Neide Cardoso Fernandes', NULL, 'F', NULL, '1995-01-07', 'São Paulo/SP', 'Branca', NULL, NULL, '211.520.043-11', '25.695.717-6', 'SSP/SP', '2021-10-19', 'União estável', 'Rua das Palmeiras, 710, casa 2', 'Mooca', '03220-660', '(11) 95634-8813', 'Josefa Barbosa Fernandes', 'Josué Fernandes', 'Ensino Médio completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2024-07-10', 1, '2025-05-01'),
  (93, NULL, 'CRAS Mooca', 'Vera Costa Alves', NULL, 'F', 'Prefere não informar', '1987-05-01', 'São Paulo/SP', 'Parda', NULL, NULL, '742.897.520-52', '33.292.055-7', 'SSP/SP', '2018-02-20', 'Solteira', 'Sem endereço fixo (situação de rua)', 'Brás', NULL, NULL, 'Elaine Moura Alves', 'Bruno Alves', 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2024-07-24', 0, NULL),
  (94, '15979941682', 'CRAS Belém', 'Simone Barbosa Araújo', NULL, 'F', NULL, '1961-11-11', 'Salvador/BA', NULL, NULL, NULL, '166.692.683-01', '54.745.031-2', 'SSP/BA', '2023-07-29', 'Casada', 'Rua das Camélias, 1323', 'Mooca', '03262-362', '(11) 96563-5700', 'Priscila Barbosa Araújo', NULL, 'Ensino Superior completo', 'Não', NULL, 'Sim', 'ATIVO', '2024-07-25', 0, NULL),
  (95, NULL, 'CRAS Belém', 'Patrícia de Andrade Gomes', NULL, 'F', NULL, '1962-08-22', 'São Paulo/SP', 'Branca', NULL, NULL, '268.112.261-63', '42.442.080-2', 'SSP/SP', '1998-06-12', 'Casada', 'Rua dos Girassóis, 755, casa 2', 'Belém', '03389-580', '(11) 92677-4216', 'Joana Marques Gomes', 'Raimundo Gomes', 'Ensino Médio completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2024-07-28', 1, '2026-01-13'),
  (96, '16648950142', 'CRAS Mooca', 'Rodrigo da Silva Andrade', NULL, 'M', 'Prefere não informar', '1950-05-07', 'Teresina/PI', 'Parda', NULL, NULL, '166.431.647-44', '35.834.819-5', 'SSP/SP', '1971-09-14', 'União estável', 'Rua das Begônias, 1426', 'Brás', '03210-244', '(11) 99714-4550', 'Tatiane Pereira Andrade', NULL, 'Sem escolaridade', 'Sim - curso técnico', NULL, 'Sim', 'ATIVO', '2024-07-30', 0, '2021-03-08'),
  (97, '12568192535', 'CRAS Mooca', 'Patrícia Nascimento Nunes', NULL, 'F', NULL, '1994-06-17', 'São Paulo/SP', 'Parda', NULL, NULL, '955.058.265-87', '38.104.731-4', 'SSP/SP', '2022-09-11', 'Viúva', 'Rua dos Manacás, 483, fundos', 'Belém', '03118-727', '(11) 92925-8010', 'Elaine Lima Nunes', 'Fábio Nunes', 'Sem escolaridade', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2024-07-31', 1, '2026-10-06'),
  (98, '23042237378', 'CRAS Belém', 'Fernanda Barbosa Brito', NULL, 'F', NULL, '1982-12-07', 'Belo Horizonte/MG', NULL, NULL, NULL, '749.222.267-92', '47.651.598-2', 'SSP/SP', '2024-07-05', 'Casada', 'Rua dos Jacarandás, 1495', 'Mooca', '03153-057', '(11) 98395-9619', 'Ana Nascimento Brito', 'Fábio Brito', 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2024-08-04', 1, '2025-08-15'),
  (99, NULL, 'CRAS Mooca', 'Valdir Brito Alves', NULL, 'M', NULL, '1952-05-09', 'Belo Horizonte/MG', NULL, NULL, NULL, '135.487.134-47', '25.089.634-7', 'SSP/SP', '1979-06-10', 'Solteiro', 'Rua dos Cedros, 353', 'Belém', '03341-999', '(11) 91399-7450', 'Fernanda Cardoso Alves', 'Cícero Alves', 'Ensino Médio incompleto', 'Não', NULL, 'Sim', 'ATIVO', '2024-08-15', 0, '2023-05-04'),
  (100, '13934677014', 'CRAS Mooca', 'Cristiane Mendes Vieira', NULL, 'F', 'Prefere não informar', '1971-11-09', 'Belo Horizonte/MG', NULL, NULL, NULL, '694.868.854-40', '19.146.411-5', 'SSP/SP', '2018-12-17', 'Solteira', 'Travessa das Violetas, 1413, apto 5', 'Cambuci', '03209-935', '(11) 97045-7920', 'Helena Barbosa Vieira', NULL, 'Ensino Fundamental completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2024-08-15', 1, '2025-06-27');

INSERT INTO beneficiario (id_beneficiario, nis, cras_creas_sas, nome_completo, nome_social, sexo, orientacao_sexual, data_nascimento, naturalidade, cor_raca, pessoa_com_deficiencia, tem_alergias, cpf, rg_numero, rg_orgao_uf_emissor, rg_data_emissao, estado_civil, endereco, bairro, cep, telefone, nome_mae, nome_pai, escolaridade, estuda_atualmente, recebe_transferencia_renda, recebe_bpc, situacao_cadastro, data_consentimento, cadunico_ativo, data_atualizacao_cadunico) VALUES
  (101, NULL, 'CRAS Mooca', 'Márcia Farias Martins', NULL, 'F', NULL, '1962-02-12', 'Caruaru/PE', 'Branca', NULL, NULL, '718.973.870-49', '35.093.508-8', 'SSP/SP', '2012-04-24', 'Viúva', 'Avenida das Figueiras, 1486, apto 48', 'Brás', '03313-054', NULL, 'Maria Fernandes Martins', 'Pedro Martins', 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2024-08-24', 1, '2024-11-29'),
  (102, NULL, 'CREAS Mooca', 'Eduardo Dias Ribeiro', NULL, 'M', NULL, '1971-05-18', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'União estável', 'Sem endereço fixo (situação de rua)', 'Brás', NULL, '(11) 98392-2065', 'Maria Batista Ribeiro', NULL, 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2024-08-28', 0, '2021-11-07'),
  (103, '14097832847', 'CREAS Mooca', 'Adriana Correia Souza', NULL, 'F', NULL, '1985-12-22', 'São Paulo/SP', 'Preta', NULL, NULL, '985.367.582-58', '49.525.896-8', 'SSP/SP', '2013-09-22', 'União estável', 'Rua das Hortênsias, 829', 'Mooca', '03355-272', '(11) 91815-8182', 'Vanessa Gonçalves Souza', NULL, 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2024-09-16', 0, NULL),
  (104, NULL, 'CRAS Belém', 'Gabriel Vieira Santos', NULL, 'M', 'Prefere não informar', '1980-05-07', 'São Paulo/SP', 'Preta', NULL, NULL, '631.936.415-63', '15.549.794-5', 'SSP/PE', '2006-04-28', 'Divorciado', 'Rua dos Manacás, 860, casa 2', 'Mooca', '03160-545', '(11) 99330-1563', 'Rita Dias Santos', 'José Santos', 'Ensino Fundamental incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2024-09-19', 1, '2025-09-02'),
  (105, '25142755106', 'CRAS Mooca', 'Valéria Brito Vieira', NULL, 'F', NULL, '1971-02-15', 'São Paulo/SP', NULL, NULL, NULL, '930.165.017-88', '27.150.983-6', 'SSP/SP', '1998-11-22', 'Solteira', 'Rua das Acácias, 389', 'Cambuci', '03329-349', '(11) 99243-6268', 'Camila Gonçalves Vieira', NULL, 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2024-09-20', 1, '2025-03-23'),
  (106, '13924635393', 'CRAS Mooca', 'Carlos da Silva Nascimento', NULL, 'M', NULL, '1963-03-17', 'São Paulo/SP', 'Branca', NULL, NULL, '708.787.234-02', '23.703.639-2', 'SSP/PE', '2014-06-01', 'União estável', 'Rua dos Manacás, 938', 'Mooca', '03384-395', '(11) 98730-9378', 'Vera Marques Nascimento', 'Severino Nascimento', 'Ensino Médio completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2024-09-21', 1, '2025-03-25'),
  (107, '19956637704', NULL, 'Fábio Rocha Oliveira', NULL, 'M', NULL, '1965-02-14', 'Belo Horizonte/MG', NULL, NULL, NULL, '529.131.993-66', '32.782.575-2', 'SSP/SP', '2017-08-16', 'Casado', 'Viela das Margaridas, 803', 'Vila Prudente', '03197-382', '(11) 97504-1312', 'Aline Lopes Oliveira', NULL, 'Ensino Médio incompleto', 'Sim - EJA', 'Bolsa Família', 'Não', 'ATIVO', '2024-09-21', 1, '2025-10-23'),
  (108, '28612797792', 'CRAS Belém', 'Patrícia Ramos Oliveira', NULL, 'F', NULL, '1992-07-24', 'Recife/PE', 'Parda', NULL, NULL, '575.204.822-55', '20.367.178-0', 'SSP/BA', '2014-09-04', 'Casada', 'Rua dos Ipês, 491', 'Água Rasa', '03112-542', '(11) 95676-6619', 'Edna Rocha Oliveira', 'Cícero Oliveira', 'Ensino Fundamental completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2024-09-28', 1, '2026-04-08'),
  (109, '26363443055', 'CRAS Mooca', 'Manoel Souza Santana', NULL, 'M', NULL, '1951-11-06', 'São Paulo/SP', NULL, NULL, NULL, '508.882.451-28', '11.535.939-4', 'SSP/CE', '1980-04-09', 'Solteiro', 'Rua dos Girassóis, 1274', 'Vila Prudente', '03202-766', '(11) 98025-3041', 'Ana Carvalho Santana', 'Carlos Santana', 'Ensino Fundamental incompleto', 'Não', NULL, 'Sim', 'ATIVO', '2024-10-06', 1, '2025-12-19'),
  (110, NULL, NULL, 'Neide Lima Oliveira', NULL, 'F', NULL, '1955-05-04', 'São Paulo/SP', 'Branca', NULL, NULL, '332.895.558-55', '53.679.823-0', 'SSP/SP', '2009-12-21', 'Casada', 'Rua dos Cedros, 1193, fundos', 'Brás', '03345-359', '(11) 91546-8023', 'Larissa Pereira Oliveira', NULL, 'Ensino Médio incompleto', 'Não', NULL, 'Sim', 'ATIVO', '2024-10-11', 1, '2025-07-02'),
  (111, '22968422998', 'CRAS Belém', 'Lúcia Pereira Brito', NULL, 'F', NULL, '1972-11-19', 'São Paulo/SP', 'Branca', NULL, NULL, '386.322.459-40', '24.377.847-4', 'SSP/CE', '1995-06-25', 'Solteira', 'Viela das Margaridas, 1387, apto 16', 'Mooca', '03133-178', '(11) 92879-2193', 'Kelly Farias Brito', 'Eduardo Brito', 'Ensino Fundamental completo', 'Não', NULL, 'Não', 'ATIVO', '2024-10-17', 0, NULL),
  (112, '15293087291', 'CRAS Mooca', 'Débora Batista Almeida', NULL, 'F', NULL, '1983-02-24', 'São Paulo/SP', NULL, NULL, NULL, '451.748.033-51', '14.338.268-6', 'SSP/PE', '2021-08-22', 'Solteira', 'Rua dos Coqueiros, 769, casa 2', 'Mooca', '03257-184', '(11) 94393-8895', 'Jéssica Brito Almeida', 'Adilson Almeida', 'Ensino Médio incompleto', 'Sim - ensino superior', NULL, 'Não', 'ATIVO', '2024-10-17', 0, NULL),
  (113, NULL, 'CREAS Mooca', 'Priscila Batista Moreira', NULL, 'F', NULL, '1993-03-10', 'Fortaleza/CE', NULL, NULL, NULL, '332.801.440-80', '40.037.308-8', 'SSP/SP', '2013-08-13', 'Divorciada', 'Rua das Acácias, 1067', 'Mooca', '03388-794', '(11) 98988-1830', 'Patrícia Marques Moreira', 'Thiago Moreira', 'Ensino Médio completo', 'Sim - EJA', NULL, 'Não', 'ATIVO', '2024-10-30', 1, '2025-09-20'),
  (114, NULL, 'CRAS Mooca', 'Gabriela Oliveira Barbosa', NULL, 'F', NULL, '1960-05-18', 'Guarulhos/SP', 'Preta', 'Deficiência auditiva', NULL, '748.521.353-45', '31.537.280-9', 'SSP/SP', '1993-04-20', 'Solteira', 'Rua dos Jacarandás, 875', 'Vila Prudente', '03203-701', '(11) 91473-6510', 'Neide Pereira Barbosa', 'Severino Barbosa', 'Ensino Fundamental completo', 'Não', NULL, 'Não', 'ATIVO', '2024-11-04', 1, '2025-09-14'),
  (115, NULL, 'CRAS Mooca', 'Elaine Carvalho Nunes', NULL, 'F', NULL, '1998-06-16', 'São Paulo/SP', 'Branca', NULL, NULL, '657.202.031-37', '17.772.348-6', 'SSP/MG', '2017-11-12', 'Solteira', 'Rua das Hortênsias, 482, casa 2', 'Tatuapé', '03106-166', '(11) 99199-9160', 'Valéria Soares Nunes', NULL, 'Ensino Superior incompleto', 'Não', NULL, 'Não', 'ATIVO', '2024-11-11', 0, NULL),
  (116, '21825409133', 'CRAS Mooca', 'Jéssica Alves Moura', NULL, 'F', NULL, '1999-11-20', 'São Paulo/SP', NULL, NULL, NULL, '131.503.626-32', '14.643.838-1', 'SSP/SP', '2018-07-11', 'União estável', 'Rua dos Coqueiros, 230', 'Vila Prudente', '03374-628', '(11) 97839-5370', 'Jéssica Ramos Moura', 'Wellington Moura', 'Ensino Superior completo', 'Sim - ensino superior', NULL, 'Não', 'ATIVO', '2024-11-12', 1, '2025-10-03'),
  (117, '10948500504', 'CRAS Mooca', 'Luciana Gomes Andrade', NULL, 'F', 'Prefere não informar', '1987-06-27', 'São Paulo/SP', 'Preta', NULL, NULL, '603.446.721-47', '48.591.350-5', 'SSP/SP', '2011-07-21', 'Casada', 'Rua das Palmeiras, 161, apto 15', 'Belém', '03325-842', '(11) 93694-5363', 'Aline Rocha Andrade', 'Edson Andrade', 'Ensino Fundamental incompleto', 'Não', NULL, 'Não', 'ATIVO', '2024-11-14', 0, NULL),
  (118, '20163348607', 'CRAS Mooca', 'Francisca Mendes Ferreira', NULL, 'F', NULL, '1990-03-18', 'São Paulo/SP', 'Branca', NULL, NULL, '129.679.063-55', '36.862.903-3', 'SSP/PE', '2019-05-04', 'Casada', 'Rua dos Coqueiros, 755', 'Mooca', '03218-376', '(11) 92616-1896', 'Michele Teixeira Ferreira', NULL, 'Ensino Médio completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2024-11-14', 1, '2025-06-28'),
  (119, NULL, 'CRAS Belém', 'Josefa Batista Silva', NULL, 'F', NULL, '1968-02-04', 'São Paulo/SP', 'Parda', NULL, NULL, NULL, '41.317.777-7', 'SSP/SP', '2020-03-31', 'Viúva', 'Rua das Acácias, 774, casa 2', 'Mooca', '03276-748', NULL, 'Ivone Andrade Silva', 'Wellington Silva', 'Ensino Fundamental incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2024-11-16', 1, '2026-09-05'),
  (120, '23534702461', 'CRAS Mooca', 'Edna Fernandes Rodrigues', NULL, 'F', NULL, '1958-06-02', 'Recife/PE', 'Parda', NULL, NULL, '653.658.122-93', '51.113.952-1', 'SSP/SP', '2017-03-07', 'Solteira', 'Viela das Margaridas, 390', 'Brás', '03314-433', NULL, 'Larissa Rocha Rodrigues', 'Marcelo Rodrigues', 'Ensino Fundamental completo', 'Sim - EJA', NULL, 'Sim', 'ATIVO', '2024-11-20', 0, '2022-08-26'),
  (121, NULL, NULL, 'Adilson Ribeiro Costa', NULL, 'M', NULL, '1969-05-01', NULL, 'Parda', NULL, NULL, NULL, NULL, NULL, NULL, 'Divorciado', 'Sem endereço fixo (situação de rua)', 'Brás', NULL, '(11) 91485-8117', 'Adriana Freitas Costa', NULL, 'Ensino Médio completo', 'Sim - ensino superior', 'Bolsa Família', 'Não', 'ATIVO', '2024-11-26', 1, '2026-08-02'),
  (122, '28007618619', 'CRAS Mooca', 'Marcos Dias Ferreira', NULL, 'M', 'Prefere não informar', '1976-10-16', 'Fortaleza/CE', 'Parda', NULL, NULL, '319.912.229-19', '47.197.949-3', 'SSP/SP', '2014-06-13', 'Divorciado', 'Rua dos Coqueiros, 855, casa 2', 'Tatuapé', '03111-314', '(11) 97500-7958', 'Bruna Santana Ferreira', 'Daniel Ferreira', 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2024-11-26', 0, '2023-01-30'),
  (123, '11549776701', 'CRAS Mooca', 'Adriana Farias Monteiro', NULL, 'F', NULL, '1985-02-16', 'São Paulo/SP', NULL, NULL, NULL, '995.523.496-99', '15.571.791-4', 'SSP/SP', '2013-01-27', 'União estável', 'Rua das Begônias, 1174', 'Tatuapé', '03274-322', '(11) 91910-7563', 'Fernanda Santos Monteiro', NULL, 'Ensino Médio incompleto', 'Não', NULL, 'Não', 'ATIVO', '2024-12-15', 0, NULL),
  (124, '29436696095', 'CRAS Belém', 'Luciana Ribeiro Machado', NULL, 'F', NULL, '1991-08-02', 'São Paulo/SP', 'Preta', NULL, NULL, '661.638.606-46', '25.865.779-5', 'SSP/MG', '2022-11-27', 'Divorciada', 'Rua dos Manacás, 641', 'Água Rasa', '03264-110', '(11) 99196-9051', 'Lúcia Moreira Machado', 'Gabriel Machado', 'Ensino Médio completo', 'Sim - curso técnico', NULL, 'Não', 'ATIVO', '2025-01-06', 1, '2026-10-07'),
  (125, NULL, NULL, 'Camila Soares Vieira', NULL, 'F', NULL, '1991-02-13', 'Feira de Santana/BA', 'Parda', NULL, NULL, '884.587.353-20', '58.953.376-0', 'SSP/SP', '2024-01-08', 'Solteira', 'Rua das Orquídeas, 35', 'Mooca', '03234-433', '(11) 97963-9816', 'Gabriela Santos Vieira', 'Gilberto Vieira', 'Ensino Médio incompleto', 'Sim - curso técnico', NULL, 'Não', 'ATIVO', '2025-01-11', 1, '2025-01-24'),
  (126, '17443630193', 'CRAS Mooca', 'Fernanda de Almeida Carvalho', NULL, 'F', 'Prefere não informar', '1950-12-15', 'Recife/PE', 'Preta', NULL, NULL, '270.759.421-56', '41.601.070-1', 'SSP/SP', '1999-04-13', 'Solteira', 'Rua dos Ipês, 483, fundos', 'Mooca', '03309-223', '(11) 99349-5654', 'Rita Costa Carvalh
