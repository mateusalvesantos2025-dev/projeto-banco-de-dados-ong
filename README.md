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

Com base no diagnóstico da triagem, a ONG realiza o atendimento direto (como a montagem e concessão de cestas básicas conforme a disponibilidade de doações e necessidade do beneficiário) ou efetua encaminhamentos externos para a rede socioassistencial e órgãos parceiros (saúde mental, assistência jurídica, habitação e empregabilidade).

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
| Acompanhamento familiar continuado (PIA) | Acompanhamento | Parcial (suportado via histórico de atendimentos) |
| Avaliação e concessão de cestas básicas / auxílio alimentação | Doação/Auxílio | Parcial (registrado como tipo de encaminhamento) |
| Controle de passeios e eventos socioeducativos | Atendimento | Parcial (registrado via ficha de atendimento) |
| Gestão e histórico de prontuários do beneficiário | Gestão | Coberta (através do id_beneficiario e atendimentos) |
| Gestão de estoque físico de alimentos e doações | Físico | Ausente (fora do escopo do modelo conceitual) |
| Agenda de atendimentos e escala de profissionais | Operacional | Ausente (não previsto na ficha atual) |
| Prestação de contas e relatórios socioassistenciais (CRAS/SAS) | Relatório | Ausente (requer agregação de dados em fase futura) |

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
* **RNF01 — Segurança e Sigilo de Dados:** O acesso às informações sensíveis e prontuários da triagem deve ser restrito a operadores autorizados, em conformidade com a LGPD.
* **RNF02 — Desempenho de Consulta:** As consultas de beneficiários por CPF/NIS ou nome devem retornar resultados em no máximo 2 segundos.
* **RNF03 — Integridade Relacional:** O banco de dados deve assegurar a integridade referencial por meio de chaves primárias e estrangeiras obrigatórias.
* **RNF04 — Disponibilidade e Acesso Local:** O sistema deve garantir a persistência segura dos dados utilizando um SGBD relacional padronizado.
* **RNF05 — Portabilidade do Modelo:** O diagrama entidade-relacionamento (DER) e o dicionário de dados devem ser documentados em formatos acessíveis (PDF, Markdown e imagens).
* **RNF06 — Auditoria de Registros:** O sistema deve manter o registo de data e operador associado aos lançamentos de triagem e atendimento.


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
* **Descrição:** Nenhum beneficiário poderá receber encaminhamentos para a rede externa de apoio ou participar de programas continuados sem que haja pelo menos um registro de triagem social válido e atualizado.
* **Motivação:** Garantir que os auxílios sejam destinados prioritariamente às famílias que realmente passam por avaliação de vulnerabilidade.
* **Tipo:** Regra de Processo / Fluxo de Atendimento.

---

### RN04 — Acompanhamento Continuado (PIA)
* **Descrição:** Famílias inseridas no Plano Individual de Atendimento (PIA) devem ter seus registros de acompanhamento vinculados ao histórico do atendimento social conduzido pela assistente social.
* **Motivação:** Permitir a evolução temporal do quadro socioeconômico da família e o acompanhamento das metas de autonomia.
* **Tipo:** Acompanhamento / Histórico.

---

### RN05 — Concessão Variável de Cestas Básicas e Doações
* **Descrição:** A distribuição de cestas básicas e itens de doação não possui quantidade fixa por beneficiário; ela varia estritamente em função da disponibilidade de estoque/doações e do grau de necessidade apurado na triagem.
* **Motivação:** Refletir a realidade operacional da ONG, onde a oferta depende de doadores e a demanda é priorizada pela assistente social.
* **Tipo:** Regra Operacional de Doação.

---

### RN06 — Controle de Duplicidade na Entrega de Auxílios
* **Descrição:** O sistema deve permitir o registro de cada entrega efetuada (data e itens) para evitar que o mesmo beneficiário receba auxílios duplicados no mesmo ciclo de distribuição sem nova avaliação social.
* **Motivação:** Assegurar a distribuição justa e transparente dos recursos limitados da ONG.
* **Tipo:** Regra de Controle e Auditoria.

---

### RN07 — Retenção e Consentimento de Dados Sensíveis
* **Descrição:** O cadastro de informações socioeconômicas e laudos exige o consentimento do titular (ou responsável legal), mantendo o histórico de atendimentos arquivado pelo período legal estipulado para ONGs e serviços socioassistenciais.
* **Motivação:** Conformidade jurídica e respaldo legal na prestação de contas.
* **Tipo:** Legislação e Governança de Dados.
---

