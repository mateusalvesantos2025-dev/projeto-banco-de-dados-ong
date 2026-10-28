# Projeto de Modelagem Conceitual (DER) - Organização Social Nossa Senhora de Fátima

**Integrantes / Autores:**
* Gabriel Simões da Silva (RGM 47327383)
* Henrique Novais de Oliveira (RGM 47046996)
* Leandro Miranda da Silva (RGM 47397349)
* Mateus Alves dos Santos (RGM 47435887)
* Washington de Souza Silva (RGM 49080156)

---

# 0. Processo

## Triagem dos dados e DER

O fluxo operacional da Organização Social Nossa Senhora de Fátima baseia-se no atendimento de portas abertas para a população em situação de vulnerabilidade. A partir da entrevista presencial realizada pela assistente social, é feito o preenchimento da ficha de triagem (coleta de dados pessoais, ocupacionais, composição familiar e demandas sociais). 

Adicionalmente, a instituição gerencia o recebimento de doações de mantimentos de parceiros estratégicos (como o Banco de Alimentos e o projeto Cidade Invisível), a distribuição variável de cestas básicas conforme o diagnóstico de vulnerabilidade e o planejamento de atividades socioeducativas e de lazer para os assistidos.

Abaixo estão mapeados os processos do negócio e as regras operacionais identificadas na organização, bem como a cobertura atual prevista no modelo de dados conceitual.

---

### Tabela dos Processos do Negócio (Tabela I)

| Processo mapeado | Tipo | Situação |
| :--- | :--- | :--- |
| Recepção e acolhimento inicial do cidadão | Atendimento | Coberta |
| Triagem socioassistencial e anamnese social | Triagem | Coberta |
| Cadastro completo de beneficiários e dependentes | Cadastro | Coberta |
| Registro de atestados, laudos e vulnerabilidade familiar | Armazenamento | Coberta |
| Encaminhamento para redes externas (saúde, habitação, jurídica) | Atendimento | Coberta |
| Acompanhamento familiar continuado via PIA | Acompanhamento | Coberta (suportado pela entidade PIA) |
| Avaliação, montagem e concessão de cestas básicas e auxílios | Doação/Auxílio | Coberta (suportado pela entidade Entrega_Cesta) |
| Recebimento de doações de parceiros (Banco de Alimentos, etc.) | Arrecadação | Coberta (registrado no fluxo de doações e auxílios) |
| Controle de passeios e eventos socioeducativos | Atendimento | Parcial (registrado via ficha de atendimento) |
| Gestão e histórico de prontuários do beneficiário | Gestão | Coberta (através de chaves e histórico de atendimentos) |
| Gestão de estoque físico de alimentos e doações | Físico | Ausente (fora do escopo do modelo conceitual relacional) |
| Captação e escala de voluntários | Apoio | Ausente (fora do escopo do modelo atual) |
| Agenda de atendimentos e escala de profissionais | Operacional | Parcial (suportado pelo cadastro de Profissionais) |
| Prestação de contas e relatórios socioassistenciais (CRAS/SAS) | Relatório | Coberta (via agregação de dados de atendimentos, entregas e doações) |

*Legenda: Coberta = Processo totalmente mapeado no modelo conceitual; Parcial = Processo coberto de forma indireta ou limitada; Ausente = Processo sem cobertura no modelo atual.*

---

### Tabela das Regras de Negócio (Tabela II)

| Regra mapeada | O que faz | Situação |
| :--- | :--- | :--- |
| Permite apenas um CPF/NIS por beneficiário | Validação | Coberta (RN01) |
| Sigilo de triagem e acesso restrito (LGPD) | Triagem | Coberta (RN02) |
| Triagem socioassistencial obrigatória antes do encaminhamento | Triagem | Coberta (RN03) |
| Acompanhamento continuado (PIA) vinculado ao histórico | Acompanhamento | Coberta (RN04) |
| Limite de membros na composição familiar e referências | Validação | Coberta (via Dicionário e Tabelas Relacionadas) |
| Avaliação social obrigatória para concessão de auxílios | Triagem | Coberta (via Atendimento e Encaminhamentos) |
| Concessão variável de cestas conforme doações e vulnerabilidade | Doação | Coberta (RN05 / Registrada no Atendimento) |
| Controle de duplicidade e histórico na entrega de auxílios | Doação | Coberta (RN06 / Histórico de Atendimentos) |
| Obrigatoriedade de registro do profissional responsável (CRESS/CRP) | Triagem | Coberta (via Entidade Profissional) |
| Periodicidade de entrega de cesta conforme doações | Doação | Parcial (registrada no fluxo de atendimento) |
| Controle de estoque físico de alimentos | Doação | Ausente (fora do escopo do modelo de dados) |
| Prestação de contas e relatórios para órgãos parceiros (CRAS/SAS) | Relatório | Ausente (requer agregação em fase futura) |

*Legenda: Coberta = Regra mapeada com suporte direto nas entidades e atributos do modelo; Parcial = Presente no fluxo mas sem automação de estoque; Ausente = Regra sem cobertura no modelo conceitual atual.*


# 1. Diagnóstico do status e a organização

### Visão 1: O Acesso e levantamento do grupo

