| `nome` | Nome civil do familiar | `VARCHAR(150)` | Não | Sim | Pessoal |
| `nome_social` | Nome de preferência/social | `VARCHAR(150)` | Não | Não | Pessoal |
| `idade` | Idade em anos | `TINYINT UNSIGNED` | Não | Sim | Pessoal |
| `parentesco_vinculo` | Grau de parentesco | `VARCHAR(50)` | Não | Sim | Pessoal |

---

### 4.4 Entidade: Referência Familiar (`referencia_familiar`)
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

### 4.5 Entidade: Atendimento
*(Registro das entrevistas e anamneses sociais)*

| Atributo | Descrição | Domínio / Tipo Físico | Índice | Obrig. | Classe LGPD |
| :--- | :--- | :--- | :---: | :---: | :--- |
| `id_atendimento` | Identificador da sessão | `BIGINT UNSIGNED AUTO_INCREMENT` | PK | Sim | Interno |
| `id_beneficiario` | Beneficiário atendido | `BIGINT UNSIGNED` | FK | Sim | Interno |
| `id_profissional` | Técnico condutor | `BIGINT UNSIGNED` | FK | Sim | Interno |
| `data_atendimento` | Data do atendimento | `DATE` | Index | Sim | Interno |
| `demanda_inicial` | Necessidade relatada | `TEXT` | Não | Sim | Sigiloso |

---

### 4.6 Entidade: Encaminhamento (`encaminhamento_atendimento`)
*(Direcionamentos para redes externas derivados de um atendimento)*

| Atributo | Descrição | Domínio / Tipo Físico | Índice | Obrig. | Classe LGPD |
| :--- | :--- | :--- | :---: | :---: | :--- |
| `id_encaminhamento` | Identificador único | `BIGINT UNSIGNED AUTO_INCREMENT` | PK | Sim | Interno |
| `id_atendimento` | Atendimento de origem | `BIGINT UNSIGNED` | FK | Sim | Interno |
| `tipo_encaminhamento` | Categoria do encaminhamento | `VARCHAR(60)` | Não | Sim | Sigiloso |
| `detalhe_outros` | Especificação técnica | `TEXT` | Não | Cond. | Sigiloso |

---

### 4.7 Entidade: Profissional Responsável (`profissional_responsavel`)
*(Equipe técnica da ONG - CRESS/CRP)*

| Atributo | Descrição | Domínio / Tipo Físico | Índice | Obrig. | Classe LGPD |
| :--- | :--- | :--- | :---: | :---: | :--- |
| `id_profissional` | Identificador do profissional | `BIGINT UNSIGNED AUTO_INCREMENT` | PK | Sim | Interno |
| `nome` | Nome completo | `VARCHAR(150)` | Não | Sim | Pessoal |
| `funcao` | Cargo / Função | `VARCHAR(50)` | Não | Sim | Interno |
| `registro_profissional` | Conselho de classe (CRESS/CRP) | `VARCHAR(30)` | Não | Sim | Interno |

---

### 4.8 Entidade: PIA (Plano Individual de Atendimento)
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

### 4.9 Entidade: Entrega de Cesta (`entrega_cesta`)
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

### 4.10 Entidade: Recebimento de Doação (`recebimento_doacao`)
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

### 4.11 Ciclo de Vida do Fluxo de Dados

1. **Recepção e Termo LGPD:** O assistido assina o termo de consentimento LGPD e é registrado em `beneficiario` (`data_consentimento` preenchida e `situacao_cadastro = 'ATIVO'`).
2. **Triagem Socioassistencial:** O profissional habilitado conduz a entrevista e gera um registro em `atendimento`, inserindo a demanda inicial, além de atualizar o perfil em `trabalho`, `composicao_familiar` e `referencia_familiar`.
3. **Desdobramentos do Atendimento:** A partir do atendimento, o sistema permite derivar encaminhamentos externos (`encaminhamento_atendimento`), conceder cestas básicas (`entrega_cesta`, validando elegibilidade e intervalo) e iniciar o acompanhamento continuado (`pia`).
4. **Entrada de Mantimentos:** As doações enviadas por instituições parceiras são registradas em `recebimento_doacao` pelo profissional responsável.
5. **Consultas e Relatórios:** O histórico do assistido pode ser consultado para acompanhamento (RF06), gerando relatórios agregados e anonimizados para prestação de contas aos órgãos parceiros (RN08).
6. **Encerrando o Ciclo (LGPD):** Após 5 anos do último atendimento, ou por solicitação do titular, o cadastro é submetido à rotina de anonimização (`situacao_cadastro = 'ANONIMIZADO'`).