## 4. Dicionário de Dados Conceitual (Atualizado)

### 4.1 Entidade: Beneficiário
*(Reflete a Seção "Dados do Beneficiário", "Filiação" e "Educação" da ficha)*

| Atributo | Descrição | Regra de negócio associada | Tipo | Domínio / Formato | Obrig. |
| :--- | :--- | :--- | :--- | :--- | :---: |
| `id_beneficiario` | Identificador único do beneficiário no sistema | Gerado automaticamente no cadastro; nunca reutilizado | Numérico (PK) | Sequencial | Sim |
| `nis` | Número de Identificação Social no CadÚnico | Cruzamento com CRAS/CREAS/SAS | Categórico | Texto | Não |
| `cras_creas_sas` | Unidade socioassistencial vinculada | Indica o equipamento público que acompanha o caso | Categórico | Texto | Não |
| `nome_completo` | Nome civil do beneficiário | Campo básico e obrigatório de identificação | Categórico | Texto | Sim |
| `nome_social` | Nome de preferência do beneficiário | Priorizado no atendimento presencial | Categórico | Texto | Não |
| `sexo` | Sexo do beneficiário | Campo de marcação única | Categórico | (F, M) | Sim |
| `orientacao_sexual` | Orientação sexual autodeclarada | Dado sensível (LGPD); acesso restrito | Categórico | (Hetero, Homo, Bi, LGBTQIA+, Outros) | Não |
| `data_nascimento` | Data de nascimento do beneficiário | Base para cálculo de idade e benefícios | Data | DD/MM/AAAA | Sim |
| `naturalidade` | Município e estado de nascimento | Perfil socioeconômico | Categórico | Texto | Não |
| `cor_raca` | Cor/raça autodeclarada | Dado sensível (LGPD); fins estatísticos | Categórico | (Branco, Negro, Indígena, Pardo) | Não |
| `pessoa_com_deficiencia` | Indica se possui deficiência e o CID | Dado sensível (LGPD); priorização | Categórico | (Não; Sim - CID) | Não |
| `tem_alergias` | Indica se possui alergias relevantes | Relevante para doações de alimentos | Categórico | (Não; Sim - Qual) | Não |
| `cpf` | Número do CPF | Identificador único complementar; evita duplicidade | Categórico | 000.000.000-00 | Não |
| `rg_numero` | Número do RG | Documento de identificação civil | Categórico | Texto | Não |
| `rg_orgao_uf_emissor` | Órgão emissor e UF do RG | Detalha a origem do documento | Categórico | Texto (ex: SSP/SP) | Não |
| `rg_data_emissao` | Data de emissão do RG | Verifica atualização do documento | Data | DD/MM/AAAA | Não |
| `estado_civil` | Estado civil do beneficiário | Lista fechada de opções cadastrais | Categórico | (Solteiro, Casado, Divorciado, Viúvo) | Não |
| `endereco` | Endereço residencial do beneficiário | Necessário para visitas e doações | Categórico | Texto | Sim |
| `bairro` | Bairro de residência | Mapeamento territorial de atuação | Categórico | Texto | Não |
| `cep` | CEP do endereço residencial | Triagem e localização territorial | Categórico | 00000-000 | Não |
| `telefone` | Telefone principal de contato | Agendamento e aviso de atendimentos | Categórico | (00) 00000-0000 | Não |
| `nome_mae` | Nome da mãe do beneficiário | Filiação complementar para identificação | Categórico | Texto | Não |
| `nome_pai` | Nome do pai do beneficiário | Filiação complementar | Categórico | Texto | Não |
| `escolaridade` | Nível de escolaridade concluído | Orienta encaminhamentos para EJA/cursos | Categórico | (Analfabeto, Fundamental, Médio, Superior) | Não |
| `estuda_atualmente` | Indica se estuda no momento e onde | Planejamento de encaminhamentos | Categórico | (Não; Sim - Onde) | Não |
| `recebe_transferencia_renda` | Indica se recebe benefício social | Evita duplicidade de concessões | Categórico | (Não; Sim - Qual) | Não |
| `recebe_bpc` | Indica se recebe BPC | Priorização socioassistencial | Categórico | (Não; Sim - Idoso; Sim - PcD) | Não |

