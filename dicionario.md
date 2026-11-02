## Dicionário de Dados Conceitual

### 1.0 Convenções de Engenharia de Dados e Governança

* **SGBD Alvo:** MySQL v8.0+
* **Encoding e Collation:** Conjunto de caracteres `utf8mb4` e collation `utf8mb4_unicode_ci` (suporte completo a caracteres especiais e emojis).
* **Notação Formal:** Modelo Entidade-Relacionamento (Notação Chen / Merise)
* **Convenção de Nomenclatura:** Nomes de tabelas e atributos em minúsculo com separação por sublinhado (`snake_case`). Chaves primárias iniciadas com `id_`.
* **Compatibilidade de Tipos:** Todas as chaves primárias (PK) e chaves estrangeiras (FK) utilizam o tipo padronizado `BIGINT UNSIGNED` para assegurar a integridade referencial no MySQL.
* **Política de Indexação:** Além das Chaves Primárias (PK) e Estrangeiras (FK), são criados índices B-Tree para otimização de busca frequente nos campos `cpf`, `nis` e `nome_completo`.
* **Validações de Regra de Negócio:** Restrições quantitativas (como o limite de até 5 membros em `composicao_familiar` e 3 em `referencia_familiar` da RN10) serão validadas na camada de aplicação (backend) durante a inserção.

#### Governança de Dados, LGPD e Matriz de Papéis
> Diretrizes de conformidade jurídica, retenção e permissões de acesso baseadas nas normativas da LGPD e do SuAS.

**Classificação dos Dados:**
* **Interno:** Chaves, datas de controle e dados operacionais (ex: `id_beneficiario`, `quantidade_cestas`).
* **Pessoal:** Dados pessoais comuns nos termos do Art. 5º, I da LGPD (ex: `nome_completo`, `cpf`, `telefone`, `endereco`).
* **Sensível:** Dados pessoais sensíveis nos termos do Art. 5º, II da LGPD (ex: `cor_raca`, `orientacao_sexual`, `pessoa_com_deficiencia`, `tem_alergias`).
* **Sigiloso:** Dados protegidos pelo sigilo profissional da triagem e assistência social (ex: `renda_atual`, `demanda_inicial`, `metas_objetivos`).

**Bases Legais e Diretrizes:**
* **Dados Pessoais Comuns:** Art. 7º, I (Consentimento do Titular) da LGPD.
* **Dados Sensíveis:** Art. 11, I (Consentimento expresso do titular ou responsável legal) e Art. 11, II, "a" (Cumprimento de obrigação legal por legislação federal/estadual do SuAS).
* **Retenção e Expurgo:** Os cadastros e prontuários são mantidos por **5 anos** após o último atendimento do beneficiário, em conformidade com as diretrizes do SuAS/CRAS, sendo submetidos a anonimização ou expurgo seguro após este período.

**Matriz de Papéis por Operação (I: Inserir, L: Ler, A: Alterar, N: Anonimizar):**
| Categoria de Dados | TÉCNICO (Assistente Social / Psicólogo) | ADMIN (Coordenação / Presidência) | VOLUNTÁRIO (Recepção / Apoio) |
| :--- | :---: | :---: | :---: |
| **Internos e Pessoais** (Cadastro, Família, Trabalho) | I, L, A | I, L, A | L |
| **Sensíveis** (Raça, Deficiência, Alergias) | I, L, A | - | - |
| **Sigiloso** (Renda, Prontuários, PIA) | I, L, A | - | - |
| **Entrega de Cestas** (`entrega_cesta`) | I, L, A | L | I, L |

---

### 1.1 Entidade: Beneficiário
*(Centraliza a identificação do cidadão assistido)*