* **Nome e/ou sigla da organização:** Organização Social Nossa Senhora de Fátima (CNPJ: 32.667.614/0001-18).
  * **E-mail:** [ongnossasenhoradefatima@gmail.com](mailto:ongnossasenhoradefatima@gmail.com)
  * **Site:** [www.ongnossasenhoradefatima.com.br](http://www.ongnossasenhoradefatima.com.br)
  * **Assistente Social Responsável:** Maria Aparecida Fernandes Ferreira de Souza
  * **Telefone:** (11) 96972-4382
* **Acesso à ONG:** Contato direto por meio de voluntariado ativo no setor de um dos integrantes do grupo e entrevista presencial com a equipe técnica.
* **Descreva o porte:** Organização de pequeno porte, atendendo fixamente cerca de 250 famílias cadastradas na região. Conta com o Presidente e 5 voluntários recorrentes de forma fixa.
* **Serviços e como dados eram gerados:** Triagem e atendimento social presencial, encaminhamentos para moradia, saúde mental (AMA, CAPS, UBS), assistência jurídica e moradia universitária, além de distribuição de cestas básicas. Os dados eram gerados exclusivamente em formato manual através de fichas de atendimento impressas.
* **Problema a ser resolvido:** Centralização e digitalização das informações dos beneficiários. O controle atual é 100% físico e impresso, o que gera gargalos na troca de informações, risco de desgaste do papel e dificuldade na busca de históricos de atendimentos. O novo sistema eliminará a dependência do papel, garantindo agilidade e conformidade com a LGPD.

---

## 1.1. Descrição do Negócio

> Visão 1.1.1: Descrição e Funcionamento
* A Organização Social Nossa Senhora de Fátima é uma entidade sem fins lucrativos focada no acolhimento de pessoas em situação de vulnerabilidade social na região da Mooca. O fluxo operacional inicia-se no atendimento "de porta aberta", onde a assistente social realiza uma entrevista individualizada e preenche a ficha de triagem (dados pessoais, profissionais, composição familiar e demandas). A partir dessa avaliação, a ONG presta auxílio direto (montagem e entrega de cestas básicas não padronizadas) ou realiza encaminhamentos externos para redes de apoio (saúde mental, assistência jurídica, habitação e empregabilidade). Atualmente, a doação de alimentos é intermediada por parceiros como Banco de Alimentos e Cidade Invisível, e o controle de passeios sociais/culturais é organizado nos finais de semana. O novo sistema automatizará o registro cadastral, o histórico de demandas e os encaminhamentos efetuados.

---

## 2. Requisitos do Sistema
> Visão 2: O que o sistema precisa fazer e ter para resolver as necessidades da ONG.

### 2.1 Requisitos Funcionais (RF)
* **RF01 — Cadastro de Beneficiários:** O sistema deve permitir o registro completo de beneficiários e seus dependentes, validando a unicidade por CPF ou NIS.
* **RF02 — Registo de Triagem Socioassistencial:** O sistema deve armazenar as fichas de triagem preenchidas pela assistente social, contendo dados socioeconómicos, situação familiar e laudos.
* **RF03 — Gestão de Atendimentos e Encaminhamentos:** O sistema deve registrar os atendimentos realizados e os encaminhamentos efetuados para a rede externa de apoio.
* **RF04 — Registo de Concessão de Auxílios:** O sistema deve permitir o registro da distribuição de cestas básicas e doações de forma variável conforme a necessidade e a disponibilidade.
* **RF05 — Acompanhamento Continuado (PIA):** O sistema deve suportar o registro e a evolução do Plano Individual de Atendimento (PIA) conduzido pela equipe técnica.
* **RF06 — Consulta e Histórico:** O sistema deve permitir a consulta ao histórico de atendimentos e triagens anteriores de um beneficiário cadastrado.

### 2.2 Requisitos Não Funcionais (RNF)
* **RNF01 — Segurança e Sigilo de Dados (LGPD):** O sistema deve aplicar controle de acesso baseado em papéis (RBAC), garantindo que dados sensíveis e laudos socioassistenciais sejam acessíveis exclusivamente por profissionais autorizados.
* **RNF02 — Desempenho e Escalabilidade:** As consultas de beneficiários por CPF, NIS ou nome devem retornar resultados em até 2 segundos, mantendo a estabilidade mesmo com o crescimento gradual do volume de atendimentos.
* **RNF03 — Integridade Relacional:** O banco de dados deve assegurar a integridade referencial estrita por meio de chaves primárias e estrangeiras obrigatórias.
* **RNF04 — Disponibilidade e Tolerância a Falhas:** O SGBD deve garantir disponibilidade contínua durante o horário de atendimento da instituição, contando com rotinas automatizadas de backup diário e plano de recuperação de dados.
* **RNF05 — Usabilidade e Interface:** A interface do sistema deve ser intuitiva, ágil e de fácil navegação para otimizar o preenchimento de fichas por assistentes sociais e voluntários da recepção.
* **RNF06 — Auditoria de Registros:** O sistema deve registrar automaticamente a data, hora, usuário e tipo de operação (inserção, alteração ou exclusão/anonimização) para garantir rastreabilidade nos prontuários.


---

# 3. Regras de Negócio (RN)

As regras de negócio abaixo definem as restrições operacionais, validações de dados e requisitos legais que orientam a modelagem do banco de dados e a rotina da instituição.

---

### RN01 — Unicidade de Identificação (CPF/NIS)
* **Descrição:** Cada beneficiário cadastrado no sistema deve possuir apenas um registro ativo associado ao seu número de CPF ou NIS (Número de Identificação Social).
* **Motivação:** Evitar cadastros duplicados de uma mesma pessoa ou família no sistema da ONG.
* **Tipo:** Validação de Dados / Restrição do Banco.

---

### RN02 — Sigilo e Restrição de Acesso às Triagens (LGPD)
* **Descrição:** Os dados coletados durante a triagem socioassistencial (informações financeiras, relatórios de vulnerabilidade e prontuários) são confidenciais e restritos à equipe de assistência social autorizada.
* **Motivação:** Garantir o cumprimento da Lei Geral de Proteção de Dados (LGPD) e a privacidade dos atendidos.
* **Tipo:** Segurança e Controle de Acesso.

---

### RN03 — Triagem Obrigatória Prévia
* **Descrição:** Nenhum beneficiário poderá receber encaminhamentos para a rede externa de apoio, participar de programas continuados ou receber auxílios materiais sem que haja pelo menos um registro de triagem social válido e atualizado.
* **Motivação:** Garantir que os auxílios e encaminhamentos sejam destinados prioritariamente às famílias que realmente passam por avaliação de vulnerabilidade.
* **Tipo:** Regra de Processo / Fluxo de Atendimento.

---

### RN04 — Acompanhamento Continuado e PIA
* **Descrição:** Famílias inseridas no Plano Individual de Atendimento (PIA) devem ter seus registros de acompanhamento, evolução temporal e metas vinculados diretamente ao histórico conduzido pela equipe técnica.
* **Motivação:** Permitir a evolução temporal do quadro socioeconômico da família e o acompanhamento estruturado das metas de autonomia.
* **Tipo:** Acompanhamento / Histórico.

---

### RN05 — Concessão Variável de Cestas Básicas e Doações
* **Descrição:** A distribuição de cestas básicas e itens de doação não possui quantidade fixa por beneficiário; ela varia estritamente em função da disponibilidade de estoque/doações de parceiros e do grau de necessidade apurado na triagem.
* **Motivação:** Refletir a realidade operacional da ONG, onde a oferta depende de doadores externos e a demanda é priorizada pela assistente social.
* **Tipo:** Regra Operacional de Doação.

---

### RN06 — Critério de Elegibilidade e Periodicidade de Auxílios
* **Descrição:** A concessão de cestas básicas por família observa critérios de elegibilidade baseados na renda per capita apurada na triagem e respeita um intervalo mínimo de periodicidade entre as entregas, salvo em situações de calamidade avaliadas pela equipe.
* **Motivação:** Assegurar a distribuição justa, transparente e rotativa dos recursos limitados da instituição entre as famílias cadastradas.
* **Tipo:** Regra de Controle de Doação.

---

### RN07 — Consentimento, Retenção e Ciclo de Vida de Dados (LGPD)
* **Descrição:** O cadastro de informações socioeconômicas e laudos exige o consentimento expresso do titular (ou responsável legal), mantendo o histórico de prontuários arquivado pelo período estipulado pelas normativas do terceiro setor e de assistência social (5 anos), com posterior descarte seguro ou anonimização.
* **Motivação:** Garantir conformidade jurídica, respaldo legal na prestação de contas e respeito à privacidade dos assistidos.
* **Tipo:** Legislação e Governança de Dados.

---

### RN08 — Prestação de Contas e Relatórios Socioassistenciais
* **Descrição:** O sistema deve permitir a agregação de dados consolidados sobre o volume de atendimentos, perfil dos assistidos, doações recebidas e número de cestas distribuídas para a elaboração de relatórios destinados a órgãos parceiros (CRAS, SAS e doadores).
* **Motivação:** Atender às obrigações estatutárias da ONG e prestar contas de forma transparente sobre a aplicação dos recursos e doações recebidas.
* **Tipo:** Governança e Relatoria.

---

### RN09 — Validade e Integridade Físico-Sanitária dos Alimentos
* **Descrição:** Todos os alimentos e cestas básicas recebidos de doadores parceiros devem passar por verificação de prazo de validade e integridade física antes de serem registrados no sistema e disponibilizados para doação aos beneficiários.
* **Motivação:** Assegurar a segurança alimentar, a qualidade e a saúde dos assistidos pela instituição.
* **Tipo:** Regra de Controle e Qualidade de Doações.

---

### RN10 — Limite Estrutural Familiar e de Referências
* **Descrição:** Conforme a estrutura da ficha de cadastro da ONG, o sistema limita o registro direto na tabela de composição familiar a até 5 membros dependentes e a até 3 pessoas de contato/emergência na tabela de referências familiares.
* **Motivação:** Manter o alinhamento com o formulário físico de triagem e garantir a padronização no dimensionamento dos atendimentos e auxílios.
* **Tipo:** Validação de Dados / Restrição Estrutural.

---

### RN11 — Obrigatoriedade de Registro do Profissional Responsável (CRESS/CRP)
* **Descrição:** Todo atendimento socioassistencial, elaboração de PIA, concessão de auxílios e registro de doações deve obrigatoriamente estar vinculado a um profissional habilitado da equipe técnica cadastrado com seu respectivo registro no conselho de classe (ex.: CRESS ou CRP).
* **Motivação:** Garantir a responsabilidade técnica e legal pelas decisões e acompanhamentos sociais realizados na instituição.
* **Tipo:** Validação Operacional e Conformidade Técnica.

---

## 4. Dicionário de Dados e Especificação Técnica

### 4.0 Convenções de Engenharia de Dados e Governança

* **SGBD Alvo e Versão:** PostgreSQL (v15+) / MySQL (v8.0+)
* **Encoding e Collation:** `UTF-8` / `utf8mb4_unicode_ci`
* **Notação Formal:** Modelo Entidade-Relacionamento (Notação Chen / Merise)
* **Convenção de Nomenclatura:** Nomes de tabelas e atributos em minúsculo com separação por sublinhado (`snake_case`). Chaves primárias iniciadas com `id_`.
* **Política de Indexação:** Além das Chaves Primárias (PK) e Estrangeiras (FK), são criados índices B-Tree para otimização de busca frequente nos campos `cpf`, `nis` e `nome_completo`.
* **Governança de Dados e LGPD:**
  
* #### Governança de Dados, LGPD e Matriz de Papéis
> Diretrizes de conformidade jurídica, retenção e permissões de acesso baseadas nas normativas da LGPD e do SuAS.

**Classificação dos Dados:**
* **Interno:** Chaves, datas de controlo e dados operacionais (ex: `id_beneficiario`, `quantidade_cestas`).
* **Pessoal:** Dados pessoais comuns nos termos do Art. 5º, I da LGPD (ex: `nome`, `cpf`, `telefone`).
* **Sensível:** Dados pessoais sensíveis nos termos do Art. 5º, II da LGPD (ex: `cor_raca`, `orientacao_sexual`, `tem_alergias`).
* **Sigiloso:** Dados protegidos pelo sigilo profissional da triagem e assistência social (ex: `renda`, `demanda_inicial`, `metas_do_pia`).

**Retenção e Expurgo:**
* **Prazo de Retenção:** Os cadastros e prontuários são mantidos por **5 anos** após o último atendimento do beneficiário, em conformidade com as diretrizes do SuAS/CRAS.
* **Anonimização:** Após o prazo de retenção ou revogação de consentimento pelo titular, os dados identificáveis são anonimizados, preservando apenas os agregados estatísticos para prestação de contas (RN08).

**Matriz de Papéis por Operação (I: Inserir, L: Ler, A: Alterar, N: Anonimizar):**
| Categoria de Dados | TÉCNICO (Assistente Social / Psicólogo) | ADMIN (Coordenação / Presidência) | VOLUNTÁRIO (Recepção / Apoio) |
| :--- | :---: | :---: | :---: |
| **Internos e Pessoais** (Cadastro, Família, Trabalho) | I, L, A | I, L, A | L |
| **Sensíveis** (Raça, Deficiência, Alergias) | I, L, A | - | - |
| **Sigiloso** (Renda, Prontuários, PIA) | I, L, A | - | - |
| **Entrega de Cestas** (`entrega_cesta`) | I, L, A | L | I, L |

  * **Base Legal:** Art. 7º, I (Consentimento do Titular) e Art. 11, II, "a" (Cumprimento de obrigação legal/estatutária) da LGPD.
  * **Retenção de Dados:** Prontuários e fichas socioassistenciais são mantidos por 5 anos após o último atendimento do beneficiário, conforme diretrizes do SuAS/CRAS, sendo submetidos a expurgo ou anonimização após esse período.
  * **Papéis e Permissões:** 
    * `Admin / Assistente Social`: Acesso total (Leitura, Escrita, Alteração) a dados cadastrais e prontuários sensíveis.
    * `Operador / Voluntário`: Acesso restrito (Apenas Leitura/Registro de Entregas) sem visualização de laudos e diagnósticos confidenciais.

---

### 4.1 Entidade: Beneficiário
*(Centraliza a identificação do cidadão assistido)*

| Atributo | Descrição | Regra / Função | Tipo Conceitual | Tipo Físico | Índice | Obrig. | Sensível / Papéis |
| :--- | :--- | :--- | :--- | :--- | :---: | :---: | :--- |
| `id_beneficiario` | Identificador único | PK do beneficiário | Numérico | `BIGINT AUTO_INCREMENT` | PK | Sim | Não (L/E: Admin) |
| `nis` | Identificação Social | Registro CadÚnico | Categórico | `VARCHAR(15)` | Index | Não | Não (L/E: Admin) |
| `cras_creas_sas` | Equipamento vinculado | Acompanhamento externo | Categórico | `VARCHAR(100)` | Não | Não | Não (L/E: Admin) |
| `nome_completo` | Nome civil | Identificação principal | Categórico | `VARCHAR(150)` | Index | Sim | Não (L/E: Todos) |
| `nome_social` | Nome de preferência | Respeito à identidade | Categórico | `VARCHAR(150)` | Não | Não | Não (L/E: Todos) |
| `sexo` | Sexo biológico/declarado | Marcação cadastral | Categórico | `CHAR(1)` | Não | Sim | Não (L/E: Admin) |
| `orientacao_sexual` | Orientação autodeclarada | Estatística / Perfil | Categórico | `VARCHAR(30)` | Não | Não | **Sim** (L/E: Assist. Social) |
| `data_nascimento` | Data de nascimento | Faixa etária e benefícios | Data | `DATE` | Não | Sim | Não (L/E: Admin) |
| `naturalidade` | Cidade/UF de origem | Perfil demográfico | Categórico | `VARCHAR(100)` | Não | Não | Não (L/E: Admin) |
| `cor_raca` | Cor/raça autodeclarada | Fins estatísticos | Categórico | `VARCHAR(20)` | Não | Não | **Sim** (L/E: Assist. Social) |
| `pessoa_com_deficiencia` | Condição de PCD / CID | Priorização e auxílio | Categórico | `VARCHAR(100)` | Não | Não | **Sim** (L/E: Assist. Social) |
| `tem_alergias` | Restrições alimentares | Segurança na doação | Categórico | `VARCHAR(150)` | Não | Não | **Sim** (L/E: Assist. Social) |
| `cpf` | Registro de CPF | Validação (RN01) | Categórico | `VARCHAR(14)` | Index/Unique | Não | **Sim** (L/E: Admin) |
| `rg_numero` | Documento RG | Identificação civil | Categórico | `VARCHAR(20)` | Não | Não | Não (L/E: Admin) |
| `rg_orgao_uf_emissor` | Órgão emissor RG | Detalhe do documento | Categórico | `VARCHAR(20)` | Não | Não | Não (L/E: Admin) |
| `rg_data_emissao` | Data de emissão RG | Validade do documento | Data | `DATE` | Não | Não | Não (L/E: Admin) |
| `estado_civil` | Estado civil | Perfil familiar | Categórico | `VARCHAR(20)` | Não | Não | Não (L/E: Admin) |
| `endereco` | Endereço residencial | Localização territorial | Categórico | `VARCHAR(200)` | Não | Sim | **Sim** (L/E: Admin) |
| `bairro` | Bairro | Mapeamento territorial | Categórico | `VARCHAR(100)` | Não | Não | Não (L/E: Admin) |
| `cep` | Código postal | Localização geográfica | Categórico | `VARCHAR(9)` | Não | Não | Não (L/E: Admin) |
| `telefone` | Telefone principal | Contato e recados | Categórico | `VARCHAR(20)` | Não | Não | Não (L/E: Admin) |
| `nome_mae` | Nome da mãe | Filiação | Categórico | `VARCHAR(150)` | Não | Não | Não (L/E: Admin) |
| `nome_pai` | Nome do pai | Filiação | Categórico | `VARCHAR(150)` | Não | Não | Não (L/E: Admin) |
| `escolaridade` | Nível de instrução | Encaminhamento EJA/cursos | Categórico | `VARCHAR(50)` | Não | Não | Não (L/E: Admin) |
| `estuda_atualmente` | Vínculo escolar atual | Diagnóstico social | Categórico | `VARCHAR(100)` | Não | Não | Não (L/E: Admin) |
| `recebe_transferencia_renda` | Programas de transferência | Análise de vulnerabilidade | Categórico | `VARCHAR(100)` | Não | Não | **Sim** (L/E: Assist. Social) |
| `recebe_bpc` | Recebimento de BPC | Análise de vulnerabilidade | Categórico | `VARCHAR(50)` | Não | Não | **Sim** (L/E: Assist. Social) |

---

### 4.2 Entidade: Trabalho
*(Perfil ocupacional e socioeconômico)*

| Atributo | Descrição | Regra / Função | Tipo Conceitual | Tipo Físico | Índice | Obrig. | Sensível / Papéis |
| :--- | :--- | :--- | :--- | :--- | :---: | :---: | :--- |
| `id_trabalho` | Identificador único | PK do registro | Numérico | `BIGINT AUTO_INCREMENT` | PK | Sim | Não (L/E: Admin) |
| `id_beneficiario` | Beneficiário vinculado | FK para Beneficiário | Numérico | `BIGINT` | FK | Sim | Não (L/E: Admin) |
| `situacao_ocupacional` | Condição de trabalho | Análise socioeconômica | Categórico | `VARCHAR(50)` | Não | Sim | Não (L/E: Admin) |
| `profissao_habilidades` | Habilidades e cursos | Encaminhamento profissional | Categórico | `TEXT` | Não | Não | Não (L/E: Admin) |
| `renda_atual` | Renda mensal individual | Avaliação de renda per capita | Numérico | `DECIMAL(10,2)` | Não | Não | **Sim** (L/E: Assist. Social) |
| `empresa_trabalho` | Nome do empregador | Vínculo de trabalho | Categórico | `VARCHAR(150)` | Não | Não | Não (L/E: Admin) |
| `ocupacao_atual` | Função exercida | Perfil profissional | Categórico | `VARCHAR(100)` | Não | Não | Não (L/E: Admin) |
| `telefone_trabalho` | Telefone comercial | Contato de trabalho | Categórico | `VARCHAR(20)` | Não | Não | Não (L/E: Admin) |

---

### 4.3 Entidade: Composição Familiar (`composicao_familiar`)
*(Ficha da ONG, pág. 2: Composição Familiar. Limite da ficha: até 5 membros por beneficiário)*

| Atributo | Descrição | Regra / Função | Tipo Conceitual | Tipo Físico | Índice | Obrig. | Classe |
| :--- | :--- | :--- | :--- | :--- | :---: | :---: | :--- |
| `id_membro` | Identificador do membro | PK do membro familiar | Identificador | `BIGINT UNSIGNED AUTO_INCREMENT` | PK | Sim | Interno |
| `id_beneficiario` | Titular da família | FK para Beneficiário (máx. 5) | Identificador (FK) | `BIGINT UNSIGNED` | FK | Sim | Interno |
| `nome` | Nome civil do familiar | Identificação do dependente | Texto | `VARCHAR(150)` | Não | Sim | Pessoal |
| `idade` | Idade em anos | Dimensionamento de auxílio | Numérico | `TINYINT UNSIGNED` | Não | Sim | Pessoal |
| `parentesco_vinculo` | Grau de parentesco | Relação com o titular | Categórico | `VARCHAR(50)` | Não | Sim | Pessoal |

---

### 4.4 Entidade: Referencia_Familiar
*(Pessoas de contato externo e emergência)*

| Atributo | Descrição | Regra / Função | Tipo Conceitual | Tipo Físico | Índice | Obrig. | Sensível / Papéis |
| :--- | :--- | :--- | :--- | :--- | :---: | :---: | :--- |
| `id_referencia` | Identificador do contato | PK da referência | Numérico | `BIGINT AUTO_INCREMENT` | PK | Sim | Não (L/E: Admin) |
| `id_beneficiario` | Beneficiário vinculado | FK para Beneficiário | Numérico | `BIGINT` | FK | Sim | Não (L/E: Admin) |
| `nome` | Nome do contato | Referência de emergência | Categórico | `VARCHAR(150)` | Não | Sim | Não (L/E: Admin) |
| `parentesco_vinculo` | Relação/vínculo | Ex: Amigo, Vizinho | Categórico | `VARCHAR(50)` | Não | Não | Não (L/E: Admin) |
| `telefone` | Telefone de contato | Comunicação de emergência | Categórico | `VARCHAR(20)` | Não | Não | Não (L/E: Admin) |

---

### 4.5 Entidade: Atendimento
*(Registro das entrevistas e anamneses sociais)*

| Atributo | Descrição | Regra / Função | Tipo Conceitual | Tipo Físico | Índice | Obrig. | Sensível / Papéis |
| :--- | :--- | :--- | :--- | :--- | :---: | :---: | :--- |
| `id_atendimento` | Identificador da sessão | PK do atendimento | Numérico | `BIGINT AUTO_INCREMENT` | PK | Sim | Não (L/E: Todos) |
| `id_beneficiario` | Beneficiário atendido | FK para Beneficiário | Numérico | `BIGINT` | FK | Sim | Não (L/E: Todos) |
| `id_profissional` | Técnico condutor | FK para Profissional | Numérico | `BIGINT` | FK | Sim | Não (L/E: Todos) |
| `data_atendimento` | Data do atendimento | Rastreabilidade temporal | Data | `DATE` | Index | Sim | Não (L/E: Todos) |
| `demanda_inicial` | Necessidade relatada | Diagnóstico da triagem | Categórico | `TEXT` | Não | Sim | **Sim** (L/E: Assist. Social) |

---

### 4.6 Entidade: Encaminhamento (`encaminhamento_atendimento`)
*(Ficha da ONG, pág. 2: Encaminhamentos Realizados. Possui identificador próprio)*

| Atributo | Descrição | Regra / Função | Tipo Conceitual | Tipo Físico | Índice | Obrig. | Classe |
| :--- | :--- | :--- | :--- | :--- | :---: | :---: | :--- |
| `id_encaminhamento` | Identificador único | PK própria da entidade | Identificador | `BIGINT UNSIGNED AUTO_INCREMENT` | PK | Sim | Interno |
| `id_atendimento` | Atendimento de origem | FK para Atendimento | Identificador (FK) | `BIGINT UNSIGNED` | FK | Sim | Interno |
| `tipo_encaminhamento` | Categoria do encaminhamento | Lista fechada de opções | Categórico | `VARCHAR(60)` | Unique | Sim | Sigiloso |
| `detalhe_outros` | Especificação técnica | Usado apenas se tipo for "Outros" | Texto | `TEXT` | Não | Cond. | Sigiloso |

---

### 4.7 Entidade: Profissional_Responsavel
*(Equipe técnica e assistentes sociais)*

| Atributo | Descrição | Regra / Função | Tipo Conceitual | Tipo Físico | Índice | Obrig. | Sensível / Papéis |
| :--- | :--- | :--- | :--- | :--- | :---: | :---: | :--- |
| `id_profissional` | Identificador do profissional | PK do profissional | Numérico | `BIGINT AUTO_INCREMENT` | PK | Sim | Não (L/E: Admin) |
| `nome` | Nome completo | Identificação da equipe | Categórico | `VARCHAR(150)` | Não | Sim | Não (L/E: Admin) |
| `funcao` | Cargo / Função | Nível de acesso | Categórico | `VARCHAR(50)` | Não | Sim | Não (L/E: Admin) |
| `registro_profissional` | Conselho de classe | Ex: CRESS / CRP | Categórico | `VARCHAR(30)` | Não | Sim | Não (L/E: Admin) |

---

### 4.8 Entidade: PIA (Plano Individual de Atendimento)
*(Acompanhamento continuado e evolução social - RN04)*

| Atributo | Descrição | Regra / Função | Tipo Conceitual | Tipo Físico | Índice | Obrig. | Sensível / Papéis |
| :--- | :--- | :--- | :--- | :--- | :---: | :---: | :--- |
| `id_pia` | Identificador do plano | PK do PIA | Numérico | `BIGINT AUTO_INCREMENT` | PK | Sim | Não (L/E: Assist. Social) |
| `id_beneficiario` | Beneficiário titular | FK para Beneficiário | Numérico | `BIGINT` | FK | Sim | Não (L/E: Assist. Social) |
| `id_profissional` | Técnico responsável | FK para Profissional | Numérico | `BIGINT` | FK | Sim | Não (L/E: Assist. Social) |
| `data_criacao` | Data de elaboração | Registro de início | Data | `DATE` | Não | Sim | Não (L/E: Assist. Social) |
| `metas_objetivos` | Metas de autonomia | Planejamento continuado | Categórico | `TEXT` | Não | Sim | **Sim** (L/E: Assist. Social) |
| `prazo_reavaliacao` | Previsão de retorno | Agendamento de revisão | Data | `DATE` | Não | Não | Não (L/E: Assist. Social) |

---

### 4.9 Entidade: Entrega_Cesta
*(Registro e auditoria de doações diretas - RN05 e RN06)*

| Atributo | Descrição | Regra / Função | Tipo Conceitual | Tipo Físico | Índice | Obrig. | Sensível / Papéis |
| :--- | :--- | :--- | :--- | :--- | :---: | :---: | :--- |
| `id_entrega` | Identificador da entrega | PK da entrega | Numérico | `BIGINT AUTO_INCREMENT` | PK | Sim | Não (L/E: Todos) |
| `id_beneficiario` | Beneficiário recebedor | FK para Beneficiário | Numérico | `BIGINT` | FK | Sim | Não (L/E: Todos) |
| `id_profissional` | Técnico autorizador | FK para Profissional | Numérico | `BIGINT` | FK | Sim | Não (L/E: Todos) |
| `data_entrega` | Data de concessão | Controle de ciclo/ periodicidade | Data | `DATE` | Index | Sim | Não (L/E: Todos) |
| `quantidade_cestas` | Volume concedido | Gestão de doação | Numérico | `INT` | Não | Sim | Não (L/E: Todos) |
| `itens_adicionais` | Doações complementares | Registro de doações extras | Categórico | `TEXT` | Não | Não | Não (L/E: Todos) |

---

### 4.10 Fluxo de Dados Resumido Entre Entidades
O fluxo inicia-se no cadastro central do **BENEFICIÁRIO**, que desdobra seus dados socioeconômicos e dependentes nas entidades **TRABALHO**, **COMPOSIÇÃO_FAMILIAR** e **REFERÊNCIA_FAMILIAR**. Cada interação presencial gera um **ATENDIMENTO** conduzido por um **PROFISSIONAL_RESPONSÁVEL**, que por sua vez pode derivar um ou mais **ENCAMINHAMENTOS_ATENDIMENTO** para a rede externa, registrar a concessão de auxílios diretos em **ENTREGA_CESTA**, ou estruturar o acompanhamento de longo prazo criando um **PIA**. 

## 4.11 Tabelas Técnicas de Apoio
> Tabelas de apoio ao sistema. Não são entidades do negócio da ONG, por isso não aparecem no DER e não possuem chave estrangeira.

### Entidade Técnica: Log de Acesso (`log_acesso`)
*(Auditoria - RNF06 e Governança LGPD)*

| Atributo | Descrição | Regra / Função | Tipo Conceitual | Tipo Físico | Índice | Obrig. | Classe |
| :--- | :--- | :--- | :--- | :--- | :---: | :---: | :--- |
| `id_log` | Identificador do log | Sequencial | Identificador | `BIGINT UNSIGNED AUTO_INCREMENT` | PK | Sim | Interno |
| `data_hora` | Data e hora da operação | Preenchido pelo banco | Data | `DATETIME` | Index | Sim | Interno |
| `usuario` | Login de quem fez a operação | Vem de `@app_usuario` | Categórico | `VARCHAR(60)` | Index | Sim | Pessoal |
| `papel` | Papel do usuário | TECNICO, ADMIN, VOLUNTARIO | Categórico | `VARCHAR(10)` | Não | Sim | Interno |
| `operacao` | Tipo de operação | LEITURA, INSERCAO, ALTERACAO, ANONIMIZACAO | Categórico | `VARCHAR(12)` | Não | Sim | Interno |
| `tabela_afetada` | Tabela da operação | Rastreabilidade | Categórico | `VARCHAR(30)` | Index | Sim | Interno |
| `id_registro` | ID da linha afetada | Rastreabilidade | Identificador | `BIGINT UNSIGNED` | Index | Sim | Interno |
| `campos_alterados` | Campos modificados | Sem valores (proteção LGPD) | Texto | `TEXT` | Não | Não | Interno |
| `ip_origem` | IP de origem | Vem de `@app_ip` | Categórico | `VARCHAR(45)` | Não | Sim | Pessoal |

### Entidade Técnica: Parâmetros das Regras (`parametro_regra`)
*(Limites das regras de cesta - RN06)*

| Atributo | Descrição | Regra / Função | Tipo Conceitual | Tipo Físico | Índice | Obrig. | Classe |
| :--- | :--- | :--- | :--- | :--- | :---: | :---: | :--- |
| `id_parametro` | Identificador do parâmetro | Sequencial | Identificador | `BIGINT UNSIGNED AUTO_INCREMENT` | PK | Sim | Interno |
| `nome_parametro` | Nome do parâmetro | Lido pelo trigger de validação | Categórico | `VARCHAR(40)` | Unique | Sim | Interno |
| `valor` | Valor em vigor | Renda máxima ou dias | Numérico | `DECIMAL(10,2)` | Não | Sim | Interno |
| `unidade` | Unidade do valor | R$, dias | Categórico | `VARCHAR(4)` | Não | Sim | Interno |
| `data_atualizacao` | Data da última alteração | Preenchido pelo banco | Data | `DATETIME` | Não | Sim | Interno |

### 4.12 Fluxo de Dados Resumido do Sistema
> Mapeamento do ciclo de vida da informação desde a recepção até o expurgo LGPD.

1. **Recepção e Termo LGPD:** O assistido assina o termo de consentimento LGPD e é registrado em `beneficiario` (`data_consentimento` preenchida e `situacao_cadastro = 'ATIVO'`).
2. **Triagem Socioassistencial:** O profissional habilitado conduz a entrevista e gera um registro em `atendimento`, inserindo a demanda inicial e calculando a renda per capita da família, além de atualizar o perfil em `trabalho`, `composicao_familiar` e `referencia_familiar`.
3. **Desdobramentos do Atendimento:** A partir do atendimento, o sistema permite derivar encaminhamentos externos (`encaminhamento_atendimento`), conceder cestas básicas (`entrega_cesta`, validando elegibilidade de renda e intervalo de entrega) e iniciar o acompanhamento continuado (`pia`).
4. **Consultas e Relatórios:** O histórico do assistido pode ser consultado para acompanhamento (RF06), gerando relatórios agregados e anonimizados para prestação de contas aos órgãos parceiros (RN08).
5. **Auditoria em Tempo Real:** Qualquer inserção, alteração, anonimização ou consulta a dados sensíveis é gravada na tabela de suporte `log_acesso`.
6. **Encerrando o Ciclo (LGPD):** Após 5 anos do último atendimento, ou por solicitação do titular, o cadastro é submetido à rotina de anonimização (`situacao_cadastro = 'ANONIMIZADO'`).

---

## 5. Modelagem Conceitual - Entidades e Relacionamentos
> Visão 5.1: Modelo Conceitual do BD

### Entidades Reconhecidas
* **`BENEFICIÁRIO`**: Centraliza os dados individuais e cadastrais do cidadão atendido.
* **`TRABALHO`**: Armazena o perfil ocupacional, renda e dados do local de trabalho de forma isolada do beneficiário.
* **`COMPOSIÇÃO_FAMILIAR`**: Guarda as informações dos membros que residem no mesmo domicílio.
* **`REFERÊNCIA_FAMILIAR`**: Armazena os contactos externos e de emergência do beneficiário.
* **`ATENDIMENTO`**: Registra as sessões de triagem, demandas iniciais e profissionais responsáveis.
* **`PROFISSIONAL_RESPONSAVEL`**: Cadastra a equipa técnica que realiza os atendimentos na ONG.
* **`ENCAMINHAMENTO_ATENDIMENTO`**: Registra os direcionamentos e encaminhamentos externos gerados a partir de um atendimento.
* **`PIA`**: Registra o Plano Individual de Atendimento e as metas de acompanhamento continuado da família.
* **`ENTREGA_CESTA`**: Armazena o registro histórico da distribuição de cestas básicas e auxílios materiais aos beneficiários.
* **`RECEBIMENTO_DOACAO`**: Armazena o registro histórico de entradas de mantimentos e doações oriundas de parceiros estratégicos (como Banco de Alimentos e Cidade Invisível).



### Relacionamentos e Cardinalidades
* **BENEFICIÁRIO (1,1) --- POSSUI --- (0,n) TRABALHO**: Um beneficiário pode possuir registros de trabalho associados ao seu perfil ocupacional, e cada registo de trabalho pertence a um único beneficiário.
* **BENEFICIÁRIO (1,1) --- POSSUI --- (0,n) COMPOSIÇÃO_FAMILIAR**: Cada membro da composição familiar pertence obrigatoriamente a um único beneficiário titular, e um beneficiário pode possuir vários membros familiares cadastrados.
* **BENEFICIÁRIO (1,1) --- POSSUI --- (0,n) REFERÊNCIA_FAMILIAR**: Um beneficiário titular pode registar referências de apoio, e cada referência está vinculada a um único beneficiário.
* **BENEFICIÁRIO (1,1) --- SOLICITA --- (0,n) ATENDIMENTO**: Um beneficiário pode solicitar múltiplos atendimentos ao longo do tempo, e cada atendimento está vinculado a um único beneficiário solicitante.
* **PROFISSIONAL_RESPONSAVEL (1,1) --- CONDUZ --- (0,n) ATENDIMENTO**: Um profissional da equipa técnica pode conduzir vários atendimentos, e cada atendimento é conduzido por um único profissional responsável.
* **ATENDIMENTO (1,n) --- GERA --- (1,n) ENCAMINHAMENTO_ATENDIMENTO**: Um atendimento pode gerar um ou mais encaminhamentos externos, resolvido estruturalmente pela tabela associativa.
* **BENEFICIÁRIO (1,1) --- POSSUI --- (0,n) PIA**: Um beneficiário pode possuir planos de atendimento continuado ao longo de sua evolução na ONG, e cada PIA pertence a um único beneficiário.
* **PROFISSIONAL_RESPONSAVEL (1,1) --- ELABORA --- (0,n) PIA**: Um profissional técnico pode elaborar múltiplos planos de atendimento, e cada PIA é elaborado por um único profissional responsável.
* **BENEFICIÁRIO (1,1) --- RECEBE --- (0,n) ENTREGA_CESTA**: Um beneficiário pode receber múltiplas entregas de cestas básicas ao longo do tempo, e cada entrega está vinculada a um único beneficiário.
* **PROFISSIONAL_RESPONSAVEL (1,1) --- REGISTRA --- (0,n) ENTREGA_CESTA**: Um profissional pode registrar várias entregas de auxílios, e cada entrega é registrada por um único profissional.
* **PROFISSIONAL_RESPONSAVEL (1,1) --- REGISTRA --- (0,n) RECEBIMENTO_DOACAO**: Um profissional pode registrar várias doações recebidas de parceiros, e cada registro de doação é efetuado por um único profissional responsável.



---

## 6. Diagrama Entidade-Relacionamento (DER)
> Visão 6.1: O seu DER para a ONG

![Diagrama Entidade-Relacionamento](diagrama-der.jpg)

---

## 7. Justificativa Técnica
> Visão 7.1: Explicar as escolhas da modelagem do BD para a ONG.

### Escolha das Entidades e Atribuição de Atributos
* **BENEFICIÁRIO:** Entidade central do sistema. Armazena os dados demográficos e de identificação individual do assistido (`cpf`, `nis`, `nome_completo`, `data_nascimento`, `escolaridade`, `pessoa_com_deficiencia`, `orientacao_sexual`, etc.). O endereço foi modelado para detalhamento geográfico.
* **TRABALHO:** Entidade isolada para armazenar as informações socioeconômicas e ocupacionais (`renda_atual`, `situacao_ocupacional`, `empresa_trabalho`, `ocupacao_atual`, `telefone_trabalho`), garantindo a normalização adequada em relação aos dados pessoais do beneficiário.
* **COMPOSIÇÃO_FAMILIAR:** Guarda `nome`, `nome_social`, `idade` e `parentesco_vinculo` dos moradores da mesma residência, identificada unicamente por `id_membro`.
* **REFERÊNCIA_FAMILIAR:** Guarda `nome`, `nome_social`, `parentesco_vinculo`, `telefone` e endereço da pessoa de contato externo para emergências.
* **ATENDIMENTO:** Mapeia os encontros entre a equipe técnica e o assistido através da chave `id_atendimento`, vinculando o `id_profissional`, a `data_atendimento` e a `demanda_inicial`.
* **PROFISSIONAL_RESPONSAVEL:** Controla o cadastro da equipe com `id_profissional`, `nome`, `nome_social`, `funcao` e `registro_profissional`.
* **ENCAMINHAMENTO_ATENDIMENTO:** Tabela associativa que mapeia as ações institucionais através das chaves estrangeiras provenientes de `ATENDIMENTO` para assegurar a integridade referencial.
* **PIA:** Entidade essencial para cumprir a regra de negócio **RN04** e o requisito funcional **RF05**. Permite registrar a evolução temporal, objetivos e metas traçadas pela assistente social para a autonomia da família atendida, desvinculando o acompanhamento contínuo de um simples histórico de atendimento pontual.
* **ENTREGA_CESTA:** Entidade criada para gerenciar de forma transparente a principal atividade de auxílio direto da ONG (conforme **RN05** e **RN06**). Evita que a concessão de cestas básicas seja tratada apenas como um "tipo de encaminhamento", permitindo auditar quantidades, datas e evitar duplicidades indevidas no mesmo ciclo sem avaliação prévia.
* **RECEBIMENTO_DOACAO:** Criada para suprir a lacuna de rastreabilidade de entradas de mantimentos. Armazena a data, o parceiro doador, os itens recebidos e a quantidade, permitindo auditar o fluxo de arrecadação sem a necessidade de um controle complexo de estoque físico.



### Justificativa das Cardinalidades do Modelo
* **BENEFICIÁRIO (1,1) --- POSSUI --- (0,n) TRABALHO:** Todo registro ocupacional pertence obrigatoriamente a exatamente 1 beneficiário titular (1,1). Já o beneficiário pode ter 0 (desempregado/sem registro) ou múltiplos registros de histórico profissional (0,n).
* **BENEFICIÁRIO (1,1) --- POSSUI --- (0,n) COMPOSIÇÃO_FAMILIAR:** Cada dependente está associado a exatamente 1 titular (1,1). O beneficiário pode morar sozinho (0) ou possuir vários dependentes cadastrados (0,n).
* **BENEFICIÁRIO (1,1) --- POSSUI --- (0,n) REFERÊNCIA_FAMILIAR:** Cada contato de emergência pertence a 1 beneficiário (1,1), e este pode não registrar referências (0) ou indicar múltiplos contatos (0,n).
* **BENEFICIÁRIO (1,1) --- SOLICITA --- (0,n) ATENDIMENTO:** Cada atendimento é de 1 único beneficiário (1,1). O beneficiário pode estar recém-cadastrado sem atendimento (0) ou possuir vários atendimentos no histórico (0,n).
* **PROFISSIONAL_RESPONSAVEL (1,1) --- CONDUZ --- (0,n) ATENDIMENTO:** Cada atendimento é assinado por 1 único profissional (1,1). O técnico pode não ter conduzido nenhum atendimento ainda (0) ou conduzir vários (0,n).
* **BENEFICIÁRIO (1,1) --- POSSUI --- (0,n) PIA:** Cada Plano Individual pertence a 1 beneficiário (1,1), que pode não ter PIA ativo (0) ou possuir múltiplos planos ao longo do tempo (0,n).
* **BENEFICIÁRIO (1,1) --- RECEBE --- (0,n) ENTREGA_CESTA:** Cada entrega de cesta é destinada a 1 beneficiário (1,1). O assistido pode não ter recebido cestas ainda (0) ou ter um histórico de entregas periódicas (0,n).
* **ATENDIMENTO (1,1) --- GERA --- (0,n) ENCAMINHAMENTO_ATENDIMENTO:** Cada registro de encaminhamento deriva obrigatoriamente de exatamente 1 atendimento de origem (1,1). Por sua vez, um atendimento presencial pode resolver a demanda sem gerar encaminhamentos (0) ou desdobrar-se em múltiplos encaminhamentos externos (0,n).
* **PROFISSIONAL_RESPONSAVEL (1,1) --- REGISTRA --- (0,n) RECEBIMENTO_DOACAO:** Garante a autoria e a responsabilidade institucional pelo registro de entrada das doações no sistema, vinculando o operador técnico a cada lote recebido.


### Decisões de Abstração e Alternativas Rejeitadas
* **Uso de PKs Sintéticas (`id_*`):** Rejeitou-se o uso de `cpf` ou `nis` como Chave Primária (PK) em `BENEFICIÁRIO`, pois indivíduos em extrema vulnerabilidade podem não possuir esses documentos no primeiro atendimento.
* **Normalização de Listas e Tabelas Secundárias (1FN):** Manter os membros da família, dados de trabalho ou encaminhamentos na própria tabela de beneficiários geraria campos repetitivos ou dados atômicos violados (1ª Forma Normal). A criação de entidades separadas garante escalabilidade e previne redundâncias.
* **Correção de Cardinalidades Ambíguas:** Eliminaram-se as cardinalidades duplas `(1,n)` em ambas as pontas apontadas na avaliação anterior, substituindo-as por associações estruturalmente corretas `(1,1) para (0,n)` em relações de 1 para N.
* **Histórico Atemporal:** Transformar atendimentos e encaminhamentos em entidades independentes vinculadas por chaves estrangeiras permite rastrear a evolução do atendimento do cidadão sem sobrescrever dados históricos.

---

## 8. Uso de Inteligência Artificial
> Registro detalhado do uso de ferramentas de Inteligência Artificial no apoio à estruturação técnico-acadêmica, modelagem conceitual e validação de dados do projeto.

* **Ferramentas de IA utilizadas:** Google Gemini, OpenAI ChatGPT e Anthropic Claude.
* **Etapas de uso:** 
  * Estruturação e formatação da documentação técnica em Markdown e transcrição do Dicionário de Dados.
  * Compreensão profunda e refinamento dos fluxos operacionais e regras de negócio da Organização Social.
  * Mapeamento e análise crítica de riscos de modelagem e restrições legais (como conformidade com a LGPD).
  * Construção, refinamento e validação detalhada do dicionário de dados conceitual por entidades.
  * Verificação rigorosa de cardinalidades e relacionamentos, eliminando ambiguidades lógicas e pontas duplas indevidas.
  * Identificação e correção iterativa de possíveis erros conceituais, estruturais e de normalização (1FN).
* **Motivação:** Elevar o rigor técnico do projeto utilizando uma abordagem multilocal/multimodelos, permitindo cruzar diferentes perspectivas arquiteturais das IAs para garantir que o modelo relacional estivesse robusto, livre de inconsistências e alinhado às melhores práticas de bancos de dados, além de atender estritamente aos critérios de correção do professor.
* **Prompt(s) utilizados (exemplos):** 
  * *"Analise as regras de negócio e a ficha de triagem da ONG Nossa Senhora de Fátima para identificar potenciais riscos de modelagem, falhas de normalização e inconsistências estruturais."*
  * *"Com base nos apontamentos do professor, ajude a revisar e corrigir as cardinalidades dos relacionamentos (substituindo pontas duplas 1,n por 1,1 e 0,n onde aplicável) e a isolar a entidade Trabalho de forma normalizada."*
  * *"Organize a documentação técnica e estruture as tabelas do dicionário de dados conceitual no esqueleto Markdown exigido."*
* **Fontes e verificações:** O grupo submeteu as propostas das IAs a uma curadoria rigorosa, cruzando cada sugestão diretamente com a ficha física real da ONG, com a teoria de modelagem relacional de banco de dados e com as observações apontadas na avaliação docente.
* **Rejeições/Correções:** Diversas sugestões iniciais geradas pelas IAs precisaram de ajustes manuais, como a readequação de nomes de atributos para o padrão `snake_case`, a correção de cardinalidades que vieram inicialmente ambíguas e a adaptação de termos genéricos para a realidade específica da assistência social brasileira (CRAS, CADÚnico, PIA).
* **Justificativa da Escolha Final e Reflexão Crítica:** O uso conjunto de LLMs (Gemini, ChatGPT e Claude) atuou como uma camada preliminar de auditoria e estruturação documental. Contudo, a decisão arquitetural final foi estritamente humana e baseada nos critérios normativos de modelagem de dados e nas exigências técnicas da assistência social. Todas as sugestões das IAs foram submetidas ao crivo do grupo: rejeitamos a criação de tabelas desnecessárias (como estoque físico, fora do escopo do modelo conceitual) e mantivemos o foco nas entidades centrais exigidas pela rotina presencial da ONG e pelo professor (como PIA e Entrega de Cestas), garantindo a fidelidade às diretrizes do SuAS/LGPD.

---

## 9. Conclusão e Avaliação dos Integrantes

### Considerações Finais
O desenvolvimento e refinamento iterativo da modelagem conceitual para a Organização Social Nossa Senhora de Fátima permitiu ao grupo vivenciar na prática a transição de um processo puramente manual (baseado em papel) para uma arquitetura de dados relacional moderna, normalizada e estruturada. O projeto possibilitou transpor os desafios teóricos para a realidade prática, corrigindo inconsistências estruturais — como o isolamento adequado de perfis ocupacionais e o ajuste rigoroso de cardinalidades. O sistema proposto solucionará os principais problemas apontados pela equipe técnica: a perda de agilidade nos atendimentos, a dificuldade no acompanhamento histórico dos beneficiários e a estrita adequação às diretrizes da LGPD no tratamento de dados sensíveis e socioeconômicos.

---

## 10. Referências
* ORGANIZAÇÃO SOCIAL NOSSA SENHORA DE FÁTIMA. **Ficha de Cadastro e Triagem Socioassistencial**. São Paulo, 2026. Entrevista e pesquisa de campo concedidas à equipe acadêmica.

