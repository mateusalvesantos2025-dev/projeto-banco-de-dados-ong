-- =====================================================================
-- ENTREGA 2 — BANCO COMPLETO (MySQL 8.0+) — ONG Organização Social Nossa Senhora de Fátima
-- Script convertido de SQLite para MySQL Workbench.
-- Execute o arquivo inteiro no MySQL Workbench.
-- =====================================================================

-- =====================================================================
-- 1. CREATE DATABASE
-- =====================================================================
CREATE DATABASE IF NOT EXISTS ong_nossa_senhora_fatima
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ong_nossa_senhora_fatima;

-- Ordem inversa (filha antes da pai) para o DROP não violar FK
DROP TABLE IF EXISTS recebimento_doacao;
DROP TABLE IF EXISTS entrega_cesta;
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
--    Constraints declaradas no CREATE TABLE. As colunas DATE usam o tipo nativo do MySQL.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Entidade 01/10 — profissional_responsavel (dicionário 4.7)
-- ---------------------------------------------------------------------
CREATE TABLE profissional_responsavel (
  id_profissional        BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  nome                   VARCHAR(150) NOT NULL,
  funcao                 VARCHAR(50)  NOT NULL,
  registro_profissional  VARCHAR(30)  NOT NULL,
  CONSTRAINT uq_profissional_registro UNIQUE (registro_profissional)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- Entidade 02/10 — beneficiario (dicionário 4.1)
-- ---------------------------------------------------------------------
CREATE TABLE beneficiario (
  id_beneficiario             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
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
  -- RN01: CPF e NIS são opcionais (quem chega sem documento é atendido),
  -- mas, quando informados, precisam ter formato válido para a unicidade valer
  CONSTRAINT ck_beneficiario_cpf_formato CHECK (cpf IS NULL OR
        cpf REGEXP '^[0-9]{3}[.][0-9]{3}[.][0-9]{3}-[0-9]{2}$'),
  CONSTRAINT ck_beneficiario_nis_formato CHECK (nis IS NULL OR
        (CHAR_LENGTH(nis) = 11 AND nis REGEXP '^[0-9]{11}$')),
  CONSTRAINT ck_beneficiario_cep_formato CHECK (cep IS NULL OR
        cep REGEXP '^[0-9]{5}-[0-9]{3}$'),
  CONSTRAINT ck_beneficiario_rg_emissao CHECK (rg_data_emissao IS NULL OR
        rg_data_emissao >= data_nascimento)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Índices de busca (RNF02 / política de indexação do dicionário):
--   cpf e nis já têm índice B-Tree automático por causa do UNIQUE;
--   nome_completo ganha índice próprio.
CREATE INDEX idx_beneficiario_nome        ON beneficiario (nome_completo);

-- ---------------------------------------------------------------------
-- Entidade 03/10 — trabalho (dicionário 4.2)
-- ---------------------------------------------------------------------
CREATE TABLE trabalho (
  id_trabalho            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  id_beneficiario        BIGINT UNSIGNED      NOT NULL,
  situacao_ocupacional   VARCHAR(50)  NOT NULL,
  profissao_habilidades  TEXT,
  renda_atual            DECIMAL(10,2),
  empresa_trabalho       VARCHAR(150),
  ocupacao_atual         VARCHAR(100),
  telefone_trabalho      VARCHAR(20),
  CONSTRAINT ck_trabalho_renda CHECK (renda_atual IS NULL OR renda_atual >= 0),
  CONSTRAINT fk_trabalho_beneficiario FOREIGN KEY (id_beneficiario)
    REFERENCES beneficiario (id_beneficiario) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_trabalho_beneficiario    ON trabalho (id_beneficiario);

-- ---------------------------------------------------------------------
-- Entidade 04/10 — composicao_familiar (dicionário 4.3)
-- ---------------------------------------------------------------------
CREATE TABLE composicao_familiar (
  id_membro           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  id_beneficiario     BIGINT UNSIGNED      NOT NULL,
  nome                VARCHAR(150) NOT NULL,
  nome_social         VARCHAR(150),
  idade               TINYINT      NOT NULL,
  parentesco_vinculo  VARCHAR(50)  NOT NULL,
  CONSTRAINT ck_composicao_idade CHECK (idade BETWEEN 0 AND 120),
  CONSTRAINT fk_composicao_beneficiario FOREIGN KEY (id_beneficiario)
    REFERENCES beneficiario (id_beneficiario) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_composicao_beneficiario  ON composicao_familiar (id_beneficiario);

-- ---------------------------------------------------------------------
-- Entidade 05/10 — referencia_familiar (dicionário 4.4)
-- ---------------------------------------------------------------------
CREATE TABLE referencia_familiar (
  id_referencia       BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  id_beneficiario     BIGINT UNSIGNED      NOT NULL,
  nome                VARCHAR(150) NOT NULL,
  nome_social         VARCHAR(150),
  parentesco_vinculo  VARCHAR(50),
  telefone            VARCHAR(20),
  CONSTRAINT fk_referencia_beneficiario FOREIGN KEY (id_beneficiario)
    REFERENCES beneficiario (id_beneficiario) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_referencia_beneficiario  ON referencia_familiar (id_beneficiario);

-- ---------------------------------------------------------------------
-- Entidade 06/10 — atendimento (dicionário 4.5)
-- ---------------------------------------------------------------------
CREATE TABLE atendimento (
  id_atendimento    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  id_beneficiario   BIGINT UNSIGNED NOT NULL,
  id_profissional   BIGINT UNSIGNED NOT NULL,
  data_atendimento  DATE    NOT NULL,
  demanda_inicial   TEXT    NOT NULL,
  CONSTRAINT fk_atendimento_beneficiario FOREIGN KEY (id_beneficiario)
    REFERENCES beneficiario (id_beneficiario) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_atendimento_profissional FOREIGN KEY (id_profissional)
    REFERENCES profissional_responsavel (id_profissional) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_atendimento_beneficiario ON atendimento (id_beneficiario);
CREATE INDEX idx_atendimento_profissional ON atendimento (id_profissional);
CREATE INDEX idx_atendimento_data         ON atendimento (data_atendimento);

-- ---------------------------------------------------------------------
-- Entidade 07/10 — encaminhamento_atendimento (dicionário 4.6)
-- ---------------------------------------------------------------------
CREATE TABLE encaminhamento_atendimento (
  id_encaminhamento    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  id_atendimento       BIGINT UNSIGNED     NOT NULL,
  tipo_encaminhamento  VARCHAR(60) NOT NULL,
  detalhe_outros       TEXT,
  CONSTRAINT ck_encaminhamento_outros CHECK (tipo_encaminhamento <> 'Outros' OR detalhe_outros IS NOT NULL),
  CONSTRAINT fk_encaminhamento_atendimento FOREIGN KEY (id_atendimento)
    REFERENCES atendimento (id_atendimento) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_encaminhamento_atend     ON encaminhamento_atendimento (id_atendimento);

-- ---------------------------------------------------------------------
-- Entidade 08/10 — pia (dicionário 4.8)
-- ---------------------------------------------------------------------
CREATE TABLE pia (
  id_pia             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  id_beneficiario    BIGINT UNSIGNED NOT NULL,
  id_profissional    BIGINT UNSIGNED NOT NULL,
  data_criacao       DATE    NOT NULL,
  metas_objetivos    TEXT    NOT NULL,
  prazo_reavaliacao  DATE,
  CONSTRAINT ck_pia_prazo CHECK (prazo_reavaliacao IS NULL OR prazo_reavaliacao >= data_criacao),
  CONSTRAINT fk_pia_beneficiario FOREIGN KEY (id_beneficiario)
    REFERENCES beneficiario (id_beneficiario) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_pia_profissional FOREIGN KEY (id_profissional)
    REFERENCES profissional_responsavel (id_profissional) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_pia_beneficiario         ON pia (id_beneficiario);
CREATE INDEX idx_pia_profissional         ON pia (id_profissional);

-- ---------------------------------------------------------------------
-- Entidade 09/10 — entrega_cesta (dicionário 4.9)
-- ---------------------------------------------------------------------
CREATE TABLE entrega_cesta (
  id_entrega         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  id_beneficiario    BIGINT UNSIGNED NOT NULL,
  id_profissional    BIGINT UNSIGNED NOT NULL,
  data_entrega       DATE    NOT NULL,
  quantidade_cestas  INTEGER NOT NULL,
  itens_adicionais   TEXT,
  CONSTRAINT ck_entrega_quantidade CHECK (quantidade_cestas > 0),
  CONSTRAINT fk_entrega_beneficiario FOREIGN KEY (id_beneficiario)
    REFERENCES beneficiario (id_beneficiario) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_entrega_profissional FOREIGN KEY (id_profissional)
    REFERENCES profissional_responsavel (id_profissional) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_entrega_beneficiario     ON entrega_cesta (id_beneficiario);
CREATE INDEX idx_entrega_profissional     ON entrega_cesta (id_profissional);
CREATE INDEX idx_entrega_data             ON entrega_cesta (data_entrega);

-- ---------------------------------------------------------------------
-- Entidade 10/10 — recebimento_doacao (dicionário 4.10)
-- ---------------------------------------------------------------------
CREATE TABLE recebimento_doacao (
  id_recebimento    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  id_profissional   BIGINT UNSIGNED      NOT NULL,
  parceiro_doador   VARCHAR(100) NOT NULL,
  data_recebimento  DATE         NOT NULL,
  descricao_itens   TEXT         NOT NULL,
  quantidade_total  INTEGER      NOT NULL,
  CONSTRAINT ck_recebimento_quantidade CHECK (quantidade_total > 0),
  CONSTRAINT fk_recebimento_profissional FOREIGN KEY (id_profissional)
    REFERENCES profissional_responsavel (id_profissional) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_recebimento_profissional ON recebimento_doacao (id_profissional);
CREATE INDEX idx_recebimento_data         ON recebimento_doacao (data_recebimento);

-- Conferência: deve listar 10 tabelas
SELECT table_name AS tabela
FROM information_schema.tables
WHERE table_schema = DATABASE()
ORDER BY table_name;

-- =====================================================================
-- 4. INSERT INTO — massa de dados FICTÍCIA e coerente
-- =====================================================================
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
-- Inserir os dados 2 vezes dá erro de chave duplicada — é o esperado.
-- Para repetir, rode de novo a partir do 00_inicio.sql.

-- ---------------------------------------------------------------------
-- Entidade 01/10 — profissional_responsavel (dicionário 4.7)
-- ---------------------------------------------------------------------
-- PROFISSIONAL_RESPONSAVEL — Equipe técnica (registros de conselho fictícios) + presidência sem registro (A08)
INSERT INTO profissional_responsavel (id_profissional, nome, funcao, registro_profissional) VALUES
  (1, 'Ana Paula Ribeiro', 'Assistente Social', 'CRESS-SP 90001'),
  (2, 'Carlos Eduardo Lima', 'Psicólogo (voluntário)', 'CRP 06/90002'),
  (3, 'Fernanda Souza Alves', 'Assistente Social (voluntária)', 'CRESS-SP 90003'),
  (4, 'Roberto Almeida Nogueira', 'Presidente', 'SEM REGISTRO - Presidência');

-- ---------------------------------------------------------------------
-- Entidade 02/10 — beneficiario (dicionário 4.1)
-- ---------------------------------------------------------------------
-- BENEFICIARIO — 250 famílias (porte da E1), em ordem de cadastro; 2 já anonimizadas (RN07)
--   Anonimizados (1 e 2): sem identificação direta, naturalidade apagada e
--   data de nascimento reduzida ao ano (AAAA-01-01) — mesma regra da seção 6.3.
INSERT INTO beneficiario (id_beneficiario, nis, cras_creas_sas, nome_completo, nome_social, sexo, orientacao_sexual, data_nascimento, naturalidade, cor_raca, pessoa_com_deficiencia, tem_alergias, cpf, rg_numero, rg_orgao_uf_emissor, rg_data_emissao, estado_civil, endereco, bairro, cep, telefone, nome_mae, nome_pai, escolaridade, estuda_atualmente, recebe_transferencia_renda, recebe_bpc, situacao_cadastro, data_consentimento, cadunico_ativo, data_atualizacao_cadunico) VALUES
  (1, NULL, 'CRAS Mooca', 'ANONIMIZADO-1', NULL, 'M', NULL, '1943-01-01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Casado', 'ANONIMIZADO', 'Mooca', NULL, NULL, NULL, NULL, 'Ensino Médio completo', 'Não', NULL, 'Sim', 'ANONIMIZADO', '2019-04-22', 1, '2026-08-27'),
  (2, NULL, 'CRAS Mooca', 'ANONIMIZADO-2', NULL, 'F', NULL, '1968-01-01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Divorciada', 'ANONIMIZADO', 'Belém', NULL, NULL, NULL, NULL, 'Ensino Fundamental incompleto', 'Não', 'Bolsa Família', 'Não', 'ANONIMIZADO', '2019-04-30', 1, '2025-04-04'),
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
  (126, '17443630193', 'CRAS Mooca', 'Fernanda de Almeida Carvalho', NULL, 'F', 'Prefere não informar', '1950-12-15', 'Recife/PE', 'Preta', NULL, NULL, '270.759.421-56', '41.601.070-1', 'SSP/SP', '1999-04-13', 'Solteira', 'Rua dos Ipês, 483, fundos', 'Mooca', '03309-223', '(11) 99349-5654', 'Rita Costa Carvalho', 'Carlos Carvalho', 'Ensino Fundamental incompleto', 'Não', NULL, 'Sim', 'ATIVO', '2025-01-19', 1, '2025-04-29'),
  (127, '19336775942', 'CRAS Mooca', 'Jéssica de Souza Pereira', NULL, 'F', NULL, '1986-03-09', 'São Paulo/SP', 'Parda', NULL, NULL, '814.295.424-20', '37.367.888-3', 'SSP/SP', '2021-07-23', 'Solteira', 'Rua dos Cedros, 1033, apto 8', 'Vila Prudente', '03155-100', '(11) 99677-4444', 'Juliana Costa Pereira', NULL, 'Ensino Fundamental incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2025-02-02', 1, '2026-08-31'),
  (128, '28902896100', 'CRAS Belém', 'Letícia Alves Pinto', NULL, 'F', NULL, '1978-10-04', 'São Paulo/SP', 'Branca', NULL, NULL, '525.176.198-42', '21.457.783-9', 'SSP/SP', '2000-07-16', 'Casada', 'Rua dos Ipês, 154', 'Mooca', '03377-847', '(11) 99205-6382', 'Ana Almeida Pinto', NULL, 'Ensino Fundamental incompleto', 'Não', NULL, 'Não', 'ATIVO', '2025-02-05', 0, NULL),
  (129, '11029230201', 'CRAS Belém', 'Rosângela Ramos Machado', NULL, 'F', NULL, '2004-04-21', 'São Paulo/SP', 'Parda', NULL, NULL, '871.651.388-49', '24.904.776-1', 'SSP/SP', '2024-01-15', 'Casada', 'Rua dos Coqueiros, 1159, casa 2', 'Cambuci', '03158-006', '(11) 97854-7261', 'Maria Pereira Machado', NULL, 'Sem escolaridade', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2025-02-05', 1, '2026-07-29'),
  (130, '21323006184', 'CRAS Belém', 'Anderson Nascimento Gonçalves', NULL, 'M', NULL, '1973-02-24', 'Feira de Santana/BA', 'Parda', NULL, NULL, '106.395.044-44', '17.662.085-5', 'SSP/SP', '2022-06-28', 'Casado', 'Travessa das Violetas, 334, casa 2', 'Mooca', '03259-784', '(11) 93495-6793', 'Francisca Moreira Gonçalves', NULL, 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2025-02-06', 0, NULL),
  (131, '18333612969', 'CRAS Mooca', 'Manoel Silva Carvalho', NULL, 'M', NULL, '1988-01-03', 'Montes Claros/MG', 'Parda', NULL, NULL, '187.187.224-16', '45.362.219-9', 'SSP/SP', '2020-08-26', 'Solteiro', 'Rua das Orquídeas, 48, casa 2', 'Mooca', '03186-912', '(11) 99640-8097', 'Joana Ferreira Carvalho', 'João Carvalho', 'Ensino Fundamental completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2025-02-20', 1, '2025-03-17'),
  (132, '13184570427', NULL, 'Rodrigo Ramos Lopes', NULL, 'M', NULL, '2005-09-07', 'Aracaju/SE', 'Parda', NULL, NULL, '602.353.772-52', '56.187.974-4', 'SSP/SP', '2023-08-01', 'Solteiro', 'Rua dos Jacarandás, 1403', 'Água Rasa', '03299-279', '(11) 92165-9764', 'Rosângela Pinto Lopes', 'Diego Lopes', 'Ensino Fundamental completo', 'Não', NULL, 'Não', 'ATIVO', '2025-02-21', 1, '2025-12-02'),
  (133, '28756134340', 'CRAS Mooca', 'Bruna Marques Moreira', NULL, 'F', NULL, '1980-01-06', 'Feira de Santana/BA', 'Preta', NULL, NULL, '945.490.650-63', '26.453.501-9', 'SSP/SP', '2006-02-23', 'Casada', 'Rua dos Cedros, 311, casa 2', 'Água Rasa', '03379-032', '(11) 92748-5738', 'Ana Oliveira Moreira', 'Carlos Moreira', 'Ensino Fundamental completo', 'Não', NULL, 'Não', 'ATIVO', '2025-02-25', 1, '2024-12-14'),
  (134, '18552467921', NULL, 'Neide Barbosa Costa', NULL, 'F', NULL, '1999-02-02', 'Maceió/AL', NULL, NULL, NULL, '209.659.775-46', '31.583.872-8', 'SSP/MG', '2018-12-16', 'Solteira', 'Avenida das Figueiras, 293, apto 21', 'Mooca', '03132-848', '(11) 92298-4523', 'Francisca Moreira Costa', NULL, 'Ensino Fundamental completo', 'Não', NULL, 'Não', 'ATIVO', '2025-02-27', 1, '2025-09-28'),
  (135, '17742631851', 'CRAS Mooca', 'Tatiane Andrade Costa', NULL, 'F', NULL, '1991-03-15', 'São Paulo/SP', 'Parda', NULL, NULL, '875.749.609-46', '31.030.550-7', 'SSP/SP', '2017-12-01', 'Divorciada', 'Rua dos Ipês, 339, apto 43', 'Mooca', '03160-869', '(11) 93605-2528', 'Neide Nunes Costa', NULL, 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2025-03-05', 1, '2025-05-16'),
  (136, '29543413547', 'CRAS Mooca', 'Patrícia Correia Freitas', NULL, 'F', NULL, '1985-02-11', 'Feira de Santana/BA', 'Preta', NULL, NULL, '974.829.654-17', '44.136.740-1', 'SSP/SP', '2011-12-04', 'Casada', 'Rua dos Manacás, 749', 'Cambuci', '03129-076', NULL, 'Edna Silva Freitas', 'Rafael Freitas', 'Ensino Superior incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2025-03-07', 1, '2025-02-24'),
  (137, NULL, 'CRAS Belém', 'Felipe Batista Oliveira', NULL, 'M', 'Prefere não informar', '1948-10-10', 'São Paulo/SP', NULL, NULL, NULL, '836.038.148-94', '19.771.691-9', 'SSP/SP', '1980-09-11', 'União estável', 'Rua dos Coqueiros, 1082, casa 2', 'Mooca', '03215-734', '(11) 92762-3942', 'Luciana Lima Oliveira', NULL, 'Ensino Médio completo', 'Não', NULL, 'Sim', 'ATIVO', '2025-03-11', 0, NULL),
  (138, '10783632867', 'CRAS Mooca', 'Sônia Barbosa Lima', NULL, 'F', NULL, '1976-10-05', 'São Paulo/SP', 'Branca', NULL, NULL, '540.528.170-15', '35.068.298-8', 'SSP/SP', '2007-01-17', 'União estável', 'Rua dos Cedros, 1248', 'Água Rasa', '03392-349', '(11) 96897-8815', 'Edna Ribeiro Lima', NULL, 'Ensino Fundamental incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2025-03-11', 1, '2025-05-09'),
  (139, '25388971844', 'CRAS Belém', 'Adilson Moreira Ramos', NULL, 'M', NULL, '1998-01-04', 'São Paulo/SP', 'Branca', NULL, 'Amendoim', '418.092.252-37', '54.891.854-7', 'SSP/SP', '2022-01-17', 'Solteiro', 'Rua das Begônias, 1204, fundos', 'Mooca', '03239-494', '(11) 94439-3202', 'Priscila Gomes Ramos', NULL, 'Ensino Superior incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2025-03-20', 1, '2025-08-15'),
  (140, '23059590481', NULL, 'Edson Rodrigues Cardoso', NULL, 'M', NULL, '1979-01-18', 'Teresina/PI', 'Parda', NULL, NULL, '771.766.006-33', '32.807.618-9', 'SSP/SP', '2012-08-13', 'Solteiro', 'Rua das Begônias, 915, apto 41', 'Vila Prudente', '03191-706', '(11) 93490-8855', 'Sandra Rocha Cardoso', 'Jorge Cardoso', 'Ensino Médio incompleto', 'Não', NULL, 'Não', 'ATIVO', '2025-04-07', 1, '2023-04-15'),
  (141, NULL, 'CRAS Mooca', 'Rafael Vieira Cavalcanti', 'Bianca Vieira Cavalcanti', 'M', NULL, '1996-04-08', 'São Paulo/SP', NULL, NULL, NULL, '765.113.624-74', '12.248.201-5', 'SSP/SP', '2015-08-19', 'Solteiro', 'Rua das Hortênsias, 407, casa 2', 'Mooca', '03146-626', '(11) 96897-7746', 'Lúcia Gonçalves Cavalcanti', NULL, 'Ensino Fundamental incompleto', 'Sim - EJA', NULL, 'Não', 'ATIVO', '2025-04-13', 1, '2025-04-29'),
  (142, '18424940978', 'CRAS Mooca', 'Camila Batista Souza', NULL, 'F', NULL, '1971-03-15', 'Salvador/BA', NULL, NULL, NULL, '815.666.307-29', '16.380.290-6', 'SSP/SP', '1990-11-14', 'Solteira', 'Rua dos Ipês, 93', 'Vila Prudente', '03252-970', '(11) 98764-9513', 'Aline Machado Souza', NULL, 'Ensino Fundamental completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2025-04-22', 1, '2025-11-20'),
  (143, '18996703413', 'CRAS Mooca', 'Diego Batista Teixeira', NULL, 'M', 'Prefere não informar', '1968-09-06', 'São Paulo/SP', 'Preta', NULL, NULL, '352.019.968-73', '52.607.971-3', 'SSP/SP', '1987-02-20', 'União estável', 'Rua das Camélias, 125, fundos', 'Mooca', '03128-605', '(11) 97730-5128', 'Cristiane Ferreira Teixeira', 'Lucas Teixeira', 'Ensino Fundamental completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2025-04-30', 1, '2025-10-09'),
  (144, '13133639012', 'CRAS Mooca', 'Ana Pinto Rocha', NULL, 'F', 'Prefere não informar', '1967-05-17', 'Aracaju/SE', 'Parda', NULL, NULL, '304.117.016-17', '38.181.046-9', 'SSP/SP', '2002-04-26', 'Viúva', 'Rua das Begônias, 844', 'Belém', '03132-307', '(11) 94538-4849', 'Michele Martins Rocha', NULL, 'Ensino Fundamental completo', 'Não', NULL, 'Não', 'ATIVO', '2025-05-10', 0, '2020-05-27'),
  (145, '10607142316', 'CRAS Mooca', 'Marcos Rodrigues Mendes', NULL, 'M', NULL, '1951-12-19', 'São Paulo/SP', 'Parda', NULL, NULL, NULL, '36.005.503-6', 'SSP/SP', '1989-10-15', 'Solteiro', 'Rua dos Manacás, 1486', 'Mooca', '03321-289', '(11) 99857-9455', 'Priscila Marques Mendes', NULL, 'Ensino Médio completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2025-05-17', 1, '2025-09-21'),
  (146, NULL, 'CRAS Mooca', 'Rafael dos Santos Rodrigues', NULL, 'M', NULL, '1961-08-05', 'Salvador/BA', 'Parda', NULL, NULL, '670.712.671-01', '53.531.662-0', 'SSP/SP', '2010-06-03', 'União estável', 'Viela das Margaridas, 608, apto 30', 'Brás', '03245-356', '(11) 95651-6807', 'Renata Mendes Rodrigues', NULL, 'Ensino Fundamental incompleto', 'Não', NULL, 'Sim', 'ATIVO', '2025-05-19', 0, NULL),
  (147, '14885483220', 'CRAS Mooca', 'Priscila Monteiro Costa', NULL, 'F', NULL, '1971-02-05', 'Maceió/AL', 'Preta', NULL, NULL, '772.036.409-35', '29.428.743-1', 'SSP/SP', '2012-07-02', 'Solteira', 'Rua das Begônias, 1372', 'Brás', '03310-173', '(11) 99990-6889', 'Rosângela Rocha Costa', 'Thiago Costa', 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2025-06-15', 0, '2021-12-27'),
  (148, '29518117092', 'CRAS Mooca', 'Simone Correia Marques', NULL, 'F', NULL, '1965-07-18', 'São Paulo/SP', 'Preta', NULL, NULL, '556.863.669-52', '44.292.252-8', 'SSP/PE', '2001-10-28', 'Casada', 'Rua das Hortênsias, 885, apto 43', 'Água Rasa', '03330-092', '(11) 94983-5425', 'Antônia Monteiro Marques', 'Edson Marques', 'Ensino Superior incompleto', 'Sim - EJA', NULL, 'Não', 'ATIVO', '2025-06-16', 1, '2026-06-09'),
  (149, '28913957625', NULL, 'Michele Araújo Souza', NULL, 'F', NULL, '1968-08-09', 'São Paulo/SP', 'Branca', NULL, NULL, '651.499.667-01', '28.719.574-1', 'SSP/SP', '1998-06-05', 'União estável', 'Rua das Camélias, 983, fundos', 'Água Rasa', '03303-026', '(11) 95859-9989', 'Patrícia Silva Souza', NULL, 'Ensino Médio incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2025-06-25', 1, '2025-02-10'),
  (150, '16454731023', 'CRAS Belém', 'João Nascimento Moreira', NULL, 'M', NULL, '1951-01-04', 'São Paulo/SP', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'União estável', 'Rua dos Manacás, 895, casa 2', 'Mooca', '03285-511', '(11) 97787-5100', 'Renata Brito Moreira', NULL, 'Ensino Fundamental completo', 'Não', NULL, 'Sim', 'ATIVO', '2025-07-02', 1, '2025-06-19');

INSERT INTO beneficiario (id_beneficiario, nis, cras_creas_sas, nome_completo, nome_social, sexo, orientacao_sexual, data_nascimento, naturalidade, cor_raca, pessoa_com_deficiencia, tem_alergias, cpf, rg_numero, rg_orgao_uf_emissor, rg_data_emissao, estado_civil, endereco, bairro, cep, telefone, nome_mae, nome_pai, escolaridade, estuda_atualmente, recebe_transferencia_renda, recebe_bpc, situacao_cadastro, data_consentimento, cadunico_ativo, data_atualizacao_cadunico) VALUES
  (151, '17958057495', 'CRAS Mooca', 'Jéssica Rocha Moura', NULL, 'F', 'Prefere não informar', '1984-07-24', 'São Paulo/SP', 'Preta', NULL, 'Glúten', '967.796.699-63', '47.558.487-2', 'SSP/SP', '2013-05-31', 'Solteira', 'Travessa das Violetas, 516', 'Mooca', '03290-355', '(11) 94579-3012', 'Rita Nascimento Moura', 'Paulo Moura', 'Ensino Médio completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2025-07-03', 1, '2025-03-19'),
  (152, NULL, 'CRAS Mooca', 'Adilson Ferreira Andrade', NULL, 'M', NULL, '1955-04-18', 'Natal/RN', 'Branca', NULL, NULL, '991.987.071-49', '32.511.626-6', 'SSP/SP', '1993-04-12', 'Solteiro', 'Avenida das Figueiras, 1322', 'Mooca', '03305-854', '(11) 97244-6874', 'Silvana Soares Andrade', 'Carlos Andrade', 'Ensino Fundamental incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2025-07-06', 1, '2024-11-29'),
  (153, NULL, 'CRAS Mooca', 'Rodrigo Alves Cardoso', NULL, 'M', NULL, '1984-08-08', 'Teresina/PI', 'Preta', NULL, NULL, '111.185.704-62', '52.571.526-7', 'SSP/SP', '2017-01-11', 'Casado', 'Viela das Margaridas, 1245, fundos', 'Mooca', '03382-891', '(11) 99959-2080', 'Larissa Rodrigues Cardoso', 'Daniel Cardoso', 'Ensino Fundamental incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2025-07-13', 1, '2026-07-12'),
  (154, NULL, 'CRAS Mooca', 'Rodrigo Machado Vieira', NULL, 'M', NULL, '1973-04-13', 'Salvador/BA', 'Branca', NULL, NULL, '497.011.035-38', '56.222.537-4', 'SSP/SP', '2016-04-10', 'Solteiro', 'Rua dos Lírios, 1289', 'Brás', '03384-522', NULL, 'Priscila Freitas Vieira', 'João Vieira', 'Ensino Fundamental incompleto', 'Não', NULL, 'Não', 'ATIVO', '2025-07-19', 1, '2026-06-22'),
  (155, '11659876607', NULL, 'Elaine Marques Santana', NULL, 'F', NULL, '1971-05-18', 'São Paulo/SP', NULL, NULL, NULL, '921.337.769-67', '52.920.364-3', 'SSP/SP', '2007-01-06', 'Solteira', 'Rua dos Cedros, 1005, fundos', 'Mooca', '03154-973', '(11) 95097-5908', 'Adriana Ramos Santana', NULL, 'Ensino Fundamental incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2025-07-22', 1, '2026-03-10'),
  (156, NULL, 'CRAS Mooca', 'Francisca Nascimento Batista', NULL, 'F', NULL, '1973-08-09', 'São Paulo/SP', 'Branca', NULL, NULL, '753.078.902-59', '49.201.211-8', 'SSP/SP', '2018-04-21', 'Solteira', 'Rua dos Ipês, 94', 'Brás', '03390-304', '(11) 98454-5183', 'Bruna Nascimento Batista', NULL, 'Ensino Médio incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2025-07-23', 1, '2025-06-12'),
  (157, NULL, NULL, 'Gabriela Monteiro Lima', NULL, 'F', NULL, '1986-03-23', 'Guarulhos/SP', 'Preta', NULL, NULL, '448.079.695-49', '17.057.878-9', 'SSP/SP', '2019-11-19', 'Solteira', 'Rua dos Cedros, 323', 'Água Rasa', '03183-274', '(11) 98131-5078', 'Sônia Carvalho Lima', 'José Lima', 'Ensino Fundamental completo', 'Não', NULL, 'Não', 'ATIVO', '2025-07-28', 0, NULL),
  (158, '13601818017', 'CRAS Mooca', 'Felipe dos Santos Dias', NULL, 'M', NULL, '1960-12-21', 'São Paulo/SP', 'Parda', NULL, NULL, '160.143.616-65', '29.231.040-2', 'SSP/SP', '2004-03-15', 'Casado', 'Rua dos Coqueiros, 231, apto 21', 'Belém', '03170-829', '(11) 92690-5166', 'Francisca Fernandes Dias', 'Cícero Dias', 'Ensino Médio incompleto', 'Não', NULL, 'Sim', 'ATIVO', '2025-07-30', 0, NULL),
  (159, '11878541024', 'CRAS Mooca', 'Gilberto Ramos Monteiro', NULL, 'M', NULL, '1955-08-28', 'Montes Claros/MG', 'Parda', NULL, NULL, '603.990.869-59', '30.104.174-3', 'SSP/SP', '1978-09-14', 'União estável', 'Rua dos Coqueiros, 129', 'Mooca', '03341-998', '(11) 94165-4336', 'Edna Lima Monteiro', 'Valdir Monteiro', 'Ensino Fundamental completo', 'Não', NULL, 'Sim', 'ATIVO', '2025-08-01', 1, '2025-03-11'),
  (160, '24147892884', 'CRAS Mooca', 'Michele Barbosa Carvalho', NULL, 'F', NULL, '1977-10-08', 'Natal/RN', NULL, NULL, NULL, '252.966.419-74', '33.943.695-9', 'SSP/SP', '2003-02-10', 'Casada', 'Rua das Magnólias, 899, apto 7', 'Mooca', '03344-711', '(11) 97549-7399', 'Priscila Pereira Carvalho', NULL, 'Ensino Médio completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2025-08-11', 1, '2025-11-06'),
  (161, '24896956988', 'CRAS Mooca', 'Carlos Costa Cardoso', NULL, 'M', NULL, '1988-12-11', 'Maceió/AL', NULL, 'Deficiência intelectual', NULL, '219.520.244-69', '57.557.388-0', 'SSP/BA', '2011-11-03', 'Solteiro', 'Rua das Hortênsias, 809', 'Cambuci', '03302-366', '(11) 99931-3355', 'Maria Rocha Cardoso', 'Valdir Cardoso', 'Ensino Fundamental completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2025-08-12', 1, '2026-03-08'),
  (162, '24817145987', 'CRAS Belém', 'Bruna Moreira Andrade', NULL, 'F', NULL, '2000-06-19', 'São Paulo/SP', 'Preta', NULL, NULL, '593.038.421-36', '10.185.094-9', 'SSP/SP', '2023-12-05', 'Casada', 'Avenida das Figueiras, 1247, casa 2', 'Mooca', '03230-596', '(11) 96875-8251', 'Débora Mendes Andrade', NULL, 'Ensino Médio completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2025-08-30', 1, '2025-06-27'),
  (163, '10752240245', NULL, 'Rodrigo Rocha Souza', NULL, 'M', NULL, '1963-10-10', 'Feira de Santana/BA', NULL, NULL, NULL, '121.257.929-97', '45.453.440-7', 'SSP/SP', '2020-04-06', 'União estável', 'Rua dos Coqueiros, 319, casa 2', 'Mooca', '03164-132', '(11) 95458-1718', 'Aline Souza Souza', NULL, 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2025-08-31', 1, '2026-09-28'),
  (164, '12999253487', 'CRAS Mooca', 'Helena Farias Andrade', NULL, 'F', NULL, '2001-03-21', 'Teresina/PI', NULL, NULL, NULL, '941.401.981-91', '25.851.890-3', 'SSP/SP', '2020-12-04', 'Divorciada', 'Rua das Palmeiras, 1415', 'Brás', '03206-642', '(11) 97886-9124', 'Juliana Brito Andrade', 'Severino Andrade', 'Ensino Fundamental completo', 'Não', NULL, 'Não', 'ATIVO', '2025-09-04', 0, NULL),
  (165, '13847998824', NULL, 'Luciana Martins Lopes', NULL, 'F', 'Prefere não informar', '1996-09-28', 'São Paulo/SP', 'Branca', NULL, NULL, '245.644.059-36', '37.243.226-3', 'SSP/SP', '2021-09-14', 'Solteira', 'Rua dos Coqueiros, 188', 'Brás', '03161-199', '(11) 91887-3799', 'Silvana Marques Lopes', 'Gilberto Lopes', 'Ensino Fundamental incompleto', 'Sim - EJA', 'Bolsa Família', 'Não', 'ATIVO', '2025-09-24', 1, '2025-04-23'),
  (166, '22181807964', 'CRAS Mooca', 'Diego Vieira Fernandes', NULL, 'M', NULL, '1968-06-16', 'Recife/PE', 'Branca', NULL, NULL, '221.151.670-78', '26.376.989-0', 'SSP/SP', '2013-11-11', 'Solteiro', 'Rua dos Coqueiros, 701', 'Mooca', '03209-954', '(11) 94151-1640', 'Vera Fernandes Fernandes', NULL, 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2025-09-18', 1, '2025-07-28'),
  (167, NULL, 'CRAS Mooca', 'Severino Brito Martins', NULL, 'M', NULL, '1948-08-22', 'Natal/RN', NULL, NULL, NULL, '782.503.473-84', '41.229.859-6', 'SSP/SP', '1990-07-03', 'Solteiro', 'Rua dos Cedros, 1387', 'Brás', '03267-707', '(11) 95061-3012', 'Edna Farias Martins', 'Marcos Martins', 'Ensino Médio completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2025-09-20', 1, '2026-07-26'),
  (168, NULL, NULL, 'Tatiane Correia Santana', NULL, 'F', NULL, '1947-03-14', 'São Paulo/SP', 'Parda', NULL, NULL, '733.572.174-15', '55.091.348-5', 'SSP/SP', '1966-08-07', 'Solteira', 'Rua das Orquídeas, 822, apto 41', 'Mooca', '03268-023', '(11) 97947-6734', 'Tatiane Santos Santana', NULL, 'Ensino Fundamental incompleto', 'Não', NULL, 'Sim', 'ATIVO', '2025-09-21', 0, NULL),
  (169, '17626324339', 'CRAS Mooca', 'Josefa Fernandes Lima', NULL, 'F', NULL, '2000-06-06', 'Feira de Santana/BA', 'Branca', NULL, NULL, '817.435.236-82', '38.290.843-9', 'SSP/SP', '2023-12-13', 'Solteira', 'Avenida das Figueiras, 462, fundos', 'Brás', '03295-315', '(11) 99769-3518', 'Débora Correia Lima', NULL, 'Ensino Fundamental completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2025-09-26', 1, '2026-04-23'),
  (170, '25778055383', 'CRAS Mooca', 'Helena Monteiro Carvalho', NULL, 'F', NULL, '1967-12-09', 'São Paulo/SP', 'Preta', NULL, NULL, '327.164.835-86', '14.689.832-1', 'SSP/SP', '1996-05-10', 'Divorciada', 'Rua dos Ipês, 601', 'Mooca', '03342-907', '(11) 96633-5017', 'Vera Rocha Carvalho', NULL, 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2025-10-03', 1, '2024-12-21'),
  (171, NULL, 'CRAS Mooca', 'Lucas de Andrade Ribeiro', NULL, 'M', NULL, '2000-03-11', 'Maceió/AL', NULL, NULL, NULL, '598.249.107-53', '27.214.473-1', 'SSP/SP', '2022-02-06', 'Solteiro', 'Rua dos Girassóis, 378, casa 2', 'Mooca', '03354-889', '(11) 92055-3568', 'Tatiane Marques Ribeiro', NULL, 'Ensino Superior completo', 'Não', NULL, 'Não', 'ATIVO', '2025-10-03', 0, NULL),
  (172, '11214281924', 'CREAS Mooca', 'Camila Nascimento Freitas', NULL, 'F', NULL, '1968-09-23', 'Salvador/BA', 'Branca', NULL, 'Amendoim', '736.601.653-62', '43.117.702-8', 'SSP/SP', '2021-11-30', 'Solteira', 'Rua dos Girassóis, 1070, casa 2', 'Cambuci', '03273-240', '(11) 96544-7946', 'Bruna Ramos Freitas', NULL, 'Ensino Fundamental incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2025-10-04', 1, '2025-09-23'),
  (173, '25454349426', 'CREAS Mooca', 'Anderson Correia Araújo', NULL, 'M', NULL, '1970-05-19', 'São Paulo/SP', 'Branca', NULL, NULL, '403.116.682-28', '50.553.264-1', 'SSP/SP', '2022-06-26', 'Casado', 'Rua dos Cedros, 611, casa 2', 'Brás', '03292-163', '(11) 97621-5659', 'Sandra Rodrigues Araújo', 'Gilberto Araújo', 'Sem escolaridade', 'Não', NULL, 'Não', 'ATIVO', '2025-10-18', 0, NULL),
  (174, '18354538269', 'CRAS Mooca', 'Daniela Soares Batista', NULL, 'F', NULL, '1984-09-10', 'São Paulo/SP', 'Parda', NULL, NULL, '204.706.744-54', '48.531.952-6', 'SSP/SP', '2020-04-09', 'Casada', 'Rua das Magnólias, 1311', 'Tatuapé', '03247-888', '(11) 95117-1291', 'Neide Vieira Batista', NULL, 'Ensino Fundamental incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2025-10-30', 1, '2025-12-24'),
  (175, '28518371253', 'CRAS Belém', 'Tatiane da Silva Vieira', NULL, 'F', NULL, '1979-06-26', 'São Paulo/SP', 'Preta', NULL, 'Frutos do mar', '881.787.950-49', '48.712.165-3', 'SSP/SP', '2022-06-14', 'Casada', 'Rua dos Jacarandás, 265, fundos', 'Mooca', '03202-456', NULL, 'Daniela Andrade Vieira', 'Marcos Vieira', 'Ensino Médio completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2025-11-07', 1, '2025-07-23'),
  (176, '23905491851', 'CRAS Mooca', 'Thiago de Almeida Gomes', NULL, 'M', NULL, '1999-03-07', 'São Paulo/SP', 'Preta', NULL, NULL, '546.361.325-95', '59.622.108-5', 'SSP/SP', '2022-02-13', 'União estável', 'Rua das Begônias, 350, fundos', 'Mooca', '03345-439', '(11) 95176-7386', 'Edna Vieira Gomes', NULL, 'Ensino Fundamental incompleto', 'Sim - EJA', NULL, 'Não', 'ATIVO', '2025-11-15', 1, '2025-07-29'),
  (177, '10699359290', NULL, 'Gilberto Barbosa Gomes', NULL, 'M', NULL, '1971-02-15', 'Recife/PE', NULL, NULL, NULL, '275.210.152-06', '17.216.256-7', 'SSP/SP', '1997-09-23', 'Solteiro', 'Rua das Magnólias, 796', 'Brás', '03270-839', '(11) 98300-1935', 'Camila Cardoso Gomes', 'Paulo Gomes', 'Ensino Médio incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2025-11-20', 1, '2026-08-02'),
  (178, '12433496879', 'CRAS Belém', 'Valéria Cavalcanti Dias', NULL, 'F', NULL, '2005-09-23', 'Fortaleza/CE', NULL, NULL, NULL, '124.808.484-58', '24.323.836-4', 'SSP/PE', '2023-05-01', 'Divorciada', 'Travessa das Violetas, 1236, apto 48', 'Tatuapé', '03335-779', '(11) 95403-4145', 'Daniela Monteiro Dias', NULL, 'Ensino Fundamental incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2025-11-30', 1, '2026-03-04'),
  (179, NULL, 'CRAS Belém', 'Ana Freitas Souza', NULL, 'F', NULL, '1967-07-16', 'Recife/PE', NULL, NULL, NULL, '790.693.651-27', '24.952.900-9', 'SSP/SP', '2000-02-06', 'Solteira', 'Sem endereço fixo (situação de rua)', 'Brás', NULL, NULL, 'Cristiane Costa Souza', NULL, 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2025-12-10', 0, NULL),
  (180, '13921466454', 'CRAS Mooca', 'Bruna Monteiro Pereira', NULL, 'F', NULL, '1987-12-02', 'São Paulo/SP', 'Branca', NULL, NULL, '557.129.563-52', '44.754.480-6', 'SSP/SP', '2023-01-27', 'Viúva', 'Rua das Camélias, 1101', 'Mooca', '03318-686', '(11) 98051-7603', 'Luciana Oliveira Pereira', NULL, 'Ensino Fundamental incompleto', 'Sim - EJA', NULL, 'Não', 'ATIVO', '2025-12-15', 1, '2025-11-12'),
  (181, NULL, 'CRAS Belém', 'Cláudia Dias Machado', NULL, 'F', NULL, '1952-05-16', 'São Paulo/SP', 'Parda', NULL, NULL, '269.780.419-91', '59.233.813-8', 'SSP/PE', '2022-07-13', 'União estável', 'Rua dos Cedros, 489, casa 2', 'Mooca', '03190-612', '(11) 99084-1496', 'Raimunda Brito Machado', 'Reginaldo Machado', 'Sem escolaridade', 'Não', NULL, 'Sim', 'ATIVO', '2025-12-16', 1, '2025-03-10'),
  (182, '15592922647', NULL, 'Sônia Batista Nascimento', NULL, 'F', NULL, '2006-06-03', 'Belo Horizonte/MG', 'Amarela', NULL, NULL, '182.729.998-02', '15.614.236-1', 'SSP/SP', '2024-01-29', 'Solteira', 'Rua das Begônias, 1117, casa 2', 'Tatuapé', '03144-046', '(11) 95789-8327', 'Priscila Teixeira Nascimento', 'Lucas Nascimento', 'Ensino Fundamental completo', 'Não', NULL, 'Não', 'ATIVO', '2025-12-27', 0, NULL),
  (183, NULL, 'CRAS Mooca', 'Vanessa Martins Rodrigues', NULL, 'F', 'Prefere não informar', '2006-05-18', 'São Luís/MA', 'Amarela', NULL, NULL, '313.197.538-19', '28.544.792-0', 'SSP/SP', '2024-05-06', 'Solteira', 'Travessa das Violetas, 90, apto 7', 'Mooca', '03148-435', '(11) 94340-9746', 'Renata Fernandes Rodrigues', 'Diego Rodrigues', 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2026-02-07', 1, '2025-09-20'),
  (184, '25325015731', NULL, 'Juliana Costa Ramos', NULL, 'F', NULL, '1975-11-16', 'São Paulo/SP', NULL, 'Deficiência visual', NULL, '790.765.560-02', '55.920.573-9', 'SSP/SP', '2014-07-08', 'Solteira', 'Rua das Hortênsias, 375, casa 2', 'Mooca', '03127-267', '(11) 95249-3216', 'Josefa Rodrigues Ramos', 'Pedro Ramos', 'Ensino Fundamental completo', 'Não', NULL, 'Não', 'ATIVO', '2026-02-10', 0, '2022-08-16'),
  (185, '13072205384', 'CRAS Mooca', 'Manoel Araújo Fernandes', NULL, 'M', NULL, '1977-12-05', 'São Paulo/SP', 'Branca', NULL, NULL, NULL, NULL, NULL, NULL, 'Solteiro', 'Rua das Camélias, 627', 'Belém', '03140-671', '(11) 91300-6512', 'Ivone Brito Fernandes', NULL, 'Ensino Médio incompleto', 'Não', NULL, 'Não', 'ATIVO', '2026-03-04', 1, '2025-04-20'),
  (186, '12064127905', 'CRAS Mooca', 'Marcelo Batista Ramos', NULL, 'M', NULL, '1952-09-17', 'Natal/RN', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Divorciado', 'Rua dos Ipês, 104, fundos', 'Mooca', '03233-649', '(11) 95759-9440', 'Roseli Alves Ramos', NULL, 'Ensino Médio incompleto', 'Não', NULL, 'Sim', 'ATIVO', '2026-03-07', 1, '2025-08-04'),
  (187, '14920657408', NULL, 'Kelly Oliveira Dias', NULL, 'F', NULL, '1953-10-28', 'Natal/RN', 'Parda', NULL, NULL, '159.501.310-83', '51.188.982-9', 'SSP/CE', '2007-08-27', 'Solteira', 'Rua dos Cedros, 738, fundos', 'Mooca', '03355-336', '(11) 94989-9057', 'Valéria Rodrigues Dias', 'Carlos Dias', 'Ensino Médio incompleto', 'Não', NULL, 'Sim', 'ATIVO', '2026-03-09', 1, '2026-07-20'),
  (188, '23245519882', 'CRAS Mooca', 'Daniela Rocha Rodrigues', NULL, 'F', NULL, '1967-06-05', 'São Paulo/SP', NULL, NULL, NULL, '348.523.597-25', '13.728.744-1', 'SSP/SP', '1994-01-07', 'Divorciada', 'Rua dos Girassóis, 541', 'Mooca', '03356-406', '(11) 94643-3871', 'Priscila Lopes Rodrigues', 'Diego Rodrigues', 'Ensino Fundamental incompleto', 'Sim - EJA', 'Bolsa Família', 'Não', 'ATIVO', '2026-03-10', 1, '2025-09-16'),
  (189, '15977430487', 'CRAS Mooca', 'Francisca Ramos Freitas', NULL, 'F', NULL, '1971-11-19', 'Teresina/PI', 'Preta', NULL, NULL, '510.198.645-64', '24.225.542-5', 'SSP/SP', '1994-09-21', 'Casada', 'Rua das Acácias, 1484', 'Mooca', '03190-724', '(11) 97372-3967', 'Elaine Marques Freitas', NULL, 'Ensino Fundamental completo', 'Não', NULL, 'Não', 'ATIVO', '2026-03-19', 1, '2025-10-25'),
  (190, '23504412146', 'CREAS Mooca', 'Gabriela Barbosa Vieira', NULL, 'F', 'Prefere não informar', '1976-04-20', 'Recife/PE', 'Branca', NULL, NULL, '411.995.007-22', '44.174.353-9', 'SSP/SP', '2000-07-02', 'Solteira', 'Rua dos Ipês, 1429', 'Belém', '03192-206', NULL, 'Adriana Ferreira Vieira', 'Severino Vieira', 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2026-03-22', 1, '2024-12-25'),
  (191, NULL, 'CRAS Mooca', 'Ivone Martins Machado', NULL, 'F', NULL, '1956-02-15', 'São Paulo/SP', NULL, NULL, 'Lactose', '249.202.246-81', '25.398.970-8', 'SSP/SP', '2015-10-07', 'Viúva', 'Rua dos Jacarandás, 1387', 'Mooca', '03232-030', '(11) 98544-8838', 'Antônia Nunes Machado', 'Antônio Machado', 'Ensino Médio completo', 'Não', NULL, 'Sim', 'ATIVO', '2026-03-23', 1, '2025-05-23'),
  (192, NULL, NULL, 'Silvana Costa Farias', NULL, 'F', NULL, '1959-04-21', 'São Paulo/SP', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'União estável', 'Rua dos Girassóis, 527', 'Vila Prudente', '03310-758', NULL, 'Vera Marques Farias', NULL, 'Ensino Médio completo', 'Não', NULL, 'Sim', 'ATIVO', '2026-03-28', 0, NULL),
  (193, '13268421259', 'CRAS Mooca', 'Gilberto Araújo Lopes', NULL, 'M', NULL, '1985-07-27', 'São Paulo/SP', NULL, NULL, NULL, '970.847.222-68', '21.153.768-1', 'SSP/SP', '2003-04-22', 'Solteiro', 'Rua das Hortênsias, 11, apto 24', 'Mooca', '03293-028', '(11) 97987-7822', 'Juliana Costa Lopes', 'Fábio Lopes', 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2026-03-31', 0, NULL),
  (194, NULL, 'CRAS Belém', 'Ana de Souza Nascimento', NULL, 'F', 'Prefere não informar', '1980-02-13', 'Guarulhos/SP', 'Branca', NULL, NULL, NULL, '47.911.426-5', 'SSP/SP', '2010-10-15', 'Solteira', 'Sem endereço fixo (situação de rua)', 'Brás', NULL, NULL, 'Roseli Cavalcanti Nascimento', NULL, 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2026-04-05', 0, NULL),
  (195, '27827428753', NULL, 'Gabriela Dias Alves', NULL, 'F', 'Prefere não informar', '1979-12-19', 'São Paulo/SP', NULL, NULL, NULL, '976.110.804-44', '26.045.750-6', 'SSP/SP', '2012-04-27', 'Solteira', 'Rua das Begônias, 645', 'Mooca', '03156-663', '(11) 98625-1489', 'Camila Fernandes Alves', NULL, 'Ensino Superior incompleto', 'Não', NULL, 'Não', 'ATIVO', '2026-04-08', 1, '2026-07-10'),
  (196, '18690453937', 'CRAS Mooca', 'Francisca Rodrigues Barbosa', NULL, 'F', NULL, '1985-03-09', 'Fortaleza/CE', 'Branca', NULL, NULL, '694.714.063-25', '24.218.732-1', 'SSP/SP', '2016-11-10', 'Solteira', 'Rua das Palmeiras, 562', 'Belém', '03299-070', '(11) 95005-1243', 'Letícia Barbosa Barbosa', 'Luiz Barbosa', 'Ensino Médio incompleto', 'Sim - EJA', NULL, 'Não', 'ATIVO', '2026-04-09', 0, '2022-05-16'),
  (197, '26174852581', 'CRAS Belém', 'Ana Santos Carvalho', NULL, 'F', NULL, '1995-08-08', 'São Paulo/SP', 'Preta', NULL, NULL, '207.896.121-78', '26.158.930-3', 'SSP/CE', '2023-07-05', 'Viúva', 'Rua das Begônias, 65, casa 2', 'Água Rasa', '03232-488', '(11) 92850-7591', 'Priscila Barbosa Carvalho', NULL, 'Ensino Médio incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2026-04-14', 1, '2026-03-15'),
  (198, '11933832993', NULL, 'Wellington Mendes Dias', NULL, 'M', NULL, '1979-10-11', 'São Paulo/SP', 'Parda', NULL, NULL, '515.086.160-05', '58.354.275-2', 'SSP/SP', '2005-10-10', 'Solteiro', 'Rua dos Girassóis, 250, apto 40', 'Vila Prudente', '03279-275', '(11) 92311-3333', 'Juliana Lopes Dias', NULL, 'Ensino Médio completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2026-04-21', 1, '2025-08-15'),
  (199, '11970120306', 'CRAS Belém', 'Thiago Brito Vieira', NULL, 'M', 'Prefere não informar', '1963-04-12', 'Maceió/AL', 'Parda', NULL, 'Frutos do mar', '424.341.273-21', '33.835.922-3', 'SSP/SP', '1989-04-03', 'Solteiro', 'Travessa das Violetas, 1119', 'Brás', '03303-012', '(11) 95113-8138', 'Sandra Teixeira Vieira', NULL, 'Ensino Médio incompleto', 'Não', NULL, 'Não', 'ATIVO', '2026-04-22', 1, '2025-06-19'),
  (200, '18968958105', 'CRAS Mooca', 'Paulo Mendes Pinto', NULL, 'M', 'Prefere não informar', '1966-05-16', 'Salvador/BA', 'Parda', NULL, NULL, '634.415.754-17', '37.999.277-8', 'SSP/SP', '2023-05-28', 'Solteiro', 'Rua dos Coqueiros, 336, fundos', 'Mooca', '03103-130', '(11) 98449-6628', 'Fernanda Dias Pinto', NULL, 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2026-05-03', 1, '2025-11-19');

INSERT INTO beneficiario (id_beneficiario, nis, cras_creas_sas, nome_completo, nome_social, sexo, orientacao_sexual, data_nascimento, naturalidade, cor_raca, pessoa_com_deficiencia, tem_alergias, cpf, rg_numero, rg_orgao_uf_emissor, rg_data_emissao, estado_civil, endereco, bairro, cep, telefone, nome_mae, nome_pai, escolaridade, estuda_atualmente, recebe_transferencia_renda, recebe_bpc, situacao_cadastro, data_consentimento, cadunico_ativo, data_atualizacao_cadunico) VALUES
  (201, '15832970348', 'CRAS Mooca', 'Diego Almeida Teixeira', NULL, 'M', NULL, '2001-03-18', 'Fortaleza/CE', 'Indígena', NULL, NULL, '769.945.559-64', '38.382.816-2', 'SSP/SP', '2023-08-03', 'Divorciado', 'Rua das Camélias, 1346, casa 2', 'Vila Prudente', '03313-254', '(11) 93291-9578', 'Francisca Ribeiro Teixeira', NULL, 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2026-05-05', 1, '2026-08-14'),
  (202, '20544372166', 'CRAS Mooca', 'Luiz Nunes Nascimento', NULL, 'M', NULL, '1972-11-02', 'Guarulhos/SP', NULL, NULL, NULL, '376.682.542-57', '40.717.886-9', 'SSP/SP', '2019-04-11', 'Viúvo', 'Rua dos Cedros, 720', 'Mooca', '03178-259', '(11) 95898-1893', 'Lúcia Silva Nascimento', 'Rafael Nascimento', 'Ensino Superior incompleto', 'Não', NULL, 'Não', 'ATIVO', '2026-05-08', 1, '2022-11-29'),
  (203, NULL, 'CRAS Mooca', 'Elaine Marques Ramos', NULL, 'F', NULL, '1988-07-08', 'São Paulo/SP', 'Parda', NULL, NULL, '642.651.738-42', '43.571.238-3', 'SSP/SP', '2018-05-13', 'União estável', 'Rua dos Lírios, 1435, apto 45', 'Água Rasa', '03132-360', '(11) 98655-1291', 'Bruna Mendes Ramos', 'Raimundo Ramos', 'Sem escolaridade', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2026-05-12', 1, '2025-10-24'),
  (204, '10668581377', 'CRAS Mooca', 'Gabriela Moura Oliveira', NULL, 'F', NULL, '2005-04-21', 'Fortaleza/CE', 'Preta', NULL, 'Frutos do mar', '526.208.291-29', '39.712.704-9', 'SSP/SP', '2024-06-02', 'Divorciada', 'Rua das Begônias, 800, casa 2', 'Tatuapé', '03207-939', '(11) 99935-4412', 'Raimunda Gonçalves Oliveira', NULL, 'Ensino Superior incompleto', 'Não', NULL, 'Não', 'ATIVO', '2026-05-12', 0, NULL),
  (205, '20426961124', 'CRAS Belém', 'Felipe Carvalho Lima', NULL, 'M', NULL, '1957-01-21', 'São Luís/MA', NULL, NULL, NULL, '358.144.988-06', '27.741.299-8', 'SSP/SP', '1977-08-05', 'Solteiro', 'Rua dos Cedros, 12, fundos', 'Belém', '03261-562', '(11) 99326-1803', 'Vanessa Cavalcanti Lima', NULL, 'Ensino Médio completo', 'Não', NULL, 'Sim', 'ATIVO', '2026-05-14', 0, '2021-11-06'),
  (206, '25367318625', NULL, 'Lúcia Souza Batista', NULL, 'F', NULL, '1974-01-06', 'Recife/PE', 'Preta', NULL, NULL, '278.915.622-17', '42.871.500-8', 'SSP/CE', '2009-01-25', 'Divorciada', 'Rua dos Cedros, 630, casa 2', 'Belém', '03329-205', NULL, 'Cláudia Ribeiro Batista', NULL, 'Ensino Médio incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2026-05-18', 1, '2026-04-19'),
  (207, '24705444859', 'CRAS Mooca', 'Fernanda Gonçalves Ramos', NULL, 'F', NULL, '1973-07-15', 'São Paulo/SP', 'Preta', NULL, NULL, '364.021.107-52', '12.665.597-1', 'SSP/SP', '2016-04-07', 'União estável', 'Rua das Acácias, 1499, fundos', 'Mooca', '03229-377', '(11) 91277-8748', 'Raimunda Marques Ramos', 'Paulo Ramos', 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2026-05-19', 1, '2024-12-22'),
  (208, NULL, 'CRAS Belém', 'Valéria Ribeiro Carvalho', NULL, 'F', NULL, '2000-07-17', 'Fortaleza/CE', 'Preta', NULL, NULL, NULL, NULL, NULL, NULL, 'Solteira', 'Sem endereço fixo (situação de rua)', 'Mooca', NULL, NULL, 'Márcia Araújo Carvalho', NULL, 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2026-05-22', 0, NULL),
  (209, NULL, 'CRAS Mooca', 'Rodrigo Machado Gonçalves', NULL, 'M', NULL, '1977-09-17', NULL, 'Branca', NULL, NULL, NULL, '31.080.783-3', 'SSP/SP', '2002-06-11', 'Solteiro', 'Sem endereço fixo (situação de rua)', 'Brás', NULL, NULL, 'Kelly Marques Gonçalves', NULL, 'Ensino Fundamental completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2026-05-25', 1, '2026-04-20'),
  (210, NULL, 'CRAS Mooca', 'Joana Rocha Andrade', NULL, 'F', 'Prefere não informar', '1999-01-23', 'São Paulo/SP', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Solteira', 'Sem endereço fixo (situação de rua)', 'Mooca', NULL, '(11) 95341-6400', 'Elaine Nascimento Andrade', 'Francisco Andrade', 'Ensino Fundamental incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2026-05-28', 1, '2026-03-01'),
  (211, '16788012424', 'CRAS Mooca', 'Joana Rodrigues Souza', NULL, 'F', 'Prefere não informar', '2003-02-26', 'São Paulo/SP', NULL, NULL, NULL, '554.157.803-16', '23.280.073-0', 'SSP/PE', '2021-04-18', 'Solteira', 'Travessa das Violetas, 965', 'Mooca', '03252-729', '(11) 98400-3775', 'Francisca Andrade Souza', NULL, 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2026-05-30', 1, '2026-10-17'),
  (212, NULL, 'CRAS Belém', 'Carlos Lima Ramos', NULL, 'M', NULL, '1982-09-09', NULL, 'Parda', NULL, NULL, '674.187.359-48', '19.779.573-7', 'SSP/BA', '2014-11-18', 'Solteiro', 'Sem endereço fixo (situação de rua)', 'Mooca', NULL, NULL, 'Luciana Carvalho Ramos', NULL, 'Ensino Fundamental incompleto', 'Não', NULL, 'Não', 'ATIVO', '2026-06-03', 1, '2025-06-08'),
  (213, '24273156582', 'CREAS Mooca', 'Maria Nunes Teixeira', NULL, 'F', NULL, '1962-10-02', 'São Paulo/SP', 'Parda', NULL, NULL, '566.324.627-99', '28.091.723-7', 'SSP/SP', '1999-03-03', 'Solteira', 'Rua dos Lírios, 898', 'Brás', '03237-831', NULL, 'Joana Nunes Teixeira', 'Marcelo Teixeira', 'Sem escolaridade', 'Sim - EJA', NULL, 'Não', 'ATIVO', '2026-06-05', 1, '2025-05-29'),
  (214, '25480031105', NULL, 'Vera Ribeiro Teixeira', NULL, 'F', NULL, '1954-06-25', 'São Paulo/SP', NULL, NULL, NULL, '718.165.067-72', '47.866.114-2', 'SSP/SP', '1998-12-06', 'Solteira', 'Rua dos Jacarandás, 150', 'Brás', '03138-458', '(11) 91893-8468', 'Francisca Marques Teixeira', NULL, 'Ensino Fundamental incompleto', 'Não', NULL, 'Não', 'ATIVO', '2026-06-07', 0, NULL),
  (215, NULL, 'CRAS Belém', 'Helena Nascimento Santos', NULL, 'F', NULL, '1969-04-01', 'São Paulo/SP', 'Parda', NULL, NULL, '336.533.470-53', '55.558.179-1', 'SSP/SP', '2020-07-11', 'Solteira', 'Rua dos Lírios, 52', 'Mooca', '03250-255', '(11) 99099-9957', 'Michele Pereira Santos', NULL, 'Ensino Médio completo', 'Não', NULL, 'Não', 'ATIVO', '2026-06-11', 1, '2025-07-26'),
  (216, '12556396720', 'CRAS Mooca', 'Daniela Barbosa Moreira', NULL, 'F', NULL, '1962-11-01', 'São Paulo/SP', NULL, NULL, NULL, '676.342.263-03', '40.225.346-3', 'SSP/SP', '1980-09-30', 'União estável', 'Rua das Hortênsias, 300', 'Mooca', '03242-150', '(11) 94976-6577', 'Priscila Rocha Moreira', NULL, 'Sem escolaridade', 'Não', NULL, 'Não', 'ATIVO', '2026-06-14', 0, NULL),
  (217, '14371067535', NULL, 'Jéssica da Silva Pereira', NULL, 'F', 'Prefere não informar', '1975-06-09', 'Salvador/BA', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Casada', 'Rua das Acácias, 1299, casa 2', 'Mooca', '03109-868', '(11) 98776-6642', 'Fernanda Marques Pereira', NULL, 'Ensino Médio completo', 'Sim - ensino superior', 'Bolsa Família', 'Não', 'ATIVO', '2026-06-15', 1, '2025-04-17'),
  (218, '13201714362', 'CRAS Mooca', 'Camila Cardoso Rocha', NULL, 'F', NULL, '1999-03-18', 'Aracaju/SE', 'Branca', NULL, NULL, '114.468.184-14', '19.840.891-3', 'SSP/SP', '2018-01-11', 'Solteira', 'Rua dos Girassóis, 1008, casa 2', 'Mooca', '03205-371', '(11) 91586-1306', 'Aline Nascimento Rocha', 'Severino Rocha', 'Ensino Fundamental incompleto', 'Não', NULL, 'Não', 'ATIVO', '2026-06-19', 0, NULL),
  (219, NULL, 'CRAS Mooca', 'João de Souza Correia', NULL, 'M', NULL, '1974-04-14', 'Teresina/PI', 'Parda', NULL, NULL, '748.470.909-22', '16.661.466-7', 'SSP/SP', '2001-03-01', 'União estável', 'Rua das Camélias, 1373', 'Brás', '03266-330', '(11) 96534-3779', 'Valéria Carvalho Correia', NULL, 'Ensino Fundamental completo', 'Não', NULL, 'Não', 'ATIVO', '2026-06-20', 0, NULL),
  (220, '25326212601', 'CRAS Mooca', 'Larissa Ramos Dias', NULL, 'F', NULL, '1971-01-13', 'Salvador/BA', 'Parda', NULL, 'Lactose', '638.753.569-97', '26.508.631-3', 'SSP/SP', '2022-03-07', 'Viúva', 'Rua dos Coqueiros, 1202, apto 13', 'Brás', '03360-352', NULL, 'Francisca Teixeira Dias', 'Gilberto Dias', 'Ensino Médio incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2026-06-28', 1, '2026-07-04'),
  (221, '11393285976', 'CREAS Mooca', 'Josué Gonçalves Farias', NULL, 'M', 'Prefere não informar', '1991-06-25', 'São Paulo/SP', 'Parda', NULL, NULL, '427.205.833-15', '13.856.330-4', 'SSP/SP', '2022-08-07', 'Viúvo', 'Viela das Margaridas, 508, casa 2', 'Mooca', '03368-803', '(11) 97751-2594', 'Letícia Martins Farias', NULL, 'Ensino Médio completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2026-06-28', 1, '2025-06-25'),
  (222, NULL, 'CRAS Mooca', 'Valéria Lopes Pinto', NULL, 'F', NULL, '1948-01-15', 'Natal/RN', NULL, NULL, NULL, '384.349.192-21', '40.826.912-5', 'SSP/SP', '2014-01-26', 'Viúva', 'Avenida das Figueiras, 1261', 'Mooca', '03255-615', '(11) 96233-3226', 'Silvana Cardoso Pinto', NULL, 'Ensino Médio completo', 'Não', NULL, 'Sim', 'ATIVO', '2026-07-06', 1, '2026-05-02'),
  (223, NULL, NULL, 'Joana Gomes Ribeiro', NULL, 'F', NULL, '2006-05-04', 'São Paulo/SP', 'Parda', NULL, NULL, '900.313.985-71', '44.498.228-6', 'SSP/SP', '2024-04-27', 'Solteira', 'Rua das Camélias, 1457', 'Mooca', '03306-443', '(11) 94637-7729', 'Jéssica Ferreira Ribeiro', NULL, 'Ensino Médio incompleto', 'Não', NULL, 'Não', 'ATIVO', '2026-07-08', 1, '2025-07-26'),
  (224, NULL, 'CRAS Mooca', 'Jéssica Batista Teixeira', NULL, 'F', 'Prefere não informar', '1967-02-19', 'Feira de Santana/BA', 'Parda', NULL, NULL, '378.101.229-78', '22.089.073-9', 'SSP/PE', '2022-02-13', 'Solteira', 'Rua dos Coqueiros, 1250, apto 48', 'Mooca', '03153-459', '(11) 94881-5360', 'Tatiane Mendes Teixeira', 'Marcelo Teixeira', 'Ensino Médio completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2026-07-10', 1, '2026-02-23'),
  (225, '15035777115', NULL, 'Simone Silva Martins', NULL, 'F', NULL, '1970-09-27', 'São Paulo/SP', 'Preta', NULL, NULL, '448.857.969-17', '39.947.198-8', 'SSP/SP', '2024-02-09', 'Casada', 'Viela das Margaridas, 1020', 'Mooca', '03280-693', '(11) 92889-2326', 'Rita Santos Martins', 'Anderson Martins', 'Ensino Fundamental incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2026-07-12', 1, '2026-10-05'),
  (226, '12387968339', 'CRAS Mooca', 'Josefa Almeida Cardoso', NULL, 'F', NULL, '1978-07-03', 'São Paulo/SP', NULL, NULL, NULL, '826.360.052-04', '23.466.546-5', 'SSP/SP', '2015-01-20', 'União estável', 'Viela das Margaridas, 1377, fundos', 'Brás', '03287-569', '(11) 97156-5965', 'Neide Monteiro Cardoso', 'Rafael Cardoso', 'Ensino Médio incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2026-07-12', 1, '2025-12-27'),
  (227, NULL, NULL, 'Valéria Rodrigues Fernandes', NULL, 'F', NULL, '2000-08-20', 'São Paulo/SP', 'Amarela', NULL, NULL, '479.828.028-96', '47.731.426-8', 'SSP/SP', '2018-12-12', 'Solteira', 'Rua das Camélias, 1483, apto 46', 'Brás', '03373-625', '(11) 99997-9064', 'Antônia Silva Fernandes', NULL, 'Ensino Fundamental completo', 'Não', NULL, 'Não', 'ATIVO', '2026-07-15', 0, '2022-11-15'),
  (228, '13441182493', NULL, 'Francisca Araújo Pereira', NULL, 'F', NULL, '1992-06-22', 'São Paulo/SP', 'Branca', NULL, 'Frutos do mar', '156.175.139-41', '45.509.749-0', 'SSP/SP', '2019-04-18', 'União estável', 'Rua dos Cedros, 1173, fundos', 'Mooca', '03314-392', '(11) 95966-4685', 'Aline Ramos Pereira', 'Cícero Pereira', 'Ensino Fundamental completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2026-07-16', 1, '2025-09-13'),
  (229, NULL, NULL, 'Débora Moura Freitas', NULL, 'F', NULL, '2004-06-24', 'São Paulo/SP', 'Branca', 'Deficiência intelectual', NULL, '693.934.135-91', '25.630.645-7', 'SSP/SP', '2022-04-05', 'Solteira', 'Rua das Camélias, 1443', 'Vila Prudente', '03169-380', '(11) 98028-1024', 'Valéria Correia Freitas', 'Valdir Freitas', 'Ensino Médio completo', 'Sim - EJA', NULL, 'Não', 'ATIVO', '2026-07-22', 1, '2025-08-06'),
  (230, '11996047581', NULL, 'Bruna Ribeiro Soares', NULL, 'F', 'Prefere não informar', '1991-03-17', 'São Paulo/SP', 'Branca', NULL, NULL, '707.150.355-86', '28.448.912-9', 'SSP/SP', '2014-01-07', 'Solteira', 'Rua das Hortênsias, 1381, casa 2', 'Mooca', '03252-833', '(11) 96811-5003', 'Sônia Rodrigues Soares', 'Felipe Soares', 'Sem escolaridade', 'Não', NULL, 'Não', 'ATIVO', '2026-08-01', 1, '2025-04-10'),
  (231, '24057716512', NULL, 'Lúcia Gonçalves Andrade', NULL, 'F', NULL, '1955-06-02', 'São Luís/MA', NULL, NULL, NULL, '696.431.795-13', '20.416.843-3', 'SSP/MG', '2013-10-18', 'União estável', 'Rua das Orquídeas, 627', 'Cambuci', '03382-724', '(11) 96985-4193', 'Luciana Barbosa Andrade', NULL, 'Ensino Fundamental completo', 'Não', NULL, 'Não', 'ATIVO', '2026-08-02', 0, NULL),
  (232, '28245933564', 'CRAS Mooca', 'Adriana Fernandes Marques', NULL, 'F', NULL, '1969-04-01', 'São Luís/MA', 'Parda', NULL, NULL, '723.482.995-76', '55.645.673-5', 'SSP/MG', '2018-12-09', 'Divorciada', 'Rua das Orquídeas, 261, apto 2', 'Brás', '03342-401', '(11) 94231-7442', 'Rita Soares Marques', 'José Marques', 'Ensino Fundamental incompleto', 'Não', NULL, 'Não', 'ATIVO', '2026-08-09', 0, NULL),
  (233, '12486891363', NULL, 'Fernanda de Almeida Gomes', NULL, 'F', NULL, '1969-08-14', 'Belo Horizonte/MG', 'Branca', NULL, NULL, '887.920.405-83', '30.106.002-8', 'SSP/SP', '2023-11-26', 'União estável', 'Rua das Hortênsias, 1058', 'Mooca', '03101-488', '(11) 94656-2100', 'Cláudia Souza Gomes', NULL, 'Ensino Médio incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2026-08-10', 1, '2022-10-14'),
  (234, '14820188181', 'CREAS Mooca', 'Francisco Carvalho Pinto', NULL, 'M', NULL, '1985-09-22', 'Campina Grande/PB', 'Preta', NULL, NULL, '601.828.382-31', '18.271.168-6', 'SSP/SP', '2009-01-25', 'Casado', 'Rua das Hortênsias, 385, casa 2', 'Cambuci', '03196-153', '(11) 96689-5917', 'Joana Rocha Pinto', 'Diego Pinto', 'Ensino Médio completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2026-08-15', 1, '2025-04-07'),
  (235, '15398493785', 'CRAS Belém', 'Daniela Nascimento Correia', NULL, 'F', NULL, '1967-02-09', 'Caruaru/PE', 'Parda', NULL, NULL, '490.275.631-45', '13.866.043-7', 'SSP/SP', '2023-12-09', 'União estável', 'Rua dos Cedros, 656', 'Tatuapé', '03355-614', '(11) 97160-9386', 'Larissa Santana Correia', NULL, 'Ensino Fundamental incompleto', 'Não', NULL, 'Não', 'ATIVO', '2026-08-22', 0, NULL),
  (236, NULL, 'CRAS Mooca', 'Antônia Lopes Marques', NULL, 'F', NULL, '1964-03-23', 'São Paulo/SP', 'Preta', NULL, NULL, '993.513.373-10', '19.835.644-7', 'SSP/SP', '2013-07-05', 'União estável', 'Viela das Margaridas, 97', 'Mooca', '03169-086', '(11) 92082-5846', 'Roseli Nascimento Marques', NULL, 'Ensino Médio completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2026-08-29', 1, '2025-08-03'),
  (237, NULL, 'CRAS Mooca', 'Luiz Ferreira Nascimento', NULL, 'M', 'Prefere não informar', '1995-09-02', 'São Paulo/SP', 'Parda', NULL, NULL, '677.221.333-08', '59.149.054-8', 'SSP/BA', '2022-10-06', 'Viúvo', 'Rua dos Cedros, 1397, apto 15', 'Cambuci', '03253-695', '(11) 96624-5778', 'Neide Silva Nascimento', 'Josué Nascimento', 'Ensino Médio completo', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2026-09-08', 1, '2026-07-22'),
  (238, '25957122641', 'CRAS Mooca', 'Adriana Araújo Carvalho', NULL, 'F', 'Prefere não informar', '1997-03-19', 'Teresina/PI', NULL, NULL, NULL, '783.897.928-33', '40.057.833-8', 'SSP/SP', '2015-04-03', 'Solteira', 'Rua dos Coqueiros, 301, apto 29', 'Belém', '03195-678', '(11) 91714-3502', 'Vera Nascimento Carvalho', 'Thiago Carvalho', 'Ensino Fundamental incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2026-09-12', 1, '2025-01-31'),
  (239, '20278871950', 'CRAS Mooca', 'Lúcia Fernandes Ribeiro', NULL, 'F', 'Prefere não informar', '1963-06-24', 'Caruaru/PE', 'Branca', NULL, NULL, '510.665.218-28', '32.689.184-6', 'SSP/SP', '2006-08-22', 'Casada', 'Rua das Begônias, 1182, apto 9', 'Belém', '03377-635', '(11) 94307-5201', 'Kelly Oliveira Ribeiro', NULL, 'Ensino Médio incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2026-09-15', 1, '2026-10-12'),
  (240, '25612722344', 'CRAS Mooca', 'Carlos Batista Vieira', NULL, 'M', NULL, '1948-09-20', 'São Paulo/SP', 'Branca', NULL, NULL, '468.295.270-69', '21.701.304-4', 'SSP/CE', '2004-10-22', 'Solteiro', 'Rua das Palmeiras, 653, apto 24', 'Mooca', '03277-412', '(11) 95080-9778', 'Juliana Pinto Vieira', 'Raimundo Vieira', 'Ensino Médio completo', 'Não', NULL, 'Sim', 'ATIVO', '2026-09-19', 1, '2025-10-21'),
  (241, '11845866412', 'CRAS Mooca', 'Thiago Cardoso Machado', NULL, 'M', NULL, '1951-09-10', 'Recife/PE', 'Branca', NULL, NULL, '146.205.935-69', '31.774.371-3', 'SSP/SP', '2003-08-12', 'Divorciado', 'Rua dos Lírios, 1454, apto 11', 'Mooca', '03257-431', '(11) 99188-8379', 'Adriana Gonçalves Machado', 'Antônio Machado', 'Ensino Fundamental incompleto', 'Não', NULL, 'Sim', 'ATIVO', '2026-09-19', 0, '2021-11-09'),
  (242, NULL, 'CRAS Mooca', 'Antônia Soares Barbosa', NULL, 'F', NULL, '1986-07-21', 'Maceió/AL', 'Parda', NULL, NULL, '949.094.163-55', '53.238.154-4', 'SSP/SP', '2006-04-28', 'Solteira', 'Rua das Camélias, 104', 'Belém', '03227-480', '(11) 96733-5168', 'Kelly Brito Barbosa', 'Severino Barbosa', 'Ensino Fundamental incompleto', 'Não', NULL, 'Não', 'ATIVO', '2026-09-20', 1, '2022-12-24'),
  (243, '22430838373', 'CRAS Mooca', 'Roseli Soares Costa', NULL, 'F', NULL, '1998-12-28', 'Campina Grande/PB', 'Parda', 'Deficiência visual', NULL, '160.368.649-55', '54.006.312-0', 'SSP/SP', '2019-04-03', 'Solteira', 'Rua dos Manacás, 1239, fundos', 'Mooca', '03201-860', '(11) 95882-9395', 'Lúcia Monteiro Costa', 'Bruno Costa', 'Sem escolaridade', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2026-09-25', 1, '2026-04-25'),
  (244, '24025491680', 'CRAS Mooca', 'Roseli Alves Moreira', NULL, 'F', NULL, '1956-11-19', 'São Paulo/SP', 'Parda', NULL, NULL, '193.399.155-31', '29.994.932-7', 'SSP/SP', '2003-12-07', 'Solteira', 'Rua das Hortênsias, 1099, casa 2', 'Água Rasa', '03277-871', '(11) 93514-1767', 'Daniela Alves Moreira', 'Josué Moreira', 'Ensino Fundamental completo', 'Sim - curso técnico', NULL, 'Sim', 'ATIVO', '2026-10-02', 1, '2025-08-23'),
  (245, NULL, 'CRAS Mooca', 'Débora Cavalcanti Moura', NULL, 'F', NULL, '1958-06-14', 'São Paulo/SP', 'Branca', NULL, NULL, '755.366.006-01', '32.810.510-4', 'SSP/SP', '2015-04-25', 'Solteira', 'Rua dos Cedros, 515', 'Mooca', '03396-642', '(11) 91010-7773', 'Kelly Fernandes Moura', 'Wellington Moura', 'Ensino Fundamental completo', 'Não', NULL, 'Sim', 'ATIVO', '2026-10-10', 1, '2025-01-11'),
  (246, '19266180691', 'CRAS Mooca', 'Adilson Batista Martins', NULL, 'M', 'Prefere não informar', '1967-05-10', 'São Paulo/SP', 'Parda', 'Deficiência visual', NULL, '766.130.816-18', '16.891.396-0', 'SSP/SP', '2012-08-19', 'Viúvo', 'Rua dos Lírios, 667', 'Mooca', '03300-316', '(11) 96337-6509', 'Kelly Brito Martins', 'Manoel Martins', 'Ensino Fundamental completo', 'Não', NULL, 'Não', 'ATIVO', '2026-10-19', 1, '2026-09-29'),
  (247, '15807100114', 'CRAS Mooca', 'Vanessa de Almeida Correia', NULL, 'F', NULL, '1984-09-22', 'São Luís/MA', 'Branca', NULL, NULL, '336.887.555-15', '33.782.550-9', 'SSP/SP', '2010-07-15', 'Solteira', 'Rua das Camélias, 163, apto 48', 'Vila Prudente', '03233-807', '(11) 91282-4666', 'Camila Batista Correia', 'Eduardo Correia', 'Ensino Médio incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2026-10-21', 1, '2026-07-16'),
  (248, NULL, 'CRAS Belém', 'Eduardo Pinto Lopes', NULL, 'M', NULL, '1989-02-14', 'Fortaleza/CE', 'Parda', NULL, NULL, '495.868.200-97', '40.080.163-4', 'SSP/SP', '2014-10-29', 'Casado', 'Rua dos Girassóis, 583, fundos', 'Belém', '03339-450', '(11) 94592-2149', 'Simone Marques Lopes', NULL, 'Ensino Médio incompleto', 'Não', 'Bolsa Família', 'Não', 'ATIVO', '2026-10-21', 1, '2025-10-28'),
  (249, NULL, 'CRAS Mooca', 'Francisca Nunes Silva', NULL, 'F', NULL, '1998-05-16', 'Recife/PE', 'Parda', NULL, NULL, '807.734.664-87', '14.014.299-4', 'SSP/SP', '2020-12-26', 'Solteira', 'Travessa das Violetas, 1363', 'Tatuapé', '03193-452', '(11) 95445-6001', 'Maria Machado Silva', 'Marcos Silva', 'Ensino Superior completo', 'Sim - EJA', NULL, 'Não', 'ATIVO', '2026-10-24', 0, NULL),
  (250, '22134853405', 'CRAS Mooca', 'Cristiane da Rocha Ramos', NULL, 'F', NULL, '1951-09-27', 'São Paulo/SP', NULL, NULL, NULL, '950.709.735-46', '35.950.712-5', 'SSP/SP', '2009-04-15', 'Casada', 'Travessa das Violetas, 371, casa 2', 'Mooca', '03247-335', '(11) 99566-3651', 'Cristiane Silva Ramos', NULL, 'Ensino Médio incompleto', 'Não', NULL, 'Sim', 'ATIVO', '2026-10-28', 1, '2026-07-08');

-- ---------------------------------------------------------------------
-- Entidade 03/10 — trabalho (dicionário 4.2)
-- ---------------------------------------------------------------------
-- TRABALHO — Perfil ocupacional — 8 beneficiários sem registro (cardinalidade 0,n)
INSERT INTO trabalho (id_trabalho, id_beneficiario, situacao_ocupacional, profissao_habilidades, renda_atual, empresa_trabalho, ocupacao_atual, telefone_trabalho) VALUES
  (1, 1, 'Aposentado / BPC', NULL, 1600.00, NULL, NULL, NULL),
  (2, 2, 'Desempregada', 'Manicure', 0.00, NULL, NULL, NULL),
  (3, 3, 'Desempregada', 'Pintor', 0.00, NULL, NULL, NULL),
  (4, 4, 'Aposentado / BPC', 'Cuidador(a) de idosos', 1600.00, NULL, NULL, NULL),
  (5, 5, 'Empregada (CLT)', 'Garçom/garçonete', 2250.00, 'Transportes Rota Leste', 'Garçom/garçonete', '(11) 21888-1572'),
  (6, 6, 'Desempregada', 'Pintor', 0.00, NULL, NULL, NULL),
  (7, 7, 'Desempregado', 'Eletricista', 0.00, NULL, NULL, NULL),
  (8, 8, 'Aposentada / BPC', 'Eletricista', 1600.00, NULL, NULL, NULL),
  (9, 9, 'Desempregada', 'Manicure', 0.00, NULL, NULL, NULL),
  (10, 10, 'Trabalho informal', NULL, 600.00, NULL, 'Bicos (autônomo)', NULL),
  (11, 11, 'Aposentada / BPC', 'Repositor(a)', 1600.00, NULL, NULL, NULL),
  (12, 12, 'Do lar', 'Auxiliar de limpeza', 0.00, NULL, NULL, NULL),
  (13, 13, 'Trabalho informal', NULL, 850.00, NULL, 'Bicos (autônomo)', NULL),
  (14, 14, 'Desempregada', 'Manicure', 0.00, NULL, NULL, NULL),
  (15, 15, 'Desempregada', 'Ajudante geral', 0.00, NULL, NULL, NULL),
  (16, 16, 'Aposentada / BPC', 'Reciclador(a)', 1600.00, NULL, NULL, NULL),
  (17, 17, 'Desempregado', 'Manicure', 0.00, NULL, NULL, NULL),
  (18, 18, 'Do lar', 'Costureira(o)', 0.00, NULL, NULL, NULL),
  (19, 19, 'Desempregado', 'Eletricista', 0.00, NULL, NULL, NULL),
  (20, 20, 'Desempregada', 'Cuidador(a) de idosos', 0.00, NULL, NULL, NULL),
  (21, 21, 'Empregado (CLT)', 'Repositor(a)', 2100.00, 'Restaurante Sabor Caseiro', 'Repositor(a)', NULL),
  (22, 22, 'Desempregado', 'Pedreiro', 0.00, NULL, NULL, NULL),
  (23, 23, 'Trabalho informal', 'Diarista', 200.00, NULL, 'Diarista (autônomo)', NULL),
  (24, 24, 'Trabalho informal', 'Porteiro', 450.00, NULL, 'Porteiro (autônomo)', NULL),
  (25, 25, 'Empregada (CLT)', 'Repositor(a)', 2150.00, 'Padaria Pão Nosso', 'Repositor(a)', NULL),
  (26, 26, 'Aposentado / BPC', 'Cuidador(a) de idosos', 1600.00, NULL, NULL, NULL),
  (27, 27, 'Desempregada', NULL, 0.00, NULL, NULL, NULL),
  (28, 28, 'Do lar', 'Vendedor(a) ambulante', 0.00, NULL, NULL, NULL),
  (29, 29, 'Aposentada / BPC', 'Vendedor(a) ambulante', 1600.00, NULL, NULL, NULL),
  (30, 30, 'Desempregada', 'Cuidador(a) de idosos', 0.00, NULL, NULL, NULL),
  (31, 31, 'Desempregado', 'Motorista', 0.00, NULL, NULL, NULL),
  (32, 32, 'Desempregada', 'Pedreiro', 0.00, NULL, NULL, NULL),
  (33, 33, 'Desempregada', 'Cozinheira(o)', 0.00, NULL, NULL, NULL),
  (34, 34, 'Empregada (CLT)', 'Reciclador(a)', 2050.00, 'Mercado Bom Preço Ltda', 'Reciclador(a)', '(11) 25448-6697'),
  (35, 35, 'Trabalho informal', 'Repositor(a)', 200.00, NULL, 'Repositor(a) (autônomo)', NULL),
  (36, 36, 'Desempregado', 'Manicure', 0.00, NULL, NULL, NULL),
  (37, 37, 'Desempregado', 'Repositor(a)', 0.00, NULL, NULL, NULL),
  (38, 38, 'Aposentado / BPC', 'Motorista', 1600.00, NULL, NULL, NULL),
  (39, 39, 'Aposentada / BPC', NULL, 1600.00, NULL, NULL, NULL),
  (40, 40, 'Aposentada / BPC', 'Garçom/garçonete', 1600.00, NULL, NULL, NULL),
  (41, 41, 'Do lar', 'Auxiliar de limpeza', 0.00, NULL, NULL, NULL),
  (42, 42, 'Desempregado', 'Porteiro', 0.00, NULL, NULL, NULL),
  (43, 43, 'Desempregada', 'Costureira(o)', 0.00, NULL, NULL, NULL),
  (44, 44, 'Aposentada / BPC', NULL, 1600.00, NULL, NULL, NULL),
  (45, 45, 'Desempregada', 'Repositor(a)', 0.00, NULL, NULL, NULL),
  (46, 46, 'Trabalho informal', 'Pintor', 1000.00, NULL, 'Pintor (autônomo)', NULL),
  (47, 47, 'Trabalho informal', 'Cozinheira(o)', 650.00, NULL, 'Cozinheira(o) (autônomo)', NULL),
  (48, 48, 'Desempregada', 'Reciclador(a)', 0.00, NULL, NULL, NULL),
  (49, 49, 'Trabalho informal', 'Garçom/garçonete', 600.00, NULL, 'Garçom/garçonete (autônomo)', NULL),
  (50, 50, 'Aposentado / BPC', 'Porteiro', 1600.00, NULL, NULL, NULL),
  (51, 51, 'Desempregado', 'Manicure', 0.00, NULL, NULL, NULL),
  (52, 53, 'Aposentada / BPC', NULL, 1600.00, NULL, NULL, NULL),
  (53, 54, 'Do lar', 'Pintor', 0.00, NULL, NULL, NULL),
  (54, 55, 'Desempregada', 'Vendedor(a) ambulante', 0.00, NULL, NULL, NULL),
  (55, 56, 'Desempregada', 'Vendedor(a) ambulante', 0.00, NULL, NULL, NULL),
  (56, 57, 'Do lar', 'Eletricista', 0.00, NULL, NULL, NULL),
  (57, 58, 'Aposentada / BPC', 'Vendedor(a) ambulante', 1600.00, NULL, NULL, NULL),
  (58, 59, 'Aposentada / BPC', 'Diarista', 1600.00, NULL, NULL, NULL),
  (59, 60, 'Aposentada / BPC', 'Repositor(a)', 1600.00, NULL, NULL, NULL),
  (60, 61, 'Trabalho informal', 'Pintor', 950.00, NULL, 'Pintor (autônomo)', NULL),
  (61, 62, 'Desempregado', 'Auxiliar de limpeza', 0.00, NULL, NULL, NULL),
  (62, 63, 'Aposentado / BPC', 'Repositor(a)', 1600.00, NULL, NULL, NULL),
  (63, 64, 'Desempregada', 'Manicure', 0.00, NULL, NULL, NULL),
  (64, 65, 'Desempregada', 'Pedreiro', 0.00, NULL, NULL, NULL),
  (65, 66, 'Empregada (CLT)', NULL, 1950.00, 'Padaria Pão Nosso', 'Auxiliar', '(11) 23678-9052'),
  (66, 67, 'Desempregada', 'Garçom/garçonete', 0.00, NULL, NULL, NULL),
  (67, 68, 'Desempregada', NULL, 0.00, NULL, NULL, NULL),
  (68, 69, 'Desempregada', 'Cuidador(a) de idosos', 0.00, NULL, NULL, NULL),
  (69, 70, 'Do lar', 'Auxiliar de limpeza', 0.00, NULL, NULL, NULL),
  (70, 71, 'Aposentado / BPC', 'Manicure', 1600.00, NULL, NULL, NULL),
  (71, 72, 'Aposentada / BPC', NULL, 1600.00, NULL, NULL, NULL),
  (72, 73, 'Trabalho informal', 'Pintor', 1100.00, NULL, 'Pintor (autônomo)', NULL),
  (73, 74, 'Aposentada / BPC', 'Vendedor(a) ambulante', 1600.00, NULL, NULL, NULL),
  (74, 75, 'Desempregado', 'Diarista', 0.00, NULL, NULL, NULL),
  (75, 76, 'Desempregada', 'Diarista', 0.00, NULL, NULL, NULL),
  (76, 77, 'Desempregada', 'Cuidador(a) de idosos', 0.00, NULL, NULL, NULL),
  (77, 78, 'Desempregado', NULL, 0.00, NULL, NULL, NULL),
  (78, 79, 'Desempregada', 'Vendedor(a) ambulante', 0.00, NULL, NULL, NULL),
  (79, 80, 'Aposentada / BPC', 'Costureira(o)', 1600.00, NULL, NULL, NULL),
  (80, 81, 'Trabalho informal', 'Reciclador(a)', 250.00, NULL, 'Reciclador(a) (autônomo)', NULL),
  (81, 82, 'Desempregada', NULL, 0.00, NULL, NULL, NULL),
  (82, 84, 'Aposentado / BPC', NULL, 1600.00, NULL, NULL, NULL),
  (83, 85, 'Desempregada', NULL, 0.00, NULL, NULL, NULL),
  (84, 86, 'Desempregada', 'Garçom/garçonete', 0.00, NULL, NULL, NULL),
  (85, 87, 'Aposentado / BPC', 'Repositor(a)', 1600.00, NULL, NULL, NULL),
  (86, 88, 'Desempregada', 'Motorista', 0.00, NULL, NULL, NULL),
  (87, 89, 'Desempregada', 'Pintor', 0.00, NULL, NULL, NULL),
  (88, 90, 'Desempregado', NULL, 0.00, NULL, NULL, NULL),
  (89, 91, 'Desempregado', 'Porteiro', 0.00, NULL, NULL, NULL),
  (90, 92, 'Trabalho informal', 'Auxiliar de limpeza', 1150.00, NULL, 'Auxiliar de limpeza (autônomo)', NULL),
  (91, 93, 'Desempregada', 'Eletricista', 0.00, NULL, NULL, NULL),
  (92, 94, 'Aposentada / BPC', 'Eletricista', 1600.00, NULL, NULL, NULL),
  (93, 95, 'Desempregada', NULL, 0.00, NULL, NULL, NULL),
  (94, 96, 'Aposentado / BPC', 'Cozinheira(o)', 1600.00, NULL, NULL, NULL),
  (95, 97, 'Desempregada', 'Ajudante geral', 0.00, NULL, NULL, NULL),
  (96, 98, 'Desempregada', 'Manicure', 0.00, NULL, NULL, NULL),
  (97, 99, 'Aposentado / BPC', 'Pedreiro', 1600.00, NULL, NULL, NULL),
  (98, 100, 'Trabalho informal', 'Costureira(o)', 600.00, NULL, 'Costureira(o) (autônomo)', NULL),
  (99, 101, 'Trabalho informal', 'Garçom/garçonete', 450.00, NULL, 'Garçom/garçonete (autônomo)', NULL),
  (100, 102, 'Desempregado', NULL, 0.00, NULL, NULL, NULL);

INSERT INTO trabalho (id_trabalho, id_beneficiario, situacao_ocupacional, profissao_habilidades, renda_atual, empresa_trabalho, ocupacao_atual, telefone_trabalho) VALUES
  (101, 103, 'Aposentada / BPC', 'Ajudante geral', 1600.00, NULL, NULL, NULL),
  (102, 104, 'Desempregado', 'Auxiliar de limpeza', 0.00, NULL, NULL, NULL),
  (103, 105, 'Desempregada', 'Pintor', 0.00, NULL, NULL, NULL),
  (104, 106, 'Desempregado', 'Cuidador(a) de idosos', 0.00, NULL, NULL, NULL),
  (105, 107, 'Desempregado', NULL, 0.00, NULL, NULL, NULL),
  (106, 108, 'Desempregada', 'Cuidador(a) de idosos', 0.00, NULL, NULL, NULL),
  (107, 109, 'Aposentado / BPC', 'Vendedor(a) ambulante', 1600.00, NULL, NULL, NULL),
  (108, 110, 'Aposentada / BPC', 'Costureira(o)', 1600.00, NULL, NULL, NULL),
  (109, 112, 'Do lar', 'Costureira(o)', 0.00, NULL, NULL, NULL),
  (110, 113, 'Empregada (CLT)', 'Porteiro', 1850.00, 'Mercado Bom Preço Ltda', 'Porteiro', NULL),
  (111, 114, 'Do lar', 'Vendedor(a) ambulante', 0.00, NULL, NULL, NULL),
  (112, 115, 'Empregada (CLT)', 'Porteiro', 1750.00, 'Confecções Linha Fina', 'Porteiro', '(11) 21290-7739'),
  (113, 116, 'Desempregada', 'Eletricista', 0.00, NULL, NULL, NULL),
  (114, 117, 'Aposentada / BPC', NULL, 1600.00, NULL, NULL, NULL),
  (115, 118, 'Desempregada', 'Reciclador(a)', 0.00, NULL, NULL, NULL),
  (116, 119, 'Desempregada', 'Pintor', 0.00, NULL, NULL, NULL),
  (117, 120, 'Aposentada / BPC', NULL, 1600.00, NULL, NULL, NULL),
  (118, 121, 'Desempregado', 'Reciclador(a)', 0.00, NULL, NULL, NULL),
  (119, 122, 'Empregado (CLT)', 'Motorista', 2100.00, 'Restaurante Sabor Caseiro', 'Motorista', '(11) 22482-2031'),
  (120, 124, 'Desempregada', 'Auxiliar de limpeza', 0.00, NULL, NULL, NULL),
  (121, 125, 'Desempregada', 'Eletricista', 0.00, NULL, NULL, NULL),
  (122, 126, 'Aposentada / BPC', 'Costureira(o)', 1600.00, NULL, NULL, NULL),
  (123, 127, 'Desempregada', 'Diarista', 0.00, NULL, NULL, NULL),
  (124, 128, 'Desempregada', 'Pedreiro', 0.00, NULL, NULL, NULL),
  (125, 129, 'Trabalho informal', 'Repositor(a)', 300.00, NULL, 'Repositor(a) (autônomo)', NULL),
  (126, 130, 'Desempregado', 'Reciclador(a)', 0.00, NULL, NULL, NULL),
  (127, 131, 'Desempregado', 'Pedreiro', 0.00, NULL, NULL, NULL),
  (128, 132, 'Desempregado', 'Cozinheira(o)', 0.00, NULL, NULL, NULL),
  (129, 134, 'Desempregada', 'Manicure', 0.00, NULL, NULL, NULL),
  (130, 135, 'Desempregada', 'Ajudante geral', 0.00, NULL, NULL, NULL),
  (131, 136, 'Desempregada', 'Vendedor(a) ambulante', 0.00, NULL, NULL, NULL),
  (132, 137, 'Aposentado / BPC', 'Motorista', 1600.00, NULL, NULL, NULL),
  (133, 138, 'Desempregada', 'Reciclador(a)', 0.00, NULL, NULL, NULL),
  (134, 139, 'Do lar', NULL, 0.00, NULL, NULL, NULL),
  (135, 140, 'Aposentado / BPC', 'Porteiro', 1600.00, NULL, NULL, NULL),
  (136, 141, 'Desempregado', NULL, 0.00, NULL, NULL, NULL),
  (137, 142, 'Desempregada', 'Diarista', 0.00, NULL, NULL, NULL),
  (138, 143, 'Trabalho informal', 'Porteiro', 750.00, NULL, 'Porteiro (autônomo)', NULL),
  (139, 144, 'Desempregada', 'Vendedor(a) ambulante', 0.00, NULL, NULL, NULL),
  (140, 145, 'Trabalho informal', 'Costureira(o)', 1050.00, NULL, 'Costureira(o) (autônomo)', NULL),
  (141, 146, 'Aposentado / BPC', 'Repositor(a)', 1600.00, NULL, NULL, NULL),
  (142, 147, 'Trabalho informal', 'Pedreiro', 200.00, NULL, 'Pedreiro (autônomo)', NULL),
  (143, 148, 'Empregada (CLT)', NULL, 2050.00, 'Lavanderia Bolha', 'Auxiliar', '(11) 24299-7643'),
  (144, 149, 'Desempregada', 'Diarista', 0.00, NULL, NULL, NULL),
  (145, 150, 'Aposentado / BPC', 'Repositor(a)', 1600.00, NULL, NULL, NULL),
  (146, 151, 'Desempregada', 'Garçom/garçonete', 0.00, NULL, NULL, NULL),
  (147, 152, 'Desempregado', 'Auxiliar de limpeza', 0.00, NULL, NULL, NULL),
  (148, 153, 'Desempregado', NULL, 0.00, NULL, NULL, NULL),
  (149, 154, 'Desempregado', NULL, 0.00, NULL, NULL, NULL),
  (150, 155, 'Do lar', 'Eletricista', 0.00, NULL, NULL, NULL),
  (151, 156, 'Desempregada', 'Motorista', 0.00, NULL, NULL, NULL),
  (152, 157, 'Aposentada / BPC', 'Manicure', 1600.00, NULL, NULL, NULL),
  (153, 158, 'Aposentado / BPC', 'Diarista', 1600.00, NULL, NULL, NULL),
  (154, 159, 'Aposentado / BPC', 'Cozinheira(o)', 1600.00, NULL, NULL, NULL),
  (155, 161, 'Desempregado', 'Eletricista', 0.00, NULL, NULL, NULL),
  (156, 162, 'Desempregada', 'Porteiro', 0.00, NULL, NULL, NULL),
  (157, 163, 'Empregado (CLT)', 'Pedreiro', 1900.00, 'Limpeza Brilho Serviços', 'Pedreiro', NULL),
  (158, 164, 'Empregada (CLT)', 'Eletricista', 2050.00, 'Padaria Pão Nosso', 'Eletricista', '(11) 27343-9370'),
  (159, 165, 'Desempregada', 'Ajudante geral', 0.00, NULL, NULL, NULL),
  (160, 166, 'Desempregado', 'Reciclador(a)', 0.00, NULL, NULL, NULL),
  (161, 168, 'Aposentada / BPC', 'Eletricista', 1600.00, NULL, NULL, NULL),
  (162, 169, 'Desempregada', 'Cozinheira(o)', 0.00, NULL, NULL, NULL),
  (163, 170, 'Do lar', NULL, 0.00, NULL, NULL, NULL),
  (164, 171, 'Desempregado', 'Vendedor(a) ambulante', 0.00, NULL, NULL, NULL),
  (165, 172, 'Desempregada', 'Garçom/garçonete', 0.00, NULL, NULL, NULL),
  (166, 173, 'Trabalho informal', 'Motorista', 1100.00, NULL, 'Motorista (autônomo)', NULL),
  (167, 174, 'Desempregada', 'Pintor', 0.00, NULL, NULL, NULL),
  (168, 175, 'Desempregada', 'Porteiro', 0.00, NULL, NULL, NULL),
  (169, 176, 'Trabalho informal', 'Garçom/garçonete', 500.00, NULL, 'Garçom/garçonete (autônomo)', NULL),
  (170, 177, 'Desempregado', 'Manicure', 0.00, NULL, NULL, NULL),
  (171, 178, 'Desempregada', NULL, 0.00, NULL, NULL, NULL),
  (172, 179, 'Trabalho informal', 'Motorista', 500.00, NULL, 'Motorista (autônomo)', NULL),
  (173, 180, 'Desempregada', 'Pedreiro', 0.00, NULL, NULL, NULL),
  (174, 181, 'Aposentada / BPC', 'Diarista', 1600.00, NULL, NULL, NULL),
  (175, 182, 'Desempregada', 'Eletricista', 0.00, NULL, NULL, NULL),
  (176, 183, 'Empregada (CLT)', 'Repositor(a)', 1800.00, 'Confecções Linha Fina', 'Repositor(a)', '(11) 21221-5062'),
  (177, 184, 'Desempregada', 'Auxiliar de limpeza', 0.00, NULL, NULL, NULL),
  (178, 185, 'Aposentado / BPC', 'Vendedor(a) ambulante', 1600.00, NULL, NULL, NULL),
  (179, 186, 'Aposentado / BPC', 'Manicure', 1600.00, NULL, NULL, NULL),
  (180, 187, 'Aposentada / BPC', 'Cuidador(a) de idosos', 1600.00, NULL, NULL, NULL),
  (181, 188, 'Desempregada', NULL, 0.00, NULL, NULL, NULL),
  (182, 189, 'Desempregada', NULL, 0.00, NULL, NULL, NULL),
  (183, 190, 'Desempregada', 'Manicure', 0.00, NULL, NULL, NULL),
  (184, 191, 'Aposentada / BPC', 'Eletricista', 1600.00, NULL, NULL, NULL),
  (185, 192, 'Aposentada / BPC', NULL, 1600.00, NULL, NULL, NULL),
  (186, 193, 'Do lar', 'Repositor(a)', 0.00, NULL, NULL, NULL),
  (187, 194, 'Desempregada', 'Ajudante geral', 0.00, NULL, NULL, NULL),
  (188, 195, 'Trabalho informal', 'Ajudante geral', 1100.00, NULL, 'Ajudante geral (autônomo)', NULL),
  (189, 196, 'Desempregada', 'Reciclador(a)', 0.00, NULL, NULL, NULL),
  (190, 197, 'Desempregada', 'Ajudante geral', 0.00, NULL, NULL, NULL),
  (191, 198, 'Trabalho informal', 'Cozinheira(o)', 550.00, NULL, 'Cozinheira(o) (autônomo)', NULL),
  (192, 199, 'Desempregado', 'Porteiro', 0.00, NULL, NULL, NULL),
  (193, 200, 'Desempregado', 'Cozinheira(o)', 0.00, NULL, NULL, NULL),
  (194, 201, 'Aposentado / BPC', NULL, 1600.00, NULL, NULL, NULL),
  (195, 202, 'Desempregado', 'Cozinheira(o)', 0.00, NULL, NULL, NULL),
  (196, 203, 'Desempregada', 'Costureira(o)', 0.00, NULL, NULL, NULL),
  (197, 204, 'Do lar', 'Cozinheira(o)', 0.00, NULL, NULL, NULL),
  (198, 205, 'Aposentado / BPC', 'Repositor(a)', 1600.00, NULL, NULL, NULL),
  (199, 206, 'Desempregada', NULL, 0.00, NULL, NULL, NULL),
  (200, 207, 'Desempregada', 'Pedreiro', 0.00, NULL, NULL, NULL);

INSERT INTO trabalho (id_trabalho, id_beneficiario, situacao_ocupacional, profissao_habilidades, renda_atual, empresa_trabalho, ocupacao_atual, telefone_trabalho) VALUES
  (201, 208, 'Desempregada', 'Auxiliar de limpeza', 0.00, NULL, NULL, NULL),
  (202, 209, 'Desempregado', 'Cuidador(a) de idosos', 0.00, NULL, NULL, NULL),
  (203, 210, 'Desempregada', 'Cozinheira(o)', 0.00, NULL, NULL, NULL),
  (204, 211, 'Desempregada', 'Cuidador(a) de idosos', 0.00, NULL, NULL, NULL),
  (205, 212, 'Desempregado', NULL, 0.00, NULL, NULL, NULL),
  (206, 213, 'Desempregada', 'Pedreiro', 0.00, NULL, NULL, NULL),
  (207, 214, 'Trabalho informal', 'Vendedor(a) ambulante', 1100.00, NULL, 'Vendedor(a) ambulante (autônomo)', NULL),
  (208, 215, 'Desempregada', 'Porteiro', 0.00, NULL, NULL, NULL),
  (209, 216, 'Empregada (CLT)', 'Reciclador(a)', 1650.00, 'Condomínio Jardim Azul', 'Reciclador(a)', NULL),
  (210, 217, 'Desempregada', 'Pintor', 0.00, NULL, NULL, NULL),
  (211, 218, 'Desempregada', 'Porteiro', 0.00, NULL, NULL, NULL),
  (212, 219, 'Empregado (CLT)', 'Pedreiro', 2000.00, 'Lavanderia Bolha', 'Pedreiro', '(11) 24662-3335'),
  (213, 220, 'Do lar', 'Eletricista', 0.00, NULL, NULL, NULL),
  (214, 221, 'Desempregado', 'Reciclador(a)', 0.00, NULL, NULL, NULL),
  (215, 222, 'Aposentada / BPC', 'Pintor', 1600.00, NULL, NULL, NULL),
  (216, 223, 'Empregada (CLT)', 'Garçom/garçonete', 2300.00, 'Restaurante Sabor Caseiro', 'Garçom/garçonete', NULL),
  (217, 224, 'Trabalho informal', 'Repositor(a)', 700.00, NULL, 'Repositor(a) (autônomo)', NULL),
  (218, 225, 'Trabalho informal', 'Manicure', 500.00, NULL, 'Manicure (autônomo)', NULL),
  (219, 226, 'Desempregada', 'Diarista', 0.00, NULL, NULL, NULL),
  (220, 228, 'Trabalho informal', 'Auxiliar de limpeza', 900.00, NULL, 'Auxiliar de limpeza (autônomo)', NULL),
  (221, 229, 'Desempregada', 'Eletricista', 0.00, NULL, NULL, NULL),
  (222, 230, 'Desempregada', 'Repositor(a)', 0.00, NULL, NULL, NULL),
  (223, 231, 'Empregada (CLT)', 'Costureira(o)', 2100.00, 'Restaurante Sabor Caseiro', 'Costureira(o)', NULL),
  (224, 232, 'Trabalho informal', 'Cuidador(a) de idosos', 1200.00, NULL, 'Cuidador(a) de idosos (autônomo)', NULL),
  (225, 233, 'Desempregada', 'Porteiro', 0.00, NULL, NULL, NULL),
  (226, 234, 'Desempregado', 'Vendedor(a) ambulante', 0.00, NULL, NULL, NULL),
  (227, 235, 'Trabalho informal', NULL, 1050.00, NULL, 'Bicos (autônomo)', NULL),
  (228, 236, 'Desempregada', 'Porteiro', 0.00, NULL, NULL, NULL),
  (229, 237, 'Desempregado', 'Motorista', 0.00, NULL, NULL, NULL),
  (230, 238, 'Desempregada', NULL, 0.00, NULL, NULL, NULL),
  (231, 239, 'Trabalho informal', 'Pedreiro', 850.00, NULL, 'Pedreiro (autônomo)', NULL),
  (232, 240, 'Aposentado / BPC', 'Pintor', 1600.00, NULL, NULL, NULL),
  (233, 241, 'Aposentado / BPC', 'Eletricista', 1600.00, NULL, NULL, NULL),
  (234, 242, 'Empregada (CLT)', 'Pedreiro', 1800.00, 'Restaurante Sabor Caseiro', 'Pedreiro', '(11) 21074-9994'),
  (235, 243, 'Desempregada', 'Motorista', 0.00, NULL, NULL, NULL),
  (236, 244, 'Aposentada / BPC', 'Manicure', 1600.00, NULL, NULL, NULL),
  (237, 245, 'Aposentada / BPC', 'Reciclador(a)', 1600.00, NULL, NULL, NULL),
  (238, 246, 'Desempregado', 'Cozinheira(o)', 0.00, NULL, NULL, NULL),
  (239, 247, 'Trabalho informal', 'Motorista', 850.00, NULL, 'Motorista (autônomo)', NULL),
  (240, 248, 'Trabalho informal', 'Repositor(a)', 250.00, NULL, 'Repositor(a) (autônomo)', NULL),
  (241, 249, 'Aposentada / BPC', 'Costureira(o)', 1600.00, NULL, NULL, NULL),
  (242, 250, 'Aposentada / BPC', 'Manicure', 1600.00, NULL, NULL, NULL);

-- ---------------------------------------------------------------------
-- Entidade 04/10 — composicao_familiar (dicionário 4.3)
-- ---------------------------------------------------------------------
-- COMPOSICAO_FAMILIAR — Moradores do domicílio (até 5 — RN10; 1 família com 6 de propósito para a A07)
INSERT INTO composicao_familiar (id_membro, id_beneficiario, nome, nome_social, idade, parentesco_vinculo) VALUES
  (1, 1, 'ANONIMIZADO', NULL, 56, 'Filho'),
  (2, 1, 'ANONIMIZADO', NULL, 13, 'Neta'),
  (3, 2, 'ANONIMIZADO', NULL, 8, 'Filho'),
  (4, 2, 'ANONIMIZADO', NULL, 30, 'Filho'),
  (5, 3, 'Nicolas Soares', NULL, 8, 'Filho'),
  (6, 3, 'Nicolas Soares', NULL, 0, 'Filho'),
  (7, 3, 'Valentina Soares', NULL, 2, 'Filha'),
  (8, 4, 'Paulo Vieira', NULL, 42, 'Filho'),
  (9, 4, 'Samuel Vieira', NULL, 1, 'Neto'),
  (10, 5, 'Rebeca Freitas', NULL, 12, 'Neta'),
  (11, 5, 'Enzo Freitas', NULL, 0, 'Neto'),
  (12, 7, 'Tatiane Nascimento Machado', NULL, 51, 'Esposa'),
  (13, 7, 'Joana Machado', NULL, 30, 'Filha'),
  (14, 8, 'Valdir Carvalho Santos', NULL, 24, 'Companheiro'),
  (15, 9, 'Pedro Souza Barbosa', NULL, 52, 'Esposo'),
  (16, 9, 'Isabela Barbosa', NULL, 8, 'Neta'),
  (17, 9, 'Bruno Barbosa', NULL, 21, 'Filho'),
  (18, 10, 'Edson Ferreira Moura', NULL, 25, 'Companheiro'),
  (19, 10, 'Rodrigo Moura', NULL, 54, 'Pai'),
  (20, 12, 'Cícero Pereira', NULL, 40, 'Filho'),
  (21, 12, 'Marcos Pereira', NULL, 43, 'Filho'),
  (22, 13, 'Reginaldo Santana Soares', NULL, 57, 'Companheiro'),
  (23, 13, 'Isabela Soares', NULL, 2, 'Neta'),
  (24, 13, 'Bruno Soares', NULL, 42, 'Filho'),
  (25, 16, 'Heitor Ferreira', NULL, 2, 'Neto'),
  (26, 16, 'Ágatha Ferreira', NULL, 11, 'Neta'),
  (27, 16, 'Laura Ferreira', NULL, 7, 'Neta'),
  (28, 16, 'Pietro Ferreira', NULL, 9, 'Neto'),
  (29, 17, 'Alice Dias', NULL, 8, 'Filha'),
  (30, 17, 'Manuela Dias', NULL, 8, 'Filha'),
  (31, 18, 'Edson Gomes', NULL, 38, 'Filho'),
  (32, 18, 'Severino Gomes', NULL, 30, 'Filho'),
  (33, 18, 'Wellington Gomes', NULL, 54, 'Filho'),
  (34, 20, 'Emanuelly Cardoso', NULL, 6, 'Neta'),
  (35, 20, 'Davi Cardoso', NULL, 8, 'Neto'),
  (36, 20, 'Arthur Cardoso', NULL, 15, 'Neto'),
  (37, 21, 'Heloísa Martins', NULL, 7, 'Filha'),
  (38, 22, 'Samuel Correia', NULL, 13, 'Filho'),
  (39, 22, 'Raimunda Correia', NULL, 23, 'Filha'),
  (40, 24, 'Débora Santana Silva', NULL, 44, 'Esposa'),
  (41, 24, 'Heitor Silva', NULL, 3, 'Filho'),
  (42, 24, 'Valentina Silva', NULL, 4, 'Filha'),
  (43, 24, 'Henrique Silva', NULL, 7, 'Filho'),
  (44, 25, 'Pedro Souza Ribeiro', NULL, 45, 'Esposo'),
  (45, 25, 'Beatriz Ribeiro', NULL, 16, 'Filha'),
  (46, 25, 'Ryan Ribeiro', NULL, 12, 'Filho'),
  (47, 25, 'Murilo Ribeiro', NULL, 4, 'Filho'),
  (48, 26, 'Heloísa Souza', NULL, 10, 'Neta'),
  (49, 26, 'Bruna Souza', NULL, 27, 'Filha'),
  (50, 26, 'Maitê Souza', NULL, 9, 'Neta'),
  (51, 27, 'Cecília Pereira', NULL, 7, 'Filha'),
  (52, 27, 'Pietro Pereira', NULL, 11, 'Filho'),
  (53, 27, 'Henrique Pereira', NULL, 13, 'Filho'),
  (54, 27, 'Emanuelly Pereira', NULL, 9, 'Filha'),
  (55, 27, 'Letícia Pereira', NULL, 55, 'Mãe'),
  (56, 28, 'Daniel Gomes Cardoso', NULL, 27, 'Esposo'),
  (57, 30, 'Beatriz Rocha', NULL, 15, 'Filha'),
  (58, 30, 'Lucas Rocha', NULL, 26, 'Filho'),
  (59, 31, 'Regina Nascimento Fernandes', NULL, 45, 'Companheira'),
  (60, 31, 'Valentina Fernandes', NULL, 1, 'Filha'),
  (61, 31, 'Davi Fernandes', NULL, 12, 'Filho'),
  (62, 31, 'Isabela Fernandes', NULL, 10, 'Filha'),
  (63, 31, 'Maitê Fernandes', NULL, 1, 'Filha'),
  (64, 32, 'Heitor Nunes', NULL, 3, 'Filho'),
  (65, 32, 'Bernardo Nunes', NULL, 5, 'Filho'),
  (66, 32, 'Kauã Nunes', NULL, 3, 'Filho'),
  (67, 33, 'João Moura Farias', NULL, 41, 'Esposo'),
  (68, 33, 'Daniela Farias', NULL, 27, 'Filha'),
  (69, 33, 'Rosângela Farias', NULL, 24, 'Filha'),
  (70, 34, 'Helena Moreira', NULL, 4, 'Neta'),
  (71, 34, 'Anderson Moreira', NULL, 23, 'Filho'),
  (72, 34, 'Pietro Moreira', NULL, 9, 'Neto'),
  (73, 35, 'Miguel Cardoso', NULL, 11, 'Filho'),
  (74, 36, 'Eduardo Almeida', NULL, 26, 'Filho'),
  (75, 38, 'Kauã Cavalcanti', NULL, 9, 'Neto'),
  (76, 39, 'Samuel Correia', NULL, 9, 'Neto'),
  (77, 39, 'Adriana Correia', NULL, 31, 'Filha'),
  (78, 39, 'Murilo Correia', NULL, 10, 'Neto'),
  (79, 39, 'Lívia Correia', NULL, 9, 'Neta'),
  (80, 40, 'Laura Rodrigues', NULL, 14, 'Neta'),
  (81, 40, 'Silvana Rodrigues', NULL, 29, 'Filha'),
  (82, 40, 'Bernardo Rodrigues', NULL, 7, 'Neto'),
  (83, 41, 'Sophia Lima', NULL, 10, 'Neta'),
  (84, 42, 'Samuel Gomes', NULL, 11, 'Filho'),
  (85, 42, 'Heloísa Gomes', NULL, 2, 'Filha'),
  (86, 42, 'Théo Gomes', NULL, 2, 'Filho'),
  (87, 43, 'Cláudia Lopes', NULL, 49, 'Mãe'),
  (88, 43, 'Isabela Lopes', NULL, 6, 'Filha'),
  (89, 43, 'Valentina Lopes', NULL, 0, 'Filha'),
  (90, 43, 'Kauã Lopes', NULL, 3, 'Filho'),
  (91, 43, 'Valentina Lopes', NULL, 0, 'Filha'),
  (92, 45, 'Henrique Santana', NULL, 15, 'Neto'),
  (93, 45, 'Emanuelly Santana', NULL, 0, 'Neta'),
  (94, 45, 'Henrique Santana', NULL, 16, 'Neto'),
  (95, 45, 'Lívia Santana', NULL, 3, 'Neta'),
  (96, 45, 'Helena Santana', NULL, 39, 'Filha'),
  (97, 46, 'Elaine Souza', NULL, 26, 'Filha'),
  (98, 47, 'Manoel Silva Alves', NULL, 63, 'Companheiro'),
  (99, 48, 'Sophia Ribeiro', NULL, 8, 'Filha'),
  (100, 48, 'Ágatha Ribeiro', NULL, 10, 'Filha');

INSERT INTO composicao_familiar (id_membro, id_beneficiario, nome, nome_social, idade, parentesco_vinculo) VALUES
  (101, 49, 'Kauã Freitas', NULL, 8, 'Filho'),
  (102, 50, 'Patrícia Soares Pereira', NULL, 48, 'Esposa'),
  (103, 50, 'Sandra Pereira', NULL, 19, 'Filha'),
  (104, 50, 'Heloísa Pereira', NULL, 8, 'Neta'),
  (105, 53, 'Alice Marques', NULL, 10, 'Neta'),
  (106, 53, 'Jorge Marques', NULL, 36, 'Filho'),
  (107, 53, 'Samuel Marques', NULL, 4, 'Neto'),
  (108, 53, 'Cecília Marques', NULL, 2, 'Neta'),
  (109, 53, 'Manuela Marques', NULL, 4, 'Neta'),
  (110, 54, 'Sophia Pereira', NULL, 0, 'Filha'),
  (111, 55, 'Lorenzo Moreira', NULL, 15, 'Filho'),
  (112, 55, 'Vitor Moreira', NULL, 15, 'Filho'),
  (113, 56, 'João Gomes Lima', NULL, 50, 'Companheiro'),
  (114, 57, 'Manoel Fernandes', NULL, 26, 'Filho'),
  (115, 58, 'Arthur Ribeiro', NULL, 13, 'Neto'),
  (116, 58, 'Yasmin Ribeiro', NULL, 8, 'Neta'),
  (117, 58, 'Cecília Ribeiro', NULL, 0, 'Neta'),
  (118, 59, 'Benício Moreira', NULL, 11, 'Neto'),
  (119, 59, 'Manoel Moreira', NULL, 33, 'Filho'),
  (120, 59, 'Aline Moreira', NULL, 51, 'Filha'),
  (121, 59, 'Laura Moreira', NULL, 5, 'Neta'),
  (122, 60, 'Vitor Monteiro', NULL, 2, 'Neto'),
  (123, 60, 'Gael Monteiro', NULL, 8, 'Neto'),
  (124, 62, 'Lorena Rocha', NULL, 10, 'Filha'),
  (125, 62, 'Kauã Rocha', NULL, 17, 'Filho'),
  (126, 62, 'Pietro Rocha', NULL, 7, 'Neto'),
  (127, 62, 'Ryan Rocha', NULL, 13, 'Filho'),
  (128, 62, 'Murilo Rocha', NULL, 10, 'Filho'),
  (129, 63, 'Sebastião Dias', NULL, 37, 'Filho'),
  (130, 63, 'Lucas Dias', NULL, 43, 'Filho'),
  (131, 63, 'Kauã Dias', NULL, 14, 'Neto'),
  (132, 64, 'Murilo Moreira', NULL, 9, 'Neto'),
  (133, 65, 'Joana Soares', NULL, 19, 'Filha'),
  (134, 65, 'Ryan Soares', NULL, 15, 'Filho'),
  (135, 65, 'Gabriela Soares', NULL, 26, 'Filha'),
  (136, 65, 'Vanessa Soares', NULL, 29, 'Filha'),
  (137, 66, 'Rodrigo Moura Nunes', NULL, 40, 'Esposo'),
  (138, 67, 'Valentina Teixeira', NULL, 10, 'Neta'),
  (139, 67, 'Kauã Teixeira', NULL, 10, 'Neto'),
  (140, 67, 'Josué Teixeira', NULL, 37, 'Filho'),
  (141, 68, 'Alice Machado', NULL, 13, 'Filha'),
  (142, 70, 'Priscila Costa', NULL, 37, 'Filha'),
  (143, 71, 'Luciana Andrade Rocha', NULL, 53, 'Companheira'),
  (144, 71, 'Henrique Rocha', NULL, 3, 'Neto'),
  (145, 71, 'Valentina Rocha', NULL, 12, 'Filha'),
  (146, 71, 'Cecília Rocha', NULL, 12, 'Filha'),
  (147, 71, 'Cecília Rocha', NULL, 16, 'Filha'),
  (148, 72, 'Lucas Farias Farias', NULL, 48, 'Companheiro'),
  (149, 72, 'Rita Farias', NULL, 27, 'Filha'),
  (150, 72, 'Rafael Farias', NULL, 26, 'Filho'),
  (151, 73, 'Ágatha Santana', NULL, 2, 'Neta'),
  (152, 73, 'Lorena Santana', NULL, 8, 'Neta'),
  (153, 73, 'Pietro Santana', NULL, 1, 'Neto'),
  (154, 73, 'Rebeca Santana', NULL, 14, 'Filha'),
  (155, 74, 'Manuela Almeida', NULL, 8, 'Neta'),
  (156, 74, 'Valentina Almeida', NULL, 13, 'Neta'),
  (157, 74, 'Benício Almeida', NULL, 16, 'Neto'),
  (158, 75, 'Heloísa Silva', NULL, 4, 'Filha'),
  (159, 76, 'Josué Marques', NULL, 19, 'Filho'),
  (160, 78, 'Maitê Cardoso', NULL, 3, 'Filha'),
  (161, 78, 'Helena Cardoso', NULL, 4, 'Filha'),
  (162, 80, 'Jéssica Moura', NULL, 35, 'Filha'),
  (163, 82, 'Lorenzo Barbosa', NULL, 14, 'Filho'),
  (164, 82, 'Murilo Barbosa', NULL, 10, 'Filho'),
  (165, 82, 'Maitê Barbosa', NULL, 4, 'Filha'),
  (166, 82, 'Cecília Barbosa', NULL, 4, 'Filha'),
  (167, 83, 'Lorenzo Carvalho', NULL, 6, 'Neto'),
  (168, 83, 'Cecília Carvalho', NULL, 3, 'Neta'),
  (169, 84, 'Manuela Pinto', NULL, 8, 'Neta'),
  (170, 84, 'Maitê Pinto', NULL, 3, 'Neta'),
  (171, 86, 'Samuel Batista', NULL, 11, 'Neto'),
  (172, 87, 'Cecília Oliveira', NULL, 5, 'Filha'),
  (173, 87, 'Lorenzo Oliveira', NULL, 4, 'Filho'),
  (174, 87, 'Bernardo Oliveira', NULL, 2, 'Filho'),
  (175, 90, 'Théo Brito', NULL, 1, 'Filho'),
  (176, 90, 'Emanuelly Brito', NULL, 3, 'Filha'),
  (177, 90, 'Alice Brito', NULL, 4, 'Filha'),
  (178, 90, 'Beatriz Brito', NULL, 4, 'Filha'),
  (179, 92, 'Anderson Cardoso Fernandes', NULL, 36, 'Companheiro'),
  (180, 92, 'Helena Fernandes', NULL, 2, 'Filha'),
  (181, 94, 'Davi Araújo', NULL, 7, 'Neto'),
  (182, 97, 'Heitor Nunes', NULL, 4, 'Filho'),
  (183, 97, 'Ryan Nunes', NULL, 13, 'Filho'),
  (184, 97, 'Ryan Nunes', NULL, 6, 'Filho'),
  (185, 97, 'Heitor Nunes', NULL, 6, 'Filho'),
  (186, 97, 'Théo Nunes', NULL, 14, 'Filho'),
  (187, 97, 'Beatriz Nunes', NULL, 5, 'Filha'),
  (188, 98, 'Paulo Soares Brito', NULL, 43, 'Esposo'),
  (189, 103, 'Marcos Oliveira Souza', NULL, 42, 'Companheiro'),
  (190, 103, 'Miguel Souza', NULL, 2, 'Filho'),
  (191, 103, 'Heloísa Souza', NULL, 6, 'Filha'),
  (192, 103, 'Helena Souza', NULL, 4, 'Filha'),
  (193, 104, 'Nicolas Santos', NULL, 16, 'Filho'),
  (194, 105, 'Vanessa Vieira', NULL, 27, 'Filha'),
  (195, 105, 'Alice Vieira', NULL, 9, 'Neta'),
  (196, 105, 'Beatriz Vieira', NULL, 1, 'Neta'),
  (197, 106, 'Renata Nascimento', NULL, 36, 'Filha'),
  (198, 107, 'Regina Moreira Oliveira', NULL, 63, 'Esposa'),
  (199, 107, 'Beatriz Oliveira', NULL, 12, 'Neta'),
  (200, 108, 'Jorge Brito Oliveira', NULL, 35, 'Esposo');

INSERT INTO composicao_familiar (id_membro, id_beneficiario, nome, nome_social, idade, parentesco_vinculo) VALUES
  (201, 109, 'Beatriz Santana', NULL, 10, 'Neta'),
  (202, 111, 'Heitor Brito', NULL, 14, 'Filho'),
  (203, 111, 'Gael Brito', NULL, 3, 'Neto'),
  (204, 111, 'Laura Brito', NULL, 6, 'Neta'),
  (205, 111, 'Valentina Brito', NULL, 1, 'Neta'),
  (206, 112, 'Manuela Almeida', NULL, 16, 'Filha'),
  (207, 112, 'Rebeca Almeida', NULL, 14, 'Filha'),
  (208, 113, 'Ryan Moreira', NULL, 6, 'Filho'),
  (209, 113, 'Vitor Moreira', NULL, 9, 'Filho'),
  (210, 115, 'Maitê Nunes', NULL, 1, 'Filha'),
  (211, 116, 'Daniel Carvalho Moura', NULL, 23, 'Companheiro'),
  (212, 116, 'Rita Moura', NULL, 56, 'Mãe'),
  (213, 117, 'Fábio Moreira Andrade', NULL, 42, 'Esposo'),
  (214, 117, 'Laura Andrade', NULL, 9, 'Filha'),
  (215, 117, 'Heloísa Andrade', NULL, 8, 'Filha'),
  (216, 117, 'Davi Andrade', NULL, 9, 'Filho'),
  (217, 118, 'Wellington Soares Ferreira', NULL, 30, 'Esposo'),
  (218, 118, 'Heloísa Ferreira', NULL, 16, 'Filha'),
  (219, 118, 'Emanuelly Ferreira', NULL, 11, 'Filha'),
  (220, 118, 'Laura Ferreira', NULL, 15, 'Filha'),
  (221, 118, 'Gael Ferreira', NULL, 15, 'Filho'),
  (222, 119, 'Sandra Silva', NULL, 22, 'Filha'),
  (223, 119, 'Thiago Silva', NULL, 22, 'Filho'),
  (224, 119, 'Laura Silva', NULL, 14, 'Filha'),
  (225, 120, 'Vanessa Rodrigues', NULL, 35, 'Filha'),
  (226, 120, 'Manuela Rodrigues', NULL, 8, 'Neta'),
  (227, 120, 'Ágatha Rodrigues', NULL, 15, 'Neta'),
  (228, 120, 'Yasmin Rodrigues', NULL, 3, 'Neta'),
  (229, 122, 'Paulo Ferreira', NULL, 19, 'Filho'),
  (230, 122, 'Miguel Ferreira', NULL, 11, 'Filho'),
  (231, 122, 'Diego Ferreira', NULL, 29, 'Filho'),
  (232, 122, 'Valentina Ferreira', NULL, 10, 'Filha'),
  (233, 122, 'Bernardo Ferreira', NULL, 12, 'Filho'),
  (234, 123, 'Antônio Andrade Monteiro', NULL, 37, 'Companheiro'),
  (235, 124, 'Nicolas Machado', NULL, 5, 'Filho'),
  (236, 125, 'Lívia Vieira', NULL, 14, 'Filha'),
  (237, 125, 'Arthur Vieira', NULL, 2, 'Filho'),
  (238, 126, 'Michele Carvalho', NULL, 39, 'Filha'),
  (239, 127, 'Lívia Pereira', NULL, 14, 'Filha'),
  (240, 127, 'Samuel Pereira', NULL, 6, 'Filho'),
  (241, 127, 'Clara Pereira', NULL, 14, 'Filha'),
  (242, 128, 'Severino Andrade Pinto', NULL, 47, 'Esposo'),
  (243, 130, 'Tatiane Barbosa Gonçalves', NULL, 51, 'Esposa'),
  (244, 130, 'Emanuelly Gonçalves', NULL, 10, 'Filha'),
  (245, 130, 'Heloísa Gonçalves', NULL, 1, 'Neta'),
  (246, 131, 'Wellington Carvalho', NULL, 58, 'Pai'),
  (247, 133, 'Jorge Fernandes Moreira', NULL, 40, 'Esposo'),
  (248, 133, 'Emanuelly Moreira', NULL, 3, 'Neta'),
  (249, 134, 'Davi Costa', NULL, 10, 'Filho'),
  (250, 134, 'Lorena Costa', NULL, 1, 'Filha'),
  (251, 134, 'Clara Costa', NULL, 4, 'Filha'),
  (252, 136, 'Wellington Pinto Freitas', NULL, 42, 'Esposo'),
  (253, 136, 'Helena Freitas', NULL, 0, 'Filha'),
  (254, 136, 'Lívia Freitas', NULL, 13, 'Filha'),
  (255, 137, 'Wellington Oliveira', NULL, 48, 'Filho'),
  (256, 137, 'Antônia Oliveira', NULL, 47, 'Filha'),
  (257, 137, 'Lorena Oliveira', NULL, 10, 'Neta'),
  (258, 138, 'Paulo Cavalcanti Lima', NULL, 55, 'Companheiro'),
  (259, 138, 'Rodrigo Lima', NULL, 19, 'Filho'),
  (260, 138, 'Lorena Lima', NULL, 14, 'Filha'),
  (261, 139, 'Isabela Ramos', NULL, 6, 'Filha'),
  (262, 139, 'Clara Ramos', NULL, 6, 'Filha'),
  (263, 140, 'Ana Cardoso', NULL, 23, 'Filha'),
  (264, 141, 'Rebeca Cavalcanti', NULL, 3, 'Filha'),
  (265, 141, 'Rebeca Cavalcanti', NULL, 12, 'Filha'),
  (266, 142, 'Clara Souza', NULL, 15, 'Filha'),
  (267, 142, 'Heitor Souza', NULL, 8, 'Filho'),
  (268, 142, 'Lorenzo Souza', NULL, 1, 'Neto'),
  (269, 142, 'Valentina Souza', NULL, 4, 'Neta'),
  (270, 142, 'Beatriz Souza', NULL, 4, 'Neta'),
  (271, 143, 'Camila Fernandes Teixeira', NULL, 61, 'Companheira'),
  (272, 144, 'Vitor Rocha', NULL, 10, 'Filho'),
  (273, 144, 'Manuela Rocha', NULL, 9, 'Neta'),
  (274, 144, 'Vera Rocha', NULL, 28, 'Filha'),
  (275, 145, 'Bernardo Mendes', NULL, 7, 'Neto'),
  (276, 145, 'Francisca Mendes', NULL, 40, 'Filha'),
  (277, 145, 'Severino Mendes', NULL, 50, 'Filho'),
  (278, 147, 'Yasmin Costa', NULL, 6, 'Neta'),
  (279, 148, 'Felipe Correia Marques', NULL, 60, 'Esposo'),
  (280, 148, 'Helena Marques', NULL, 31, 'Filha'),
  (281, 149, 'Antônio Dias Souza', NULL, 54, 'Companheiro'),
  (282, 149, 'Gilberto Souza', NULL, 18, 'Filho'),
  (283, 149, 'Valéria Souza', NULL, 26, 'Filha'),
  (284, 149, 'Gael Souza', NULL, 9, 'Filho'),
  (285, 150, 'Benício Moreira', NULL, 8, 'Neto'),
  (286, 150, 'Ryan Moreira', NULL, 11, 'Neto'),
  (287, 150, 'Daniela Moreira', NULL, 31, 'Filha'),
  (288, 151, 'Gael Moura', NULL, 5, 'Filho'),
  (289, 151, 'Henrique Moura', NULL, 10, 'Filho'),
  (290, 151, 'Alice Moura', NULL, 4, 'Filha'),
  (291, 152, 'Nicolas Andrade', NULL, 12, 'Neto'),
  (292, 152, 'Valentina Andrade', NULL, 15, 'Neta'),
  (293, 153, 'Cristiane Ferreira Cardoso', NULL, 48, 'Esposa'),
  (294, 153, 'Murilo Cardoso', NULL, 4, 'Filho'),
  (295, 154, 'Manuela Vieira', NULL, 3, 'Neta'),
  (296, 154, 'Renata Vieira', NULL, 19, 'Filha'),
  (297, 155, 'Laura Santana', NULL, 16, 'Filha'),
  (298, 155, 'Enzo Santana', NULL, 13, 'Filho'),
  (299, 156, 'Samuel Batista', NULL, 14, 'Filho'),
  (300, 157, 'Heitor Lima', NULL, 1, 'Filho');

INSERT INTO composicao_familiar (id_membro, id_beneficiario, nome, nome_social, idade, parentesco_vinculo) VALUES
  (301, 157, 'Cecília Lima', NULL, 8, 'Filha'),
  (302, 158, 'Thiago Dias', NULL, 31, 'Filho'),
  (303, 158, 'Renata Dias', NULL, 28, 'Filha'),
  (304, 158, 'Sophia Dias', NULL, 11, 'Neta'),
  (305, 158, 'Rosângela Dias', NULL, 29, 'Filha'),
  (306, 158, 'Pietro Dias', NULL, 11, 'Neto'),
  (307, 159, 'Helena Monteiro', NULL, 48, 'Filha'),
  (308, 160, 'Antônio Silva Carvalho', NULL, 49, 'Esposo'),
  (309, 160, 'Jorge Carvalho', NULL, 21, 'Filho'),
  (310, 161, 'Bernardo Cardoso', NULL, 11, 'Filho'),
  (311, 162, 'Valdir Souza Andrade', NULL, 22, 'Esposo'),
  (312, 162, 'Helena Andrade', NULL, 6, 'Filha'),
  (313, 164, 'Benício Andrade', NULL, 5, 'Filho'),
  (314, 164, 'Helena Andrade', NULL, 6, 'Filha'),
  (315, 165, 'Simone Lopes', NULL, 50, 'Mãe'),
  (316, 166, 'Cícero Fernandes', NULL, 23, 'Filho'),
  (317, 166, 'Lucas Fernandes', NULL, 18, 'Filho'),
  (318, 166, 'Anderson Fernandes', NULL, 29, 'Filho'),
  (319, 166, 'Bernardo Fernandes', NULL, 9, 'Filho'),
  (320, 166, 'Josué Fernandes', NULL, 19, 'Filho'),
  (321, 167, 'Miguel Martins', NULL, 15, 'Neto'),
  (322, 167, 'Heloísa Martins', NULL, 7, 'Neta'),
  (323, 167, 'Clara Martins', NULL, 9, 'Neta'),
  (324, 167, 'Josefa Martins', NULL, 30, 'Filha'),
  (325, 168, 'Manuela Santana', NULL, 16, 'Neta'),
  (326, 168, 'Sophia Santana', NULL, 2, 'Neta'),
  (327, 168, 'Alice Santana', NULL, 12, 'Neta'),
  (328, 168, 'Bernardo Santana', NULL, 14, 'Neto'),
  (329, 168, 'Silvana Santana', NULL, 57, 'Filha'),
  (330, 169, 'Murilo Lima', NULL, 2, 'Filho'),
  (331, 169, 'Cecília Lima', NULL, 0, 'Filha'),
  (332, 169, 'Miguel Lima', NULL, 8, 'Filho'),
  (333, 170, 'Maitê Carvalho', NULL, 17, 'Filha'),
  (334, 170, 'Emanuelly Carvalho', NULL, 17, 'Filha'),
  (335, 170, 'Pietro Carvalho', NULL, 10, 'Filho'),
  (336, 170, 'Marcos Carvalho', NULL, 27, 'Filho'),
  (337, 170, 'Francisca Carvalho', NULL, 21, 'Filha'),
  (338, 171, 'Isabela Ribeiro', NULL, 9, 'Filha'),
  (339, 172, 'João Freitas', NULL, 27, 'Filho'),
  (340, 172, 'Heloísa Freitas', NULL, 11, 'Filha'),
  (341, 173, 'Ivone Teixeira Araújo', NULL, 60, 'Esposa'),
  (342, 175, 'Luiz Santos Vieira', NULL, 50, 'Esposo'),
  (343, 175, 'Antônia Vieira', NULL, 24, 'Filha'),
  (344, 176, 'Josefa Pinto Gomes', NULL, 21, 'Companheira'),
  (345, 176, 'João Gomes', NULL, 50, 'Pai'),
  (346, 176, 'Beatriz Gomes', NULL, 8, 'Filha'),
  (347, 176, 'Davi Gomes', NULL, 6, 'Filho'),
  (348, 177, 'Adriana Gomes', NULL, 18, 'Filha'),
  (349, 180, 'Ágatha Pereira', NULL, 13, 'Filha'),
  (350, 181, 'Beatriz Machado', NULL, 0, 'Neta'),
  (351, 181, 'Enzo Machado', NULL, 12, 'Neto'),
  (352, 181, 'Adriana Machado', NULL, 41, 'Filha'),
  (353, 181, 'Davi Machado', NULL, 5, 'Neto'),
  (354, 182, 'Ryan Nascimento', NULL, 2, 'Filho'),
  (355, 184, 'Alice Ramos', NULL, 5, 'Neta'),
  (356, 184, 'Rodrigo Ramos', NULL, 24, 'Filho'),
  (357, 184, 'Yasmin Ramos', NULL, 14, 'Filha'),
  (358, 185, 'Théo Fernandes', NULL, 5, 'Neto'),
  (359, 185, 'Patrícia Fernandes', NULL, 18, 'Filha'),
  (360, 185, 'Heloísa Fernandes', NULL, 11, 'Filha'),
  (361, 186, 'Lorena Ramos', NULL, 0, 'Neta'),
  (362, 186, 'Lívia Ramos', NULL, 7, 'Neta'),
  (363, 186, 'Helena Ramos', NULL, 52, 'Filha'),
  (364, 187, 'Jorge Dias', NULL, 25, 'Filho'),
  (365, 187, 'Ágatha Dias', NULL, 12, 'Neta'),
  (366, 187, 'Laura Dias', NULL, 8, 'Neta'),
  (367, 187, 'Henrique Dias', NULL, 1, 'Neto'),
  (368, 189, 'Eduardo Batista Freitas', NULL, 57, 'Esposo'),
  (369, 189, 'Maitê Freitas', NULL, 9, 'Filha'),
  (370, 189, 'Samuel Freitas', NULL, 10, 'Filho'),
  (371, 191, 'Pedro Machado', NULL, 27, 'Filho'),
  (372, 192, 'Antônio Farias', NULL, 41, 'Filho'),
  (373, 192, 'Sebastião Farias', NULL, 42, 'Filho'),
  (374, 192, 'Heloísa Farias', NULL, 6, 'Neta'),
  (375, 193, 'Helena Lopes', NULL, 6, 'Filha'),
  (376, 193, 'Nicolas Lopes', NULL, 17, 'Filho'),
  (377, 196, 'Lorena Barbosa', NULL, 12, 'Filha'),
  (378, 196, 'Alice Barbosa', NULL, 4, 'Filha'),
  (379, 197, 'Helena Carvalho', NULL, 8, 'Filha'),
  (380, 197, 'Bernardo Carvalho', NULL, 9, 'Filho'),
  (381, 197, 'Pietro Carvalho', NULL, 4, 'Filho'),
  (382, 197, 'Sophia Carvalho', NULL, 4, 'Filha'),
  (383, 198, 'Sandra Dias', NULL, 24, 'Filha'),
  (384, 198, 'Thiago Dias', NULL, 24, 'Filho'),
  (385, 199, 'Valentina Vieira', NULL, 1, 'Neta'),
  (386, 200, 'Maitê Pinto', NULL, 1, 'Neta'),
  (387, 200, 'Arthur Pinto', NULL, 16, 'Neto'),
  (388, 201, 'Alice Teixeira', NULL, 3, 'Filha'),
  (389, 202, 'Lorenzo Nascimento', NULL, 5, 'Neto'),
  (390, 202, 'Samuel Nascimento', NULL, 3, 'Neto'),
  (391, 202, 'Camila Nascimento', NULL, 20, 'Filha'),
  (392, 202, 'Nicolas Nascimento', NULL, 9, 'Filho'),
  (393, 202, 'Raimunda Nascimento', NULL, 18, 'Filha'),
  (394, 203, 'Cícero Ribeiro Ramos', NULL, 37, 'Companheiro'),
  (395, 204, 'Heloísa Oliveira', NULL, 2, 'Filha'),
  (396, 204, 'Arthur Oliveira', NULL, 3, 'Filho'),
  (397, 204, 'Ágatha Oliveira', NULL, 1, 'Filha'),
  (398, 204, 'Heloísa Oliveira', NULL, 0, 'Filha'),
  (399, 205, 'Juliana Lima', NULL, 42, 'Filha'),
  (400, 205, 'Rafael Lima', NULL, 33, 'Filho');

INSERT INTO composicao_familiar (id_membro, id_beneficiario, nome, nome_social, idade, parentesco_vinculo) VALUES
  (401, 205, 'Beatriz Lima', NULL, 11, 'Neta'),
  (402, 206, 'Théo Batista', NULL, 12, 'Filho'),
  (403, 206, 'Sebastião Batista', NULL, 26, 'Filho'),
  (404, 206, 'José Batista', NULL, 29, 'Filho'),
  (405, 206, 'Bruno Batista', NULL, 28, 'Filho'),
  (406, 207, 'Paulo Brito Ramos', NULL, 53, 'Companheiro'),
  (407, 207, 'Isabela Ramos', NULL, 12, 'Filha'),
  (408, 207, 'Benício Ramos', NULL, 8, 'Filho'),
  (409, 207, 'Lucas Ramos', NULL, 29, 'Filho'),
  (410, 207, 'José Ramos', NULL, 25, 'Filho'),
  (411, 211, 'Henrique Souza', NULL, 5, 'Filho'),
  (412, 211, 'Raimundo Souza', NULL, 50, 'Pai'),
  (413, 213, 'Diego Teixeira', NULL, 44, 'Filho'),
  (414, 213, 'Isabela Teixeira', NULL, 9, 'Neta'),
  (415, 214, 'Manoel Teixeira', NULL, 52, 'Filho'),
  (416, 214, 'Josué Teixeira', NULL, 33, 'Filho'),
  (417, 214, 'Cecília Teixeira', NULL, 2, 'Neta'),
  (418, 214, 'Jorge Teixeira', NULL, 42, 'Filho'),
  (419, 214, 'Henrique Teixeira', NULL, 16, 'Neto'),
  (420, 215, 'Helena Santos', NULL, 13, 'Filha'),
  (421, 216, 'Ágatha Moreira', NULL, 10, 'Neta'),
  (422, 217, 'Raimundo Souza Pereira', NULL, 47, 'Esposo'),
  (423, 217, 'Heitor Pereira', NULL, 2, 'Neto'),
  (424, 218, 'Lorena Rocha', NULL, 4, 'Filha'),
  (425, 219, 'Sônia Araújo Correia', NULL, 56, 'Companheira'),
  (426, 219, 'Henrique Correia', NULL, 17, 'Filho'),
  (427, 219, 'Manuela Correia', NULL, 16, 'Filha'),
  (428, 220, 'Sophia Dias', NULL, 12, 'Filha'),
  (429, 220, 'Bernardo Dias', NULL, 13, 'Filho'),
  (430, 220, 'Manoel Dias', NULL, 30, 'Filho'),
  (431, 221, 'Nicolas Farias', NULL, 3, 'Filho'),
  (432, 221, 'Emanuelly Farias', NULL, 6, 'Filha'),
  (433, 221, 'Lorena Farias', NULL, 15, 'Filha'),
  (434, 221, 'Murilo Farias', NULL, 7, 'Filho'),
  (435, 221, 'Vanessa Farias', NULL, 62, 'Mãe'),
  (436, 222, 'Laura Pinto', NULL, 13, 'Neta'),
  (437, 222, 'Miguel Pinto', NULL, 0, 'Neto'),
  (438, 222, 'Enzo Pinto', NULL, 4, 'Neto'),
  (439, 222, 'Benício Pinto', NULL, 14, 'Neto'),
  (440, 223, 'Antônio Ribeiro', NULL, 40, 'Pai'),
  (441, 224, 'Ana Teixeira', NULL, 30, 'Filha'),
  (442, 224, 'Marcos Teixeira', NULL, 23, 'Filho'),
  (443, 225, 'Adilson Silva Martins', NULL, 53, 'Esposo'),
  (444, 225, 'Davi Martins', NULL, 12, 'Filho'),
  (445, 225, 'Sônia Martins', NULL, 20, 'Filha'),
  (446, 226, 'Josué Vieira Cardoso', NULL, 50, 'Companheiro'),
  (447, 228, 'José Cardoso Pereira', NULL, 37, 'Companheiro'),
  (448, 228, 'Patrícia Pereira', NULL, 59, 'Mãe'),
  (449, 228, 'Lívia Pereira', NULL, 0, 'Filha'),
  (450, 228, 'Manuela Pereira', NULL, 17, 'Filha'),
  (451, 228, 'Gael Pereira', NULL, 3, 'Filho'),
  (452, 229, 'Lorena Freitas', NULL, 2, 'Filha'),
  (453, 229, 'Cecília Freitas', NULL, 3, 'Filha'),
  (454, 229, 'Samuel Freitas', NULL, 5, 'Filho'),
  (455, 229, 'Davi Freitas', NULL, 5, 'Filho'),
  (456, 229, 'Kauã Freitas', NULL, 4, 'Filho'),
  (457, 231, 'Laura Andrade', NULL, 15, 'Neta'),
  (458, 231, 'Bernardo Andrade', NULL, 5, 'Neto'),
  (459, 232, 'Camila Marques', NULL, 29, 'Filha'),
  (460, 232, 'Carlos Marques', NULL, 26, 'Filho'),
  (461, 232, 'Benício Marques', NULL, 9, 'Neto'),
  (462, 233, 'Anderson Carvalho Gomes', NULL, 53, 'Companheiro'),
  (463, 233, 'Rebeca Gomes', NULL, 15, 'Filha'),
  (464, 233, 'Débora Gomes', NULL, 19, 'Filha'),
  (465, 234, 'Raimunda Cavalcanti Pinto', NULL, 35, 'Esposa'),
  (466, 234, 'Nicolas Pinto', NULL, 8, 'Filho'),
  (467, 235, 'Manoel Ramos Correia', NULL, 55, 'Companheiro'),
  (468, 235, 'Emanuelly Correia', NULL, 17, 'Filha'),
  (469, 235, 'Laura Correia', NULL, 7, 'Neta'),
  (470, 235, 'Henrique Correia', NULL, 13, 'Filho'),
  (471, 236, 'Francisco Lima Marques', NULL, 61, 'Companheiro'),
  (472, 236, 'Patrícia Marques', NULL, 40, 'Filha'),
  (473, 236, 'Arthur Marques', NULL, 9, 'Neto'),
  (474, 236, 'Bernardo Marques', NULL, 11, 'Neto'),
  (475, 237, 'Yasmin Nascimento', NULL, 9, 'Filha'),
  (476, 237, 'Lívia Nascimento', NULL, 4, 'Filha'),
  (477, 237, 'Helena Nascimento', NULL, 8, 'Filha'),
  (478, 237, 'Samuel Nascimento', NULL, 4, 'Filho'),
  (479, 238, 'Sophia Carvalho', NULL, 0, 'Filha'),
  (480, 238, 'Heloísa Carvalho', NULL, 4, 'Filha'),
  (481, 238, 'Enzo Carvalho', NULL, 1, 'Filho'),
  (482, 239, 'Emanuelly Ribeiro', NULL, 8, 'Neta'),
  (483, 239, 'Pietro Ribeiro', NULL, 13, 'Neto'),
  (484, 239, 'Heitor Ribeiro', NULL, 10, 'Neto'),
  (485, 240, 'Miguel Vieira', NULL, 0, 'Neto'),
  (486, 241, 'Nicolas Machado', NULL, 15, 'Neto'),
  (487, 241, 'Arthur Machado', NULL, 11, 'Neto'),
  (488, 242, 'Rebeca Barbosa', NULL, 0, 'Filha'),
  (489, 243, 'Beatriz Costa', NULL, 9, 'Filha'),
  (490, 243, 'Kauã Costa', NULL, 8, 'Filho'),
  (491, 243, 'Emanuelly Costa', NULL, 6, 'Filha'),
  (492, 243, 'Henrique Costa', NULL, 9, 'Filho'),
  (493, 244, 'Lorena Moreira', NULL, 6, 'Neta'),
  (494, 244, 'Emanuelly Moreira', NULL, 1, 'Neta'),
  (495, 245, 'Sophia Moura', NULL, 0, 'Neta'),
  (496, 245, 'Henrique Moura', NULL, 16, 'Neto'),
  (497, 245, 'Ágatha Moura', NULL, 0, 'Neta'),
  (498, 246, 'Clara Martins', NULL, 14, 'Filha'),
  (499, 246, 'Manoel Martins', NULL, 22, 'Filho'),
  (500, 246, 'Letícia Martins', NULL, 21, 'Filha');

INSERT INTO composicao_familiar (id_membro, id_beneficiario, nome, nome_social, idade, parentesco_vinculo) VALUES
  (501, 246, 'Lívia Martins', NULL, 10, 'Filha'),
  (502, 248, 'Débora Gonçalves Lopes', NULL, 31, 'Esposa'),
  (503, 248, 'Alice Lopes', NULL, 11, 'Filha'),
  (504, 248, 'Samuel Lopes', NULL, 3, 'Filho'),
  (505, 249, 'Heitor Silva', NULL, 0, 'Filho'),
  (506, 249, 'Gael Silva', NULL, 7, 'Filho'),
  (507, 250, 'Cecília Ramos', NULL, 2, 'Neta'),
  (508, 250, 'Beatriz Ramos', NULL, 14, 'Neta'),
  (509, 250, 'Maitê Ramos', NULL, 12, 'Neta');

-- ---------------------------------------------------------------------
-- Entidade 05/10 — referencia_familiar (dicionário 4.4)
-- ---------------------------------------------------------------------
-- REFERENCIA_FAMILIAR — Contatos de emergência (até 3 — RN10; 1 família com 4 de propósito para a A07)
INSERT INTO referencia_familiar (id_referencia, id_beneficiario, nome, nome_social, parentesco_vinculo, telefone) VALUES
  (1, 1, 'ANONIMIZADO', NULL, 'Pai', NULL),
  (2, 2, 'ANONIMIZADO', NULL, 'Mãe', NULL),
  (3, 3, 'Pedro Costa Moreira', NULL, 'Primo', '(11) 91407-9930'),
  (4, 4, 'Francisca Rodrigues Fernandes', NULL, 'Tia', '(11) 97544-7453'),
  (5, 4, 'Edna Machado Farias', NULL, 'Vizinha', '(11) 97910-2230'),
  (6, 4, 'Anderson Gomes Marques', NULL, 'Primo', '(11) 92582-2654'),
  (7, 6, 'Josefa Fernandes Gonçalves', NULL, 'Tia', '(11) 92723-7543'),
  (8, 8, 'Diego Alves Farias', NULL, 'Filho (não reside)', '(11) 99292-9677'),
  (9, 10, 'Francisca Correia Rocha', NULL, 'Prima', '(11) 99486-8648'),
  (10, 12, 'Pedro Costa Almeida', NULL, 'Primo', '(11) 97359-5481'),
  (11, 13, 'Sônia Santos Santana', NULL, 'Irmã', '(11) 92384-7992'),
  (12, 14, 'Anderson Ferreira Lopes', NULL, 'Tio', '(11) 95376-2553'),
  (13, 14, 'Renata Fernandes Lopes', NULL, 'Prima', '(11) 91228-4448'),
  (14, 17, 'Simone Machado Lopes', NULL, 'Vizinha', '(11) 99117-9820'),
  (15, 19, 'Thiago Soares Gomes', NULL, 'Filho (não reside)', '(11) 93047-7284'),
  (16, 20, 'Silvana Barbosa Lopes', NULL, 'Tia', '(11) 92339-8337'),
  (17, 21, 'Anderson Gomes Batista', NULL, 'Filho (não reside)', '(11) 96793-8732'),
  (18, 25, 'Rita Brito Pinto', NULL, 'Filha (não reside)', '(11) 95230-8577'),
  (19, 26, 'Rosângela Oliveira Teixeira', NULL, 'Mãe', '(11) 98680-1384'),
  (20, 27, 'Rita Pinto Ferreira', NULL, 'Vizinha', '(11) 99703-9434'),
  (21, 29, 'Raimundo Machado Cardoso', NULL, 'Primo', '(11) 93556-5405'),
  (22, 29, 'Antônia Pinto Ribeiro', NULL, 'Tia', '(11) 98933-2009'),
  (23, 29, 'Adriana Lopes Marques', NULL, 'Vizinha', '(11) 97093-9315'),
  (24, 30, 'Letícia Souza Almeida', NULL, 'Tia', '(11) 92931-1408'),
  (25, 32, 'Camila Carvalho Soares', NULL, 'Vizinha', '(11) 99929-5666'),
  (26, 32, 'Valéria Alves Carvalho', NULL, 'Irmã', '(11) 97836-7437'),
  (27, 34, 'Márcia Santos Pinto', NULL, 'Mãe', '(11) 96581-1885'),
  (28, 35, 'Juliana Correia Gomes', NULL, 'Amiga', '(11) 94195-6601'),
  (29, 35, 'Lúcia Oliveira Ramos', NULL, 'Amiga', '(11) 93174-2986'),
  (30, 36, 'Bruno Nascimento Machado', NULL, 'Vizinho', '(11) 97866-3593'),
  (31, 37, 'Antônio Mendes Carvalho', NULL, 'Pai', '(11) 95854-2209'),
  (32, 38, 'Larissa Ribeiro Mendes', NULL, 'Amiga', '(11) 96639-3697'),
  (33, 38, 'Valéria Soares Marques', NULL, 'Mãe', '(11) 92465-2671'),
  (34, 40, 'Roseli Brito Pinto', NULL, 'Tia', '(11) 92134-8578'),
  (35, 41, 'Fernanda Costa Almeida', NULL, 'Vizinha', '(11) 91615-7807'),
  (36, 42, 'Thiago Silva Almeida', NULL, 'Vizinho', '(11) 95492-5666'),
  (37, 42, 'Fábio Oliveira Santana', NULL, 'Vizinho', '(11) 99773-5491'),
  (38, 46, 'Michele Ferreira Correia', NULL, 'Vizinha', '(11) 91748-5956'),
  (39, 48, 'Francisca Ribeiro Pereira', NULL, 'Vizinha', '(11) 99017-6225'),
  (40, 48, 'Gabriela Almeida Pereira', NULL, 'Irmã', '(11) 91815-2360'),
  (41, 49, 'Tatiane Andrade Martins', NULL, 'Mãe', '(11) 98795-9355'),
  (42, 50, 'Edson Ferreira Teixeira', NULL, 'Irmão', '(11) 92342-3805'),
  (43, 50, 'Ana Vieira Santana', NULL, 'Filha (não reside)', '(11) 96486-5176'),
  (44, 52, 'Valdir Araújo Silva', NULL, 'Vizinho', '(11) 96416-4933'),
  (45, 54, 'Rafael Silva Vieira', NULL, 'Pai', '(11) 93334-8195'),
  (46, 54, 'José Moura Cavalcanti', NULL, 'Tio', '(11) 92017-4837'),
  (47, 56, 'Cláudia Moreira Soares', NULL, 'Irmã', '(11) 96211-8501'),
  (48, 57, 'Jéssica Rocha Rodrigues', NULL, 'Prima', '(11) 98939-3258'),
  (49, 57, 'Sebastião Brito Rodrigues', NULL, 'Amigo', '(11) 97326-7840'),
  (50, 58, 'Rosângela Vieira Brito', NULL, 'Filha (não reside)', '(11) 97583-9365'),
  (51, 59, 'Rita Dias Dias', NULL, 'Prima', '(11) 91352-4692'),
  (52, 60, 'Lúcia Cardoso Ferreira', NULL, 'Amiga', '(11) 96218-3978'),
  (53, 60, 'Francisca Brito Ramos', NULL, 'Filha (não reside)', '(11) 92999-7192'),
  (54, 60, 'Débora Lopes Nunes', NULL, 'Tia', '(11) 95299-7216'),
  (55, 61, 'Fernanda Teixeira Farias', NULL, 'Vizinha', '(11) 98356-9181'),
  (56, 61, 'Elaine Silva Costa', NULL, 'Amiga', '(11) 98562-3744'),
  (57, 62, 'Gabriela Freitas Soares', NULL, 'Irmã', '(11) 92492-5503'),
  (58, 62, 'Antônia Pinto Silva', NULL, 'Prima', '(11) 93140-1050'),
  (59, 64, 'Carlos Moreira Moreira', NULL, 'Vizinho', '(11) 91808-8174'),
  (60, 64, 'Bruna Fernandes Vieira', NULL, 'Amiga', '(11) 97621-9732'),
  (61, 66, 'Fernanda Cardoso Souza', NULL, 'Vizinha', '(11) 93829-1406'),
  (62, 67, 'Bruna Mendes Andrade', NULL, 'Vizinha', '(11) 96457-7032'),
  (63, 68, 'Sandra Santos Gonçalves', NULL, 'Amiga', '(11) 95665-3529'),
  (64, 68, 'Márcia Ferreira Vieira', NULL, 'Tia', '(11) 98855-3022'),
  (65, 69, 'Josefa Dias Gonçalves', NULL, 'Prima', '(11) 99616-7901'),
  (66, 70, 'Patrícia Souza Nascimento', NULL, 'Amiga', '(11) 92918-3308'),
  (67, 70, 'Renata Santana Souza', NULL, 'Prima', '(11) 99313-2251'),
  (68, 71, 'Neide Rocha Gomes', NULL, 'Amiga', '(11) 92196-9907'),
  (69, 72, 'Eduardo Cavalcanti Santos', NULL, 'Irmão', '(11) 94870-6520'),
  (70, 72, 'Adilson Lima Vieira', NULL, 'Primo', '(11) 94968-5437'),
  (71, 72, 'Antônia Almeida Ramos', NULL, 'Vizinha', '(11) 97635-8697'),
  (72, 74, 'Sebastião Brito Nascimento', NULL, 'Tio', '(11) 98474-2699'),
  (73, 77, 'Luciana Cardoso Oliveira', NULL, 'Irmã', '(11) 93339-1233'),
  (74, 77, 'Sebastião Ramos Farias', NULL, 'Amigo', '(11) 97088-1855'),
  (75, 79, 'Fábio Alves Fernandes', NULL, 'Filho (não reside)', '(11) 98895-7673'),
  (76, 82, 'Francisco Dias Ramos', NULL, 'Pai', '(11) 97383-2912'),
  (77, 83, 'Rafael Carvalho Mendes', NULL, 'Primo', '(11) 93269-2666'),
  (78, 84, 'Fernanda Cardoso Cardoso', NULL, 'Filha (não reside)', '(11) 97854-8448'),
  (79, 84, 'Camila Martins Ramos', NULL, 'Amiga', '(11) 93809-2927'),
  (80, 86, 'Jéssica Gonçalves Vieira', NULL, 'Amiga', '(11) 93036-9465'),
  (81, 89, 'Silvana Ramos Nascimento', NULL, 'Mãe', '(11) 92984-2872'),
  (82, 90, 'Antônio Soares Martins', NULL, 'Vizinho', '(11) 97150-6011'),
  (83, 93, 'Sônia Martins Teixeira', NULL, 'Irmã', '(11) 97463-5921'),
  (84, 93, 'Valdir Santana Costa', NULL, 'Irmão', '(11) 91841-6788'),
  (85, 94, 'Valdir Vieira Moreira', NULL, 'Amigo', '(11) 99588-8608'),
  (86, 96, 'Maria Alves Gonçalves', NULL, 'Tia', '(11) 93605-2429'),
  (87, 97, 'Aline Teixeira Martins', NULL, 'Prima', '(11) 97262-7078'),
  (88, 97, 'Marcos Freitas Andrade', NULL, 'Irmão', '(11) 96384-2312'),
  (89, 99, 'Camila Araújo Soares', NULL, 'Prima', '(11) 97380-3670'),
  (90, 101, 'Valéria Costa Moreira', NULL, 'Prima', '(11) 98031-8753'),
  (91, 104, 'Felipe Dias Machado', NULL, 'Pai', '(11) 92988-6660'),
  (92, 106, 'Edson Lima Moreira', NULL, 'Pai', '(11) 93976-6862'),
  (93, 107, 'Sônia Ferreira Cardoso', NULL, 'Amiga', '(11) 97202-3387'),
  (94, 108, 'Josué Barbosa Mendes', NULL, 'Vizinho', '(11) 98143-7680'),
  (95, 110, 'Eduardo Oliveira Andrade', NULL, 'Pai', '(11) 95597-7681'),
  (96, 110, 'Antônia Gonçalves Fernandes', NULL, 'Prima', '(11) 97024-5588'),
  (97, 110, 'Valdir Lopes Teixeira', NULL, 'Irmão', '(11) 92983-4510'),
  (98, 111, 'Regina Lima Oliveira', NULL, 'Mãe', '(11) 99031-6505'),
  (99, 112, 'Francisco Marques Souza', NULL, 'Irmão', '(11) 95632-1375'),
  (100, 112, 'Maria Farias Correia', NULL, 'Prima', '(11) 97789-8351');

INSERT INTO referencia_familiar (id_referencia, id_beneficiario, nome, nome_social, parentesco_vinculo, telefone) VALUES
  (101, 113, 'Márcia Nunes Pinto', NULL, 'Prima', '(11) 97838-1142'),
  (102, 113, 'Rosângela Brito Farias', NULL, 'Tia', '(11) 98467-4640'),
  (103, 114, 'Reginaldo Freitas Fernandes', NULL, 'Amigo', '(11) 94195-9704'),
  (104, 115, 'Raimundo Dias Machado', NULL, 'Amigo', '(11) 96534-1014'),
  (105, 116, 'Vera Costa Ramos', NULL, 'Amiga', '(11) 99108-7195'),
  (106, 116, 'Letícia Pereira Cardoso', NULL, 'Prima', '(11) 99086-1729'),
  (107, 116, 'Daniel Monteiro Machado', NULL, 'Amigo', '(11) 98139-4852'),
  (108, 116, 'Elaine Brito Pereira', NULL, 'Comadre', '(11) 91318-3770'),
  (109, 117, 'Elaine Brito Pereira', NULL, 'Prima', '(11) 99207-3956'),
  (110, 118, 'Vera Moreira Vieira', NULL, 'Mãe', '(11) 99081-4779'),
  (111, 118, 'Gilberto Soares Almeida', NULL, 'Pai', '(11) 98149-5690'),
  (112, 119, 'Renata Mendes Brito', NULL, 'Irmã', '(11) 93194-3347'),
  (113, 120, 'Roseli Marques Souza', NULL, 'Tia', '(11) 94829-1644'),
  (114, 122, 'Juliana Lopes Rodrigues', NULL, 'Filha (não reside)', '(11) 94542-9628'),
  (115, 123, 'Francisco Monteiro Costa', NULL, 'Tio', '(11) 99804-4650'),
  (116, 124, 'Ivone Moreira Marques', NULL, 'Prima', '(11) 96680-5412'),
  (117, 127, 'Sônia Cardoso Monteiro', NULL, 'Amiga', '(11) 92174-7962'),
  (118, 127, 'Eduardo Pereira Correia', NULL, 'Irmão', '(11) 96771-4718'),
  (119, 128, 'Francisco Fernandes Farias', NULL, 'Irmão', '(11) 92714-7888'),
  (120, 129, 'Juliana Andrade Moreira', NULL, 'Mãe', '(11) 93683-1007'),
  (121, 129, 'Gabriel Rocha Carvalho', NULL, 'Primo', '(11) 99954-9479'),
  (122, 130, 'Elaine Silva Gomes', NULL, 'Filha (não reside)', '(11) 93504-6353'),
  (123, 131, 'Vera Alves Nunes', NULL, 'Prima', '(11) 91541-3438'),
  (124, 131, 'Sandra Moura Monteiro', NULL, 'Irmã', '(11) 91311-3187'),
  (125, 132, 'Larissa Araújo Martins', NULL, 'Irmã', '(11) 91314-1907'),
  (126, 133, 'Rafael Almeida Moreira', NULL, 'Pai', '(11) 91125-8954'),
  (127, 134, 'Thiago Cavalcanti Barbosa', NULL, 'Irmão', '(11) 95415-2869'),
  (128, 135, 'João Brito Marques', NULL, 'Vizinho', '(11) 96222-3264'),
  (129, 135, 'Fernanda Moura Dias', NULL, 'Mãe', '(11) 99016-4813'),
  (130, 135, 'Gabriela Mendes Santos', NULL, 'Amiga', '(11) 94227-6926'),
  (131, 136, 'Elaine Pinto Santos', NULL, 'Filha (não reside)', '(11) 94290-6984'),
  (132, 136, 'Patrícia Nunes Alves', NULL, 'Irmã', '(11) 96116-6231'),
  (133, 136, 'Rosângela Marques Fernandes', NULL, 'Mãe', '(11) 91595-5530'),
  (134, 138, 'Gabriel Batista Cardoso', NULL, 'Pai', '(11) 93348-9448'),
  (135, 139, 'Adriana Pereira Cardoso', NULL, 'Amiga', '(11) 97777-4274'),
  (136, 139, 'Eduardo Marques Araújo', NULL, 'Filho (não reside)', '(11) 93401-7471'),
  (137, 140, 'Jéssica Araújo Cavalcanti', NULL, 'Filha (não reside)', '(11) 96318-8830'),
  (138, 140, 'Michele Vieira Moreira', NULL, 'Amiga', '(11) 91280-6594'),
  (139, 141, 'Fábio Moreira Ferreira', NULL, 'Amigo', '(11) 99322-3735'),
  (140, 141, 'Helena Nunes Pinto', NULL, 'Tia', '(11) 99320-1529'),
  (141, 141, 'Elaine Nunes Nunes', NULL, 'Mãe', '(11) 96328-4640'),
  (142, 142, 'Fernanda Oliveira Lima', NULL, 'Irmã', '(11) 99191-4972'),
  (143, 142, 'Thiago Souza Vieira', NULL, 'Irmão', '(11) 94483-5027'),
  (144, 143, 'Edna Barbosa Pereira', NULL, 'Vizinha', '(11) 95523-4781'),
  (145, 144, 'Bruna Nunes Martins', NULL, 'Tia', '(11) 95447-1533'),
  (146, 145, 'Aline Rodrigues Machado', NULL, 'Mãe', '(11) 97147-2442'),
  (147, 145, 'Regina Teixeira Cavalcanti', NULL, 'Irmã', '(11) 99862-4109'),
  (148, 146, 'Adilson Santos Teixeira', NULL, 'Pai', '(11) 94899-6614'),
  (149, 146, 'Valéria Farias Rodrigues', NULL, 'Amiga', '(11) 96737-1776'),
  (150, 146, 'Ivone Andrade Dias', NULL, 'Prima', '(11) 91576-6419'),
  (151, 148, 'Elaine Batista Nunes', NULL, 'Amiga', '(11) 96920-6293'),
  (152, 150, 'Maria Moreira Silva', NULL, 'Tia', '(11) 95041-1606'),
  (153, 150, 'Cristiane Pinto Alves', NULL, 'Filha (não reside)', '(11) 99302-6120'),
  (154, 150, 'Raimundo Vieira Gomes', NULL, 'Pai', '(11) 92759-3552'),
  (155, 152, 'Débora Monteiro Ramos', NULL, 'Filha (não reside)', '(11) 95544-4477'),
  (156, 152, 'Adilson Brito Lima', NULL, 'Amigo', '(11) 99453-8635'),
  (157, 152, 'Simone Gomes Lima', NULL, 'Mãe', '(11) 93190-2002'),
  (158, 153, 'Josefa Souza Pereira', NULL, 'Prima', '(11) 91545-7957'),
  (159, 153, 'Simone Oliveira Alves', NULL, 'Amiga', '(11) 92996-6388'),
  (160, 153, 'Eduardo Oliveira Santana', NULL, 'Amigo', '(11) 93763-4409'),
  (161, 154, 'Renata Lima Araújo', NULL, 'Filha (não reside)', '(11) 91552-3709'),
  (162, 155, 'Manoel Pinto Silva', NULL, 'Tio', '(11) 97942-4652'),
  (163, 156, 'Antônio Vieira Cavalcanti', NULL, 'Irmão', '(11) 97256-1220'),
  (164, 157, 'Rodrigo Silva Rodrigues', NULL, 'Tio', '(11) 92159-5038'),
  (165, 158, 'Reginaldo Rodrigues Carvalho', NULL, 'Pai', '(11) 91008-5672'),
  (166, 159, 'Joana Costa Oliveira', NULL, 'Amiga', '(11) 98936-5188'),
  (167, 159, 'Lucas Mendes Farias', NULL, 'Amigo', '(11) 97882-8763'),
  (168, 160, 'Lucas Lima Araújo', NULL, 'Irmão', '(11) 94114-3093'),
  (169, 162, 'Bruno Ferreira Ramos', NULL, 'Filho (não reside)', '(11) 93568-1251'),
  (170, 163, 'Michele Alves Rocha', NULL, 'Vizinha', '(11) 97745-3024'),
  (171, 165, 'Thiago Brito Carvalho', NULL, 'Primo', '(11) 95585-6163'),
  (172, 165, 'Gabriel Dias Brito', NULL, 'Amigo', '(11) 95586-6742'),
  (173, 166, 'Joana Nunes Marques', NULL, 'Tia', '(11) 97878-3524'),
  (174, 168, 'Lúcia Souza Barbosa', NULL, 'Filha (não reside)', '(11) 97287-1910'),
  (175, 170, 'Josefa Teixeira Brito', NULL, 'Vizinha', '(11) 95887-9441'),
  (176, 171, 'Simone Souza Moura', NULL, 'Irmã', '(11) 97083-9093'),
  (177, 171, 'Regina Monteiro Martins', NULL, 'Prima', '(11) 91210-7572'),
  (178, 173, 'Valdir Nunes Silva', NULL, 'Tio', '(11) 94951-5571'),
  (179, 174, 'Ana Teixeira Batista', NULL, 'Irmã', '(11) 92846-4104'),
  (180, 174, 'Rodrigo Correia Lopes', NULL, 'Amigo', '(11) 91737-8134'),
  (181, 175, 'Márcia Costa Santos', NULL, 'Irmã', '(11) 92584-3887'),
  (182, 176, 'Camila Alves Fernandes', NULL, 'Vizinha', '(11) 94138-5675'),
  (183, 176, 'Marcelo Moura Santos', NULL, 'Tio', '(11) 94202-1262'),
  (184, 177, 'Maria Gomes Oliveira', NULL, 'Irmã', '(11) 97499-6803'),
  (185, 177, 'Elaine Machado Soares', NULL, 'Vizinha', '(11) 95841-4095'),
  (186, 177, 'Manoel Araújo Ribeiro', NULL, 'Vizinho', '(11) 94606-3254'),
  (187, 179, 'Ana Martins Lima', NULL, 'Filha (não reside)', '(11) 98715-2691'),
  (188, 180, 'Jorge Barbosa Gonçalves', NULL, 'Irmão', '(11) 93505-1473'),
  (189, 180, 'Juliana Costa Brito', NULL, 'Tia', '(11) 95790-5335'),
  (190, 181, 'Bruna Rocha Pereira', NULL, 'Amiga', '(11) 92922-4979'),
  (191, 181, 'Jéssica Teixeira Vieira', NULL, 'Filha (não reside)', '(11) 94159-4825'),
  (192, 182, 'Rafael Martins Rodrigues', NULL, 'Pai', '(11) 99244-9209'),
  (193, 184, 'Lúcia Pinto Araújo', NULL, 'Vizinha', '(11) 98513-4425'),
  (194, 184, 'Juliana Santos Andrade', NULL, 'Tia', '(11) 98819-2813'),
  (195, 184, 'Valéria Costa Teixeira', NULL, 'Prima', '(11) 99535-5372'),
  (196, 185, 'Ana Vieira Soares', NULL, 'Filha (não reside)', '(11) 91476-9606'),
  (197, 186, 'Tatiane Carvalho Nascimento', NULL, 'Tia', '(11) 94999-8897'),
  (198, 187, 'Raimunda Santana Ferreira', NULL, 'Tia', '(11) 95182-6620'),
  (199, 188, 'Rita Rocha Monteiro', NULL, 'Prima', '(11) 98946-6117'),
  (200, 190, 'Fernanda Nunes Souza', NULL, 'Amiga', '(11) 97058-8795');

INSERT INTO referencia_familiar (id_referencia, id_beneficiario, nome, nome_social, parentesco_vinculo, telefone) VALUES
  (201, 190, 'Fernanda Almeida Freitas', NULL, 'Vizinha', '(11) 91625-4424'),
  (202, 191, 'Paulo Almeida Lopes', NULL, 'Vizinho', '(11) 94739-6938'),
  (203, 192, 'Tatiane Cavalcanti Andrade', NULL, 'Vizinha', '(11) 96641-5216'),
  (204, 195, 'Roseli Mendes Cavalcanti', NULL, 'Mãe', '(11) 94397-9189'),
  (205, 196, 'Débora Pereira Carvalho', NULL, 'Irmã', '(11) 91496-3113'),
  (206, 197, 'Tatiane Ferreira Soares', NULL, 'Vizinha', '(11) 92900-2463'),
  (207, 198, 'Priscila Santos Ferreira', NULL, 'Tia', '(11) 91903-6689'),
  (208, 199, 'Tatiane Almeida Cavalcanti', NULL, 'Mãe', '(11) 92679-9920'),
  (209, 199, 'Camila Farias Costa', NULL, 'Irmã', '(11) 93979-6543'),
  (210, 199, 'Gabriel Vieira Ramos', NULL, 'Tio', '(11) 98573-8571'),
  (211, 200, 'Luciana Fernandes Alves', NULL, 'Tia', '(11) 91356-5536'),
  (212, 200, 'Lúcia Andrade Santana', NULL, 'Amiga', '(11) 96366-9742'),
  (213, 201, 'Cristiane Almeida Rodrigues', NULL, 'Prima', '(11) 98728-4429'),
  (214, 201, 'Priscila Moreira Andrade', NULL, 'Tia', '(11) 95804-4583'),
  (215, 202, 'Juliana Martins Batista', NULL, 'Mãe', '(11) 92436-3301'),
  (216, 202, 'Helena Soares Marques', NULL, 'Amiga', '(11) 92803-1961'),
  (217, 203, 'Paulo Cardoso Pinto', NULL, 'Vizinho', '(11) 96299-4563'),
  (218, 203, 'Rafael Rocha Rodrigues', NULL, 'Tio', '(11) 99615-7658'),
  (219, 204, 'Antônia Silva Machado', NULL, 'Irmã', '(11) 99443-2002'),
  (220, 206, 'Elaine Lopes Oliveira', NULL, 'Prima', '(11) 99129-7644'),
  (221, 207, 'Sônia Teixeira Gomes', NULL, 'Prima', '(11) 91357-6899'),
  (222, 207, 'Francisca Vieira Teixeira', NULL, 'Amiga', '(11) 94013-4140'),
  (223, 207, 'Felipe Freitas Vieira', NULL, 'Vizinho', '(11) 94753-6387'),
  (224, 213, 'Francisca Vieira Ribeiro', NULL, 'Vizinha', '(11) 93441-9966'),
  (225, 213, 'Márcia Andrade Correia', NULL, 'Tia', '(11) 95050-3831'),
  (226, 214, 'Aline Lopes Lima', NULL, 'Amiga', '(11) 94668-1204'),
  (227, 214, 'Edson Marques Farias', NULL, 'Amigo', '(11) 99471-6549'),
  (228, 215, 'Fernanda Rodrigues Araújo', NULL, 'Filha (não reside)', '(11) 97194-9836'),
  (229, 216, 'Regina Correia Teixeira', NULL, 'Irmã', '(11) 99240-9718'),
  (230, 216, 'Pedro Araújo Moura', NULL, 'Vizinho', '(11) 93794-5777'),
  (231, 216, 'Antônio Santos Martins', NULL, 'Tio', '(11) 94853-5297'),
  (232, 217, 'Regina Alves Nunes', NULL, 'Prima', '(11) 99680-2074'),
  (233, 217, 'Letícia Dias Andrade', NULL, 'Irmã', '(11) 96054-4902'),
  (234, 218, 'Márcia Pinto Oliveira', NULL, 'Filha (não reside)', '(11) 98252-6274'),
  (235, 219, 'Larissa Cavalcanti Araújo', NULL, 'Prima', '(11) 97154-4912'),
  (236, 219, 'Adilson Andrade Martins', NULL, 'Tio', '(11) 93667-7602'),
  (237, 220, 'Daniela Moreira Santos', NULL, 'Irmã', '(11) 95606-7865'),
  (238, 221, 'Francisca Marques Fernandes', NULL, 'Amiga', '(11) 92959-1654'),
  (239, 224, 'Josefa Pinto Rodrigues', NULL, 'Prima', '(11) 94266-6404'),
  (240, 224, 'Adilson Cardoso Araújo', NULL, 'Pai', '(11) 94235-2448'),
  (241, 226, 'Carlos Alves Teixeira', NULL, 'Amigo', '(11) 97697-9275'),
  (242, 227, 'João Fernandes Marques', NULL, 'Primo', '(11) 94875-5737'),
  (243, 227, 'Ana Lima Ferreira', NULL, 'Vizinha', '(11) 92704-3805'),
  (244, 230, 'Helena Marques Moreira', NULL, 'Vizinha', '(11) 97233-4366'),
  (245, 230, 'Larissa Ferreira Martins', NULL, 'Tia', '(11) 99479-4810'),
  (246, 230, 'Ana Farias Rocha', NULL, 'Mãe', '(11) 99202-6717'),
  (247, 231, 'Reginaldo Martins Silva', NULL, 'Filho (não reside)', '(11) 92879-3716'),
  (248, 232, 'Antônio Alves Silva', NULL, 'Vizinho', '(11) 93443-6175'),
  (249, 233, 'Elaine Pinto Santos', NULL, 'Prima', '(11) 96231-7876'),
  (250, 234, 'Antônia Mendes Teixeira', NULL, 'Amiga', '(11) 99291-2421'),
  (251, 236, 'Marcos Andrade Araújo', NULL, 'Filho (não reside)', '(11) 96512-4221'),
  (252, 238, 'Vera Freitas Mendes', NULL, 'Amiga', '(11) 95525-6355'),
  (253, 239, 'Carlos Moura Almeida', NULL, 'Tio', '(11) 95237-5801'),
  (254, 239, 'Raimunda Silva Ribeiro', NULL, 'Filha (não reside)', '(11) 93578-9126'),
  (255, 240, 'Priscila Marques Rocha', NULL, 'Filha (não reside)', '(11) 98590-9767'),
  (256, 245, 'Juliana Gonçalves Ramos', NULL, 'Tia', '(11) 97124-4367'),
  (257, 246, 'Manoel Vieira Mendes', NULL, 'Filho (não reside)', '(11) 91216-7837'),
  (258, 248, 'Silvana Lopes Almeida', NULL, 'Irmã', '(11) 93366-5338'),
  (259, 248, 'José Rocha Pinto', NULL, 'Irmão', '(11) 99029-8121'),
  (260, 249, 'Regina Marques Dias', NULL, 'Vizinha', '(11) 98627-7807'),
  (261, 250, 'Neide Alves Machado', NULL, 'Amiga', '(11) 96192-6758');

-- ---------------------------------------------------------------------
-- Entidade 06/10 — atendimento (dicionário 4.5)
-- ---------------------------------------------------------------------
-- ATENDIMENTO — Triagens e retornos (histórico digitalizado + período jul-out/2026)
INSERT INTO atendimento (id_atendimento, id_beneficiario, id_profissional, data_atendimento, demanda_inicial) VALUES
  (1, 1, 1, '2019-04-22', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (2, 2, 3, '2019-04-30', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (3, 1, 3, '2019-10-10', 'Retorno: atualização cadastral e acompanhamento'),
  (4, 2, 1, '2020-04-28', 'Retorno: atualização cadastral e acompanhamento'),
  (5, 3, 1, '2020-06-02', 'Triagem inicial: Desemprego; busca recolocação profissional'),
  (6, 4, 1, '2020-08-01', 'Triagem inicial: Sofrimento psíquico; solicita apoio psicológico'),
  (7, 4, 1, '2020-09-14', 'Retorno: atualização cadastral e acompanhamento'),
  (8, 5, 1, '2020-11-11', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (9, 6, 1, '2021-01-13', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (10, 7, 1, '2021-02-09', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (11, 4, 1, '2021-03-07', 'Retorno: atualização cadastral e acompanhamento'),
  (12, 8, 1, '2021-03-25', 'Triagem inicial: Sofrimento psíquico; solicita apoio psicológico'),
  (13, 7, 1, '2021-07-22', 'Retorno: atualização cadastral e acompanhamento'),
  (14, 8, 3, '2021-08-09', 'Retorno: atualização cadastral e acompanhamento'),
  (15, 6, 3, '2021-08-19', 'Retorno: atualização cadastral e acompanhamento'),
  (16, 9, 3, '2021-11-17', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (17, 10, 1, '2021-12-25', 'Triagem inicial: Busca vaga em creche/escola para os filhos'),
  (18, 11, 1, '2022-01-12', 'Triagem inicial: Sem documentos pessoais; solicita emissão de 2ª via'),
  (19, 12, 1, '2022-01-31', 'Triagem inicial: Estudante de baixa renda; busca moradia universitária'),
  (20, 13, 3, '2022-02-13', 'Triagem inicial: Dificuldade de acesso a consulta médica e medicamentos'),
  (21, 14, 3, '2022-02-18', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (22, 10, 1, '2022-03-03', 'Retorno: desemprego; busca recolocação profissional'),
  (23, 15, 1, '2022-04-24', 'Triagem inicial: Pessoa em situação de rua; solicita acolhimento e documentação'),
  (24, 16, 1, '2022-05-14', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (25, 13, 1, '2022-06-26', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (26, 17, 1, '2022-06-27', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (27, 18, 3, '2022-07-16', 'Triagem inicial: Solicita apoio para outras demandas'),
  (28, 19, 1, '2022-08-14', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (29, 20, 3, '2022-08-15', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (30, 16, 3, '2022-08-28', 'Retorno: solicita apoio para outras demandas'),
  (31, 21, 3, '2022-09-05', 'Triagem inicial: Necessita orientação jurídica (pensão alimentícia / guarda)'),
  (32, 22, 1, '2022-10-02', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (33, 23, 3, '2022-10-07', 'Triagem inicial: Necessita orientação jurídica (pensão alimentícia / guarda)'),
  (34, 24, 3, '2022-10-08', 'Triagem inicial: Sem documentos pessoais; solicita emissão de 2ª via'),
  (35, 25, 1, '2022-10-24', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (36, 26, 1, '2022-11-03', 'Triagem inicial: Risco de despejo; busca orientação habitacional'),
  (37, 27, 1, '2022-12-12', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (38, 9, 3, '2023-01-18', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (39, 28, 1, '2023-01-30', 'Triagem inicial: Solicita apoio para outras demandas'),
  (40, 13, 1, '2023-02-18', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (41, 29, 1, '2023-02-21', 'Triagem inicial: Busca vaga em creche/escola para os filhos'),
  (42, 30, 3, '2023-03-07', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (43, 31, 1, '2023-03-14', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (44, 32, 1, '2023-03-15', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (45, 33, 1, '2023-03-31', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (46, 34, 1, '2023-04-06', 'Triagem inicial: Estudante de baixa renda; busca moradia universitária'),
  (47, 35, 3, '2023-04-07', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (48, 36, 3, '2023-04-08', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (49, 37, 1, '2023-04-28', 'Triagem inicial: Pessoa em situação de rua; solicita acolhimento e documentação'),
  (50, 18, 1, '2023-04-29', 'Retorno: solicita apoio para outras demandas'),
  (51, 38, 1, '2023-05-17', 'Triagem inicial: Necessita orientação jurídica (pensão alimentícia / guarda)'),
  (52, 39, 3, '2023-05-18', 'Triagem inicial: Risco de despejo; busca orientação habitacional'),
  (53, 29, 1, '2023-05-25', 'Retorno: busca vaga em creche/escola para os filhos'),
  (54, 12, 1, '2023-05-28', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (55, 40, 1, '2023-06-03', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (56, 41, 1, '2023-06-04', 'Triagem inicial: Risco de despejo; busca orientação habitacional'),
  (57, 36, 1, '2023-06-09', 'Retorno: desemprego; busca recolocação profissional'),
  (58, 42, 1, '2023-06-09', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (59, 43, 1, '2023-06-16', 'Triagem inicial: Desemprego; busca recolocação profissional'),
  (60, 44, 3, '2023-06-17', 'Triagem inicial: Busca vaga em creche/escola para os filhos'),
  (61, 45, 1, '2023-06-22', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (62, 11, 1, '2023-06-25', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (63, 46, 3, '2023-07-01', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (64, 47, 1, '2023-07-03', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (65, 48, 1, '2023-08-09', 'Triagem inicial: Desemprego; busca recolocação profissional'),
  (66, 45, 1, '2023-08-21', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (67, 49, 3, '2023-08-23', 'Triagem inicial: Solicita apoio para outras demandas'),
  (68, 50, 1, '2023-08-28', 'Triagem inicial: Solicita apoio para outras demandas'),
  (69, 51, 3, '2023-09-04', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (70, 52, 1, '2023-09-20', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (71, 53, 1, '2023-09-29', 'Triagem inicial: Estudante de baixa renda; busca moradia universitária'),
  (72, 54, 1, '2023-09-30', 'Triagem inicial: Sofrimento psíquico; solicita apoio psicológico'),
  (73, 11, 3, '2023-10-09', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (74, 55, 1, '2023-11-10', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (75, 56, 3, '2023-11-18', 'Triagem inicial: Desemprego; busca recolocação profissional'),
  (76, 57, 1, '2023-11-22', 'Triagem inicial: Dificuldade de acesso a consulta médica e medicamentos'),
  (77, 58, 3, '2023-11-25', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (78, 27, 1, '2023-12-30', 'Retorno: solicita apoio para outras demandas'),
  (79, 59, 1, '2024-01-08', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (80, 60, 3, '2024-01-10', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (81, 14, 1, '2024-01-22', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (82, 61, 1, '2024-02-01', 'Triagem inicial: Risco de despejo; busca orientação habitacional'),
  (83, 62, 1, '2024-02-20', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (84, 63, 2, '2024-02-26', 'Triagem inicial: Sofrimento psíquico; solicita apoio psicológico'),
  (85, 64, 1, '2024-03-02', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (86, 65, 3, '2024-03-03', 'Triagem inicial: Desemprego; busca recolocação profissional'),
  (87, 66, 1, '2024-03-05', 'Triagem inicial: Busca vaga em creche/escola para os filhos'),
  (88, 67, 1, '2024-03-15', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (89, 68, 3, '2024-03-18', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (90, 69, 3, '2024-03-27', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (91, 70, 1, '2024-04-05', 'Triagem inicial: Risco de despejo; busca orientação habitacional'),
  (92, 71, 3, '2024-04-09', 'Triagem inicial: Risco de despejo; busca orientação habitacional'),
  (93, 72, 1, '2024-04-12', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (94, 73, 1, '2024-04-12', 'Triagem inicial: Estudante de baixa renda; busca moradia universitária'),
  (95, 15, 1, '2024-04-15', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (96, 74, 1, '2024-04-17', 'Triagem inicial: Estudante de baixa renda; busca moradia universitária'),
  (97, 75, 3, '2024-04-18', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (98, 39, 1, '2024-04-20', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (99, 76, 3, '2024-04-20', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (100, 77, 3, '2024-04-22', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família');

INSERT INTO atendimento (id_atendimento, id_beneficiario, id_profissional, data_atendimento, demanda_inicial) VALUES
  (101, 55, 3, '2024-05-04', 'Retorno: solicita apoio para outras demandas'),
  (102, 78, 1, '2024-05-08', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (103, 79, 1, '2024-05-09', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (104, 9, 1, '2024-05-12', 'Retorno: desemprego; busca recolocação profissional'),
  (105, 80, 1, '2024-05-12', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (106, 81, 3, '2024-05-15', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (107, 82, 1, '2024-05-21', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (108, 68, 1, '2024-05-26', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (109, 83, 2, '2024-05-26', 'Triagem inicial: Sofrimento psíquico; solicita apoio psicológico'),
  (110, 84, 3, '2024-06-02', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (111, 85, 1, '2024-06-06', 'Triagem inicial: Pessoa em situação de rua; solicita acolhimento e documentação'),
  (112, 49, 3, '2024-06-07', 'Retorno: busca vaga em creche/escola para os filhos'),
  (113, 86, 1, '2024-06-08', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (114, 87, 3, '2024-06-16', 'Triagem inicial: Busca vaga em creche/escola para os filhos'),
  (115, 25, 1, '2024-06-17', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (116, 88, 3, '2024-06-18', 'Triagem inicial: Desemprego; busca recolocação profissional'),
  (117, 89, 1, '2024-06-22', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (118, 90, 3, '2024-06-29', 'Triagem inicial: Desemprego; busca recolocação profissional'),
  (119, 91, 1, '2024-07-03', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (120, 37, 3, '2024-07-07', 'Retorno: solicita apoio para outras demandas'),
  (121, 92, 2, '2024-07-10', 'Triagem inicial: Sofrimento psíquico; solicita apoio psicológico'),
  (122, 93, 1, '2024-07-24', 'Triagem inicial: Pessoa em situação de rua; solicita acolhimento e documentação'),
  (123, 94, 1, '2024-07-25', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (124, 95, 3, '2024-07-28', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (125, 96, 3, '2024-07-30', 'Triagem inicial: Dificuldade de acesso a consulta médica e medicamentos'),
  (126, 97, 3, '2024-07-31', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (127, 98, 1, '2024-08-04', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (128, 64, 3, '2024-08-13', 'Retorno: solicita apoio para outras demandas'),
  (129, 99, 1, '2024-08-15', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (130, 100, 1, '2024-08-15', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (131, 87, 1, '2024-08-20', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (132, 54, 3, '2024-08-22', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (133, 68, 3, '2024-08-23', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (134, 101, 3, '2024-08-24', 'Triagem inicial: Estudante de baixa renda; busca moradia universitária'),
  (135, 102, 3, '2024-08-28', 'Triagem inicial: Pessoa em situação de rua; solicita acolhimento e documentação'),
  (136, 103, 1, '2024-09-16', 'Triagem inicial: Necessita orientação jurídica (pensão alimentícia / guarda)'),
  (137, 25, 3, '2024-09-17', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (138, 104, 1, '2024-09-19', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (139, 105, 1, '2024-09-20', 'Triagem inicial: Desemprego; busca recolocação profissional'),
  (140, 106, 1, '2024-09-21', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (141, 107, 3, '2024-09-21', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (142, 48, 3, '2024-09-23', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (143, 108, 1, '2024-09-28', 'Triagem inicial: Desemprego; busca recolocação profissional'),
  (144, 109, 3, '2024-10-06', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (145, 110, 1, '2024-10-11', 'Triagem inicial: Risco de despejo; busca orientação habitacional'),
  (146, 111, 1, '2024-10-17', 'Triagem inicial: Estudante de baixa renda; busca moradia universitária'),
  (147, 112, 3, '2024-10-17', 'Triagem inicial: Necessita orientação jurídica (pensão alimentícia / guarda)'),
  (148, 42, 3, '2024-10-19', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (149, 70, 3, '2024-10-28', 'Retorno: busca vaga em creche/escola para os filhos'),
  (150, 113, 1, '2024-10-30', 'Triagem inicial: Sofrimento psíquico; solicita apoio psicológico'),
  (151, 114, 3, '2024-11-04', 'Triagem inicial: Dificuldade de acesso a consulta médica e medicamentos'),
  (152, 115, 1, '2024-11-11', 'Triagem inicial: Estudante de baixa renda; busca moradia universitária'),
  (153, 29, 1, '2024-11-12', 'Retorno: solicita apoio para outras demandas'),
  (154, 116, 1, '2024-11-12', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (155, 73, 3, '2024-11-14', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (156, 117, 1, '2024-11-14', 'Triagem inicial: Sem documentos pessoais; solicita emissão de 2ª via'),
  (157, 118, 1, '2024-11-14', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (158, 119, 1, '2024-11-16', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (159, 120, 1, '2024-11-20', 'Triagem inicial: Solicita apoio para outras demandas'),
  (160, 121, 1, '2024-11-26', 'Triagem inicial: Pessoa em situação de rua; solicita acolhimento e documentação'),
  (161, 122, 1, '2024-11-26', 'Triagem inicial: Sem documentos pessoais; solicita emissão de 2ª via'),
  (162, 109, 1, '2024-12-06', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (163, 123, 3, '2024-12-15', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (164, 119, 1, '2024-12-22', 'Retorno: solicita apoio para outras demandas'),
  (165, 124, 1, '2025-01-06', 'Triagem inicial: Desemprego; busca recolocação profissional'),
  (166, 101, 1, '2025-01-07', 'Retorno: busca vaga em creche/escola para os filhos'),
  (167, 107, 1, '2025-01-07', 'Retorno: busca vaga em creche/escola para os filhos'),
  (168, 125, 1, '2025-01-11', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (169, 126, 1, '2025-01-19', 'Triagem inicial: Busca vaga em creche/escola para os filhos'),
  (170, 76, 3, '2025-01-25', 'Retorno: busca vaga em creche/escola para os filhos'),
  (171, 88, 1, '2025-01-25', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (172, 103, 3, '2025-01-29', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (173, 108, 3, '2025-01-29', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (174, 127, 1, '2025-02-02', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (175, 118, 3, '2025-02-03', 'Retorno: solicita apoio para outras demandas'),
  (176, 128, 1, '2025-02-05', 'Triagem inicial: Desemprego; busca recolocação profissional'),
  (177, 129, 1, '2025-02-05', 'Triagem inicial: Necessita orientação jurídica (pensão alimentícia / guarda)'),
  (178, 130, 1, '2025-02-06', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (179, 101, 3, '2025-02-15', 'Retorno: desemprego; busca recolocação profissional'),
  (180, 131, 1, '2025-02-20', 'Triagem inicial: Desemprego; busca recolocação profissional'),
  (181, 132, 3, '2025-02-21', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (182, 133, 2, '2025-02-25', 'Triagem inicial: Sofrimento psíquico; solicita apoio psicológico'),
  (183, 134, 1, '2025-02-27', 'Triagem inicial: Desemprego; busca recolocação profissional'),
  (184, 135, 1, '2025-03-05', 'Triagem inicial: Desemprego; busca recolocação profissional'),
  (185, 136, 1, '2025-03-07', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (186, 73, 1, '2025-03-08', 'Retorno: solicita apoio para outras demandas'),
  (187, 137, 3, '2025-03-11', 'Triagem inicial: Busca vaga em creche/escola para os filhos'),
  (188, 138, 1, '2025-03-11', 'Triagem inicial: Desemprego; busca recolocação profissional'),
  (189, 86, 1, '2025-03-18', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (190, 139, 3, '2025-03-20', 'Triagem inicial: Busca vaga em creche/escola para os filhos'),
  (191, 124, 1, '2025-04-05', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (192, 140, 1, '2025-04-07', 'Triagem inicial: Dificuldade de acesso a consulta médica e medicamentos'),
  (193, 67, 3, '2025-04-13', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (194, 141, 1, '2025-04-13', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (195, 94, 1, '2025-04-22', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (196, 142, 3, '2025-04-22', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (197, 143, 1, '2025-04-30', 'Triagem inicial: Sem documentos pessoais; solicita emissão de 2ª via'),
  (198, 144, 1, '2025-05-10', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (199, 145, 1, '2025-05-17', 'Triagem inicial: Risco de despejo; busca orientação habitacional'),
  (200, 146, 1, '2025-05-19', 'Triagem inicial: Busca vaga em creche/escola para os filhos');

INSERT INTO atendimento (id_atendimento, id_beneficiario, id_profissional, data_atendimento, demanda_inicial) VALUES
  (201, 91, 1, '2025-05-27', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (202, 35, 1, '2025-05-29', 'Retorno: busca vaga em creche/escola para os filhos'),
  (203, 138, 1, '2025-06-02', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (204, 66, 1, '2025-06-05', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (205, 23, 1, '2025-06-08', 'Retorno: solicita apoio para outras demandas'),
  (206, 48, 1, '2025-06-12', 'Retorno: busca vaga em creche/escola para os filhos'),
  (207, 36, 1, '2025-06-14', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (208, 147, 3, '2025-06-15', 'Triagem inicial: Estudante de baixa renda; busca moradia universitária'),
  (209, 123, 1, '2025-06-16', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (210, 148, 1, '2025-06-16', 'Triagem inicial: Dificuldade de acesso a consulta médica e medicamentos'),
  (211, 140, 3, '2025-06-22', 'Retorno: busca vaga em creche/escola para os filhos'),
  (212, 85, 1, '2025-06-24', 'Retorno: solicita apoio para outras demandas'),
  (213, 145, 1, '2025-06-25', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (214, 149, 1, '2025-06-25', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (215, 150, 3, '2025-07-02', 'Triagem inicial: Risco de despejo; busca orientação habitacional'),
  (216, 151, 1, '2025-07-03', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (217, 152, 3, '2025-07-06', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (218, 153, 1, '2025-07-13', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (219, 154, 3, '2025-07-19', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (220, 155, 3, '2025-07-22', 'Triagem inicial: Solicita apoio para outras demandas'),
  (221, 156, 3, '2025-07-23', 'Triagem inicial: Desemprego; busca recolocação profissional'),
  (222, 126, 3, '2025-07-24', 'Retorno: desemprego; busca recolocação profissional'),
  (223, 100, 1, '2025-07-25', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (224, 32, 1, '2025-07-27', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (225, 157, 3, '2025-07-28', 'Triagem inicial: Busca vaga em creche/escola para os filhos'),
  (226, 158, 3, '2025-07-30', 'Triagem inicial: Sem documentos pessoais; solicita emissão de 2ª via'),
  (227, 159, 1, '2025-08-01', 'Triagem inicial: Busca vaga em creche/escola para os filhos'),
  (228, 79, 3, '2025-08-03', 'Retorno: busca vaga em creche/escola para os filhos'),
  (229, 90, 1, '2025-08-08', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (230, 111, 1, '2025-08-11', 'Retorno: busca vaga em creche/escola para os filhos'),
  (231, 160, 1, '2025-08-11', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (232, 161, 1, '2025-08-12', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (233, 128, 1, '2025-08-15', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (234, 84, 1, '2025-08-21', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (235, 162, 1, '2025-08-30', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (236, 163, 1, '2025-08-31', 'Triagem inicial: Risco de despejo; busca orientação habitacional'),
  (237, 164, 3, '2025-09-04', 'Triagem inicial: Necessita orientação jurídica (pensão alimentícia / guarda)'),
  (238, 159, 1, '2025-09-07', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (239, 165, 3, '2025-09-11', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (240, 166, 3, '2025-09-18', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (241, 167, 1, '2025-09-20', 'Triagem inicial: Estudante de baixa renda; busca moradia universitária'),
  (242, 168, 1, '2025-09-21', 'Triagem inicial: Solicita apoio para outras demandas'),
  (243, 163, 1, '2025-09-23', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (244, 169, 1, '2025-09-26', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (245, 170, 1, '2025-10-03', 'Triagem inicial: Sofrimento psíquico; solicita apoio psicológico'),
  (246, 171, 1, '2025-10-03', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (247, 172, 1, '2025-10-04', 'Triagem inicial: Desemprego; busca recolocação profissional'),
  (248, 158, 1, '2025-10-13', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (249, 102, 3, '2025-10-14', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (250, 146, 1, '2025-10-14', 'Retorno: desemprego; busca recolocação profissional'),
  (251, 173, 1, '2025-10-18', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (252, 14, 1, '2025-10-30', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (253, 174, 1, '2025-10-30', 'Triagem inicial: Desemprego; busca recolocação profissional'),
  (254, 175, 1, '2025-11-07', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (255, 125, 3, '2025-11-12', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (256, 116, 1, '2025-11-13', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (257, 176, 1, '2025-11-15', 'Triagem inicial: Risco de despejo; busca orientação habitacional'),
  (258, 102, 1, '2025-11-16', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (259, 177, 1, '2025-11-20', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (260, 178, 1, '2025-11-21', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (261, 88, 3, '2025-11-26', 'Retorno: solicita apoio para outras demandas'),
  (262, 165, 1, '2025-11-28', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (263, 171, 1, '2025-12-01', 'Retorno: desemprego; busca recolocação profissional'),
  (264, 157, 3, '2025-12-02', 'Retorno: desemprego; busca recolocação profissional'),
  (265, 109, 1, '2025-12-08', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (266, 179, 1, '2025-12-10', 'Triagem inicial: Pessoa em situação de rua; solicita acolhimento e documentação'),
  (267, 56, 3, '2025-12-11', 'Retorno: busca vaga em creche/escola para os filhos'),
  (268, 180, 1, '2025-12-15', 'Triagem inicial: Desemprego; busca recolocação profissional'),
  (269, 181, 1, '2025-12-16', 'Triagem inicial: Estudante de baixa renda; busca moradia universitária'),
  (270, 182, 1, '2025-12-27', 'Triagem inicial: Desemprego; busca recolocação profissional'),
  (271, 151, 1, '2025-12-28', 'Retorno: desemprego; busca recolocação profissional'),
  (272, 148, 1, '2025-12-29', 'Retorno: desemprego; busca recolocação profissional'),
  (273, 22, 3, '2025-12-31', 'Retorno: solicita apoio para outras demandas'),
  (274, 156, 3, '2026-01-01', 'Retorno: busca vaga em creche/escola para os filhos'),
  (275, 169, 1, '2026-01-06', 'Retorno: busca vaga em creche/escola para os filhos'),
  (276, 95, 1, '2026-01-08', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (277, 97, 1, '2026-01-08', 'Retorno: desemprego; busca recolocação profissional'),
  (278, 180, 1, '2026-01-12', 'Retorno: busca vaga em creche/escola para os filhos'),
  (279, 149, 1, '2026-01-15', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (280, 157, 3, '2026-01-15', 'Retorno: busca vaga em creche/escola para os filhos'),
  (281, 172, 1, '2026-02-06', 'Retorno: solicita apoio para outras demandas'),
  (282, 183, 1, '2026-02-07', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (283, 184, 1, '2026-02-10', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (284, 150, 1, '2026-02-11', 'Retorno: desemprego; busca recolocação profissional'),
  (285, 21, 1, '2026-02-15', 'Retorno: busca vaga em creche/escola para os filhos'),
  (286, 175, 3, '2026-02-16', 'Retorno: solicita apoio para outras demandas'),
  (287, 164, 1, '2026-02-20', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (288, 162, 3, '2026-02-21', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (289, 180, 1, '2026-02-25', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (290, 95, 3, '2026-02-26', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (291, 185, 1, '2026-03-04', 'Triagem inicial: Risco de despejo; busca orientação habitacional'),
  (292, 140, 1, '2026-03-05', 'Retorno: solicita apoio para outras demandas'),
  (293, 186, 3, '2026-03-07', 'Triagem inicial: Risco de despejo; busca orientação habitacional'),
  (294, 187, 1, '2026-03-09', 'Triagem inicial: Sem documentos pessoais; solicita emissão de 2ª via'),
  (295, 10, 1, '2026-03-10', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (296, 188, 3, '2026-03-10', 'Triagem inicial: Desemprego; busca recolocação profissional'),
  (297, 47, 1, '2026-03-12', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (298, 153, 3, '2026-03-13', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (299, 126, 1, '2026-03-14', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (300, 127, 3, '2026-03-15', 'Retorno: desemprego; busca recolocação profissional');

INSERT INTO atendimento (id_atendimento, id_beneficiario, id_profissional, data_atendimento, demanda_inicial) VALUES
  (301, 189, 3, '2026-03-19', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (302, 121, 1, '2026-03-20', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (303, 190, 3, '2026-03-22', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (304, 191, 3, '2026-03-23', 'Triagem inicial: Necessita orientação jurídica (pensão alimentícia / guarda)'),
  (305, 150, 1, '2026-03-24', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (306, 192, 1, '2026-03-28', 'Triagem inicial: Solicita apoio para outras demandas'),
  (307, 72, 3, '2026-03-29', 'Retorno: desemprego; busca recolocação profissional'),
  (308, 193, 1, '2026-03-31', 'Triagem inicial: Dificuldade de acesso a consulta médica e medicamentos'),
  (309, 164, 1, '2026-04-03', 'Retorno: busca vaga em creche/escola para os filhos'),
  (310, 162, 3, '2026-04-04', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (311, 194, 1, '2026-04-05', 'Triagem inicial: Pessoa em situação de rua; solicita acolhimento e documentação'),
  (312, 195, 1, '2026-04-08', 'Triagem inicial: Estudante de baixa renda; busca moradia universitária'),
  (313, 196, 1, '2026-04-09', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (314, 63, 3, '2026-04-12', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (315, 185, 1, '2026-04-14', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (316, 197, 3, '2026-04-14', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (317, 152, 1, '2026-04-16', 'Retorno: solicita apoio para outras demandas'),
  (318, 198, 1, '2026-04-21', 'Triagem inicial: Estudante de baixa renda; busca moradia universitária'),
  (319, 134, 3, '2026-04-22', 'Retorno: desemprego; busca recolocação profissional'),
  (320, 199, 3, '2026-04-22', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (321, 190, 3, '2026-04-23', 'Retorno: solicita apoio para outras demandas'),
  (322, 179, 3, '2026-04-24', 'Retorno: desemprego; busca recolocação profissional'),
  (323, 57, 1, '2026-04-26', 'Retorno: desemprego; busca recolocação profissional'),
  (324, 97, 3, '2026-04-29', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (325, 113, 1, '2026-04-29', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (326, 179, 3, '2026-04-29', 'Retorno: desemprego; busca recolocação profissional'),
  (327, 77, 1, '2026-04-30', 'Retorno: solicita apoio para outras demandas'),
  (328, 200, 1, '2026-05-03', 'Triagem inicial: Desemprego; busca recolocação profissional'),
  (329, 188, 1, '2026-05-05', 'Retorno: busca vaga em creche/escola para os filhos'),
  (330, 201, 1, '2026-05-05', 'Triagem inicial: Estudante de baixa renda; busca moradia universitária'),
  (331, 80, 3, '2026-05-06', 'Retorno: busca vaga em creche/escola para os filhos'),
  (332, 156, 1, '2026-05-06', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (333, 145, 1, '2026-05-08', 'Retorno: desemprego; busca recolocação profissional'),
  (334, 189, 1, '2026-05-08', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (335, 202, 3, '2026-05-08', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (336, 203, 3, '2026-05-12', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (337, 204, 3, '2026-05-12', 'Triagem inicial: Risco de despejo; busca orientação habitacional'),
  (338, 83, 1, '2026-05-13', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (339, 205, 3, '2026-05-14', 'Triagem inicial: Solicita apoio para outras demandas'),
  (340, 100, 1, '2026-05-15', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (341, 183, 3, '2026-05-15', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (342, 195, 1, '2026-05-18', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (343, 206, 3, '2026-05-18', 'Triagem inicial: Desemprego; busca recolocação profissional'),
  (344, 207, 1, '2026-05-19', 'Triagem inicial: Desemprego; busca recolocação profissional'),
  (345, 30, 1, '2026-05-22', 'Retorno: busca vaga em creche/escola para os filhos'),
  (346, 208, 3, '2026-05-22', 'Triagem inicial: Pessoa em situação de rua; solicita acolhimento e documentação'),
  (347, 209, 3, '2026-05-25', 'Triagem inicial: Pessoa em situação de rua; solicita acolhimento e documentação'),
  (348, 189, 1, '2026-05-26', 'Retorno: solicita apoio para outras demandas'),
  (349, 81, 1, '2026-05-27', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (350, 210, 1, '2026-05-28', 'Triagem inicial: Pessoa em situação de rua; solicita acolhimento e documentação'),
  (351, 211, 3, '2026-05-30', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (352, 108, 1, '2026-06-01', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (353, 177, 1, '2026-06-01', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (354, 212, 1, '2026-06-03', 'Triagem inicial: Pessoa em situação de rua; solicita acolhimento e documentação'),
  (355, 213, 3, '2026-06-05', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (356, 196, 1, '2026-06-07', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (357, 214, 2, '2026-06-07', 'Triagem inicial: Sofrimento psíquico; solicita apoio psicológico'),
  (358, 198, 1, '2026-06-08', 'Retorno: desemprego; busca recolocação profissional'),
  (359, 70, 1, '2026-06-10', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (360, 215, 1, '2026-06-11', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (361, 183, 1, '2026-06-14', 'Retorno: busca vaga em creche/escola para os filhos'),
  (362, 195, 3, '2026-06-14', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (363, 198, 1, '2026-06-14', 'Retorno: solicita apoio para outras demandas'),
  (364, 216, 1, '2026-06-14', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (365, 202, 3, '2026-06-15', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (366, 217, 1, '2026-06-15', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (367, 196, 3, '2026-06-16', 'Retorno: solicita apoio para outras demandas'),
  (368, 112, 3, '2026-06-17', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (369, 201, 1, '2026-06-17', 'Retorno: busca vaga em creche/escola para os filhos'),
  (370, 191, 1, '2026-06-18', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (371, 218, 1, '2026-06-19', 'Triagem inicial: Desemprego; busca recolocação profissional'),
  (372, 219, 1, '2026-06-20', 'Triagem inicial: Busca vaga em creche/escola para os filhos'),
  (373, 163, 1, '2026-06-21', 'Retorno: solicita apoio para outras demandas'),
  (374, 177, 3, '2026-06-22', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (375, 188, 1, '2026-06-23', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (376, 199, 3, '2026-06-27', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (377, 106, 1, '2026-06-28', 'Retorno: solicita apoio para outras demandas'),
  (378, 220, 3, '2026-06-28', 'Triagem inicial: Risco de despejo; busca orientação habitacional'),
  (379, 221, 3, '2026-06-28', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (380, 69, 3, '2026-07-01', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (381, 115, 1, '2026-07-01', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (382, 162, 1, '2026-07-01', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (383, 218, 1, '2026-07-01', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (384, 11, 3, '2026-07-02', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (385, 148, 1, '2026-07-02', 'Retorno: desemprego; busca recolocação profissional'),
  (386, 161, 1, '2026-07-02', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (387, 172, 3, '2026-07-02', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (388, 216, 1, '2026-07-02', 'Retorno: sem documentos pessoais; solicita emissão de 2ª via'),
  (389, 79, 3, '2026-07-03', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (390, 93, 1, '2026-07-03', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (391, 99, 3, '2026-07-03', 'Retorno: risco de despejo; busca orientação habitacional'),
  (392, 151, 1, '2026-07-03', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (393, 152, 1, '2026-07-03', 'Retorno: risco de despejo; busca orientação habitacional'),
  (394, 197, 1, '2026-07-03', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (395, 122, 3, '2026-07-06', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (396, 144, 3, '2026-07-06', 'Retorno: solicita apoio para outras demandas'),
  (397, 153, 1, '2026-07-06', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (398, 199, 1, '2026-07-06', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (399, 222, 3, '2026-07-06', 'Triagem inicial: Necessita orientação jurídica (pensão alimentícia / guarda)'),
  (400, 38, 3, '2026-07-07', 'Retorno: risco de despejo; busca orientação habitacional');

INSERT INTO atendimento (id_atendimento, id_beneficiario, id_profissional, data_atendimento, demanda_inicial) VALUES
  (401, 62, 3, '2026-07-07', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (402, 108, 1, '2026-07-07', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (403, 200, 3, '2026-07-07', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (404, 89, 3, '2026-07-08', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (405, 160, 1, '2026-07-08', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (406, 166, 1, '2026-07-08', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (407, 223, 3, '2026-07-08', 'Triagem inicial: Solicita apoio para outras demandas'),
  (408, 15, 1, '2026-07-09', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (409, 92, 1, '2026-07-09', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (410, 145, 1, '2026-07-09', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (411, 163, 1, '2026-07-09', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (412, 60, 1, '2026-07-10', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (413, 115, 1, '2026-07-10', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (414, 178, 1, '2026-07-10', 'Retorno: risco de despejo; busca orientação habitacional'),
  (415, 202, 1, '2026-07-10', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (416, 224, 1, '2026-07-10', 'Triagem inicial: Sofrimento psíquico; solicita apoio psicológico'),
  (417, 225, 1, '2026-07-12', 'Triagem inicial: Solicita apoio para outras demandas'),
  (418, 226, 1, '2026-07-12', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (419, 127, 1, '2026-07-13', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (420, 134, 1, '2026-07-13', 'Retorno: risco de despejo; busca orientação habitacional'),
  (421, 155, 3, '2026-07-13', 'Retorno: busca vaga em creche/escola para os filhos'),
  (422, 9, 1, '2026-07-14', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (423, 103, 1, '2026-07-14', 'Retorno: sem documentos pessoais; solicita emissão de 2ª via'),
  (424, 127, 3, '2026-07-14', 'Retorno: risco de despejo; busca orientação habitacional'),
  (425, 130, 3, '2026-07-14', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (426, 45, 3, '2026-07-15', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (427, 77, 1, '2026-07-15', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (428, 90, 1, '2026-07-15', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (429, 125, 1, '2026-07-15', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (430, 227, 3, '2026-07-15', 'Triagem inicial: Busca vaga em creche/escola para os filhos'),
  (431, 17, 1, '2026-07-16', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (432, 30, 3, '2026-07-16', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (433, 89, 1, '2026-07-16', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (434, 209, 1, '2026-07-16', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (435, 228, 1, '2026-07-16', 'Triagem inicial: Sem documentos pessoais; solicita emissão de 2ª via'),
  (436, 20, 3, '2026-07-17', 'Retorno: solicita apoio para outras demandas'),
  (437, 68, 1, '2026-07-17', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (438, 97, 1, '2026-07-17', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (439, 191, 3, '2026-07-17', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (440, 80, 1, '2026-07-20', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (441, 142, 3, '2026-07-20', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (442, 224, 1, '2026-07-20', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (443, 94, 3, '2026-07-21', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (444, 124, 1, '2026-07-21', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (445, 136, 1, '2026-07-21', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (446, 154, 1, '2026-07-21', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (447, 222, 3, '2026-07-21', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (448, 31, 3, '2026-07-22', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (449, 52, 3, '2026-07-22', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (450, 113, 1, '2026-07-22', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (451, 115, 3, '2026-07-22', 'Retorno: solicita apoio para outras demandas'),
  (452, 165, 1, '2026-07-22', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (453, 229, 1, '2026-07-22', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (454, 14, 1, '2026-07-23', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (455, 178, 1, '2026-07-23', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (456, 51, 1, '2026-07-24', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (457, 138, 1, '2026-07-24', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (458, 211, 3, '2026-07-24', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (459, 73, 3, '2026-07-27', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (460, 95, 1, '2026-07-27', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (461, 107, 1, '2026-07-27', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (462, 174, 3, '2026-07-27', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (463, 16, 1, '2026-07-28', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (464, 19, 1, '2026-07-28', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (465, 82, 1, '2026-07-28', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (466, 132, 1, '2026-07-28', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (467, 149, 3, '2026-07-28', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (468, 119, 3, '2026-07-29', 'Retorno: risco de despejo; busca orientação habitacional'),
  (469, 128, 1, '2026-07-29', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (470, 132, 1, '2026-07-29', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (471, 188, 3, '2026-07-29', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (472, 189, 1, '2026-07-29', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (473, 104, 1, '2026-07-30', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (474, 230, 3, '2026-08-01', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (475, 231, 1, '2026-08-02', 'Triagem inicial: Busca vaga em creche/escola para os filhos'),
  (476, 118, 1, '2026-08-03', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (477, 154, 1, '2026-08-03', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (478, 207, 3, '2026-08-03', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (479, 212, 1, '2026-08-03', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (480, 104, 3, '2026-08-04', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (481, 20, 1, '2026-08-05', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (482, 116, 3, '2026-08-05', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (483, 121, 3, '2026-08-05', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (484, 36, 1, '2026-08-06', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (485, 214, 1, '2026-08-06', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (486, 43, 1, '2026-08-07', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (487, 66, 3, '2026-08-07', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (488, 167, 3, '2026-08-07', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (489, 232, 1, '2026-08-09', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (490, 33, 3, '2026-08-10', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (491, 86, 3, '2026-08-10', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (492, 98, 3, '2026-08-10', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (493, 144, 3, '2026-08-10', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (494, 233, 1, '2026-08-10', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (495, 13, 1, '2026-08-11', 'Retorno: sofrimento psíquico; solicita apoio psicológico'),
  (496, 106, 3, '2026-08-11', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (497, 156, 3, '2026-08-11', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (498, 45, 1, '2026-08-12', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (499, 100, 3, '2026-08-12', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (500, 85, 1, '2026-08-13', 'Retorno: avaliação socioeconômica e concessão de cesta básica');

INSERT INTO atendimento (id_atendimento, id_beneficiario, id_profissional, data_atendimento, demanda_inicial) VALUES
  (501, 128, 3, '2026-08-13', 'Retorno: risco de despejo; busca orientação habitacional'),
  (502, 150, 3, '2026-08-13', 'Retorno: sem documentos pessoais; solicita emissão de 2ª via'),
  (503, 196, 1, '2026-08-13', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (504, 230, 1, '2026-08-13', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (505, 22, 1, '2026-08-14', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (506, 48, 3, '2026-08-14', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (507, 122, 1, '2026-08-14', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (508, 175, 1, '2026-08-14', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (509, 206, 3, '2026-08-14', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (510, 215, 1, '2026-08-14', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (511, 225, 1, '2026-08-14', 'Retorno: risco de despejo; busca orientação habitacional'),
  (512, 234, 3, '2026-08-15', 'Triagem inicial: Desemprego; busca recolocação profissional'),
  (513, 21, 3, '2026-08-17', 'Retorno: desemprego; busca recolocação profissional'),
  (514, 54, 3, '2026-08-17', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (515, 104, 2, '2026-08-17', 'Retorno: sofrimento psíquico; solicita apoio psicológico'),
  (516, 180, 1, '2026-08-17', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (517, 213, 3, '2026-08-17', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (518, 233, 1, '2026-08-17', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (519, 234, 3, '2026-08-17', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (520, 88, 1, '2026-08-18', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (521, 137, 1, '2026-08-18', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (522, 142, 1, '2026-08-18', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (523, 229, 3, '2026-08-18', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (524, 32, 1, '2026-08-19', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (525, 67, 1, '2026-08-19', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (526, 75, 1, '2026-08-19', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (527, 169, 1, '2026-08-19', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (528, 49, 1, '2026-08-20', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (529, 171, 1, '2026-08-20', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (530, 221, 3, '2026-08-20', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (531, 22, 1, '2026-08-21', 'Retorno: solicita apoio para outras demandas'),
  (532, 42, 1, '2026-08-21', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (533, 51, 1, '2026-08-21', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (534, 55, 1, '2026-08-21', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (535, 56, 1, '2026-08-21', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (536, 135, 1, '2026-08-21', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (537, 177, 1, '2026-08-21', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (538, 235, 1, '2026-08-22', 'Triagem inicial: Estudante de baixa renda; busca moradia universitária'),
  (539, 91, 3, '2026-08-24', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (540, 131, 1, '2026-08-24', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (541, 153, 1, '2026-08-24', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (542, 190, 1, '2026-08-25', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (543, 210, 1, '2026-08-26', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (544, 226, 1, '2026-08-26', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (545, 31, 2, '2026-08-27', 'Retorno: sofrimento psíquico; solicita apoio psicológico'),
  (546, 182, 3, '2026-08-27', 'Retorno: solicita apoio para outras demandas'),
  (547, 236, 3, '2026-08-29', 'Triagem inicial: Desemprego; busca recolocação profissional'),
  (548, 76, 1, '2026-08-31', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (549, 105, 1, '2026-08-31', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (550, 217, 3, '2026-08-31', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (551, 236, 1, '2026-08-31', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (552, 9, 1, '2026-09-01', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (553, 95, 3, '2026-09-01', 'Retorno: sem documentos pessoais; solicita emissão de 2ª via'),
  (554, 127, 3, '2026-09-01', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (555, 171, 1, '2026-09-01', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (556, 33, 2, '2026-09-02', 'Retorno: sofrimento psíquico; solicita apoio psicológico'),
  (557, 153, 3, '2026-09-02', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (558, 209, 3, '2026-09-02', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (559, 223, 1, '2026-09-03', 'Retorno: sem documentos pessoais; solicita emissão de 2ª via'),
  (560, 130, 1, '2026-09-04', 'Retorno: busca vaga em creche/escola para os filhos'),
  (561, 178, 1, '2026-09-04', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (562, 179, 1, '2026-09-04', 'Retorno: pessoa em situação de rua; solicita acolhimento e documentação'),
  (563, 98, 1, '2026-09-07', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (564, 107, 1, '2026-09-07', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (565, 34, 1, '2026-09-08', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (566, 37, 3, '2026-09-08', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (567, 57, 2, '2026-09-08', 'Retorno: sofrimento psíquico; solicita apoio psicológico'),
  (568, 95, 1, '2026-09-08', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (569, 123, 3, '2026-09-08', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (570, 174, 1, '2026-09-08', 'Retorno: sofrimento psíquico; solicita apoio psicológico'),
  (571, 200, 3, '2026-09-08', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (572, 229, 1, '2026-09-08', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (573, 237, 1, '2026-09-08', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (574, 23, 1, '2026-09-09', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (575, 230, 3, '2026-09-09', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (576, 215, 1, '2026-09-10', 'Retorno: risco de despejo; busca orientação habitacional'),
  (577, 27, 3, '2026-09-11', 'Retorno: solicita apoio para outras demandas'),
  (578, 66, 1, '2026-09-11', 'Retorno: desemprego; busca recolocação profissional'),
  (579, 119, 1, '2026-09-11', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (580, 129, 3, '2026-09-11', 'Retorno: busca vaga em creche/escola para os filhos'),
  (581, 185, 3, '2026-09-11', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (582, 238, 1, '2026-09-12', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (583, 82, 3, '2026-09-15', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (584, 177, 1, '2026-09-15', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (585, 239, 1, '2026-09-15', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (586, 17, 1, '2026-09-16', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (587, 40, 3, '2026-09-16', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (588, 51, 3, '2026-09-16', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (589, 61, 3, '2026-09-16', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (590, 116, 1, '2026-09-16', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (591, 185, 1, '2026-09-16', 'Retorno: sofrimento psíquico; solicita apoio psicológico'),
  (592, 238, 3, '2026-09-16', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (593, 15, 3, '2026-09-17', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (594, 20, 1, '2026-09-17', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (595, 36, 1, '2026-09-17', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (596, 44, 1, '2026-09-17', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (597, 138, 1, '2026-09-17', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (598, 162, 3, '2026-09-17', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (599, 180, 1, '2026-09-17', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (600, 189, 1, '2026-09-17', 'Retorno: solicita apoio para outras demandas');

INSERT INTO atendimento (id_atendimento, id_beneficiario, id_profissional, data_atendimento, demanda_inicial) VALUES
  (601, 189, 3, '2026-09-17', 'Retorno: sem documentos pessoais; solicita emissão de 2ª via'),
  (602, 124, 3, '2026-09-18', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (603, 134, 1, '2026-09-18', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (604, 240, 1, '2026-09-19', 'Triagem inicial: Necessita orientação jurídica (pensão alimentícia / guarda)'),
  (605, 241, 3, '2026-09-19', 'Triagem inicial: Risco de despejo; busca orientação habitacional'),
  (606, 242, 1, '2026-09-20', 'Triagem inicial: Necessita orientação jurídica (pensão alimentícia / guarda)'),
  (607, 14, 1, '2026-09-21', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (608, 36, 1, '2026-09-21', 'Retorno: desemprego; busca recolocação profissional'),
  (609, 81, 1, '2026-09-21', 'Retorno: desemprego; busca recolocação profissional'),
  (610, 118, 1, '2026-09-21', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (611, 85, 3, '2026-09-22', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (612, 177, 1, '2026-09-22', 'Retorno: nova solicitação de cesta básica'),
  (613, 90, 1, '2026-09-23', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (614, 189, 3, '2026-09-23', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (615, 191, 1, '2026-09-23', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (616, 201, 1, '2026-09-23', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (617, 213, 3, '2026-09-23', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (618, 16, 1, '2026-09-24', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (619, 32, 2, '2026-09-24', 'Retorno: sofrimento psíquico; solicita apoio psicológico'),
  (620, 151, 1, '2026-09-24', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (621, 169, 3, '2026-09-24', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (622, 190, 1, '2026-09-24', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (623, 236, 1, '2026-09-24', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (624, 63, 1, '2026-09-25', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (625, 92, 1, '2026-09-25', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (626, 197, 1, '2026-09-25', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (627, 243, 3, '2026-09-25', 'Triagem inicial: Desemprego; busca recolocação profissional'),
  (628, 55, 1, '2026-09-28', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (629, 101, 1, '2026-09-28', 'Retorno: solicita apoio para outras demandas'),
  (630, 108, 2, '2026-09-28', 'Retorno: sofrimento psíquico; solicita apoio psicológico'),
  (631, 188, 1, '2026-09-28', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (632, 234, 1, '2026-09-28', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (633, 18, 1, '2026-09-29', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (634, 181, 1, '2026-09-29', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (635, 215, 3, '2026-09-29', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (636, 27, 1, '2026-09-30', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (637, 153, 3, '2026-09-30', 'Retorno: desemprego; busca recolocação profissional'),
  (638, 165, 3, '2026-09-30', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (639, 174, 3, '2026-09-30', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (640, 30, 3, '2026-10-01', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (641, 58, 3, '2026-10-01', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (642, 67, 3, '2026-10-01', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (643, 144, 1, '2026-10-01', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (644, 240, 1, '2026-10-01', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (645, 97, 1, '2026-10-02', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (646, 230, 3, '2026-10-02', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (647, 244, 1, '2026-10-02', 'Triagem inicial: Solicita apoio para outras demandas'),
  (648, 173, 1, '2026-10-05', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (649, 216, 1, '2026-10-05', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (650, 45, 1, '2026-10-06', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (651, 48, 1, '2026-10-06', 'Retorno: busca vaga em creche/escola para os filhos'),
  (652, 53, 1, '2026-10-06', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (653, 104, 1, '2026-10-06', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (654, 217, 1, '2026-10-06', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (655, 107, 1, '2026-10-07', 'Retorno: sem documentos pessoais; solicita emissão de 2ª via'),
  (656, 206, 1, '2026-10-07', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (657, 243, 1, '2026-10-07', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (658, 139, 1, '2026-10-08', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (659, 154, 1, '2026-10-08', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (660, 112, 1, '2026-10-09', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (661, 135, 1, '2026-10-09', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (662, 245, 1, '2026-10-10', 'Triagem inicial: Solicita apoio para outras demandas'),
  (663, 31, 3, '2026-10-12', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (664, 142, 3, '2026-10-12', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (665, 233, 1, '2026-10-13', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (666, 22, 1, '2026-10-14', 'Retorno: solicita apoio para outras demandas'),
  (667, 26, 1, '2026-10-14', 'Retorno: sofrimento psíquico; solicita apoio psicológico'),
  (668, 59, 3, '2026-10-14', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (669, 98, 2, '2026-10-14', 'Retorno: sofrimento psíquico; solicita apoio psicológico'),
  (670, 232, 1, '2026-10-14', 'Retorno: solicita apoio para outras demandas'),
  (671, 117, 1, '2026-10-15', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (672, 141, 1, '2026-10-15', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (673, 152, 3, '2026-10-15', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (674, 175, 1, '2026-10-16', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (675, 20, 1, '2026-10-19', 'Retorno: risco de despejo; busca orientação habitacional'),
  (676, 77, 1, '2026-10-19', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (677, 104, 1, '2026-10-19', 'Retorno: nova solicitação de cesta básica'),
  (678, 184, 1, '2026-10-19', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (679, 214, 3, '2026-10-19', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (680, 246, 1, '2026-10-19', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (681, 43, 1, '2026-10-20', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (682, 205, 1, '2026-10-20', 'Retorno: desemprego; busca recolocação profissional'),
  (683, 212, 1, '2026-10-20', 'Retorno: pessoa em situação de rua; solicita acolhimento e documentação'),
  (684, 135, 3, '2026-10-21', 'Retorno: risco de despejo; busca orientação habitacional'),
  (685, 237, 3, '2026-10-21', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (686, 240, 1, '2026-10-21', 'Retorno: risco de despejo; busca orientação habitacional'),
  (687, 247, 3, '2026-10-21', 'Triagem inicial: Busca vaga em creche/escola para os filhos'),
  (688, 248, 3, '2026-10-21', 'Triagem inicial: Estudante de baixa renda; busca moradia universitária'),
  (689, 166, 1, '2026-10-22', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (690, 212, 3, '2026-10-22', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (691, 54, 1, '2026-10-23', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (692, 68, 1, '2026-10-23', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (693, 85, 1, '2026-10-23', 'Retorno: pessoa em situação de rua; solicita acolhimento e documentação'),
  (694, 86, 1, '2026-10-23', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (695, 92, 1, '2026-10-23', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (696, 105, 3, '2026-10-23', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (697, 125, 1, '2026-10-23', 'Retorno: desemprego; busca recolocação profissional'),
  (698, 232, 3, '2026-10-23', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (699, 249, 1, '2026-10-24', 'Triagem inicial: Insegurança alimentar; renda insuficiente para a alimentação da família'),
  (700, 21, 3, '2026-10-26', 'Retorno: avaliação socioeconômica e concessão de cesta básica');

INSERT INTO atendimento (id_atendimento, id_beneficiario, id_profissional, data_atendimento, demanda_inicial) VALUES
  (701, 42, 3, '2026-10-26', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (702, 106, 3, '2026-10-26', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (703, 122, 1, '2026-10-26', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (704, 142, 1, '2026-10-26', 'Retorno: nova solicitação de cesta básica'),
  (705, 161, 1, '2026-10-27', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (706, 225, 1, '2026-10-27', 'Retorno: desemprego; busca recolocação profissional'),
  (707, 240, 3, '2026-10-27', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (708, 48, 1, '2026-10-28', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (709, 54, 1, '2026-10-28', 'Retorno: dificuldade de acesso a consulta médica e medicamentos'),
  (710, 91, 1, '2026-10-28', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (711, 113, 1, '2026-10-28', 'Retorno: desemprego; busca recolocação profissional'),
  (712, 131, 3, '2026-10-28', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (713, 199, 1, '2026-10-28', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (714, 216, 2, '2026-10-28', 'Retorno: sofrimento psíquico; solicita apoio psicológico'),
  (715, 239, 1, '2026-10-28', 'Retorno: busca orientação sobre cadúnico e programas de transferência de renda'),
  (716, 250, 3, '2026-10-28', 'Triagem inicial: Busca orientação sobre CadÚnico e programas de transferência de renda'),
  (717, 75, 3, '2026-10-29', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (718, 239, 1, '2026-10-29', 'Retorno: necessita orientação jurídica (pensão alimentícia / guarda)'),
  (719, 241, 1, '2026-10-29', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (720, 249, 1, '2026-10-29', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (721, 76, 3, '2026-10-30', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (722, 79, 1, '2026-10-30', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (723, 88, 1, '2026-10-30', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (724, 125, 1, '2026-10-30', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (725, 172, 1, '2026-10-30', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (726, 221, 3, '2026-10-30', 'Retorno: avaliação socioeconômica e concessão de cesta básica'),
  (727, 244, 1, '2026-10-30', 'Retorno: risco de despejo; busca orientação habitacional');

-- ---------------------------------------------------------------------
-- Entidade 07/10 — encaminhamento_atendimento (dicionário 4.6)
-- ---------------------------------------------------------------------
-- ENCAMINHAMENTO_ATENDIMENTO — Encaminhamentos à rede externa (o id 222 foi lançado em duplicidade e é excluído na seção 6)
INSERT INTO encaminhamento_atendimento (id_encaminhamento, id_atendimento, tipo_encaminhamento, detalhe_outros) VALUES
  (1, 5, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (2, 6, 'Saúde mental - CAPS', 'CAPS Adulto da região'),
  (3, 10, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (4, 11, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (5, 12, 'Saúde mental - CAPS', 'CAPS Adulto da região'),
  (6, 13, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (7, 17, 'Educação - creche/escola', 'Solicitação de vaga em CEI/EMEF da região'),
  (8, 18, 'Documentação civil', 'Poupatempo / cartório: 2ª via de RG, CPF e certidão'),
  (9, 23, 'Habitação', 'Centro de Acolhida para adultos'),
  (10, 30, 'Outros', 'Inscrição em curso gratuito de informática'),
  (11, 35, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (12, 38, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (13, 40, 'Saúde - AMA', 'AMA da região'),
  (14, 40, 'Saúde - UBS', 'UBS de referência do território'),
  (15, 47, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (16, 49, 'Habitação', 'Centro de Acolhida para adultos'),
  (17, 52, 'Habitação', 'Programas habitacionais e auxílio aluguel'),
  (18, 53, 'Educação - creche/escola', 'Solicitação de vaga em CEI/EMEF da região'),
  (19, 54, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (20, 57, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (21, 59, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (22, 60, 'Educação - creche/escola', 'Solicitação de vaga em CEI/EMEF da região'),
  (23, 64, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (24, 68, 'Outros', 'Orientação sobre aposentadoria no INSS'),
  (25, 75, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (26, 76, 'Saúde - AMA', 'AMA da região'),
  (27, 81, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (28, 83, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (29, 84, 'Saúde mental - CAPS', 'CAPS Adulto da região'),
  (30, 86, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (31, 87, 'Educação - creche/escola', 'Solicitação de vaga em CEI/EMEF da região'),
  (32, 91, 'Habitação', 'Programas habitacionais e auxílio aluguel'),
  (33, 93, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (34, 101, 'Outros', 'Orientação sobre aposentadoria no INSS'),
  (35, 103, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (36, 104, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (37, 105, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (38, 106, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (39, 109, 'Saúde mental - CAPS', 'CAPS Adulto da região'),
  (40, 110, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (41, 111, 'Documentação civil', '2ª via de RG e CPF'),
  (42, 111, 'Habitação', 'Centro de Acolhida para adultos'),
  (43, 112, 'Educação - creche/escola', 'Solicitação de vaga em CEI/EMEF da região'),
  (44, 114, 'Educação - creche/escola', 'Solicitação de vaga em CEI/EMEF da região'),
  (45, 115, 'Assistência jurídica', 'Defensoria Pública do Estado'),
  (46, 119, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (47, 120, 'Outros', 'Inscrição em curso gratuito de informática'),
  (48, 121, 'Saúde mental - CAPS', 'CAPS Adulto da região'),
  (49, 122, 'Documentação civil', '2ª via de RG e CPF'),
  (50, 123, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (51, 132, 'Assistência jurídica', 'Defensoria Pública do Estado'),
  (52, 133, 'Assistência jurídica', 'Defensoria Pública do Estado'),
  (53, 134, 'Moradia universitária', 'Inscrição em programa de moradia estudantil'),
  (54, 150, 'Saúde mental - CAPS', 'CAPS Adulto da região'),
  (55, 151, 'Saúde - UBS', 'UBS de referência do território'),
  (56, 153, 'Outros', 'Inscrição em curso gratuito de informática'),
  (57, 155, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (58, 156, 'Documentação civil', 'Poupatempo / cartório: 2ª via de RG, CPF e certidão'),
  (59, 161, 'Documentação civil', 'Poupatempo / cartório: 2ª via de RG, CPF e certidão'),
  (60, 162, 'Saúde - AMA', 'AMA da região'),
  (61, 164, 'Outros', 'Orientação sobre passe livre no transporte'),
  (62, 165, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (63, 169, 'Educação - creche/escola', 'Solicitação de vaga em CEI/EMEF da região'),
  (64, 171, 'Assistência jurídica', 'Defensoria Pública do Estado'),
  (65, 172, 'Saúde - AMA', 'AMA da região'),
  (66, 173, 'Assistência jurídica', 'Defensoria Pública do Estado'),
  (67, 174, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (68, 176, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (69, 177, 'Assistência jurídica', 'Defensoria Pública do Estado'),
  (70, 178, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (71, 179, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (72, 182, 'Saúde mental - CAPS', 'CAPS Adulto da região'),
  (73, 183, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (74, 187, 'Educação - creche/escola', 'Solicitação de vaga em CEI/EMEF da região'),
  (75, 188, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (76, 192, 'Saúde - AMA', 'AMA da região'),
  (77, 192, 'Saúde - UBS', 'UBS de referência do território'),
  (78, 195, 'Assistência jurídica', 'Defensoria Pública do Estado'),
  (79, 197, 'Documentação civil', 'Poupatempo / cartório: 2ª via de RG, CPF e certidão'),
  (80, 198, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (81, 199, 'Habitação', 'Programas habitacionais e auxílio aluguel'),
  (82, 201, 'Saúde - AMA', 'AMA da região'),
  (83, 202, 'Educação - creche/escola', 'Solicitação de vaga em CEI/EMEF da região'),
  (84, 206, 'Educação - creche/escola', 'Solicitação de vaga em CEI/EMEF da região'),
  (85, 208, 'Moradia universitária', 'Inscrição em programa de moradia estudantil'),
  (86, 209, 'Assistência jurídica', 'Defensoria Pública do Estado'),
  (87, 210, 'Saúde - AMA', 'AMA da região'),
  (88, 215, 'Habitação', 'Programas habitacionais e auxílio aluguel'),
  (89, 221, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (90, 222, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (91, 225, 'Educação - creche/escola', 'Solicitação de vaga em CEI/EMEF da região'),
  (92, 226, 'Documentação civil', 'Poupatempo / cartório: 2ª via de RG, CPF e certidão'),
  (93, 227, 'Educação - creche/escola', 'Solicitação de vaga em CEI/EMEF da região'),
  (94, 228, 'Educação - creche/escola', 'Solicitação de vaga em CEI/EMEF da região'),
  (95, 236, 'Habitação', 'Programas habitacionais e auxílio aluguel'),
  (96, 237, 'Assistência jurídica', 'Defensoria Pública do Estado'),
  (97, 238, 'Assistência jurídica', 'Defensoria Pública do Estado'),
  (98, 240, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (99, 241, 'Moradia universitária', 'Inscrição em programa de moradia estudantil'),
  (100, 244, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência');

INSERT INTO encaminhamento_atendimento (id_encaminhamento, id_atendimento, tipo_encaminhamento, detalhe_outros) VALUES
  (101, 245, 'Saúde mental - CAPS', 'CAPS Adulto da região'),
  (102, 248, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (103, 251, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (104, 253, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (105, 254, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (106, 256, 'Assistência jurídica', 'Defensoria Pública do Estado'),
  (107, 262, 'Saúde - UBS', 'UBS de referência do território'),
  (108, 263, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (109, 265, 'Assistência jurídica', 'Defensoria Pública do Estado'),
  (110, 268, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (111, 269, 'Moradia universitária', 'Inscrição em programa de moradia estudantil'),
  (112, 276, 'Assistência jurídica', 'Defensoria Pública do Estado'),
  (113, 278, 'Educação - creche/escola', 'Solicitação de vaga em CEI/EMEF da região'),
  (114, 280, 'Educação - creche/escola', 'Solicitação de vaga em CEI/EMEF da região'),
  (115, 283, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (116, 286, 'Outros', 'Orientação sobre passe livre no transporte'),
  (117, 291, 'Habitação', 'Programas habitacionais e auxílio aluguel'),
  (118, 293, 'Habitação', 'Programas habitacionais e auxílio aluguel'),
  (119, 296, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (120, 297, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (121, 300, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (122, 302, 'Saúde - AMA', 'AMA da região'),
  (123, 304, 'Assistência jurídica', 'Defensoria Pública do Estado'),
  (124, 308, 'Saúde - UBS', 'UBS de referência do território'),
  (125, 310, 'Assistência jurídica', 'Defensoria Pública do Estado'),
  (126, 311, 'Habitação', 'Centro de Acolhida para adultos'),
  (127, 311, 'Documentação civil', '2ª via de RG e CPF'),
  (128, 313, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (129, 315, 'Assistência jurídica', 'Defensoria Pública do Estado'),
  (130, 318, 'Moradia universitária', 'Inscrição em programa de moradia estudantil'),
  (131, 319, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (132, 320, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (133, 321, 'Outros', 'Inscrição em curso gratuito de informática'),
  (134, 323, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (135, 324, 'Saúde - UBS', 'UBS de referência do território'),
  (136, 327, 'Outros', 'Orientação sobre tarifa social de energia'),
  (137, 328, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (138, 343, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (139, 344, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (140, 345, 'Educação - creche/escola', 'Solicitação de vaga em CEI/EMEF da região'),
  (141, 346, 'Habitação', 'Centro de Acolhida para adultos'),
  (142, 347, 'Documentação civil', '2ª via de RG e CPF'),
  (143, 350, 'Documentação civil', '2ª via de RG e CPF'),
  (144, 351, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (145, 353, 'Assistência jurídica', 'Defensoria Pública do Estado'),
  (146, 354, 'Documentação civil', '2ª via de RG e CPF'),
  (147, 354, 'Habitação', 'Centro de Acolhida para adultos'),
  (148, 358, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (149, 361, 'Educação - creche/escola', 'Solicitação de vaga em CEI/EMEF da região'),
  (150, 362, 'Assistência jurídica', 'Defensoria Pública do Estado'),
  (151, 363, 'Outros', 'Orientação sobre tarifa social de energia'),
  (152, 365, 'Saúde - AMA', 'AMA da região'),
  (153, 366, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (154, 367, 'Outros', 'Doação de enxoval para recém-nascido'),
  (155, 369, 'Educação - creche/escola', 'Solicitação de vaga em CEI/EMEF da região'),
  (156, 370, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (157, 371, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (158, 376, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (159, 384, 'Assistência jurídica', 'Defensoria Pública do Estado'),
  (160, 385, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (161, 393, 'Habitação', 'Programas habitacionais e auxílio aluguel'),
  (162, 396, 'Outros', 'Doação de enxoval para recém-nascido'),
  (163, 399, 'Assistência jurídica', 'Defensoria Pública do Estado'),
  (164, 407, 'Outros', 'Orientação sobre tarifa social de energia'),
  (165, 413, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (166, 414, 'Habitação', 'Programas habitacionais e auxílio aluguel'),
  (167, 416, 'Saúde mental - CAPS', 'CAPS Adulto da região'),
  (168, 420, 'Habitação', 'Programas habitacionais e auxílio aluguel'),
  (169, 421, 'Educação - creche/escola', 'Solicitação de vaga em CEI/EMEF da região'),
  (170, 423, 'Documentação civil', 'Poupatempo / cartório: 2ª via de RG, CPF e certidão'),
  (171, 430, 'Educação - creche/escola', 'Solicitação de vaga em CEI/EMEF da região'),
  (172, 436, 'Outros', 'Orientação sobre passe livre no transporte'),
  (173, 440, 'Saúde - UBS', 'UBS de referência do território'),
  (174, 441, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (175, 446, 'Saúde - AMA', 'AMA da região'),
  (176, 447, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (177, 451, 'Outros', 'Doação de enxoval para recém-nascido'),
  (178, 456, 'Saúde - UBS', 'UBS de referência do território'),
  (179, 456, 'Saúde - AMA', 'AMA da região'),
  (180, 464, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (181, 468, 'Habitação', 'Programas habitacionais e auxílio aluguel'),
  (182, 470, 'Assistência jurídica', 'Defensoria Pública do Estado'),
  (183, 473, 'Saúde - AMA', 'AMA da região'),
  (184, 473, 'Saúde - UBS', 'UBS de referência do território'),
  (185, 495, 'Saúde mental - CAPS', 'CAPS Adulto da região'),
  (186, 498, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (187, 501, 'Habitação', 'Programas habitacionais e auxílio aluguel'),
  (188, 502, 'Documentação civil', 'Poupatempo / cartório: 2ª via de RG, CPF e certidão'),
  (189, 512, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (190, 513, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (191, 531, 'Outros', 'Orientação sobre tarifa social de energia'),
  (192, 546, 'Outros', 'Inscrição em curso gratuito de informática'),
  (193, 560, 'Educação - creche/escola', 'Solicitação de vaga em CEI/EMEF da região'),
  (194, 562, 'Habitação', 'Centro de Acolhida para adultos'),
  (195, 567, 'Saúde mental - CAPS', 'CAPS Adulto da região'),
  (196, 573, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (197, 574, 'Saúde - UBS', 'UBS de referência do território'),
  (198, 576, 'Habitação', 'Programas habitacionais e auxílio aluguel'),
  (199, 577, 'Outros', 'Doação de enxoval para recém-nascido'),
  (200, 580, 'Educação - creche/escola', 'Solicitação de vaga em CEI/EMEF da região');

INSERT INTO encaminhamento_atendimento (id_encaminhamento, id_atendimento, tipo_encaminhamento, detalhe_outros) VALUES
  (201, 585, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (202, 591, 'Saúde mental - CAPS', 'CAPS Adulto da região'),
  (203, 600, 'Outros', 'Inscrição em curso gratuito de informática'),
  (204, 601, 'Documentação civil', 'Poupatempo / cartório: 2ª via de RG, CPF e certidão'),
  (205, 604, 'Assistência jurídica', 'Defensoria Pública do Estado'),
  (206, 606, 'Assistência jurídica', 'Defensoria Pública do Estado'),
  (207, 608, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (208, 609, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (209, 615, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (210, 619, 'Saúde mental - CAPS', 'CAPS Adulto da região'),
  (211, 625, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (212, 629, 'Outros', 'Orientação sobre passe livre no transporte'),
  (213, 637, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (214, 644, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (215, 646, 'Assistência jurídica', 'Defensoria Pública do Estado'),
  (216, 647, 'Outros', 'Doação de enxoval para recém-nascido'),
  (217, 655, 'Documentação civil', 'Poupatempo / cartório: 2ª via de RG, CPF e certidão'),
  (218, 666, 'Outros', 'Orientação sobre tarifa social de energia'),
  (219, 667, 'Saúde mental - CAPS', 'CAPS Adulto da região'),
  (220, 669, 'Saúde mental - CAPS', 'CAPS Adulto da região'),
  (221, 675, 'Habitação', 'Programas habitacionais e auxílio aluguel'),
  (222, 675, 'Habitação', 'Programas habitacionais e auxílio aluguel'),
  (223, 680, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (224, 682, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (225, 683, 'Habitação', 'Centro de Acolhida para adultos'),
  (226, 684, 'Habitação', 'Programas habitacionais e auxílio aluguel'),
  (227, 686, 'Habitação', 'Programas habitacionais e auxílio aluguel'),
  (228, 687, 'Educação - creche/escola', 'Solicitação de vaga em CEI/EMEF da região'),
  (229, 697, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (230, 706, 'Empregabilidade - CAT', 'CAT - Centro de Apoio ao Trabalho da região'),
  (231, 714, 'Saúde mental - CAPS', 'CAPS Adulto da região'),
  (232, 715, 'CRAS - CadÚnico', 'Inclusão/atualização no CadÚnico no CRAS de referência'),
  (233, 727, 'Habitação', 'Programas habitacionais e auxílio aluguel');

-- ---------------------------------------------------------------------
-- Entidade 08/10 — pia (dicionário 4.8)
-- ---------------------------------------------------------------------
-- PIA — Planos Individuais de Atendimento (prazo de reavaliação de 90 dias)
INSERT INTO pia (id_pia, id_beneficiario, id_profissional, data_criacao, metas_objetivos, prazo_reavaliacao) VALUES
  (1, 65, 3, '2024-03-03', 'Requerimento do BPC; Inserção em curso profissionalizante; Regularizar documentação civil.', '2024-06-01'),
  (2, 102, 1, '2025-11-16', 'Regularizar documentação civil; Acesso a moradia (Centro de Acolhida / auxílio aluguel); Inscrição/atualização no CadÚnico.', '2026-02-14'),
  (3, 180, 1, '2026-02-25', 'Recolocação no mercado de trabalho; Inserção em curso profissionalizante; Acompanhamento em saúde mental (CAPS).', '2026-05-26'),
  (4, 188, 3, '2026-03-10', 'Recolocação no mercado de trabalho; Matrícula dos filhos em creche/escola; Inscrição/atualização no CadÚnico.', '2026-06-08'),
  (5, 194, 1, '2026-04-05', 'Regularizar documentação civil; Acesso a moradia (Centro de Acolhida / auxílio aluguel); Inscrição/atualização no CadÚnico.', '2026-07-04'),
  (6, 208, 3, '2026-05-22', 'Regularizar documentação civil; Acesso a moradia (Centro de Acolhida / auxílio aluguel); Garantir acesso regular a alimentos.', '2026-08-20'),
  (7, 209, 3, '2026-05-25', 'Regularizar documentação civil; Acesso a moradia (Centro de Acolhida / auxílio aluguel); Recolocação no mercado de trabalho.', '2026-08-23'),
  (8, 108, 1, '2026-06-01', 'Acesso a moradia (Centro de Acolhida / auxílio aluguel); Recolocação no mercado de trabalho; Regularizar documentação civil.', '2026-08-30'),
  (9, 212, 1, '2026-06-03', 'Regularizar documentação civil; Acesso a moradia (Centro de Acolhida / auxílio aluguel); Inscrição/atualização no CadÚnico.', '2026-09-01'),
  (10, 213, 3, '2026-06-05', 'Garantir acesso regular a alimentos; Requerimento do BPC; Regularizar documentação civil.', '2026-09-03'),
  (11, 161, 1, '2026-07-02', 'Garantir acesso regular a alimentos; Inserção em curso profissionalizante; Regularizar documentação civil.', '2026-09-30'),
  (12, 79, 3, '2026-07-03', 'Garantir acesso regular a alimentos; Inserção em curso profissionalizante; Recolocação no mercado de trabalho.', '2026-10-01'),
  (13, 93, 1, '2026-07-03', 'Regularizar documentação civil; Acesso a moradia (Centro de Acolhida / auxílio aluguel); Inserção em curso profissionalizante.', '2026-10-01'),
  (14, 15, 1, '2026-07-09', 'Regularizar documentação civil; Acesso a moradia (Centro de Acolhida / auxílio aluguel); Regularizar documentação civil.', '2026-10-07'),
  (15, 125, 1, '2026-07-15', 'Recolocação no mercado de trabalho; Acesso a moradia (Centro de Acolhida / auxílio aluguel); Matrícula dos filhos em creche/escola.', '2026-10-13'),
  (16, 20, 3, '2026-07-17', 'Requerimento do BPC; Matrícula dos filhos em creche/escola; Inscrição/atualização no CadÚnico.', '2026-10-15'),
  (17, 165, 1, '2026-07-22', 'Matrícula dos filhos em creche/escola; Recolocação no mercado de trabalho; Requerimento do BPC.', '2026-10-20'),
  (18, 132, 1, '2026-07-28', 'Acesso a moradia (Centro de Acolhida / auxílio aluguel); Regularizar documentação civil; Requerimento do BPC.', '2026-10-26'),
  (19, 149, 3, '2026-07-28', 'Matrícula dos filhos em creche/escola; Inserção em curso profissionalizante; Regularizar documentação civil.', '2026-10-26'),
  (20, 116, 3, '2026-08-05', 'Regularizar documentação civil; Matrícula dos filhos em creche/escola; Acompanhamento em saúde mental (CAPS).', '2026-11-03'),
  (21, 121, 3, '2026-08-05', 'Regularizar documentação civil; Acesso a moradia (Centro de Acolhida / auxílio aluguel); Acesso a moradia (Centro de Acolhida / auxílio aluguel).', '2026-11-03'),
  (22, 36, 1, '2026-08-06', 'Regularizar documentação civil; Matrícula dos filhos em creche/escola; Acompanhamento em saúde mental (CAPS).', '2026-11-04'),
  (23, 98, 3, '2026-08-10', 'Matrícula dos filhos em creche/escola; Inserção em curso profissionalizante; Acompanhamento em saúde mental (CAPS).', '2026-11-08'),
  (24, 48, 3, '2026-08-14', 'Garantir acesso regular a alimentos; Acesso a moradia (Centro de Acolhida / auxílio aluguel); Requerimento do BPC.', '2026-11-12'),
  (25, 180, 1, '2026-08-17', 'Reavaliação: Recolocação no mercado de trabalho; Inserção em curso profissionalizante; Acompanhamento em saúde mental (CAPS).', '2026-11-15'),
  (26, 213, 3, '2026-08-17', 'Reavaliação: Garantir acesso regular a alimentos; Requerimento do BPC; Regularizar documentação civil.', '2026-11-15'),
  (27, 88, 1, '2026-08-18', 'Acompanhamento em saúde mental (CAPS); Matrícula dos filhos em creche/escola; Inscrição/atualização no CadÚnico.', '2026-11-16'),
  (28, 135, 1, '2026-08-21', 'Acompanhamento em saúde mental (CAPS); Acesso a moradia (Centro de Acolhida / auxílio aluguel); Regularizar documentação civil.', '2026-11-19'),
  (29, 210, 1, '2026-08-26', 'Regularizar documentação civil; Acesso a moradia (Centro de Acolhida / auxílio aluguel); Regularizar documentação civil.', '2026-11-24'),
  (30, 236, 1, '2026-08-31', 'Requerimento do BPC; Matrícula dos filhos em creche/escola; Acesso a moradia (Centro de Acolhida / auxílio aluguel).', '2026-11-29'),
  (31, 179, 1, '2026-09-04', 'Regularizar documentação civil; Acesso a moradia (Centro de Acolhida / auxílio aluguel); Acesso a moradia (Centro de Acolhida / auxílio aluguel).', '2026-12-03'),
  (32, 37, 3, '2026-09-08', 'Regularizar documentação civil; Acesso a moradia (Centro de Acolhida / auxílio aluguel); Acompanhamento em saúde mental (CAPS).', '2026-12-07'),
  (33, 237, 1, '2026-09-08', 'Inserção em curso profissionalizante; Matrícula dos filhos em creche/escola; Inscrição/atualização no CadÚnico.', '2026-12-07'),
  (34, 27, 3, '2026-09-11', 'Acompanhamento em saúde mental (CAPS); Requerimento do BPC; Inscrição/atualização no CadÚnico.', '2026-12-10'),
  (35, 15, 1, '2026-09-17', 'Reavaliação: Regularizar documentação civil; Acesso a moradia (Centro de Acolhida / auxílio aluguel); Regularizar documentação civil.', '2026-12-16'),
  (36, 20, 3, '2026-09-17', 'Reavaliação: Requerimento do BPC; Matrícula dos filhos em creche/escola; Inscrição/atualização no CadÚnico.', '2026-12-16'),
  (37, 108, 1, '2026-09-28', 'Reavaliação: Acesso a moradia (Centro de Acolhida / auxílio aluguel); Recolocação no mercado de trabalho; Regularizar documentação civil.', '2026-12-27'),
  (38, 234, 1, '2026-09-28', 'Inserção em curso profissionalizante; Regularizar documentação civil; Matrícula dos filhos em creche/escola.', '2026-12-27'),
  (39, 165, 1, '2026-09-30', 'Reavaliação: Matrícula dos filhos em creche/escola; Recolocação no mercado de trabalho; Requerimento do BPC.', '2026-12-29'),
  (40, 31, 3, '2026-10-12', 'Requerimento do BPC; Acompanhamento em saúde mental (CAPS); Inserção em curso profissionalizante.', '2027-01-10'),
  (41, 142, 3, '2026-10-12', 'Acesso a moradia (Centro de Acolhida / auxílio aluguel); Regularizar documentação civil; Inserção em curso profissionalizante.', '2027-01-10'),
  (42, 85, 1, '2026-10-23', 'Regularizar documentação civil; Acesso a moradia (Centro de Acolhida / auxílio aluguel); Regularizar documentação civil.', '2027-01-21');

-- ---------------------------------------------------------------------
-- Entidade 09/10 — entrega_cesta (dicionário 4.9)
-- ---------------------------------------------------------------------
-- ENTREGA_CESTA — Concessão de cestas — prioridade RN06; inclui exceções, duplicidades (A03) e entregas sem triagem (A01)
INSERT INTO entrega_cesta (id_entrega, id_beneficiario, id_profissional, data_entrega, quantidade_cestas, itens_adicionais) VALUES
  (1, 69, 3, '2026-07-01', 1, NULL),
  (2, 115, 4, '2026-07-01', 1, NULL),
  (3, 162, 1, '2026-07-01', 1, 'Kit de higiene'),
  (4, 218, 1, '2026-07-01', 1, NULL),
  (5, 161, 1, '2026-07-02', 1, 'Kit de higiene'),
  (6, 172, 3, '2026-07-02', 1, NULL),
  (7, 79, 3, '2026-07-03', 1, NULL),
  (8, 93, 1, '2026-07-03', 1, 'Hortifrúti (Cidade Invisível)'),
  (9, 151, 1, '2026-07-03', 2, NULL),
  (10, 197, 1, '2026-07-03', 2, NULL),
  (11, 153, 1, '2026-07-06', 1, NULL),
  (12, 199, 1, '2026-07-06', 1, NULL),
  (13, 62, 3, '2026-07-07', 2, NULL),
  (14, 108, 1, '2026-07-07', 1, 'Fraldas'),
  (15, 200, 3, '2026-07-07', 1, 'Material escolar'),
  (16, 89, 3, '2026-07-08', 1, NULL),
  (17, 160, 1, '2026-07-08', 1, 'Hortifrúti (Cidade Invisível)'),
  (18, 166, 1, '2026-07-08', 2, 'Kit de limpeza'),
  (19, 15, 1, '2026-07-09', 1, 'Hortifrúti (Cidade Invisível)'),
  (20, 92, 1, '2026-07-09', 1, NULL),
  (21, 145, 1, '2026-07-09', 1, NULL),
  (22, 163, 1, '2026-07-09', 1, NULL),
  (23, 60, 1, '2026-07-10', 1, NULL),
  (24, 127, 1, '2026-07-13', 2, 'Kit de limpeza'),
  (25, 134, 1, '2026-07-13', 2, NULL),
  (26, 9, 1, '2026-07-14', 2, NULL),
  (27, 130, 3, '2026-07-14', 1, 'Leite em pó'),
  (28, 45, 3, '2026-07-15', 2, NULL),
  (29, 77, 1, '2026-07-15', 1, NULL),
  (30, 90, 1, '2026-07-15', 2, 'Kit de higiene'),
  (31, 125, 1, '2026-07-15', 1, NULL),
  (32, 17, 1, '2026-07-16', 1, NULL),
  (33, 30, 3, '2026-07-16', 1, NULL),
  (34, 209, 1, '2026-07-16', 1, NULL),
  (35, 68, 1, '2026-07-17', 1, NULL),
  (36, 97, 1, '2026-07-17', 2, NULL),
  (37, 191, 3, '2026-07-17', 1, 'Kit de higiene'),
  (38, 224, 1, '2026-07-20', 1, NULL),
  (39, 124, 1, '2026-07-21', 1, 'Leite em pó'),
  (40, 136, 1, '2026-07-21', 2, NULL),
  (41, 31, 3, '2026-07-22', 2, NULL),
  (42, 52, 3, '2026-07-22', 1, 'Hortifrúti (Cidade Invisível)'),
  (43, 113, 1, '2026-07-22', 1, NULL),
  (44, 165, 1, '2026-07-22', 1, NULL),
  (45, 14, 1, '2026-07-23', 1, NULL),
  (46, 178, 1, '2026-07-23', 1, NULL),
  (47, 138, 1, '2026-07-24', 2, NULL),
  (48, 211, 3, '2026-07-24', 1, 'Leite em pó'),
  (49, 73, 3, '2026-07-27', 1, NULL),
  (50, 95, 1, '2026-07-27', 1, NULL),
  (51, 107, 1, '2026-07-27', 1, NULL),
  (52, 174, 3, '2026-07-27', 1, NULL),
  (53, 16, 1, '2026-07-28', 1, 'Material escolar'),
  (54, 82, 1, '2026-07-28', 2, NULL),
  (55, 132, 1, '2026-07-28', 1, NULL),
  (56, 149, 3, '2026-07-28', 2, NULL),
  (57, 128, 1, '2026-07-29', 1, 'Fraldas'),
  (58, 188, 3, '2026-07-29', 1, NULL),
  (59, 189, 1, '2026-07-29', 2, NULL),
  (60, 118, 1, '2026-08-03', 2, 'Material escolar'),
  (61, 154, 1, '2026-08-03', 1, NULL),
  (62, 207, 3, '2026-08-03', 2, NULL),
  (63, 212, 1, '2026-08-03', 1, NULL),
  (64, 104, 3, '2026-08-04', 1, NULL),
  (65, 20, 1, '2026-08-05', 2, 'Kit de limpeza'),
  (66, 116, 3, '2026-08-05', 1, NULL),
  (67, 121, 3, '2026-08-05', 1, NULL),
  (68, 36, 1, '2026-08-06', 1, NULL),
  (69, 214, 1, '2026-08-06', 1, NULL),
  (70, 43, 1, '2026-08-07', 2, NULL),
  (71, 66, 3, '2026-08-07', 1, NULL),
  (72, 167, 3, '2026-08-07', 1, 'Material escolar'),
  (73, 33, 3, '2026-08-10', 2, NULL),
  (74, 86, 3, '2026-08-10', 1, NULL),
  (75, 98, 3, '2026-08-10', 1, NULL),
  (76, 144, 3, '2026-08-10', 1, 'Fraldas'),
  (77, 106, 3, '2026-08-11', 1, 'Hortifrúti (Cidade Invisível)'),
  (78, 156, 3, '2026-08-11', 1, NULL),
  (79, 100, 3, '2026-08-12', 1, 'Kit de higiene'),
  (80, 85, 1, '2026-08-13', 1, NULL),
  (81, 196, 1, '2026-08-13', 1, NULL),
  (82, 230, 1, '2026-08-13', 1, NULL),
  (83, 22, 1, '2026-08-14', 1, NULL),
  (84, 48, 3, '2026-08-14', 1, NULL),
  (85, 122, 1, '2026-08-14', 1, NULL),
  (86, 175, 1, '2026-08-14', 1, NULL),
  (87, 206, 3, '2026-08-14', 2, NULL),
  (88, 215, 1, '2026-08-14', 1, 'Kit de higiene'),
  (89, 54, 3, '2026-08-17', 1, NULL),
  (90, 180, 1, '2026-08-17', 1, NULL),
  (91, 213, 3, '2026-08-17', 1, 'Kit de limpeza'),
  (92, 233, 1, '2026-08-17', 2, NULL),
  (93, 234, 3, '2026-08-17', 1, NULL),
  (94, 88, 1, '2026-08-18', 1, NULL),
  (95, 137, 1, '2026-08-18', 1, NULL),
  (96, 142, 1, '2026-08-18', 2, NULL),
  (97, 229, 3, '2026-08-18', 2, NULL),
  (98, 32, 1, '2026-08-19', 2, 'Pães'),
  (99, 67, 1, '2026-08-19', 2, NULL),
  (100, 75, 1, '2026-08-19', 1, NULL);

INSERT INTO entrega_cesta (id_entrega, id_beneficiario, id_profissional, data_entrega, quantidade_cestas, itens_adicionais) VALUES
  (101, 169, 1, '2026-08-19', 2, NULL),
  (102, 49, 1, '2026-08-20', 1, NULL),
  (103, 171, 1, '2026-08-20', 1, NULL),
  (104, 221, 3, '2026-08-20', 2, 'Kit de limpeza'),
  (105, 42, 1, '2026-08-21', 2, NULL),
  (106, 51, 1, '2026-08-21', 1, NULL),
  (107, 55, 1, '2026-08-21', 1, 'Fraldas'),
  (108, 56, 1, '2026-08-21', 1, NULL),
  (109, 135, 1, '2026-08-21', 1, NULL),
  (110, 177, 1, '2026-08-21', 1, 'Hortifrúti (Cidade Invisível)'),
  (111, 91, 3, '2026-08-24', 1, NULL),
  (112, 131, 1, '2026-08-24', 1, NULL),
  (113, 190, 1, '2026-08-25', 1, NULL),
  (114, 210, 1, '2026-08-26', 1, NULL),
  (115, 226, 1, '2026-08-26', 1, NULL),
  (116, 76, 1, '2026-08-31', 1, NULL),
  (117, 105, 1, '2026-08-31', 2, NULL),
  (118, 217, 3, '2026-08-31', 1, NULL),
  (119, 236, 1, '2026-08-31', 2, NULL),
  (120, 9, 1, '2026-09-01', 2, NULL),
  (121, 127, 3, '2026-09-01', 2, NULL),
  (122, 171, 1, '2026-09-01', 1, 'Hortifrúti (Cidade Invisível)'),
  (123, 153, 3, '2026-09-02', 1, 'Pães'),
  (124, 209, 3, '2026-09-02', 1, NULL),
  (125, 178, 1, '2026-09-04', 1, 'Kit de limpeza'),
  (126, 98, 1, '2026-09-07', 1, NULL),
  (127, 107, 1, '2026-09-07', 1, NULL),
  (128, 34, 1, '2026-09-08', 1, NULL),
  (129, 37, 3, '2026-09-08', 1, NULL),
  (130, 95, 1, '2026-09-08', 1, NULL),
  (131, 123, 3, '2026-09-08', 1, NULL),
  (132, 200, 3, '2026-09-08', 1, 'Kit de higiene'),
  (133, 229, 1, '2026-09-08', 2, NULL),
  (134, 230, 3, '2026-09-09', 1, NULL),
  (135, 119, 1, '2026-09-11', 2, 'Fraldas'),
  (136, 185, 3, '2026-09-11', 1, 'Hortifrúti (Cidade Invisível)'),
  (137, 82, 3, '2026-09-15', 2, NULL),
  (138, 177, 1, '2026-09-15', 1, NULL),
  (139, 17, 1, '2026-09-16', 1, NULL),
  (140, 51, 3, '2026-09-16', 1, NULL),
  (141, 61, 3, '2026-09-16', 1, NULL),
  (142, 116, 1, '2026-09-16', 1, NULL),
  (143, 238, 3, '2026-09-16', 2, NULL),
  (144, 15, 3, '2026-09-17', 1, NULL),
  (145, 20, 1, '2026-09-17', 2, NULL),
  (146, 36, 1, '2026-09-17', 1, NULL),
  (147, 44, 1, '2026-09-17', 1, NULL),
  (148, 138, 1, '2026-09-17', 2, NULL),
  (149, 162, 3, '2026-09-17', 1, 'Leite em pó'),
  (150, 180, 1, '2026-09-17', 1, NULL),
  (151, 124, 3, '2026-09-18', 1, NULL),
  (152, 134, 1, '2026-09-18', 2, NULL),
  (153, 14, 1, '2026-09-21', 1, NULL),
  (154, 118, 1, '2026-09-21', 2, NULL),
  (155, 85, 3, '2026-09-22', 1, NULL),
  (156, 177, 1, '2026-09-22', 1, NULL),
  (157, 90, 1, '2026-09-23', 2, NULL),
  (158, 189, 3, '2026-09-23', 2, NULL),
  (159, 201, 1, '2026-09-23', 1, NULL),
  (160, 213, 3, '2026-09-23', 1, NULL),
  (161, 16, 4, '2026-09-24', 1, NULL),
  (162, 151, 1, '2026-09-24', 2, 'Material escolar'),
  (163, 169, 3, '2026-09-24', 2, 'Pães'),
  (164, 190, 1, '2026-09-24', 1, 'Material escolar'),
  (165, 236, 1, '2026-09-24', 2, 'Fraldas'),
  (166, 63, 1, '2026-09-25', 1, NULL),
  (167, 197, 1, '2026-09-25', 2, NULL),
  (168, 55, 1, '2026-09-28', 1, NULL),
  (169, 188, 1, '2026-09-28', 1, NULL),
  (170, 234, 1, '2026-09-28', 1, NULL),
  (171, 18, 1, '2026-09-29', 1, NULL),
  (172, 181, 1, '2026-09-29', 1, NULL),
  (173, 215, 3, '2026-09-29', 1, 'Pães'),
  (174, 27, 1, '2026-09-30', 2, 'Leite em pó'),
  (175, 165, 3, '2026-09-30', 1, 'Pães'),
  (176, 174, 3, '2026-09-30', 1, 'Leite em pó'),
  (177, 30, 3, '2026-10-01', 1, NULL),
  (178, 58, 3, '2026-10-01', 1, NULL),
  (179, 67, 3, '2026-10-01', 2, NULL),
  (180, 144, 1, '2026-10-01', 1, 'Material escolar'),
  (181, 97, 1, '2026-10-02', 2, NULL),
  (182, 173, 1, '2026-10-05', 1, NULL),
  (183, 216, 1, '2026-10-05', 1, NULL),
  (184, 45, 1, '2026-10-06', 2, NULL),
  (185, 53, 1, '2026-10-06', 1, NULL),
  (186, 104, 1, '2026-10-06', 1, NULL),
  (187, 217, 1, '2026-10-06', 1, 'Hortifrúti (Cidade Invisível)'),
  (188, 206, 1, '2026-10-07', 2, NULL),
  (189, 243, 1, '2026-10-07', 2, NULL),
  (190, 139, 1, '2026-10-08', 1, NULL),
  (191, 154, 1, '2026-10-08', 1, NULL),
  (192, 112, 1, '2026-10-09', 1, NULL),
  (193, 135, 1, '2026-10-09', 1, 'Fraldas'),
  (194, 31, 3, '2026-10-12', 2, 'Kit de limpeza'),
  (195, 142, 3, '2026-10-12', 2, 'Kit de higiene'),
  (196, 246, 3, '2026-10-12', 1, 'Entrega emergencial'),
  (197, 233, 1, '2026-10-13', 2, NULL),
  (198, 59, 3, '2026-10-14', 1, NULL),
  (199, 117, 1, '2026-10-15', 1, NULL),
  (200, 141, 1, '2026-10-15', 1, NULL);

INSERT INTO entrega_cesta (id_entrega, id_beneficiario, id_profissional, data_entrega, quantidade_cestas, itens_adicionais) VALUES
  (201, 152, 3, '2026-10-15', 1, 'Leite em pó'),
  (202, 175, 1, '2026-10-16', 1, NULL),
  (203, 77, 1, '2026-10-19', 1, NULL),
  (204, 104, 1, '2026-10-19', 1, NULL),
  (205, 184, 1, '2026-10-19', 1, 'Material escolar'),
  (206, 214, 3, '2026-10-19', 1, NULL),
  (207, 43, 1, '2026-10-20', 2, NULL),
  (208, 250, 3, '2026-10-20', 1, 'Entrega emergencial'),
  (209, 237, 3, '2026-10-21', 2, 'Material escolar'),
  (210, 166, 1, '2026-10-22', 2, NULL),
  (211, 212, 3, '2026-10-22', 1, 'Kit de higiene'),
  (212, 54, 1, '2026-10-23', 1, NULL),
  (213, 68, 1, '2026-10-23', 1, NULL),
  (214, 86, 1, '2026-10-23', 1, NULL),
  (215, 92, 1, '2026-10-23', 1, NULL),
  (216, 105, 3, '2026-10-23', 2, 'Fraldas'),
  (217, 232, 3, '2026-10-23', 1, NULL),
  (218, 21, 3, '2026-10-26', 1, 'Hortifrúti (Cidade Invisível)'),
  (219, 42, 3, '2026-10-26', 2, NULL),
  (220, 106, 3, '2026-10-26', 1, NULL),
  (221, 122, 1, '2026-10-26', 1, NULL),
  (222, 142, 1, '2026-10-26', 1, NULL),
  (223, 161, 1, '2026-10-27', 1, NULL),
  (224, 240, 3, '2026-10-27', 1, NULL),
  (225, 48, 1, '2026-10-28', 1, NULL),
  (226, 91, 1, '2026-10-28', 1, NULL),
  (227, 131, 3, '2026-10-28', 1, NULL),
  (228, 199, 1, '2026-10-28', 1, 'Leite em pó'),
  (229, 75, 3, '2026-10-29', 1, NULL),
  (230, 241, 1, '2026-10-29', 1, NULL),
  (231, 249, 1, '2026-10-29', 1, 'Kit de higiene'),
  (232, 76, 3, '2026-10-30', 1, NULL),
  (233, 79, 1, '2026-10-30', 1, NULL),
  (234, 88, 1, '2026-10-30', 1, NULL),
  (235, 125, 1, '2026-10-30', 1, NULL),
  (236, 172, 1, '2026-10-30', 1, NULL),
  (237, 221, 3, '2026-10-30', 2, 'Kit de higiene');

-- ---------------------------------------------------------------------
-- Entidade 10/10 — recebimento_doacao (dicionário 4.10)
-- ---------------------------------------------------------------------
-- RECEBIMENTO_DOACAO — Entradas: 2 lotes bimestrais da Prefeitura (150 cestas) + doações esporádicas (RN05)
INSERT INTO recebimento_doacao (id_recebimento, id_profissional, parceiro_doador, data_recebimento, descricao_itens, quantidade_total) VALUES
  (1, 1, 'Prefeitura (lote bimestral)', '2026-07-01', 'Lote bimestral: 150 cestas básicas padronizadas — validade conferida', 150),
  (2, 3, 'Banco de Alimentos', '2026-07-08', 'Arroz, feijão, óleo, macarrão e enlatados (kg) — validade conferida', 320),
  (3, 3, 'Cidade Invisível', '2026-07-10', 'Hortifrúti e pães (kg) — integridade conferida', 45),
  (4, 1, 'Cidade Invisível', '2026-07-22', 'Hortifrúti e pães (kg) — integridade conferida', 80),
  (5, 4, 'Doador particular', '2026-07-22', 'Leite em pó e fraldas (unidades)', 40),
  (6, 1, 'Banco de Alimentos', '2026-08-05', 'Arroz, feijão, óleo, macarrão e enlatados (kg) — validade conferida', 290),
  (7, 3, 'Cidade Invisível', '2026-08-10', 'Hortifrúti e pães (kg) — integridade conferida', 50),
  (8, 4, 'Campanha da paróquia do bairro', '2026-08-17', 'Alimentos não perecíveis (kg) — validade conferida', 180),
  (9, 3, 'Cidade Invisível', '2026-08-20', 'Hortifrúti e pães (kg) — integridade conferida', 90),
  (10, 1, 'Prefeitura (lote bimestral)', '2026-09-01', 'Lote bimestral: 150 cestas básicas padronizadas — validade conferida', 150),
  (11, 1, 'Cidade Invisível', '2026-09-08', 'Hortifrúti e pães (kg) — integridade conferida', 80),
  (12, 1, 'Banco de Alimentos', '2026-09-11', 'Arroz, feijão, óleo, macarrão e enlatados (kg) — validade conferida', 340),
  (13, 1, 'Doador particular', '2026-09-14', 'Kits de higiene (unidades)', 60),
  (14, 1, 'Cidade Invisível', '2026-09-24', 'Hortifrúti e pães (kg) — integridade conferida', 65),
  (15, 3, 'Cidade Invisível', '2026-10-06', 'Hortifrúti e pães (kg) — integridade conferida', 90),
  (16, 1, 'Banco de Alimentos', '2026-10-09', 'Arroz, feijão, óleo, macarrão e enlatados (kg) — validade conferida', 250),
  (17, 4, 'Doador particular', '2026-10-09', 'Material escolar (unidades)', 35),
  (18, 3, 'Campanha da paróquia do bairro', '2026-10-19', 'Alimentos não perecíveis (kg) — validade conferida', 150),
  (19, 1, 'Cidade Invisível', '2026-10-22', 'Hortifrúti e pães (kg) — integridade conferida', 55);

-- Conferência — registros por tabela
-- Esperado: 4 / 250 / 242 / 509 / 261 / 727 / 233 / 42 / 19 / 237
SELECT 'profissional_responsavel'   AS tabela, COUNT(*) AS registros FROM profissional_responsavel
UNION ALL SELECT 'beneficiario',               COUNT(*) FROM beneficiario
UNION ALL SELECT 'trabalho',                   COUNT(*) FROM trabalho
UNION ALL SELECT 'composicao_familiar',        COUNT(*) FROM composicao_familiar
UNION ALL SELECT 'referencia_familiar',        COUNT(*) FROM referencia_familiar
UNION ALL SELECT 'atendimento',                COUNT(*) FROM atendimento
UNION ALL SELECT 'encaminhamento_atendimento', COUNT(*) FROM encaminhamento_atendimento
UNION ALL SELECT 'pia',                        COUNT(*) FROM pia
UNION ALL SELECT 'recebimento_doacao',         COUNT(*) FROM recebimento_doacao
UNION ALL SELECT 'entrega_cesta',              COUNT(*) FROM entrega_cesta;

-- =====================================================================
-- 5, 6 e 7. SELECT COM JOIN · UPDATE E DELETE · CONSULTAS G E A
-- =====================================================================
-- PROBLEMAS (proposta a partir da E1 — conferir/ajustar com o README)
--   P1 Histórico do beneficiário espalhado em fichas de papel: difícil
--      saber o que já foi feito por uma família.
--   P2 Sem controle de quem recebeu cesta e quando: risco de duplicidade
--      e de deixar família prioritária sem cesta.
--   P3 Sem consolidação de doações recebidas x cestas entregues para
--      prestar contas à Prefeitura e aos doadores.
--   P4 Encaminhamentos à rede externa sem registro nem estatística.
--   P5 Planos de acompanhamento (PIA) sem controle do prazo de reavaliação.
--   P6 Dados sensíveis em papel, sem controle de consentimento e de prazo
--      de guarda (LGPD).
--   P7 Relatórios ao CRAS/SAS montados à mão (volume e perfil atendido).
--
-- KPIs (fórmula · período · meta a definir com a ONG)
--   KPI1 Taxa de distribuição do lote = cestas entregues ÷ cestas recebidas
--        da Prefeitura × 100 · bimestral · G02
--   KPI2 Focalização = cestas para famílias prioritárias (RN06) ÷ total de
--        cestas × 100 · bimestral · G04
--   KPI3 Prioritárias sem cesta = nº de famílias prioritárias sem entrega
--        no bimestre · bimestral · G03
--   KPI4 Volume de atendimento = atendimentos, pessoas e novos cadastros
--        por mês · mensal · G05
--   KPI5 Encaminhamentos por rede = nº e % por tipo · no período · G06
--   KPI6 PIAs vencidos = PIAs com reavaliação vencida ÷ PIAs vigentes × 100
--        · na data de referência · G08
--
-- RASTREABILIDADE (problema/KPI -> tabelas -> consulta)
--   P1         beneficiario, atendimento, encaminhamento_atendimento,
--              entrega_cesta, pia ........................... G01, G05
--   P2 KPI2-3  beneficiario, trabalho, entrega_cesta ......... G03, G04,
--                                                              A01-A04
--   P3 KPI1    recebimento_doacao, entrega_cesta ............. G02, G10
--   P4 KPI5    encaminhamento_atendimento, atendimento ....... G06
--   P5 KPI6    pia, beneficiario, profissional_responsavel ... G07, G08
--   P6         beneficiario, atendimento ..................... A05, A06
--   P7 KPI4    beneficiario, composicao_familiar, trabalho,
--              atendimento ................................... G05, G09
--   RN10 RN11  composicao_familiar, referencia_familiar,
--              profissional_responsavel ...................... A07, A08
--
-- Família prioritária (RN06) = CadÚnico ativo E situação "Desempregado(a)".
-- TRABALHO é (0,n): um beneficiário pode ter mais de um registro ao longo
-- do tempo. Como a tabela não tem data, vale o registro MAIS RECENTE
-- (maior id_trabalho). As consultas abaixo leem sempre esse registro, para
-- não duplicar linhas no JOIN nem usar uma situação de trabalho antiga.
-- =====================================================================

-- As chaves estrangeiras são verificadas automaticamente pelo MySQL.

-- ---------------------------------------------------------------------
-- PARÂMETROS DOS RELATÓRIOS — o MySQL não tem variáveis, então as datas
-- estão escritas direto nas consultas:
--   '2026-10-31' = data de referência (fim do período da massa)
--   '2026-07-01' = início do período operacional (2 bimestres)
--   '2026-09-01' = início do bimestre de referência (set-out)
-- ---------------------------------------------------------------------


-- =====================================================================
-- 5. SELECT COM JOIN
-- =====================================================================

-- 5.1 — Quem foi atendido em 28/10/2026 e por qual profissional?
SELECT a.id_atendimento,
       b.nome_completo          AS beneficiario,
       p.nome                   AS profissional,
       p.registro_profissional,
       a.demanda_inicial
FROM atendimento a
JOIN beneficiario b             ON b.id_beneficiario = a.id_beneficiario
JOIN profissional_responsavel p ON p.id_profissional = a.id_profissional
WHERE a.data_atendimento = '2026-10-28'
ORDER BY a.id_atendimento;

-- 5.2 — Quem mora com Fernanda Carvalho Ribeiro e quem são os contatos de emergência?
SELECT b.nome_completo AS titular, 'Mora junto' AS vinculo, cf.nome,
       cf.parentesco_vinculo AS parentesco, cf.idade, NULL AS telefone
FROM beneficiario b
JOIN composicao_familiar cf ON cf.id_beneficiario = b.id_beneficiario
WHERE b.id_beneficiario = 48
UNION ALL
SELECT b.nome_completo, 'Referência', rf.nome,
       rf.parentesco_vinculo, NULL, rf.telefone
FROM beneficiario b
JOIN referencia_familiar rf ON rf.id_beneficiario = b.id_beneficiario
WHERE b.id_beneficiario = 48
ORDER BY vinculo, nome;

-- 5.3 — Quais cestas saíram na última semana de outubro, para quem e quem registrou?
SELECT e.data_entrega,
       b.nome_completo                               AS beneficiario,
       e.quantidade_cestas,
       e.itens_adicionais,
       COALESCE(t.situacao_ocupacional, 'Sem registro') AS situacao_ocupacional,
       p.nome                                        AS registrado_por
FROM entrega_cesta e
JOIN beneficiario b             ON b.id_beneficiario = e.id_beneficiario
JOIN profissional_responsavel p ON p.id_profissional = e.id_profissional
LEFT JOIN trabalho t            ON t.id_trabalho = (SELECT MAX(t2.id_trabalho) FROM trabalho t2
                                                    WHERE t2.id_beneficiario = b.id_beneficiario)
WHERE e.data_entrega BETWEEN '2026-10-26' AND '2026-10-30'
ORDER BY e.data_entrega, b.nome_completo;


-- =====================================================================
-- 6. UPDATE E DELETE
--    Cada operação mostra o registro ANTES e DEPOIS.
-- =====================================================================

-- 6.1 UPDATE — a família 41 atualizou o CadÚnico no CRAS e trocou de telefone.
--     (era um dos casos da auditoria A04; os demais continuam aparecendo lá)
SELECT id_beneficiario, nome_completo, telefone, data_atualizacao_cadunico
FROM beneficiario WHERE id_beneficiario = 41;

UPDATE beneficiario
   SET data_atualizacao_cadunico = '2026-10-29',
       telefone = '(11) 91234-0000'
 WHERE id_beneficiario = 41;

SELECT id_beneficiario, nome_completo, telefone, data_atualizacao_cadunico
FROM beneficiario WHERE id_beneficiario = 41;

-- 6.2 UPDATE — o PIA 1 estava vencido; foi reavaliado e ganhou novo prazo (RN04).
SELECT id_pia, id_beneficiario, data_criacao, prazo_reavaliacao FROM pia WHERE id_pia = 1;

UPDATE pia
   SET prazo_reavaliacao = '2027-01-29',
       metas_objetivos   = CONCAT(metas_objetivos, ' Reavaliado em 29/10/2026.')
 WHERE id_pia = 1;

SELECT id_pia, id_beneficiario, data_criacao, prazo_reavaliacao, metas_objetivos FROM pia WHERE id_pia = 1;

-- 6.3 UPDATE — RN07: anonimização do cadastro 3, sem atendimento há mais de
--     5 anos. Os dados pessoais saem; o histórico fica para os relatórios.
--     Sai: identificação direta, dados sensíveis, naturalidade e os dados
--     do empregador; a data de nascimento fica só com o ano (AAAA-01-01),
--     o que ainda permite a faixa etária nos relatórios (RN08).
--     (os demais cadastros nessa situação aparecem na auditoria A05)
SELECT id_beneficiario, nome_completo, cpf, data_nascimento, naturalidade, endereco, situacao_cadastro
FROM beneficiario WHERE id_beneficiario = 3;

UPDATE beneficiario
   SET nome_completo = CONCAT('ANONIMIZADO-', id_beneficiario),
       nome_social = NULL, nis = NULL, cpf = NULL,
       rg_numero = NULL, rg_orgao_uf_emissor = NULL, rg_data_emissao = NULL,
       data_nascimento = STR_TO_DATE(CONCAT(YEAR(data_nascimento), '-01-01'), '%Y-%m-%d'),
       naturalidade = NULL,
       endereco = 'ANONIMIZADO', cep = NULL, telefone = NULL,
       nome_mae = NULL, nome_pai = NULL, orientacao_sexual = NULL, cor_raca = NULL,
       pessoa_com_deficiencia = NULL, tem_alergias = NULL,
       situacao_cadastro = 'ANONIMIZADO'
 WHERE id_beneficiario = 3;

UPDATE trabalho            SET empresa_trabalho = NULL, telefone_trabalho = NULL WHERE id_beneficiario = 3;
UPDATE composicao_familiar SET nome = 'ANONIMIZADO', nome_social = NULL WHERE id_beneficiario = 3;
UPDATE referencia_familiar SET nome = 'ANONIMIZADO', nome_social = NULL, telefone = NULL WHERE id_beneficiario = 3;

SELECT b.id_beneficiario, b.nome_completo, b.cpf, b.data_nascimento, b.naturalidade, b.endereco, b.situacao_cadastro,
       (SELECT COUNT(*) FROM atendimento a WHERE a.id_beneficiario = b.id_beneficiario) AS atendimentos_mantidos
FROM beneficiario b WHERE b.id_beneficiario = 3;

-- 6.4 DELETE — o encaminhamento 222 foi lançado em duplicidade
--     (mesmo atendimento, mesmo tipo). Antes: 2 linhas iguais; depois: 1.
SELECT * FROM encaminhamento_atendimento WHERE id_atendimento = 675;

DELETE FROM encaminhamento_atendimento WHERE id_encaminhamento = 222;

SELECT * FROM encaminhamento_atendimento WHERE id_atendimento = 675;

-- 6.5 DELETE — a referência familiar 258 pediu para não ser mais contato.
SELECT * FROM referencia_familiar WHERE id_beneficiario = 248;

DELETE FROM referencia_familiar WHERE id_referencia = 258;

SELECT * FROM referencia_familiar WHERE id_beneficiario = 248;

-- 6.6 DELETE bloqueado de propósito — descomente para ver o erro de FK:
--     um beneficiário com histórico NÃO pode ser apagado (ON DELETE RESTRICT);
--     o caminho correto é a anonimização (6.3).
-- DELETE FROM beneficiario WHERE id_beneficiario = 48;


-- =====================================================================
-- 7. CONSULTAS GERENCIAIS (G) E DE AUDITORIA (A)
-- =====================================================================

-- G01 — Qual é o histórico completo da família de CPF 717.741.964-48?
-- Atende: P1 (histórico espalhado em fichas de papel) · RF06
SELECT a.data_atendimento AS data_evento, 'Atendimento' AS evento,
       a.demanda_inicial AS detalhe, p.nome AS profissional
FROM atendimento a
JOIN beneficiario b             ON b.id_beneficiario = a.id_beneficiario
JOIN profissional_responsavel p ON p.id_profissional = a.id_profissional
WHERE b.cpf = '717.741.964-48'
UNION ALL
SELECT a.data_atendimento, 'Encaminhamento',
       CONCAT(ea.tipo_encaminhamento, COALESCE(CONCAT(' — ', ea.detalhe_outros), '')), p.nome
FROM encaminhamento_atendimento ea
JOIN atendimento a              ON a.id_atendimento = ea.id_atendimento
JOIN beneficiario b             ON b.id_beneficiario = a.id_beneficiario
JOIN profissional_responsavel p ON p.id_profissional = a.id_profissional
WHERE b.cpf = '717.741.964-48'
UNION ALL
SELECT e.data_entrega, 'Cesta básica',
       CONCAT(e.quantidade_cestas, ' cesta(s)', COALESCE(CONCAT(' + ', e.itens_adicionais), '')), p.nome
FROM entrega_cesta e
JOIN beneficiario b             ON b.id_beneficiario = e.id_beneficiario
JOIN profissional_responsavel p ON p.id_profissional = e.id_profissional
WHERE b.cpf = '717.741.964-48'
UNION ALL
SELECT x.data_criacao, 'PIA', x.metas_objetivos, p.nome
FROM pia x
JOIN beneficiario b             ON b.id_beneficiario = x.id_beneficiario
JOIN profissional_responsavel p ON p.id_profissional = x.id_profissional
WHERE b.cpf = '717.741.964-48'
ORDER BY data_evento, evento;

-- G02 — Quanto do lote da Prefeitura foi distribuído em cada bimestre?
-- Atende: P3 (prestação de contas de doações x entregas) · KPI1 Taxa de distribuição
-- (B4 = jul-ago, B5 = set-out; acima de 100% = cestas montadas com doações avulsas)
SELECT r.bimestre,
       r.cestas_recebidas,
       COALESCE(e.cestas_entregues, 0)   AS cestas_entregues,
       COALESCE(e.familias_atendidas, 0) AS familias_atendidas,
       ROUND(100.0 * COALESCE(e.cestas_entregues, 0) / r.cestas_recebidas, 1) AS taxa_distribuicao_pct
FROM (SELECT CONCAT(YEAR(data_recebimento), '-B', CEIL(MONTH(data_recebimento) / 2)) AS bimestre,
             SUM(quantidade_total) AS cestas_recebidas
      FROM recebimento_doacao
      WHERE parceiro_doador LIKE 'Prefeitura%'
      GROUP BY bimestre) r
LEFT JOIN (SELECT CONCAT(YEAR(data_entrega), '-B', CEIL(MONTH(data_entrega) / 2)) AS bimestre,
                  SUM(quantidade_cestas)          AS cestas_entregues,
                  COUNT(DISTINCT id_beneficiario) AS familias_atendidas
           FROM entrega_cesta
           GROUP BY bimestre) e ON e.bimestre = r.bimestre
ORDER BY r.bimestre;

-- G03 — Quais famílias prioritárias ainda não receberam cesta no bimestre set-out?
-- Atende: P2 (família prioritária sem cesta) · KPI3 · RN06
SELECT b.id_beneficiario,
       b.nome_completo,
       b.telefone,
       b.bairro,
       1 + (SELECT COUNT(*) FROM composicao_familiar cf
             WHERE cf.id_beneficiario = b.id_beneficiario) AS pessoas_na_familia,
       (SELECT MAX(e.data_entrega) FROM entrega_cesta e
         WHERE e.id_beneficiario = b.id_beneficiario)       AS ultima_cesta
FROM beneficiario b
WHERE b.situacao_cadastro = 'ATIVO'
  AND b.cadunico_ativo = 1
  AND COALESCE((SELECT t.situacao_ocupacional FROM trabalho t
                 WHERE t.id_beneficiario = b.id_beneficiario
                 ORDER BY t.id_trabalho DESC LIMIT 1), '') LIKE 'Desempregad%'
  AND NOT EXISTS (SELECT 1 FROM entrega_cesta e
                   WHERE e.id_beneficiario = b.id_beneficiario
                     AND e.data_entrega BETWEEN '2026-09-01' AND '2026-10-31')
ORDER BY pessoas_na_familia DESC, b.nome_completo;

-- G04 — Que parte das cestas foi para famílias prioritárias em cada bimestre?
-- Atende: P2 (focalização dos recursos) · KPI2 Focalização · RN06
SELECT bimestre,
       SUM(quantidade_cestas) AS cestas_entregues,
       SUM(CASE WHEN prioritaria = 1 THEN quantidade_cestas ELSE 0 END) AS cestas_prioritarias,
       ROUND(100.0 * SUM(CASE WHEN prioritaria = 1 THEN quantidade_cestas ELSE 0 END)
             / SUM(quantidade_cestas), 1) AS focalizacao_pct
FROM (SELECT CONCAT(YEAR(e.data_entrega), '-B', CEIL(MONTH(e.data_entrega) / 2)) AS bimestre,
             e.quantidade_cestas,
             CASE WHEN b.cadunico_ativo = 1
                   AND COALESCE((SELECT t.situacao_ocupacional FROM trabalho t
                                  WHERE t.id_beneficiario = b.id_beneficiario
                                  ORDER BY t.id_trabalho DESC LIMIT 1), '') LIKE 'Desempregad%'
                  THEN 1 ELSE 0 END AS prioritaria
      FROM entrega_cesta e
      JOIN beneficiario b ON b.id_beneficiario = e.id_beneficiario
      WHERE e.data_entrega BETWEEN '2026-07-01' AND '2026-10-31') x
GROUP BY bimestre
ORDER BY bimestre;

-- G05 — Quantos atendimentos, pessoas e novos cadastros houve por mês?
-- Atende: P7 (relatório CRAS/SAS) e P1 · KPI4 Volume de atendimento · RN08
SELECT DATE_FORMAT(a.data_atendimento, '%Y-%m') AS mes,
       COUNT(*)                          AS atendimentos,
       COUNT(DISTINCT a.id_beneficiario) AS pessoas_atendidas,
       COUNT(DISTINCT CASE WHEN a.data_atendimento = f.primeiro
                           THEN a.id_beneficiario END) AS novos_cadastros
FROM atendimento a
JOIN (SELECT id_beneficiario, MIN(data_atendimento) AS primeiro
      FROM atendimento GROUP BY id_beneficiario) f ON f.id_beneficiario = a.id_beneficiario
WHERE a.data_atendimento BETWEEN '2026-07-01' AND '2026-10-31'
GROUP BY mes
ORDER BY mes;

-- G06 — Para quais redes externas a ONG mais encaminhou no período?
-- Atende: P4 (encaminhamentos sem estatística) · KPI5
SELECT ea.tipo_encaminhamento,
       COUNT(*) AS encaminhamentos,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*)
                                  FROM encaminhamento_atendimento ea2
                                  JOIN atendimento a2 ON a2.id_atendimento = ea2.id_atendimento
                                  WHERE a2.data_atendimento BETWEEN '2026-07-01' AND '2026-10-31'), 1) AS pct_do_total
FROM encaminhamento_atendimento ea
JOIN atendimento a ON a.id_atendimento = ea.id_atendimento
WHERE a.data_atendimento BETWEEN '2026-07-01' AND '2026-10-31'
GROUP BY ea.tipo_encaminhamento
ORDER BY encaminhamentos DESC, ea.tipo_encaminhamento;

-- G07 — Quais PIAs estão com a reavaliação vencida, e há quantos dias?
-- Atende: P5 (PIA sem controle de prazo) · RN04
SELECT b.id_beneficiario,
       b.nome_completo,
       x.data_criacao,
       x.prazo_reavaliacao,
       DATEDIFF('2026-10-31', x.prazo_reavaliacao) AS dias_em_atraso,
       p.nome AS profissional_responsavel
FROM pia x
JOIN beneficiario b             ON b.id_beneficiario = x.id_beneficiario
JOIN profissional_responsavel p ON p.id_profissional = x.id_profissional
WHERE b.situacao_cadastro = 'ATIVO'
  AND x.prazo_reavaliacao < '2026-10-31'
  AND x.data_criacao = (SELECT MAX(x2.data_criacao) FROM pia x2
                         WHERE x2.id_beneficiario = x.id_beneficiario)
ORDER BY dias_em_atraso DESC;

-- G08 — Qual o percentual de PIAs vigentes com reavaliação vencida?
-- Atende: P5 · KPI6 PIAs vencidos · RN04
SELECT COUNT(*) AS pias_vigentes,
       SUM(CASE WHEN x.prazo_reavaliacao < '2026-10-31' THEN 1 ELSE 0 END) AS pias_vencidos,
       ROUND(100.0 * SUM(CASE WHEN x.prazo_reavaliacao < '2026-10-31' THEN 1 ELSE 0 END)
             / COUNT(*), 1) AS pct_vencidos
FROM pia x
JOIN beneficiario b ON b.id_beneficiario = x.id_beneficiario
WHERE b.situacao_cadastro = 'ATIVO'
  AND x.data_criacao = (SELECT MAX(x2.data_criacao) FROM pia x2
                         WHERE x2.id_beneficiario = x.id_beneficiario);

-- G09 — Qual o perfil das famílias ativas por faixa etária do titular?
-- Atende: P7 (relatório de perfil ao CRAS/SAS) · RN08 (dados agregados, sem identificação)
SELECT CASE WHEN idade < 30 THEN '18 a 29'
            WHEN idade < 45 THEN '30 a 44'
            WHEN idade < 60 THEN '45 a 59'
            ELSE '60 ou mais' END                         AS faixa_etaria_titular,
       COUNT(*)                                           AS familias,
       SUM(pessoas)                                       AS pessoas,
       ROUND(AVG(pessoas), 1)                             AS media_pessoas_por_familia,
       ROUND(100.0 * SUM(cadunico_ativo) / COUNT(*), 1)   AS pct_cadunico_ativo,
       ROUND(100.0 * SUM(desempregado) / COUNT(*), 1)     AS pct_desempregados
FROM (SELECT b.cadunico_ativo,
             TIMESTAMPDIFF(YEAR, b.data_nascimento, '2026-10-31') AS idade,
             1 + (SELECT COUNT(*) FROM composicao_familiar cf
                   WHERE cf.id_beneficiario = b.id_beneficiario) AS pessoas,
             CASE WHEN COALESCE((SELECT t.situacao_ocupacional FROM trabalho t
                                  WHERE t.id_beneficiario = b.id_beneficiario
                                  ORDER BY t.id_trabalho DESC LIMIT 1), '') LIKE 'Desempregad%'
                  THEN 1 ELSE 0 END AS desempregado
      FROM beneficiario b
      WHERE b.situacao_cadastro = 'ATIVO') perfil
GROUP BY faixa_etaria_titular
ORDER BY faixa_etaria_titular;

-- G10 — Quanto cada parceiro doou por mês?
-- Atende: P3 (prestação de contas aos doadores) · RN08
-- (a unidade depende do parceiro: cestas, kg ou unidades — ver descricao_itens)
SELECT DATE_FORMAT(r.data_recebimento, '%Y-%m') AS mes,
       r.parceiro_doador,
       COUNT(*)                AS recebimentos,
       SUM(r.quantidade_total) AS quantidade
FROM recebimento_doacao r
WHERE r.data_recebimento BETWEEN '2026-07-01' AND '2026-10-31'
GROUP BY mes, r.parceiro_doador
ORDER BY mes, quantidade DESC;

-- A01 — Existe cesta entregue sem triagem (atendimento) anterior?
-- Verifica: RN03 (triagem obrigatória antes de qualquer auxílio)
SELECT e.id_entrega,
       e.data_entrega,
       b.id_beneficiario,
       b.nome_completo,
       (SELECT MIN(a.data_atendimento) FROM atendimento a
         WHERE a.id_beneficiario = e.id_beneficiario) AS primeira_triagem,
       p.nome AS registrado_por
FROM entrega_cesta e
JOIN beneficiario b             ON b.id_beneficiario = e.id_beneficiario
JOIN profissional_responsavel p ON p.id_profissional = e.id_profissional
WHERE NOT EXISTS (SELECT 1 FROM atendimento a
                   WHERE a.id_beneficiario = e.id_beneficiario
                     AND a.data_atendimento <= e.data_entrega)
ORDER BY e.data_entrega;

-- A02 — Quais cestas do bimestre set-out foram para famílias fora do critério prioritário?
-- Verifica: RN06 (exceções precisam de avaliação da assistente social)
SELECT e.id_entrega,
       e.data_entrega,
       b.nome_completo,
       b.cadunico_ativo,
       COALESCE((SELECT t.situacao_ocupacional FROM trabalho t
                  WHERE t.id_beneficiario = b.id_beneficiario
                  ORDER BY t.id_trabalho DESC LIMIT 1), 'Sem registro') AS situacao_ocupacional,
       p.nome AS autorizado_por
FROM entrega_cesta e
JOIN beneficiario b             ON b.id_beneficiario = e.id_beneficiario
JOIN profissional_responsavel p ON p.id_profissional = e.id_profissional
WHERE e.data_entrega BETWEEN '2026-09-01' AND '2026-10-31'
  AND NOT (b.cadunico_ativo = 1
           AND COALESCE((SELECT t.situacao_ocupacional FROM trabalho t
                          WHERE t.id_beneficiario = b.id_beneficiario
                          ORDER BY t.id_trabalho DESC LIMIT 1), '') LIKE 'Desempregad%')
ORDER BY e.data_entrega, b.nome_completo;

-- A03 — Alguma família recebeu mais de uma cesta no mesmo mês?
-- Verifica: RN06 (controle de duplicidade na entrega de auxílios)
SELECT b.id_beneficiario,
       b.nome_completo,
       DATE_FORMAT(e.data_entrega, '%Y-%m') AS mes,
       COUNT(*)                  AS entregas_no_mes,
       SUM(e.quantidade_cestas)  AS cestas_no_mes
FROM entrega_cesta e
JOIN beneficiario b ON b.id_beneficiario = e.id_beneficiario
GROUP BY b.id_beneficiario, b.nome_completo, mes
HAVING COUNT(*) > 1
ORDER BY mes, b.nome_completo;

-- A04 — Quem está com CadÚnico "ativo" mas sem atualização há mais de 24 meses?
-- Verifica: RN06 (CadÚnico ativo E atualizado; a atualização vale por 24 meses)
SELECT b.id_beneficiario,
       b.nome_completo,
       b.nis,
       b.data_atualizacao_cadunico,
       DATEDIFF('2026-10-31', b.data_atualizacao_cadunico) AS dias_sem_atualizar
FROM beneficiario b
WHERE b.situacao_cadastro = 'ATIVO'
  AND b.cadunico_ativo = 1
  AND (b.data_atualizacao_cadunico IS NULL
       OR b.data_atualizacao_cadunico < DATE_SUB('2026-10-31', INTERVAL 24 MONTH))
ORDER BY b.data_atualizacao_cadunico;

-- A05 — Há cadastros sem atendimento há mais de 5 anos que ainda não foram anonimizados?
-- Verifica: RN07 (retenção de 5 anos e anonimização)
SELECT b.id_beneficiario,
       b.nome_completo,
       b.situacao_cadastro,
       MAX(a.data_atendimento) AS ultimo_atendimento
FROM beneficiario b
JOIN atendimento a ON a.id_beneficiario = b.id_beneficiario
WHERE b.situacao_cadastro = 'ATIVO'
GROUP BY b.id_beneficiario, b.nome_completo, b.situacao_cadastro
HAVING MAX(a.data_atendimento) < DATE_SUB('2026-10-31', INTERVAL 5 YEAR)
ORDER BY ultimo_atendimento;

-- A06 — Algum consentimento LGPD foi registrado depois do primeiro atendimento?
-- Verifica: RN07 (consentimento expresso antes da coleta de dados)
SELECT b.id_beneficiario,
       b.nome_completo,
       b.data_consentimento,
       MIN(a.data_atendimento) AS primeiro_atendimento
FROM beneficiario b
JOIN atendimento a ON a.id_beneficiario = b.id_beneficiario
GROUP BY b.id_beneficiario, b.nome_completo, b.data_consentimento
HAVING b.data_consentimento > MIN(a.data_atendimento)
ORDER BY b.id_beneficiario;

-- A07 — Alguma família passou do limite de 5 membros ou de 3 referências?
-- Verifica: RN10 (limite estrutural da ficha; validado no backend)
SELECT b.id_beneficiario, b.nome_completo,
       'Composição familiar' AS cadastro, COUNT(*) AS registros, 5 AS limite
FROM composicao_familiar cf
JOIN beneficiario b ON b.id_beneficiario = cf.id_beneficiario
GROUP BY b.id_beneficiario, b.nome_completo
HAVING COUNT(*) > 5
UNION ALL
SELECT b.id_beneficiario, b.nome_completo,
       'Referência familiar', COUNT(*), 3
FROM referencia_familiar rf
JOIN beneficiario b ON b.id_beneficiario = rf.id_beneficiario
GROUP BY b.id_beneficiario, b.nome_completo
HAVING COUNT(*) > 3;

-- A08 — Algum registro foi feito por quem não tem CRESS ou CRP?
-- Verifica: RN11 (profissional habilitado responsável por cada registro)
SELECT p.nome,
       p.funcao,
       p.registro_profissional,
       r.tipo_registro,
       COUNT(*) AS registros
FROM (SELECT id_profissional, 'Atendimento' AS tipo_registro FROM atendimento
      UNION ALL SELECT id_profissional, 'PIA' FROM pia
      UNION ALL SELECT id_profissional, 'Entrega de cesta' FROM entrega_cesta
      UNION ALL SELECT id_profissional, 'Recebimento de doação' FROM recebimento_doacao) r
JOIN profissional_responsavel p ON p.id_profissional = r.id_profissional
WHERE p.registro_profissional NOT LIKE 'CRESS%'
  AND p.registro_profissional NOT LIKE 'CRP%'
GROUP BY p.nome, p.funcao, p.registro_profissional, r.tipo_registro
ORDER BY p.nome, r.tipo_registro;