| Atributo | Descrição | Domínio / Tipo Físico | Índice | Obrig. | Classe LGPD |
| :--- | :--- | :--- | :---: | :---: | :--- |
| `id_beneficiario` | Identificador único | `BIGINT UNSIGNED AUTO_INCREMENT` | PK | Sim | Interno |
| `nis` | Identificação Social | `VARCHAR(15)` | Index | Não | Pessoal |
| `cras_creas_sas` | Equipamento vinculado | `VARCHAR(100)` | Não | Não | Interno |
| `nome_completo` | Nome civil | `VARCHAR(150)` | Index | Sim | Pessoal |
| `nome_social` | Nome de preferência | `VARCHAR(150)` | Não | Não | Pessoal |
| `sexo` | Sexo biológico/declarado | `CHAR(1)` | Não | Sim | Pessoal |
| `orientacao_sexual` | Orientação autodeclarada | `VARCHAR(30)` | Não | Não | Sensível |
| `data_nascimento` | Data de nascimento | `DATE` | Não | Sim | Pessoal |
| `naturalidade` | Cidade/UF de origem | `VARCHAR(100)` | Não | Não | Pessoal |
| `cor_raca` | Cor/raça autodeclarada | `VARCHAR(20)` | Não | Não | Sensível |
| `pessoa_com_deficiencia` | Condição de PCD / CID | `VARCHAR(100)` | Não | Não | Sensível |
| `tem_alergias` | Restrições alimentares | `VARCHAR(150)` | Não | Não | Sensível |
| `cpf` | Registro de CPF | `VARCHAR(14)` | Index/Unique | Não | Pessoal |
| `rg_numero` | Documento RG | `VARCHAR(20)` | Não | Não | Pessoal |
| `rg_orgao_uf_emissor` | Órgão emissor RG | `VARCHAR(20)` | Não | Não | Pessoal |
| `rg_data_emissao` | Data de emissão RG | `DATE` | Não | Não | Pessoal |
| `estado_civil` | Estado civil | `VARCHAR(20)` | Não | Não | Pessoal |
| `endereco` | Endereço residencial | `VARCHAR(200)` | Não | Sim | Pessoal |
| `bairro` | Bairro | `VARCHAR(100)` | Não | Não | Pessoal |
| `cep` | Código postal | `VARCHAR(9)` | Não | Não | Pessoal |
| `telefone` | Telefone principal | `VARCHAR(20)` | Não | Não | Pessoal |
| `nome_mae` | Nome da mãe | `VARCHAR(150)` | Não | Não | Pessoal |
| `nome_pai` | Nome do pai | `VARCHAR(150)` | Não | Não | Pessoal |
| `escolaridade` | Nível de instrução | `VARCHAR(50)` | Não | Não | Pessoal |
| `estuda_atualmente` | Vínculo escolar atual | `VARCHAR(100)` | Não | Não | Pessoal |
| `recebe_transferencia_renda`| Programas sociais | `VARCHAR(100)` | Não | Não | Sigiloso |
| `recebe_bpc` | Recebimento de BPC | `VARCHAR(50)` | Não | Não | Sigiloso |
| `situacao_cadastro` | Status do cadastro | `VARCHAR(20)` (ATIVO/ANONIMIZADO) | Não | Sim | Interno |
| `data_consentimento` | Data do aceite LGPD | `DATE` | Não | Sim | Interno |
| `cadunico_ativo` | Possui Cadastro Único ativo | `TINYINT(1)` | Não | Sim | Sigiloso |
| `data_atualizacao_cadunico` | Última atualização CadÚnico | `DATE` | Não | Não | Sigiloso |

---

### 1.2 Entidade: Trabalho
*(Perfil ocupacional e socioeconômico - isolado para normalização 1FN/2FN)*

| Atributo | Descrição | Domínio / Tipo Físico | Índice | Obrig. | Classe LGPD |
| :--- | :--- | :--- | :---: | :---: | :--- |
| `id_trabalho` | Identificador único | `BIGINT UNSIGNED AUTO_INCREMENT` | PK | Sim | Interno |
| `id_beneficiario` | Beneficiário vinculado | `BIGINT UNSIGNED` | FK | Sim | Interno |
| `situacao_ocupacional` | Condição de trabalho | `VARCHAR(50)` | Não | Sim | Pessoal |
| `profissao_habilidades` | Habilidades e cursos | `TEXT` | Não | Não | Pessoal |
| `renda_atual` | Renda mensal individual | `DECIMAL(10,2)` | Não | Não | Sigiloso |
| `empresa_trabalho` | Nome do empregador | `VARCHAR(150)` | Não | Não | Pessoal |
| `ocupacao_atual` | Função exercida | `VARCHAR(100)` | Não | Não | Pessoal |
| `telefone_trabalho` | Telefone comercial | `VARCHAR(20)` | Não | Não | Pessoal |

---

### 1.3 Entidade: Composição Familiar (`composicao_familiar`)
*(Membros dependentes que residem no mesmo domicílio - até 5 membros)*