### 4.2 Entidade: Trabalho
*(Reflete o Bloco de Perfil Ocupacional e Renda da ficha — Separado conforme exigência da modelagem)*

| Atributo | Descrição | Regra de negócio associada | Tipo | Domínio / Formato | Obrig. |
| :--- | :--- | :--- | :--- | :--- | :---: |
| `id_trabalho` | Identificador único do registro de trabalho | Gerado a cada registro profissional vinculado | Numérico (PK) | Sequencial | Sim |
| `id_beneficiario` | Beneficiário titular do vínculo trabalhista | Relaciona o trabalho ao beneficiário correspondente | Numérico (FK) | Existir em Beneficiário | Sim |
| `situacao_ocupacional` | Situação de trabalho atual | Avaliação de vulnerabilidade socioeconômica | Categórico | (Empregado, Desempregado, Autônomo) | Sim |
| `profissao_habilidades` | Profissão ou habilidades autodeclaradas | Encaminhamento a vagas e capacitação | Categórico | Texto livre | Não |
| `renda_atual` | Renda mensal individual | Dado financeiro restrito; dimensiona o apoio | Numérico | Decimal (R$) | Não |
| `empresa_trabalho` | Nome da empresa onde trabalha | Preenchido para vínculos formais ou informais | Categórico | Texto | Não |
| `ocupacao_atual` | Ocupação exercida no momento | Identificação da função real exercida | Categórico | Texto | Não |
| `telefone_trabalho` | Telefone do local de trabalho | Contato profissional alternativo | Categórico | (00) 00000-0000 | Não |

### 4.3 Entidade: Membro_Familia
*(Reflete a Tabela "Composição Familiar", Pág. 2 da ficha)*

| Atributo | Descrição | Regra de negócio associada | Tipo | Domínio / Formato | Obrig. |
| :--- | :--- | :--- | :--- | :--- | :---: |
| `id_membro` | Identificador único do integrante | Gerado a cada dependente cadastrado | Numérico (PK) | Sequencial | Sim |
| `id_beneficiario` | Beneficiário titular do cadastro | Vincula o dependente ao titular | Numérico (FK) | Existir em Beneficiário | Sim |
| `nome` | Nome do familiar | Limite máximo de até 5 integrantes | Categórico | Texto | Sim |
| `idade` | Idade do familiar no cadastro | Dimensiona cestas e encaminhamentos | Numérico | Inteiro | Sim |
| `parentesco_vinculo` | Relação de parentesco com o titular | Identifica dependência (filho, cônjuge, etc.) | Categórico | Texto | Sim |

### 4.4 Entidade: Referencia_Familiar
*(Reflete o Bloco "Referência Familiar", Pág. 2 da ficha)*

| Atributo | Descrição | Regra de negócio associada | Tipo | Domínio / Formato | Obrig. |
| :--- | :--- | :--- | :--- | :--- | :---: |
| `id_referencia` | Identificador único da referência | Gerado a cada contato adicionado | Numérico (PK) | Sequencial | Sim |
| `id_beneficiario` | Beneficiário titular do cadastro | Vincula a referência ao beneficiário | Numérico (FK) | Existir em Beneficiário | Sim |
| `nome` | Nome do contato de referência | Limite de até 3 referências de emergência | Categórico | Texto | Sim |
| `parentesco_vinculo` | Grau de relação/vínculo | Ex.: vizinho, amigo, parente | Categórico | Texto | Não |
| `telefone` | Telefone de contato da referência | Usado em caso de inacessibilidade | Categórico | (00) 00000-0000 | Não |

### 4.5 Entidade: Atendimento
*(Reflete o Bloco "Demanda Inicial Apresentada" + Assinatura)*

| Atributo | Descrição | Regra de negócio associada | Tipo | Domínio / Formato | Obrig. |
| :--- | :--- | :--- | :--- | :--- | :---: |
| `id_atendimento` | Identificador único do atendimento | Permite histórico de múltiplos atendimentos | Numérico (PK) | Sequencial | Sim |
| `id_beneficiario` | Beneficiário atendido | Todo atendimento pertence a 1 beneficiário | Numérico (FK) | Existir em Beneficiário | Sim |
| `id_profissional` | Técnico responsável pela sessão | Exige identificação do profissional habilitado | Numérico (FK) | Existir em Profissional | Sim |
| `data_atendimento` | Data de realização do atendimento | Data da sessão técnica | Data | DD/MM/AAAA | Sim |
| `demanda_inicial` | Necessidade declarada na triagem | Origina os encaminhamentos sociais | Categórico | Texto livre | Sim |

