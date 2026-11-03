USE ong_nossa_senhora_fatima;
SET NAMES utf8mb4;

-- ==========================================
-- 4.0 LIMPEZA (Esvazia as tabelas para recarga)
-- ==========================================
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE recebimento_doacao;
TRUNCATE TABLE entrega_cesta;
TRUNCATE TABLE pia;
TRUNCATE TABLE encaminhamento_atendimento;
TRUNCATE TABLE atendimento;
TRUNCATE TABLE referencia_familiar;
TRUNCATE TABLE composicao_familiar;
TRUNCATE TABLE trabalho;
TRUNCATE TABLE beneficiario;
TRUNCATE TABLE profissional_responsavel;
SET FOREIGN_KEY_CHECKS = 1;

-- ==========================================
-- 4.1 PROFISSIONAL RESPONSAVEL
-- ==========================================
INSERT INTO profissional_responsavel (id_profissional, nome, funcao, registro_profissional) VALUES
(1, 'Ana Paula Ribeiro', 'Assistente Social', 'CRESS-SP 90001'),
(2, 'Carlos Eduardo Lima', 'Psicólogo (voluntário)', 'CRP 06/90002'),
(3, 'Fernanda Souza Alves', 'Assistente Social (voluntária)', 'CRESS-SP 90003'),
(4, 'Roberto Almeida Nogueira', 'Presidente', 'SEM REGISTRO - Presidência');