| Atributo | Descrição | Domínio / Tipo Físico | Índice | Obrig. | Classe LGPD |
| :--- | :--- | :--- | :---: | :---: | :--- |
| `id_membro` | Identificador do membro | `BIGINT UNSIGNED AUTO_INCREMENT` | PK | Sim | Interno |
| `id_beneficiario` | Titular da família | `BIGINT UNSIGNED` | FK | Sim | Interno |
| `nome` | Nome civil do familiar | `VARCHAR(150)` | Não | Sim | Pessoal |
| `nome_social` | Nome de preferência/social | `VARCHAR(150)` | Não | Não | Pessoal |
| `idade` | Idade em anos | `TINYINT UNSIGNED` | Não | Sim | Pessoal |
| `parentesco_vinculo` | Grau de parentesco | `VARCHAR(50)` | Não | Sim | Pessoal |

---

### 1.4 Entidade: Referência Familiar (`referencia_familiar`)
*(Contatos externos e de emergência - até 3 referências)*

| Atributo | Descrição | Domínio / Tipo Físico | Índice | Obrig. | Classe LGPD |
| :--- | :--- | :--- | :---: | :---: | :--- |
| `id_referencia` | Identificador do contato | `BIGINT UNSIGNED AUTO_INCREMENT` | PK | Sim | Interno |
| `id_beneficiario` | Beneficiário vinculado | `BIGINT UNSIGNED` | FK | Sim | Interno |
| `nome` | Nome do contato | `VARCHAR(150)` | Não | Sim | Pessoal |
| `nome_social` | Nome de preferência/social | `VARCHAR(150)` | Não | Não | Pessoal |
| `parentesco_vinculo` | Relação/vínculo | `VARCHAR(50)` | Não | Não | Pessoal |
| `telefone` | Telefone de contato | `VARCHAR(20)` | Não | Não | Pessoal |

---

### 1.5 Entidade: Atendimento
*(Registro das entrevistas e anamneses sociais)*

| Atributo | Descrição | Domínio / Tipo Físico | Índice | Obrig. | Classe LGPD |
| :--- | :--- | :--- | :---: | :---: | :--- |
| `id_atendimento` | Identificador da sessão | `BIGINT UNSIGNED AUTO_INCREMENT` | PK | Sim | Interno |
| `id_beneficiario` | Beneficiário atendido | `BIGINT UNSIGNED` | FK | Sim | Interno |
| `id_profissional` | Técnico condutor | `BIGINT UNSIGNED` | FK | Sim | Interno |
| `data_atendimento` | Data do atendimento | `DATE` | Index | Sim | Interno |
| `demanda_inicial` | Necessidade relatada | `TEXT` | Não | Sim | Sigiloso |

---

### 1.6 Entidade: Encaminhamento (`encaminhamento_atendimento`)
*(Direcionamentos para redes externas derivados de um atendimento)*

| Atributo | Descrição | Domínio / Tipo Físico | Índice | Obrig. | Classe LGPD |
| :--- | :--- | :--- | :---: | :---: | :--- |
| `id_encaminhamento` | Identificador único | `BIGINT UNSIGNED AUTO_INCREMENT` | PK | Sim | Interno |
| `id_atendimento` | Atendimento de origem | `BIGINT UNSIGNED` | FK | Sim | Interno |
| `tipo_encaminhamento` | Categoria do encaminhamento | `VARCHAR(60)` | Não | Sim | Sigiloso |
| `detalhe_outros` | Especificação técnica | `TEXT` | Não | Cond. | Sigiloso |

---

### 1.7 Entidade: Profissional Responsável (`profissional_responsavel`)
*(Equipe técnica da ONG - CRESS/CRP)*

| Atributo | Descrição | Domínio / Tipo Físico | Índice | Obrig. | Classe LGPD |
| :--- | :--- | :--- | :---: | :---: | :--- |
| `id_profissional` | Identificador do profissional | `BIGINT UNSIGNED AUTO_INCREMENT` | PK | Sim | Interno |
| `nome` | Nome completo | `VARCHAR(150)` | Não | Sim | Pessoal |
| `funcao` | Cargo / Função | `VARCHAR(50)` | Não | Sim | Interno |
| `registro_profissional` | Conselho de classe (CRESS/CRP) | `VARCHAR(30)` | Não | Sim | Interno |

