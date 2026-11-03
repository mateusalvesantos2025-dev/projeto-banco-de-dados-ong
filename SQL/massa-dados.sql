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
-- ==========================================
-- 4.2 BENEFICIARIO (Continuação - Registros 51 a 100)
-- ==========================================
INSERT INTO beneficiario (id_beneficiario, nis, cras_creas_sas, nome_completo, nome_social, sexo, raca_cor, data_nascimento, naturalidade, endereco_cep, logradouro, numero, complemento, bairro, cidade, uf, telefone, consentimento_lgpd_data, cadunico_atualizado_em, obs) VALUES
(51, '13018358012', NULL, 'Severino Nunes Oliveira', NULL, 'M', NULL, '1988-08-14', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(52, '11462790290', 'CRAS Belém', 'Jéssica Ribeiro Lima', NULL, 'F', NULL, '2001-02-18', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(53, '11667453276', 'CRAS Mooca', 'Tatiane Gonçalves Marques', NULL, 'F', 'Prefere não informar', '1959-10-25', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(54, '11150830026', 'CRAS Belém', 'Priscila Santana Pereira', NULL, 'F', NULL, '1991-04-23', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(55, NULL, 'CRAS Mooca', 'Juliana Moura Moreira', NULL, 'F', NULL, '1973-01-12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(56, NULL, 'CRAS Mooca', 'Adriana Pereira Lima', NULL, 'F', NULL, '1970-04-16', 'Manaus', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(57, NULL, NULL, 'Ana Nascimento Fernandes', NULL, 'F', NULL, '1946-09-01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(58, NULL, 'CRAS Mooca', 'Juliana Farias Ribeiro', NULL, 'F', NULL, '1994-03-21', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(59, '19943751941', 'CRAS Mooca', 'Simone Correia Moreira', NULL, 'F', NULL, '1982-05-18', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(60, '19974709638', 'CRAS Mooca', 'Elaine Silva Monteiro', NULL, 'F', NULL, '1954-07-13', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(61, '22524402774', 'CRAS Mooca', 'Leticia Ferreira Freitas', NULL, 'F', NULL, '1979-02-14', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(62, '18286192255', 'CRAS Mooca', 'Rodrigo Fernandes Rocha', NULL, 'M', NULL, '1981-07-08', 'Salvador', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(63, NULL, 'CRAS Mooca', 'José Teixeira Dias', NULL, 'M', NULL, '1949-02-09', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(64, '16424436574', 'CRAS Mooca', 'Helena Vieira Moreira', NULL, 'F', 'Prefere não informar', '1979-02-28', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(65, '20221635787', 'CRAS Belém', 'Renata Monteiro Soares', NULL, 'F', NULL, '1951-01-05', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(66, '14618223247', NULL, 'Vera Pinto Nunes', NULL, 'F', NULL, '1998-02-12', 'Feira de Santana', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(67, NULL, 'CRAS Mooca', 'Adriana Correia Teixeira', NULL, 'F', 'Prefere não informar', '1972-07-13', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(68, NULL, 'CREAS Mooca', 'Adriana Santana Machado', NULL, 'F', NULL, '2005-06-11', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(69, '22312496592', 'CRAS Mooca', 'Regina Gonçalves Dias', NULL, 'F', NULL, '1967-05-05', 'Fortaleza', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(70, NULL, 'CRAS Mooca', 'Gilberto Soares Costa', NULL, 'M', 'Prefere não informar', '1961-12-18', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(71, '18057462984', NULL, 'Diego Soares Rocha', NULL, 'M', NULL, '1997-11-19', 'São Paulo', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(72, '20842315600', 'CRAS Mooca', 'Francisca de Oliveira Farias', NULL, 'F', NULL, '1982-02-14', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(73, '25200246084', 'CRAS Mooca', 'Débora Rodrigues Santana', NULL, 'F', 'Prefere não informar', '1988-06-25', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(74, '25368646243', 'CRAS Mooca', 'Edna Nunes Almeida', NULL, 'F', NULL, '1960-05-01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(75, NULL, 'CRAS Belém', 'João Brito Silva', NULL, 'M', NULL, '1964-09-23', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(76, NULL, 'CRAS Belém', 'Michele Brito Marques', NULL, 'F', 'Prefere não informar', '1961-04-10', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(77, NULL, 'CRAS Mooca', 'Márcia Andrade Ramos', NULL, 'F', NULL, '2003-11-16', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(78, '17830653176', NULL, 'Adilson Barbosa Cardoso', NULL, 'M', NULL, '1984-09-02', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(79, NULL, NULL, 'Leticia Correia Ramos', NULL, 'F', NULL, '1991-03-14', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(80, NULL, 'CRAS Mooca', 'Vera Cavalcanti Moura', NULL, 'F', NULL, '1991-05-12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(81, NULL, NULL, 'João Mendes Araújo', NULL, 'M', NULL, '1974-03-08', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(82, NULL, 'CRAS Mooca', 'Antônia Martins Barbosa', NULL, 'F', NULL, '1965-02-14', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(83, '27107280972', 'CRAS Mooca', 'Débora Silva Carvalho', NULL, 'F', NULL, '1963-10-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(84, '13773085551', NULL, 'José Rodrigues Pinto', NULL, 'M', NULL, '1955-05-04', 'São Paulo', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(85, NULL, 'CREAS Mooca', 'Vera Farias Andrade', NULL, 'F', NULL, '1977-03-15', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(86, '27728641914', 'CRAS Mooca', 'Patricia Lima Batista', NULL, 'F', NULL, '1993-01-14', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(87, NULL, 'CRAS Mooca', 'Fábio Cardoso Oliveira', NULL, 'M', NULL, '1960-06-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(88, '11934985682', 'CRAS Mooca', 'Letícia Cardoso Monteiro', NULL, 'F', NULL, '1963-04-15', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(89, NULL, 'CRAS Mooca', 'Ana Martins Cavalcanti', 'Rafael Martins Cavalcanti', 'F', NULL, '1998-06-16', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(90, '25061170956', 'CRAS Mooca', 'Carlos Nunes Brito', NULL, 'M', 'Prefere não informar', '1991-09-08', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(91, '24479411097', 'CRAS Belém', 'Daniel Brito Costa', NULL, 'M', NULL, '1999-02-02', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(92, '27428347903', 'CREAS Mooca', 'Neide Cardoso Fernandes', NULL, 'F', NULL, '1976-11-20', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(93, NULL, 'CRAS Mooca', 'Vera Costa Alves', NULL, 'F', 'Prefere não informar', '1979-01-15', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(94, '15979941682', 'CRAS Belém', 'Simone Barbosa Araújo', NULL, 'F', NULL, '1979-01-10', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(95, NULL, 'CRAS Belém', 'Patrícia de Andrade Gomes', NULL, 'F', NULL, '1962-08-03', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(96, '16648950142', 'CRAS Mooca', 'Rodrigo da Silva Andrade', NULL, 'M', 'Prefere não informar', '1971-05-18', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(97, '12568192535', 'CRAS Mooca', 'Patricia Nascimento Nunes', NULL, 'F', NULL, '1986-04-12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(98, '23042237378', 'CRAS Belém', 'Fernanda Barbosa Brito', NULL, 'F', NULL, '1978-09-10', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(99, NULL, 'CRAS Mooca', 'Valdir Brito Alves', NULL, 'M', NULL, '1952-05-09', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(100, '13934677014', 'CRAS Mooca', 'Cristiane Mendes Vieira', NULL, 'F', 'Prefere não informar', '1962-02-12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
-- ==========================================
-- 4.2 BENEFICIARIO (Continuação - Registros 101 a 150)
-- ==========================================
INSERT INTO beneficiario (id_beneficiario, nis, cras_creas_sas, nome_completo, nome_social, sexo, raca_cor, data_nascimento, naturalidade, endereco_cep, logradouro, numero, complemento, bairro, cidade, uf, telefone, consentimento_lgpd_data, cadunico_atualizado_em, obs) VALUES
(101, NULL, 'CRAS Mooca', 'Márcia Farias Martins', NULL, 'F', NULL, '1962-02-12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(102, NULL, 'CREAS Mooca', 'Eduardo Dias Ribeiro', NULL, 'M', NULL, '1971-05-18', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(103, '14097832847', 'CREAS Mooca', 'Adriana Correia Souza', NULL, 'F', NULL, '1986-04-12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(104, NULL, 'CRAS Belém', 'Gabriel Vieira Santos', NULL, 'M', 'Prefere não informar', '1978-09-10', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(105, '25142755106', 'CRAS Mooca', 'Valéria Brito Vieira', NULL, 'F', NULL, '1952-05-09', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(106, '13924635393', 'CRAS Mooca', 'Carlos da Silva Nascimento', NULL, 'M', NULL, '1962-02-12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(107, '19956637704', NULL, 'Fábio Rocha Oliveira', NULL, 'M', NULL, '1965-02-14', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(108, '28612797792', 'CRAS Belém', 'Patricia Ramos Oliveira', NULL, 'F', NULL, '1963-10-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(109, '26363443055', 'CRAS Mooca', 'Manoel Souza Santana', NULL, 'M', NULL, '1955-05-04', 'São Paulo', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(110, NULL, NULL, 'Neide Lima Oliveira', NULL, 'F', NULL, '1977-03-15', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(111, '22968422998', 'CRAS Belém', 'Lúcia Pereira Brito', NULL, 'F', NULL, '1993-01-14', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(112, '15293087291', 'CRAS Mooca', 'Débora Batista Almeida', NULL, 'F', NULL, '1960-06-22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(113, NULL, 'CREAS Mooca', 'Priscila Batista Moreira', NULL, 'F', NULL, '1963-04-15', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(114, NULL, 'CRAS Mooca', 'Gabriela Oliveira Barbosa', NULL, 'F', NULL, '1998-06-16', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(115, NULL, 'CRAS Mooca', 'Elaine Carvalho Nunes', NULL, 'F', NULL, '1991-09-08', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(116, '21825409133', 'CRAS Mooca', 'Jéssica Alves Moura', NULL, 'F', NULL, '1999-02-02', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(117, '10948500504', 'CRAS Mooca', 'Luciana Gomes Andrade', NULL, 'F', 'Prefere não informar', '1976-11-20', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(118, '20163348607', 'CRAS Mooca', 'Francisca Mendes Ferreira', NULL, 'F', NULL, '1979-01-15', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(119, NULL, 'CRAS Belém', 'Josefa Batista Silva', NULL, 'F', NULL, '1968-02-04', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(120, '23534702461', 'CRAS Mooca', 'Edna Fernandes Rodrigues', NULL, 'F', NULL, '1979-01-10', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(121, NULL, NULL, 'Adilson Ribeiro Costa', NULL, 'M', NULL, '1969-05-01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(122, '28007618619', 'CRAS Mooca', 'Marcos Dias Ferreira', NULL, 'M', 'Prefere não informar', '1971-05-18', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(123, '11549776701', 'CRAS Mooca', 'Jéssica de Souza Pereira', NULL, 'F', NULL, '1986-04-12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(124, '17443630193', 'CRAS Mooca', 'Fernanda de Almeida Carvalho', NULL, 'F', NULL, '1978-09-10', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(125, '19336775942', 'CRAS Mooca', 'Adriana Farias Monteiro', NULL, 'F', NULL, '1952-05-09', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(126, '29436696095', 'CRAS Belém', 'Luciana Ribeiro Machado', NULL, 'F', NULL, '1962-02-12', NULL, NULL, NULL, NULL, NULL, NULL, NULL,