* **Domínio de `tipo_encaminhamento` (30 opções padronizadas):** Atualização cadastral CAD Único/PTR; Inclusão em programa de transferência de renda; Inclusão no BPC; Orientação de débito de contas de consumo; Regularização de documentação civil; Transporte Urbano (Bilhete Único Especial); Passagem Intermunicipal/Interestadual; Alimentação (Bom Prato/Cesta Básica); Solicitação de Carteira do Idoso; INSS (orientação/aposentadoria/auxílio); Inserção Rede Socioassistencial Básica; Inserção Rede Socioassistencial Especial; Inserção Rede Socioassistencial Local; Inserção Rede Setorial SAS Mooca; Orientação ao Imigrante; Habitação Social (MCMV/CDHU/COHAB); Capacitação Profissional; Inserção no mercado de trabalho; Educação (EJA/Técnico/Faculdade); Tratamento de Saúde; Curso de Informática; Curso de Idiomas; Curso de Educação Financeira; Defesa e proteção ao Idoso; Defesa e proteção à PcD; Defesa e proteção à mulher; Defesa e proteção à criança e adolescente; Defesa dos direitos LGBTQIA+; Defesa e proteção animal; Outros. Qual?


### 4.6 Entidade: Encaminhamento_Atendimento
*(Tabela Relacional - Mapeia os encaminhamentos gerados por atendimento)*

| Atributo | Descrição | Regra de negócio associada | Tipo | Domínio / Formato | Obrig. |
| :--- | :--- | :--- | :--- | :--- | :---: |
| `id_atendimento` | Atendimento que gerou a ação | Chave estrangeira e primária composta | Numérico (FK/PK) | Existir em Atendimento | Sim |
| `tipo_encaminhamento` | Categoria do encaminhamento | Domínio fechado de opções padronizadas | Categórico (PK) | Lista padronizada | Sim |
| `detalhe_outros` | Especificação para "Outros" | Preenchido apenas se o tipo for "Outros" | Categórico | Texto | Não |

### 4.7 Entidade: Profissional_Responsavel
*(Reflete a Assinatura do Técnico)*

| Atributo | Descrição | Regra de negócio associada | Tipo | Domínio / Formato | Obrig. |
| :--- | :--- | :--- | :--- | :--- | :---: |
| `id_profissional` | Identificador único do técnico | Gerado no cadastro da equipe técnica | Numérico (PK) | Sequencial | Sim |
| `nome` | Nome completo do profissional | Identificação do responsável técnico | Categórico | Texto | Sim |
| `funcao` | Cargo/função exercida na ONG | Controla níveis de acesso a dados sensíveis | Categórico | Texto | Sim |
| `registro_profissional` | Número no conselho de classe | Validação legal (ex.: CRESS/CRP) | Categórico | Texto | Sim |

### 4.8 Entidade: PIA (Plano Individual de Atendimento)
*(Reflete o acompanhamento continuado exigido pela RN04 e RF05)*

| Atributo | Descrição | Regra de negócio associada | Tipo | Domínio / Formato | Obrig. |
| :--- | :--- | :--- | :--- | :--- | :---: |
| `id_pia` | Identificador único do plano de atendimento | Gerado a cada novo plano de acompanhamento | Numérico (PK) | Sequencial | Sim |
| `id_beneficiario` | Beneficiário titular do plano | Vincula o PIA ao beneficiário assistido | Numérico (FK) | Existir em Beneficiário | Sim |
| `id_profissional` | Técnico responsável pela elaboração | Identifica o profissional habilitado | Numérico (FK) | Existir em Profissional | Sim |
| `data_criacao` | Data de início ou atualização do plano | Rastreabilidade temporal da evolução | Data | DD/MM/AAAA | Sim |
| `metas_objetivos` | Metas de autonomia e evolução traçadas | Acompanhamento da superação da vulnerabilidade | Categórico | Texto livre | Sim |
| `prazo_reavaliacao` | Previsão para reavaliação do quadro | Controle de andamento continuado | Data | DD/MM/AAAA | Não |