---

### 1.8 Entidade: PIA (Plano Individual de Atendimento)
*(Acompanhamento continuado e evolução social)*

| Atributo | Descrição | Domínio / Tipo Físico | Índice | Obrig. | Classe LGPD |
| :--- | :--- | :--- | :---: | :---: | :--- |
| `id_pia` | Identificador do plano | `BIGINT UNSIGNED AUTO_INCREMENT` | PK | Sim | Interno |
| `id_beneficiario` | Beneficiário titular | `BIGINT UNSIGNED` | FK | Sim | Interno |
| `id_profissional` | Técnico responsável | `BIGINT UNSIGNED` | FK | Sim | Interno |
| `data_criacao` | Data de elaboração | `DATE` | Não | Sim | Interno |
| `metas_objetivos` | Metas de autonomia | `TEXT` | Não | Sim | Sigiloso |
| `prazo_reavaliacao` | Previsão de retorno | `DATE` | Não | Não | Interno |

---

### 1.9 Entidade: Entrega de Cesta (`entrega_cesta`)
*(Registro e auditoria de doações diretas)*

| Atributo | Descrição | Domínio / Tipo Físico | Índice | Obrig. | Classe LGPD |
| :--- | :--- | :--- | :---: | :---: | :--- |
| `id_entrega` | Identificador da entrega | `BIGINT UNSIGNED AUTO_INCREMENT` | PK | Sim | Interno |
| `id_beneficiario` | Beneficiário recebedor | `BIGINT UNSIGNED` | FK | Sim | Interno |
| `id_profissional` | Técnico autorizador | `BIGINT UNSIGNED` | FK | Sim | Interno |
| `data_entrega` | Data de concessão | `DATE` | Index | Sim | Interno |
| `quantidade_cestas` | Volume concedido | `INT` | Não | Sim | Interno |
| `itens_adicionais` | Doações complementares | `TEXT` | Não | Não | Interno |

---

### 1.10 Entidade: Recebimento de Doação (`recebimento_doacao`)
*(Registro de entrada de mantimentos enviados por parceiros)*

| Atributo | Descrição | Domínio / Tipo Físico | Índice | Obrig. | Classe LGPD |
| :--- | :--- | :--- | :---: | :---: | :--- |
| `id_recebimento` | Identificador da doação | `BIGINT UNSIGNED AUTO_INCREMENT` | PK | Sim | Interno |
| `id_profissional` | Técnico recebedor | `BIGINT UNSIGNED` | FK | Sim | Interno |
| `parceiro_doador` | Nome do doador (ex: Banco de Alimentos) | `VARCHAR(100)` | Não | Sim | Interno |
| `data_recebimento` | Data de entrada | `DATE` | Index | Sim | Interno |
| `descricao_itens` | Descrição dos itens doados | `TEXT` | Não | Sim | Interno |
| `quantidade_total` | Volume/peso recebido | `INT` | Não | Sim | Interno |

---

### 1.11 Ciclo de Vida do Fluxo de Dados

1. **Recepção e Termo LGPD:** O assistido assina o termo de consentimento LGPD e é registrado em `beneficiario` (`data_consentimento` preenchida e `situacao_cadastro = 'ATIVO'`).
2. **Triagem Socioassistencial:** O profissional habilitado conduz a entrevista e gera um registro em `atendimento`, inserindo a demanda inicial, além de atualizar o perfil em `trabalho`, `composicao_familiar` e `referencia_familiar`.
3. **Desdobramentos do Atendimento:** A partir do atendimento, o sistema permite derivar encaminhamentos externos (`encaminhamento_atendimento`), conceder cestas básicas (`entrega_cesta`, validando elegibilidade e intervalo) e iniciar o acompanhamento continuado (`pia`).
4. **Entrada de Mantimentos:** As doações enviadas por instituições parceiras são registradas em `recebimento_doacao` pelo profissional responsável.
5. **Consultas e Relatórios:** O histórico do assistido pode ser consultado para acompanhamento (RF06), gerando relatórios agregados e anonimizados para prestação de contas aos órgãos parceiros (RN08).
6. **Encerrando o Ciclo (LGPD):** Após 5 anos do último atendimento, ou por solicitação do titular, o cadastro é submetido à rotina de anonimização (`situacao_cadastro = 'ANONIMIZADO'`).