-- ==========================================
-- 4.2 BENEFICIARIO (Registros 1 a 50)
-- ==========================================
INSERT INTO beneficiario (id_beneficiario, nis, cras_creas_sas, nome_completo, nome_social, sexo, raca_cor, data_nascimento, naturalidade) VALUES
(1, NULL, 'CRAS Mooca', 'ANONIMIZADO-1', NULL, 'M', NULL, '1943-01-01', NULL),
(2, NULL, 'CRAS Mooca', 'ANONIMIZADO-2', NULL, 'F', NULL, '1968-01-01', NULL),
(3, '15115567817', 'CREAS Mooca', 'Jéssica Araújo Soares', NULL, 'F', NULL, '1987-04-12', NULL),
(4, '12320246721', 'CRAS Mooca', 'Francisco Rodrigues Vieira', NULL, 'M', NULL, '1974-06-15', NULL),
(5, '24916769617', 'CRAS Mooca', 'Ana Machado Freitas', NULL, 'F', NULL, '1965-02-20', NULL),
(6, '20693157929', 'CREAS Mooca', 'Juliana Nunes Moreira', NULL, 'F', NULL, '1982-11-05', NULL),
(7, '27416774501', 'CRAS Mooca', 'Cristiane de Lima Santos', NULL, 'F', NULL, '1971-10-14', NULL),
(8, '14513467618', 'CRAS Mooca', 'Maria da Silva Barbosa', NULL, 'F', NULL, '1978-09-03', NULL),
(9, '15804549125', NULL, 'Fernanda Lima Moura', NULL, 'F', NULL, '1998-01-27', NULL),
(10, NULL, 'CRAS Belém', 'Débora Nunes Gomes', NULL, 'M', NULL, '1953-05-09', NULL),
(11, NULL, 'CREAS Mooca', 'Adilson Gonçalves Machado', NULL, 'M', NULL, '1962-09-21', NULL),
(12, '19204999309', NULL, 'Fernanda Rocha Pereira', NULL, 'F', NULL, '1989-12-01', NULL),
(13, NULL, NULL, 'Daniela Carvalho Soares', NULL, 'F', 'Prefere não informar', '1976-08-11', NULL),
(14, '14402501210', 'CRAS Mooca', 'Ana Alves Rocha', NULL, 'F', 'Prefere não informar', '1980-03-05', NULL),
(15, NULL, 'CRAS Mooca', 'Luciana Santana Brito', NULL, 'F', NULL, '1969-05-10', NULL),
(16, '28402410969', 'CRAS Mooca', 'Josefa de Freitas Ferreira', NULL, 'F', NULL, '1975-01-18', NULL),
(17, '21711229032', 'CRAS Mooca', 'José Cardoso Dias', NULL, 'M', NULL, '1985-07-22', NULL),
(18, '15637089228', NULL, 'Silvana Monteiro Gomes', NULL, 'F', NULL, '1951-02-14', NULL),
(19, NULL, 'CRAS Belém', 'Anderson Mendes Lima', NULL, 'M', NULL, '1995-06-19', NULL),
(20, '13422054246', 'CRAS Belém', 'Larissa Martins Cardoso', NULL, 'F', NULL, '1988-04-03', NULL),
(21, '11807902698', NULL, 'João Araújo Martins', NULL, 'M', 'Prefere não informar', '1992-09-12', NULL),
(22, '21183082343', 'CRAS Mooca', 'Carlos Araújo Correia', NULL, 'M', 'Prefere não informar', '1981-11-30', NULL),
(23, NULL, 'CRAS Mooca', 'Patricia Rocha Ribeiro', NULL, 'F', NULL, '1954-08-23', NULL),
(24, '17847745876', 'CRAS Belém', 'Carlos Teixeira Silva', NULL, 'M', NULL, '1979-12-04', NULL),
(25, NULL, 'CRAS Mooca', 'Aline Silva Ribeiro', NULL, 'F', NULL, '1983-05-22', NULL),
(26, '19394255100', 'CREAS Mooca', 'Wellington Ramos Souza', NULL, 'M', NULL, '1977-03-17', NULL),
(27, NULL, 'CRAS Mooca', 'Juliana Santos Pereira', NULL, 'F', NULL, '1996-10-02', NULL),
(28, '18648579527', 'CRAS Mooca', 'Rita Ramos Cardoso', NULL, 'F', 'Prefere não informar', '1964-07-19', NULL),
(29, NULL, 'CRAS Belém', 'Ivone Barbosa Pinto', NULL, 'F', NULL, '1996-10-11', NULL),
(30, '28328369955', 'CRAS Mooca', 'Rosângela Moreira Rocha', NULL, 'F', NULL, '1984-01-25', NULL),
(31, '28728659363', 'CRAS Belém', 'Rodrigo Ramos Fernandes', NULL, 'M', NULL, '1997-05-10', NULL),
(32, NULL, 'CRAS Belém', 'Michele Cardoso Nunes', NULL, 'F', NULL, '1989-08-14', NULL),
(33, NULL, 'CRAS Mooca', 'Juliana Fernandes Farias', NULL, 'F', 'Prefere não informar', '1982-06-03', NULL),
(34, NULL, 'CRAS Belém', 'Renata Cavalcanti Moreira', NULL, 'F', NULL, '1977-09-09', NULL),
(35, '23886241882', NULL, 'Rodrigo Ramos Cardoso', NULL, 'M', NULL, '1967-08-19', NULL),
(36, NULL, 'CRAS Belém', 'Paulo de Freitas Almeida', NULL, 'M', NULL, '1969-08-11', NULL),
(37, NULL, 'CRAS Mooca', 'Valdir Martins Rodrigues', NULL, 'M', NULL, '1997-11-28', NULL),
(38, '19672472511', 'CRAS Mooca', 'Gabriel Marques Cavalcanti', NULL, 'M', 'Prefere não informar', '1990-02-15', NULL),
(39, '28312050957', 'CRAS Belém', 'Michele Mendes Correia', NULL, 'F', 'Prefere não informar', '1985-05-02', NULL),
(40, '19387289180', 'CRAS Mooca', 'Silvana Ribeiro Rodrigues', NULL, 'F', NULL, '1973-04-18', NULL),
(41, NULL, NULL, 'Bruna Ferreira Lima', NULL, 'F', NULL, '1965-04-10', 'Montes Claros'),
(42, '17861536763', 'CRAS Belém', 'Cicero Pereira Gomes', NULL, 'M', NULL, '1991-09-24', NULL),
(43, NULL, 'CRAS Mooca', 'Larissa Teixeira Lopes', NULL, 'F', NULL, '2000-07-09', NULL),
(44, NULL, 'CREAS Mooca', 'Regina Dias Andrade', NULL, 'F', NULL, '1949-12-03', NULL),
(45, '15591502066', 'CRAS Belém', 'Bruna Souza Santana', NULL, 'F', NULL, '1963-01-29', NULL),
(46, '19456551473', 'CRAS Mooca', 'Tatiane Gomes Souza', NULL, 'F', NULL, '1963-06-11', NULL),
(47, '16306130803', 'CRAS Mooca', 'Bruna Cavalcanti Alves', NULL, 'F', NULL, '1962-08-01', NULL),
(48, '26391679132', 'CRAS Belém', 'Fernanda Carvalho Ribeiro', NULL, 'F', NULL, '1987-12-19', NULL),
(49, '28103451119', 'CRAS Mooca', 'Francisca Ramos Freitas', NULL, 'F', NULL, '1985-11-04', NULL),
(50, NULL, 'CRAS Mooca', 'Thiago de Lima Pereira', NULL, 'M', NULL, '1979-04-17', NULL);