### 4.9 Entidade: Entrega_Cesta (Controle de Doações e Auxílios)
*(Reflete a concessão variável de cestas básicas - RN05 e RN06)*

| Atributo | Descrição | Regra de negócio associada | Tipo | Domínio / Formato | Obrig. |
| :--- | :--- | :--- | :--- | :--- | :---: |
| `id_entrega` | Identificador único da entrega de auxílio | Controla o histórico de concessões | Numérico (PK) | Sequencial | Sim |
| `id_beneficiario` | Beneficiário recebedor do auxílio | Evita duplicidades sem nova triagem (RN06) | Numérico (FK) | Existir em Beneficiário | Sim |
| `id_profissional` | Profissional que autorizou/registrou a entrega | Auditoria e responsabilidade técnica | Numérico (FK) | Existir em Profissional | Sim |
| `data_entrega` | Data em que a cesta/doação foi entregue | Rastreabilidade do ciclo de distribuição | Data | DD/MM/AAAA | Sim |
| `quantidade_cestas` | Quantidade de cestas básicas concedidas | Concessão variável conforme estoque (RN05) | Numérico | Inteiro | Sim |
| `itens_adicionais` | Descrição de itens extras doados (ex: roupas, leite) | Registro detalhado da doação | Categórico | Texto livre | Não |

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


### Relacionamentos e Cardinalidades
* **BENEFICIÁRIO (1,1) --- POSSUI --- (0,n) TRABALHO:** Um beneficiário pode possuir registros de trabalho associados ao seu perfil ocupacional, e cada registro de trabalho pertence a um único beneficiário.
* **BENEFICIÁRIO (1,1) --- POSSUI --- (0,n) COMPOSIÇÃO_FAMILIAR:** Cada membro da composição familiar pertence obrigatoriamente a um único beneficiário titular, e um beneficiário pode possuir vários membros familiares cadastrados.
* **BENEFICIÁRIO (1,1) --- POSSUI --- (0,n) REFERÊNCIA_FAMILIAR:** Um beneficiário titular pode registrar referências de apoio, e cada referência está vinculada a um único beneficiário.
* **BENEFICIÁRIO (1,1) --- SOLICITA --- (0,n) ATENDIMENTO:** Um beneficiário pode solicitar múltiplos atendimentos ao longo do tempo, e cada atendimento está vinculado a um único beneficiário solicitante.
* **PROFISSIONAL_RESPONSAVEL (1,1) --- CONDUZ --- (0,n) ATENDIMENTO:** Um profissional da equipe técnica pode conduzir vários atendimentos, e cada atendimento é conduzido por um único profissional responsável.
* **ATENDIMENTO (1,n) --- GERA --- (1,n) ENCAMINHAMENTO_ATENDIMENTO:** Um atendimento pode gerar um ou mais encaminhamentos externos, resolvido estruturalmente pela tabela associativa.

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
* **Reflexão crítica:** O uso conjunto do Gemini, ChatGPT e Claude funcionou como um comitê de revisão técnica de alta eficiência, acelerando a depuração de erros e a formatação documental. No entanto, o discernimento técnico, a tomada de decisões de projeto, a validação com a assistente social da ONG e a responsabilidade integral pelo código e pela modelagem permaneceram exclusivamente sob o controle do grupo.

---

## 9. Conclusão e Avaliação dos Integrantes

### Considerações Finais
O desenvolvimento e refinamento iterativo da modelagem conceitual para a Organização Social Nossa Senhora de Fátima permitiu ao grupo vivenciar na prática a transição de um processo puramente manual (baseado em papel) para uma arquitetura de dados relacional moderna, normalizada e estruturada. O projeto possibilitou transpor os desafios teóricos para a realidade prática, corrigindo inconsistências estruturais — como o isolamento adequado de perfis ocupacionais e o ajuste rigoroso de cardinalidades. O sistema proposto solucionará os principais problemas apontados pela equipe técnica: a perda de agilidade nos atendimentos, a dificuldade no acompanhamento histórico dos beneficiários e a estrita adequação às diretrizes da LGPD no tratamento de dados sensíveis e socioeconômicos.

---

## 10. Referências
* ORGANIZAÇÃO SOCIAL NOSSA SENHORA DE FÁTIMA. **Ficha de Cadastro e Triagem Socioassistencial**. São Paulo, 2026. Entrevista e pesquisa de campo concedidas à equipe acadêmica.

