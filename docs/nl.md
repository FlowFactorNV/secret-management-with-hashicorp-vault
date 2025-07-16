# Secret Management with HashiCorp Vault

16 Juni 2025

---

# Executive summary

Het project richtte zich op de uitrol van twee aparte EKS-clusters: één voor de applicatie-
omgeving en één voor ondersteunende tooling zoals CI/CD en secret management. Centraal
binnen dit project stonden technologieën zoals HashiCorp Vault voor veilig secret
management, Terraform voor Infrastructure as Code, Helm voor Kubernetes applicatiebeheer
en FluxCD voor GitOps-gebaseerde automatisering.

Onze taken omvatten onder andere de volledige automatisering van de infrastructuur, het
opzetten van veilige multi-cluster communicatie, de integratie van een service mesh voor
microservices communicatie, en het bouwen van CI/CD pipelines met een self-hosted GitLab
Runner. Daarnaast ontwikkelden we een aanpak voor veilig en efficiënt secret management,
inclusief key rotation en het gebruik van short-lived credentials.

Door deze opdracht hebben we niet alleen diepgaande technische kennis opgedaan in
moderne cloud native technologieën, maar ook ervaring verworven met het bouwen van
schaalbare en onderhoudbare omgevingen volgens best practices. Dit systeemdossier biedt
een overzicht van de gehanteerde werkwijze, gebruikte technologieën, opgeleverde
componenten en onze leerervaringen.

# Inhoudsopgave

- [1. Inleiding](#1-inleiding)
- [2. Voorstelling van het bedrijf](#2-voorstelling-van-het-bedrijf)
- [3. Beschrijving van de opdracht](#3-beschrijving-van-de-opdracht)
- [4. Systeemarchitectuur](#4-systeemarchitectuur)
- [5. AWS-infrastructuur](#5-aws-infrastructuur)
- [6. Applicatie cluster (EKS-applicatie)](#6-applicatie-cluster--eks-applicatie-)
- [7. Tooling cluster (EKS-tooling)](#7-tooling-cluster--eks-tooling-)
- [8. Verdieping op de gebruikte tools](#8-verdieping-op-de-gebruikte-tools)
  * [8.1 Terraform (Infrastructure as Code)](#81-terraform--infrastructure-as-code-)
    + [8.1.1 Terraform - Wat is het?](#811-terraform---wat-is-het-)
    + [8.1.2 Terraform - How werkt het?](#812-terraform---how-werkt-het-)
    + [8.1.3 Terraform - Waarom gekozen?](#813-terraform---waarom-gekozen-)
    + [8.1.4 Terraform - Hoe geïmplementeerd?](#814-terraform---hoe-ge-mplementeerd-)
    + [8.1.5 Terraform - Voordelen](#815-terraform---voordelen)
    + [8.1.6 Terraform - Nadelen](#816-terraform---nadelen)
  * [8.2 Helm](#82-helm)
    + [8.2.1 Helm - Wat is het?](#821-helm---wat-is-het-)
    + [8.2.2 Helm - Onderdelen van Helm](#822-helm---onderdelen-van-helm)
    + [8.2.3 Helm - Hoe werkt het?](#823-helm---hoe-werkt-het-)
    + [8.2.4 Helm - Waarom gekozen?](#824-helm---waarom-gekozen-)
    + [8.2.5 Helm - Hoe geïmplementeerd?](#825-helm---hoe-ge-mplementeerd-)
    + [8.2.6 Helm - Voordelen](#826-helm---voordelen)
    + [8.2.7 Helm - Nadelen](#827-helm---nadelen)
  * [8.3 GitOps (FluxCD)](#83-gitops--fluxcd-)
    + [8.3.1 FluxCD - Wat is het?](#831-fluxcd---wat-is-het-)
    + [8.3.2 FluxCD - Onderdelen van FluxCD](#832-fluxcd---onderdelen-van-fluxcd)
    + [8.3.3 FluxCD - Hoe werkt het?](#833-fluxcd---hoe-werkt-het-)
    + [8.3.4 FluxCD - Waarom gekozen?](#834-fluxcd---waarom-gekozen-)
    + [8.3.5 FluxCD - Hoe geïmplementeerd?](#835-fluxcd---hoe-ge-mplementeerd-)
    + [8.3.6 FluxCD - Voordelen](#836-fluxcd---voordelen)
    + [8.3.7 FluxCD - Nadelen](#837-fluxcd---nadelen)
  * [8.4 - Self-hosted GitLab runner](#84---self-hosted-gitlab-runner)
    + [8.4.1 GitLab runner - Wat is het?](#841-gitlab-runner---wat-is-het-)
    + [8.4.2 GitLab runner - Onderdelen van Gitlab Runner](#842-gitlab-runner---onderdelen-van-gitlab-runner)
    + [8.4.3 GitLab runner - Hoe werkt het?](#843-gitlab-runner---hoe-werkt-het-)
    + [8.4.4 GitLab runner - Waarom gekozen?](#844-gitlab-runner---waarom-gekozen-)
    + [8.4.5 GitLab runner - Hoe geïmplementeerd?](#845-gitlab-runner---hoe-ge-mplementeerd-)
    + [8.4.6 GitLab runner - Alternatieven](#846-gitlab-runner---alternatieven)
    + [8.4.7 GitLab runner - Voordelen](#847-gitlab-runner---voordelen)
    + [8.4.8 GitLab runner - Nadelen](#848-gitlab-runner---nadelen)
  * [8.5 Service Mesh (Istio)](#85-service-mesh--istio-)
    + [8.5.1 Istio - Wat is het?](#851-istio---wat-is-het-)
    + [8.5.2 Istio - Onderdelen van Istio](#852-istio---onderdelen-van-istio)
    + [8.5.3 Istio - Hoe werkt het?](#853-istio---hoe-werkt-het-)
    + [8.5.3 Istio - Waarom gekozen?](#853-istio---waarom-gekozen-)
    + [8.5.4 Istio - Hoe geïmplementeerd?](#854-istio---hoe-ge-mplementeerd-)
    + [8.5.5 Istio - Voordelen](#855-istio---voordelen)
    + [8.5.6 Istio - Nadelen](#856-istio---nadelen)
    + [8.5.7 Istio - Alternatieven](#857-istio---alternatieven)
  * [8.6 HashiCorp Vault](#86-hashicorp-vault)
    + [8.6.7 HashiCorp Vault - Wat is het?](#867-hashicorp-vault---wat-is-het-)
    + [8.6.8 HashiCorp Vault - Onderdelen van Vault](#868-hashicorp-vault---onderdelen-van-vault)
    + [8.6.8 HashiCorp Vault - Hoe werkt het?](#868-hashicorp-vault---hoe-werkt-het-)
    + [8.6.9 HashiCorp Vault - Waarom gekozen?](#869-hashicorp-vault---waarom-gekozen-)
    + [8.6.10 HashiCorp Vault - Hoe geïmplementeerd?](#8610-hashicorp-vault---hoe-ge-mplementeerd-)
    + [8.6.11 HashiCorp Vault - Voordelen](#8611-hashicorp-vault---voordelen)
    + [8.6.12 HashiCorp Vault - Vault agent flow](#8612-hashicorp-vault---vault-agent-flow)
    + [8.6.13 HashiCorp Vault - Database engine flow](#8613-hashicorp-vault---database-engine-flow)
  * [8.7 External Secret Operator](#87-external-secret-operator)
    + [8.7.1 External Secret Operator - Wat is het probleem?](#871-external-secret-operator---wat-is-het-probleem-)
    + [8.7.2 External Secret Operator - Wat is de oplossing?](#872-external-secret-operator---wat-is-de-oplossing-)
- [9. Gebruikersscenario: externe toegang tot Vault](#9-gebruikersscenario--externe-toegang-tot-vault)
  * [9.1 Network Load Balancer (NLB)](#91-network-load-balancer--nlb-)
    + [9.1.1 Network Load Balancer - Wat is het?](#911-network-load-balancer---wat-is-het-)
    + [9.1.2 Network Load Balancer - Hoe werkt het?](#912-network-load-balancer---hoe-werkt-het-)
    + [9.1.3 Network Load Balancer - Waarom gekozen?](#913-network-load-balancer---waarom-gekozen-)
    + [9.1.4 Network Load Balancer - Hoe geïmplementeerd?](#914-network-load-balancer---hoe-ge-mplementeerd-)
    + [9.1.5 Network Load Balancer - Voordelen](#915-network-load-balancer---voordelen)
    + [9.1.6 Network Load Balancer - Nadelen](#916-network-load-balancer---nadelen)
  * [9.2 Network Load Balancer - Target group en health check](#92-network-load-balancer---target-group-en-health-check)
  * [9.3 Route 53 Private Hosted Zone](#93-route-53-private-hosted-zone)
    + [9.3.1 Route 53 Private Hosted Zone - Wat is het?](#931-route-53-private-hosted-zone---wat-is-het-)
    + [9.3.1 Route 53 Private Hosted Zone - Waarom gekozen?](#931-route-53-private-hosted-zone---waarom-gekozen-)
    + [9.3.1 Route 53 Private Hosted Zone - Hoe geïmplementeerd?](#931-route-53-private-hosted-zone---hoe-ge-mplementeerd-)
    + [9.3.2 Route 53 Private Hosted Zone - Voordelen](#932-route-53-private-hosted-zone---voordelen)
    + [9.3.3 Route 53 Private Hosted Zone - Nadelen](#933-route-53-private-hosted-zone---nadelen)
  * [9.4 VPN](#94-vpn)
    + [9.4.1 VPN - Wat is het?](#941-vpn---wat-is-het-)
    + [9.4.2 VPN - Waarom gekozen?](#942-vpn---waarom-gekozen-)
    + [9.4.3 VPN - Hoe geïmplementeerd?](#943-vpn---hoe-ge-mplementeerd-)
- [10. Installatiehandleiding](#10-installatiehandleiding)
  * [10.1 Vereisten](#101-vereisten)
  * [10.2 Clonen van de infrastructuur repository](#102-clonen-van-de-infrastructuur-repository)
  * [10.3 Terraform initialisatie](#103-terraform-initialisatie)
  * [10.4 GitOps-automatisering via FluxCD](#104-gitops-automatisering-via-fluxcd)
  * [10.5 Vault recovery bij eerste bootstrap](#105-vault-recovery-bij-eerste-bootstrap)
  * [10.6 GitLab-runner instellen](#106-gitlab-runner-instellen)
  * [10.7 VPN Configuratie (voor externe toegang tot Vault)](#107-vpn-configuratie--voor-externe-toegang-tot-vault-)
  * [10.8 Overzicht van de Deployment Flow](#108-overzicht-van-de-deployment-flow)
  * [10.9 Resultaat](#109-resultaat)
- [11. Conclusie en reflectie](#11-conclusie-en-reflectie)

# 1. Inleiding

Wij kregen de opdracht om een Kubernetes-gebaseerde infrastructuur op
AWS te ontwerpen, automatiseren en beveiligen. Dit project speelt in op actuele noden binnen
de IT-sector: het bouwen van veilige, flexibel beheersbare en volledig geautomatiseerde
cloudomgevingen. Bedrijven willen snel kunnen schalen, CI/CD-processen efficiënt beheren
en gevoelige gegevens veilig afhandelen — en dat zonder manuele configuratie of publieke
blootstelling van interne systemen.

De infrastructuur bestaat uit twee gescheiden EKS-clusters:

- een applicatie cluster voor frontend, backend, databases, service mesh en FluxCD
- een tooling cluster voor ondersteunende diensten zoals Vault, FluxCD en een self-
hosted GitLab Runner

Het doel was een veilige, uitbreidbare omgeving te realiseren via Infrastructure as Code
(Terraform), GitOps (FluxCD), met groot belang voor secret management met HashiCorp
Vault, ondersteund door een service mesh (Istio) en een interne DNS-laag (Route 53).

In dit systeemdossier wordt het volledige traject stap voor stap beschreven: van de architectuur
keuzes tot de technische implementatie. Er wordt toegelicht hoe de componenten
samenwerken, welke voordelen dit oplevert en hoe het geheel beheersbaar blijft. Het
document dient zowel als bewijs van de geleverde opdracht, als naslagwerk voor toekomstige
verdere ontwikkeling en gebruik.

# 2. Voorstelling van het bedrijf

FlowFactor NV is een Belgisch software adviesbureau, opgericht op 9 mei 2017 en gevestigd
in Kontich. Het bedrijf is actief in het domein van cloud native softwareontwikkeling en richt
zich voornamelijk op het begeleiden van organisaties bij hun digitale transformatie. FlowFactor
helpt klanten om hun IT-infrastructuur te moderniseren door in te zetten op automatisering,
schaalbaarheid en betrouwbaarheid.

FlowFactor heeft een sterke focus op reactieve architecturen en DevOps-praktijken. Deze
specialisatie stelt het bedrijf in staat om hoogperformante en veerkrachtige applicaties te
ondersteunen, onder andere via schaalbare microservices en event-driven systemen.

Het team van FlowFactor bestaat uit een twintigtal consultants, elk met diepgaande technische
kennis op vlak van Kubernetes, GitOps, Infrastructure as Code (IaC), CI/CD, en cloud
infrastructuren in platformen zoals AWS, Azure en OpenShift. Door deze brede expertise kan
FlowFactor bedrijven begeleiden bij het uitrollen van moderne IT-oplossingen die afgestemd
zijn op de noden van snelheid, betrouwbaarheid en operationele efficiëntie.

De dienstverlening van FlowFactor gaat verder dan technische implementatie. Het bedrijf
hecht veel belang aan kennisdeling, best practices en het trainen van interne teams. Klanten
worden niet alleen technisch ondersteund, maar ook strategisch begeleid in het duurzaam
opbouwen van een future-proof IT-infrastructuur.

Kortom, FlowFactor positioneert zich als een betrouwbare technologiepartner voor
organisaties die willen evolueren naar een cloud native manier van werken, met een sterke
nadruk op automatisering, flexibiliteit en continue levering.

# 3. Beschrijving van de opdracht

De opdracht vertrok vanuit een groeiend beveiligingsvraagstuk in moderne
cloudomgevingen: hoe kunnen gevoelige gegevens zoals API-sleutels,
databasewachtwoorden en certificaten veilig en efficiënt beheerd worden in dynamische
infrastructuren? In omgevingen waarin applicaties continu worden deployed en geüpdatet, is
het beheren van deze zogenaamde secrets cruciaal voor zowel veiligheid als
betrouwbaarheid.

Binnen deze context kregen wij de opdracht om een volledige cloud-native infrastructuur op te
zetten in AWS, met bijzondere focus op het verkennen, evalueren en implementeren van
HashiCorp Vault als centrale secret manager. HashiCorp Vault is een toonaangevende
oplossing voor secret management, die onder andere ondersteuning biedt voor short-lived
credentials, fine-grained access control, geautomatiseerde rotatie van secrets, en integratie
met Kubernetes.

Het doel van de opdracht was om te onderzoeken op welke manieren Vault kan worden ingezet
in een productieklare infrastructuur, hoe het zich verhoudt tot andere methoden van secret
management, en welke afwegingen er gemaakt moeten worden tussen beveiliging en
flexibiliteit. Concreet moesten we verschillende deployment modellen van Vault analyseren
(zoals server mode en agent mode), diverse authenticatie- en autorisatiemethoden
configureren (waaronder AppRole en Kubernetes JWT), en Vault integreren in een werkende
Kubernetes-omgeving.

Een belangrijk deel van de opdracht bestond uit het opzetten van een veilige,
geautomatiseerde workflow voor het beheren van secrets in een microservices context. We
onderzochten hoe applicaties veilig toegang krijgen tot secrets zonder dat deze lokaal
opgeslagen moeten worden, en hoe Vault dynamisch credentials kan genereren voor
bijvoorbeeld databases. Naast de technische implementatie, analyseerden we de beveiliging
implicaties van elke gekozen benadering en documenteerden we onze bevindingen met het
oog op hergebruik in professionele omgevingen.

# 4. Systeemarchitectuur

![Systeemarchitectuur](img/system-architecture.png)

Onze infrastructuur is volledig opgebouwd binnen AWS en maakt gebruik van enkele
fundamentele bouwstenen voor schaalbaarheid, veiligheid en beheerbaarheid. Om een
duidelijke scheiding te maken tussen applicatielogica en ondersteunende infrastructuur,
hebben we bewust gekozen voor een opdeling in twee afzonderlijke Kubernetes-clusters
(EKS): een applicatie cluster en een tooling cluster. Deze aanpak verhoogt de veiligheid,
vereenvoudigt het beheer en maakt het mogelijk om beide omgevingen onafhankelijk van
elkaar te schalen of te onderhouden.

# 5. AWS-infrastructuur

Voor toegang tot de applicatie gebruiken we een Application Load Balancer (ALB) die HTTP-
verkeer routeert naar de frontend en backend van onze toepassing. Deze ALB zorgt voor een
gecontroleerde en gestructureerde toegang tot de verschillende applicatiecomponenten.

Daarnaast hebben we een interne Network Load Balancer (NLB) opgezet die poort 8200
beschikbaar stelt voor veilige toegang tot de HashiCorp Vault. De NLB is uitsluitend binnen
het VPC bereikbaar en ontvangt verkeer via een VPN-verbinding, waardoor Vault ook extern
veilig benaderd kan worden zonder publiek beschikbaar te zijn.

Om interne diensten zoals Vault overzichtelijk bereikbaar te maken, gebruiken we Route 53
private DNS, waarbij de domeinnaam vault.internal wordt gekoppeld aan de url van de Network
Load Balancer.

# 6. Applicatie cluster (EKS-applicatie)

De applicatie cluster bevat de core services van een demo applicatie: een frontend, een
backend en databases. Binnen deze cluster wordt ook een service mesh toegepast (via Istio)
om interne communicatie tussen microservices te beveiligen en te beheren. Alle componenten
binnen deze cluster gebruiken DNS-resolutie via Route 53 om met Vault te communiceren via
het interne domein _vault.internal_.

Door deze componenten te scheiden van de infrastructuurdiensten, blijven de ontwikkel- en
runtime-omgevingen zuiver gescheiden, wat de stabiliteit en veiligheid ten goede komt.

# 7. Tooling cluster (EKS-tooling)

De tooling cluster omvat onder andere HashiCorp Vault, FluxCD en een self-hosted GitLab
Runner. Vault fungeert hier als centraal secret managementsysteem, terwijl FluxCD instaat
voor de GitOps-automatisering van beide clusters. De Network LoadBalancer die Vault
exposed, bevindt zich eveneens binnen deze cluster en wordt intern benaderd, of extern via
de VPN-verbinding.

Door deze opbouw ontstaat een modulaire architectuur die veiligheid en eenvoud combineert.
Beheerscomponenten zoals Vault kunnen los van applicaties worden onderhouden of
aangepast, terwijl developers zich in de applicatie cluster kunnen concentreren op
softwareontwikkeling en deployment.

# 8. Verdieping op de gebruikte tools

## 8.1 Terraform (Infrastructure as Code)

### 8.1.1 Terraform - Wat is het?

Terraform is een open-source tool ontwikkeld door HashiCorp waarmee infrastructuur
geautomatiseerd beheerd kan worden via code. In plaats van manueel resources aan te
maken in een cloud console, wordt infrastructuur beschreven in een declaratieve taal (HCL –
HashiCorp Configuration Language). Terraform zorgt er vervolgens zelf voor dat de gewenste
toestand bereikt wordt, ongeacht de huidige toestand van de infrastructuur.

### 8.1.2 Terraform - How werkt het?

Terraform leest configuratiebestanden waarin staat beschreven hoe de infrastructuur eruit
moet zien: denk aan netwerken, compute resources, databases, rollen en policies. Bij het
uitvoeren van een `terraform plan` vergelijkt Terraform de gewenste toestand (zoals
gedefinieerd in de code) met de bestaande infrastructuur, en stelt het exact die wijzigingen
voor, die nodig zijn om beide te laten overeenkomen. De uitvoer van `terraform apply` zorgt
ervoor dat deze wijzigingen effectief worden uitgevoerd.

### 8.1.3 Terraform - Waarom gekozen?

Terraform biedt een betrouwbare, schaalbare en herhaalbare manier om cloudinfrastructuur
te beheren. Binnen ons project was het essentieel dat de infrastructuur:

- Volledig geautomatiseerd kon worden
- Versiebeheer mogelijk was
- Opgesplitst kon worden in herbruikbare modules
- Kon deployed worden in verschillende omgevingen (applicatie en tooling) zonder duplicatie van code

Terraform is bovendien de industriestandaard binnen Infrastructure as Code en sluit perfect
aan bij de andere tools in ons project, zoals Helm en FluxCD. Aangezien Terraform, net zoals
Vault, ook van Hashicorp is, werken ze naadloos samen.

### 8.1.4 Terraform - Hoe geïmplementeerd?

Binnen dit project vormt Terraform de centrale motor achter onze volledige AWS-infrastructuur.
Om het beheer schaalbaar, overzichtelijk en herbruikbaar te houden, hebben we de
configuratie opgesplitst in afzonderlijke herbruikbare modules en cluster-specifieke
configuraties. Deze structuur zorgt voor een duidelijke scheiding tussen generieke
infrastructuur logica en project- of omgevingsspecifieke parameters.

**Module bibliotheek (modules/)**

In deze centrale folder bevinden zich alle herbruikbare modules, elk verantwoordelijk voor één
specifiek infrastructuur onderdeel:

- vpc: bouwt de basis netwerkinfrastructuur met subnets, route tables en gateways
- iam: beheert rollen, policies en service accounts
- kms: genereert en beheert keys voor veilige opslag en toegang
- efs: stelt gedeelde bestanden beschikbaar via Elastic File System
- eks: maakt de Kubernetes-cluster aan, inclusief nodegroups en configuratie

Elke module bevat drie kernbestanden:
- `main.tf`: beschrijft de resources die Terraform zal aanmaken. Dit is het hart van de
module.
- `variables.tf`: definieert de inputparameters die nodig zijn om de module flexibel te maken. Denk
hierbij aan CIDR-blokken, naamgeving, instance types of regio’s.
- `outputs.tf`: geeft geselecteerde waarden van de gemaakte resources terug aan het
bovenliggende configuratieniveau. Deze outputs worden vaak gebruikt als input voor
andere modules of configuraties (bijvoorbeeld het VPC-ID doorgeven aan de EKS-
module).

Deze modulaire structuur zorgt ervoor dat complexe infrastructuur herleidbaar, aanpasbaar en
reproduceerbaar blijft. We hanteren hierbij het "80%-principe": elke module ondersteunt de
meest voorkomende configuraties, maar vermijdt overcomplicatie door niet elke edge-case te
ondersteunen.

**Cluster-specifieke configuratie**

Zowel de applicatie cluster als de tooling cluster hebben een eigen folderstructuur met
specifieke main.tf-bestanden die deze modules aanroepen. Binnen deze configuraties bepalen
we de concrete parameters zoals regio, subnet-ID’s, namen, CIDR-blokken, of EKS-node-
instellingen.

Deze indeling laat toe om beide clusters los van elkaar te beheren, wijzigingen door te voeren
in isolatie, of nieuwe omgevingen (bijv. staging of een cluster in een andere regio) eenvoudig
te creëren door een extra folder aan te maken met andere parameters, zonder enige duplicatie
van logica.

**Waarom een aparte applicatie en tooling cluster?**
We hebben bewust gekozen om de infrastructuur op te splitsen in twee afzonderlijke EKS-
clusters — één voor de applicatie, en één voor tooling zoals Vault, GitLab Runner en ESO —
omwille van de volgende redenen:

**1. Schaalbaarheid**
De applicatie cluster draait alle microservices, frontend/backend en ondersteunende
services die onderhevig zijn aan intensief schalen bij piekbelasting. Door tooling (zoals
Vault of GitLab Runner) te isoleren in een aparte cluster, voorkomen we dat deze
cruciale infrastructuurcomponenten onnodig moeten meeschalen of beïnvloed worden
door autoscaling events in de app-cluster.

**2. Beschikbaarheid & stabiliteit**
CI/CD en secret management moeten altijd beschikbaar blijven — ook als de applicatie
zelf wordt herstart, opgeschaald of gewijzigd. Door deze tooling los te trekken van de
workloads die ze beheren, verhogen we de stabiliteit en uptime van het platform als
geheel.

**3. Beveiliging**
De isolatie van clusters introduceert een sterke security boundary. Zo kunnen IAM
policies, netwerkregels en Kubernetes RBAC strikt gescheiden worden toegepast
tussen gebruikers van de applicatie cluster en beheersystemen in de tooling cluster.
Vault moet bijvoorbeeld alleen verkeer van specifieke pods uit de applicatie cluster toe
laten via de service mesh of een VPN-verbinding.

**4. Onafhankelijke lifecycle**
De tooling cluster evolueert op een ander tempo dan de applicatie cluster. Upgrades,
maintenance of herconfiguraties van bijvoorbeeld GitLab Runner of ESO kunnen
uitgevoerd worden zonder impact op productie services.

### 8.1.5 Terraform - Voordelen

- Herbruikbaarheid: dankzij modulaire opbouw is de infrastructuur eenvoudig aanpasbaar voor andere
omgevingen of projecten.

- Veiligheid en compliance: alle resources zijn gecentraliseerd beheerd en voorzien van
consistente tags, policies en lifecycle-beheer.

- Versiebeheer: elke wijziging in infrastructuur wordt via Git beheerd, met volledige zichtbaarheid
op wie wat wanneer heeft aangepast.

- Drift-detectie: Terraform detecteert afwijkingen tijdens het runnen tussen de werkelijke
toestand en de code, zodat we afwijkingen snel kunnen rechtzetten.

- Schaalbaarheid: nieuwe clusters of regio’s kunnen eenvoudig worden deployed door
het hergebruiken van bestaande modules met aangepaste parameters

### 8.1.6 Terraform - Nadelen

- Terraform vereist een duidelijke structuur en goede documentatie. Zonder deze
afspraken kunnen configuraties snel chaotisch worden.

- Voor complexe resources of uitzonderingen is soms een workaround of custom module
nodig.

- Terraform kent een leercurve; vooral bij foutmeldingen tijdens apply is debugging niet
altijd evident.


## 8.2 Helm

### 8.2.1 Helm - Wat is het?

Helm is een veelgebruikte standaard voor k8s package management. Het stelt teams in staat
om applicaties en infrastructuurcomponenten op een gestructureerde, herhaalbare manier te
deployen in een Kubernetes-cluster met de mogelijkheid tot versiebeheer. Helm maakt het
mogelijk om Kubernetes-manifests (zoals Deployments, Services en ConfigMaps) te bundelen
in zogeheten charts, waarmee complexe applicaties eenvoudig kunnen worden beheerd.

### 8.2.2 Helm - Onderdelen van Helm

Een Helm chart bestaat uit verschillende componenten die samen het gedrag van de installatie
bepalen:
- `Chart.yaml`: Metadata van de chart (naam, versie, beschrijving).
- `values.yaml`: Het standaard configuratiebestand waarin parameters gedefinieerd worden (zoals
versienummers, poorten, resources).
- `templates/`: Bevat de Kubernetes-manifests in Jinja-achtige template vorm. Tijdens
de installatie worden deze gevuld met waarden uit values.yaml.
- `Charts/` (optioneel): Subcharts die als afhankelijkheden worden meegenomen.
- `Templates/_*.tpl`: Bevat herbruikbare template snippets, zoals
naamgevingsconventies.

Deze structuur maakt het mogelijk om dezelfde chart in verschillende omgevingen
(development, staging, production) te deployen door simpelweg andere waarden in te geven
via een aangepast values.yaml bestand of CLI-parameters.


### 8.2.3 Helm - Hoe werkt het?
Helm neemt de templates uit een chart en combineert die met waarden uit het values.yaml
bestand. Tijdens een helm install of helm upgrade wordt de gegenereerde output naar
Kubernetes gepusht als standaard YAML-manifests. Doordat Helm versiebeheer ondersteunt,
kunnen eerdere releases makkelijk worden teruggedraaid met helm rollback.

Helm bewaart metadata van elke release in een eigen namespace (via secrets of ConfigMaps),
zodat het exact weet welke versie van een chart geïnstalleerd is, inclusief bijhorende waarden
en status.

### 8.2.4 Helm - Waarom gekozen?

Helm sluit naadloos aan bij de principes van GitOps en Infrastructure as Code. Binnen
ons project biedt Helm een oplossing voor:
- Gestandaardiseerde deployments van applicaties zoals Vault, Istio, FluxCD en
GitLab Runner
- Herbruikbaarheid en het parametriseren van configuraties
- Versiebeheer van releases per omgeving (applicatie cluster, tooling cluster)
- Integratie met FluxCD, zodat alles vanuit Git gecontroleerd en uitgerold kan
worden

### 8.2.5 Helm - Hoe geïmplementeerd?

In onze architectuur is Helm de standaard tool om Kubernetes-resources te beheren en
deployen, zowel voor infrastructuurcomponenten als voor applicatiediensten. De
implementatie omvat meerdere lagen:

**Installatie en beheer via FluxCD**

Alle Helm charts worden deployed via HelmRelease-resources in combinatie met
FluxCD. Dit betekent dat de gewenste toestand van elke Helm chart beschreven is in
Git, en dat elke aanpassing automatisch gesynchroniseerd wordt naar de juiste cluster.

Voor elk cluster (applicatie en tooling) zijn afzonderlijke HelmRelease-bestanden
opgezet die verwijzen naar:

- een externe chart repository (zoals Hashicorp/Vault of istio.io),
- of een interne chart folder in de Git-repo (voor eigen charts).

Flux detecteert wijzigingen in de chartversie of in het values.yaml bestand, en triggert
automatisch een helm upgrade.

**Custom values per cluster en omgeving**

De configuratie van elke chart gebeurt via een values.yaml bestand dat in de Git-
repository staat. Zo gebruiken we binnen de tooling cluster bijvoorbeeld aangepaste
waarden voor Vault (zoals nodeSelector, service type, storage backends), terwijl de
applicatie cluster met zijn eigen Istio-configuratie draait (zoals ingress gateways en
mesh policies).

**Consistente naming en labels**

Via helpers.tpl en conventions in values.yaml zorgen we ervoor dat resources netjes
gegroepeerd en gelabeld zijn per omgeving, wat het beheer aanzienlijk vereenvoudigt.

**Upgrades, rollbacks en debugging**

Bij issues kunnen we eenvoudig terugrollen naar een vorige release via helm rollback.
Omdat elke HelmRelease een exacte chartversie en configuratie bevat, is het gedrag
van een release perfect reproduceerbaar.

### 8.2.6 Helm - Voordelen

- **Herbruikbaarheid:** dezelfde chart kan over meerdere omgevingen deployed worden
met aangepaste parameters
- Versiebeheer: elke release is traceerbaar en terug te draaien
- Automatisatie: integreert naadloos met GitOps via FluxCD
- Schaalbaarheid: eenvoudig toe te passen op tientallen of honderden componenten
- Beheerbaarheid: overzichtelijke structuur van waarden en configuratie per component

### 8.2.7 Helm - Nadelen

- **Complexe templating:** bij grote charts met veel condities of logica kan het template
gedrag lastig te doorgronden zijn

- **Debugging** van gegenereerde manifests is soms omslachtig; helm template is dan
nodig om de effectieve output te inspecteren

- **Afhankelijkheid van chart kwaliteit:** slecht opgebouwde of onvoldoende
gedocumenteerde charts van externe repositories kunnen het beheer moeilijk maken

Door Helm als standaard deployment mechanisme in te zetten, gecombineerd met FluxCD,
hebben we een controleerbare en schaalbare release pipeline gecreëerd. Het stelt ons in staat
om alle componenten — van Vault en Istio tot interne services — op een consistente manier
te beheren, te auditen en indien nodig te herstellen.


## 8.3 GitOps (FluxCD)

### 8.3.1 FluxCD - Wat is het?

FluxCD is een open-source GitOps tool voor Kubernetes die ervoor zorgt dat de toestand van
een cluster altijd overeenkomt met de configuratie zoals die in een Git-repository staat. In
plaats van manueel Kubernetes-manifests toe te passen via kubectl, maakt FluxCD het
mogelijk om configuratieveranderingen automatisch toe te passen op basis van wijzigingen in
Git. Dit zorgt voor meer veiligheid, traceerbaarheid en automatisering.

FluxCD fungeert als een pull-based Continuous Delivery-systeem dat de Git-repository
periodiek scant op wijzigingen en deze wijzigingen automatisch doorvoert in de cluster. Dit
bevordert consistentie, auditeerbaarheid en self-healing gedrag. Flux biedt ook de
mogelijkheid om een rollback te doen. Dat maakt het gemakkelijk als de nieuwe configuratie
fouten bevat en naar een vorige versie moet worden gesteld.

### 8.3.2 FluxCD - Onderdelen van FluxCD
Flux bestaat uit een aantal afzonderlijke Kubernetes-controllers, elk met een specifieke
verantwoordelijkheid:

- **Source Controller:** Synchroniseert Git-repositories of Helm-repositories naar de
cluster
- **Kustomize Controller:** Past Kustomize-manifests toe die in de Git-repo staan
- **Helm Controller:** Beheert HelmReleases en voert helm upgrade automatisch uit.
- **Notification Controller:** Stuurt meldingen (Slack, email, webhook) over veranderingen
of fouten
- **Image Automation Controller (optioneel):** Automatische image tag updates in Git bij
nieuwe builds
- **Image Reflector Controller (optioneel):** Fetchen van nieuwe image tags uit een repo

### 8.3.3 FluxCD - Hoe werkt het?

FluxCD gebruikt een declaratieve benadering: je beschrijft in Git hoe je
infrastructuur en applicaties eruit moeten zien. De controllers van FluxCD
vergelijken voortdurend de actuele toestand van de cluster met deze
gewenste toestand en zorgen ervoor dat de cluster wordt aangepast waar
nodig.

Een typische workflow:

1. Developer commit een nieuwe versie van een HelmRelease/manifest in Git.
2. FluxCD detecteert deze wijziging.
3. De Helm/source Controller voert een helm upgrade/manifest
wijziging uit met de nieuwe waarden.
4. De cluster is nu up-to-date met de laatste Git-versie.

```mermaid
flowchart TD
A[Git]
B[Flux Controller]
C[Kubernetes Cluster]
D[Application Pods]

A -- Flux synx watches Git --> B -- Pulls updated manifests --> C -- Deploy updated pods with new
image tag --> D
```

### 8.3.4 FluxCD - Waarom gekozen?

Wij kozen FluxCD vanwege de volgende redenen:

- **Kubernetes-native:** Het draait volledig in de cluster zonder externe componenten
- **Lichtgewicht en modulair:** Slechts de nodige controllers worden geïnstalleerd
- **Eenvoudige Git-integratie:** Geen extra tooling nodig zoals webhooks of pipelines
- **Goede Helm-ondersteuning:** Naadloze integratie met onze Helm-charts
- **Secret management:** FluxCD laat zich goed combineren met HashiCorp Vault (via
Vault Secrets Operator of SOPS)
- **Versiebeheer:** indien gewenst kunnen we gemakkelijk een rollback doen naar een
eerdere versie


### 8.3.5 FluxCD - Hoe geïmplementeerd?

FluxCD is door ons deployed via Terraform met gebruik van de officiële Flux Terraform
provider. Voor elke cluster (zowel tooling als applicatie) werd een afzonderlijke GitOps folder
aangemaakt:

- Authenticatie via SSH: De Git-repository wordt via SSH benaderd (geen HTTPS),
waarbij een privé sleutel werd ingevoegd via Terraform
(flux_git_ssh_private_key_path)
- Flux-configuratie als Terraform resource: Elke Flux-installatie is volledig
geautomatiseerd met declaratieve code:

```terraform
provider "flux" {
  kubernetes = {
    host = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_ca)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args = ["eks", "get-token", "--cluster-name", var.cluster_name]
      command = "aws"
    }
  }
  
  git = {
    url = "ssh://${var.git_repo_ssh}"
    branch = var.git_branch
    ssh = {
      username = "git"
      private_key = file(var.flux_git_ssh_private_key_path) 
    }
  }
}
```

- **HelmReleases per omgeving:** In onze Git-repo staan meerdere HelmRelease-
manifesten, opgesplitst per component (Vault, Istio, GitLab Runner, etc.) en per cluster

- **Automatische sync:** Iedere verandering in de Helm-release, manifests of values.yaml
wordt door FluxCD automatisch deployed naar de juiste omgeving

Zo beheren wij beide clusters volledig Git-gedreven: aanpassingen gebeuren via Pull
Requests.

**Interne werking van FluxCD - Controller Flow**

De interne werking van FluxCD is modulair opgebouwd rond een aantal gespecialiseerde
controllers, die elk een eigen taak uitvoeren in de GitOps-keten. Deze opbouw laat toe om
wijzigingen uit Git volledig automatisch en gecontroleerd toe te passen binnen Kubernetes

Stap-voor-stap flow:

**1. Git-repository:**

De workflow start met een Git repository waarin alle declaratieve YAML-manifests of
HelmRelease-resources worden opgeslagen. Dit is de single source of truth voor alle
Kubernetes-resources binnen de cluster.

**2. Source Controller**

Deze controller is verantwoordelijk voor
het ophalen van externe bronnen zoals
Git-repositories of Helm-repositories. Hij
scant periodiek de opgegeven Git-branch
en downloadt de inhoud (YAML-manifests
of Helm charts) naar een lokaal artifact in
de cluster. Dit artifact bevat de laatst
bekende en gevalideerde configuratie.

**3. Artifact productie**

Na het ophalen van de Git-inhoud, wordt
hiervan een renderbaar artifact gemaakt
dat als input dient voor de volgende stap.
Dit artifact bevat alle gegenereerde
manifests die effectief kunnen worden
toegepast.

**4. Controllers**

De controllers zijn verantwoordelijk voor het interpreteren en toepassen van de inhoud
van het artifact dat door de Source Controller is aangemaakt. Ze verwerken de
declaratieve configuratie en vertalen deze naar concrete Kubernetes-resources.

**5. Cluster Resources**

de Controllers sturen hun output direct door naar de Kubernetes-cluster, waar de
gewenste toestand wordt toegepast. Door deze continue cyclus van polling, vergelijken
en bijwerken, garandeert Flux dat de cluster altijd synchroon blijft met de Git-repository.

Deze opdeling in controllers maakt FluxCD robuust, schaalbaar en eenvoudig te debuggen:
elk onderdeel doet exact één taak, en foutopsporing blijft daardoor overzichtelijk. In ons project
maken we vooral gebruik van de Source Controller en Helm Controller, omdat al onze
applicaties en infrastructuurcomponenten via HelmReleases worden uitgerold.

```mermaid
flowchart TD
subgraph Git Repositories 
GitRepository[Git Repository - YAML manifests]
end
    
subgraph Flux Controllers 
SourceControllers[Source Controllers]
Controllers
end

subgraph Kubernetes Cluster 
ClusterResources[Cluster Resources]
end

GitRepository -- polls --> SourceControllers
SourceControllers -- produces --> Artifact[Artifact - rendered source]
Artifact --> Controllers
Controllers -- applies --> ClusterResources
```


**Image automation - Automatische updates van container images**

Een optionele, maar krachtige extensie van FluxCD is het Image Automation-systeem, dat
wijzigingen in container images automatisch kan detecteren, verwerken en toepassen in Git.
In plaats van manueel een nieuwe image-tag in YAML-bestanden aan te passen, laat deze
feature toe om automatisch de juiste tag in Git te laten updaten, waardoor de volledige GitOps-
flow intact blijft.

**Werking van image automation:**

**1. Image Reflector Controller**

Deze controller monitort op vaste intervallen een container registry (zoals ECR, Docker
Hub of GitLab Container Registry) en haalt de beschikbare tags van een opgegeven
image op.

**2. Image Repository:**

De tags van de image worden lokaal
opgeslagen in een Kubernetes custom
resource genaamd Image Repository.
Deze resource vormt de databron voor
verdere filtering en evaluatie.

**3. Image Update Policy**

Via deze policy geef je aan op basis van
welke criteria (bijvoorbeeld: latest, semver,
regex) een nieuwe tag als "updatewaardig"
beschouwd wordt.

**4. Image Automation Controller**

Zodra een nieuwe geschikte image-tag
wordt herkend, past deze controller het
corresponderende manifest-bestand aan
in de Git-repository. Bijvoorbeeld, als
frontend:1.3.0 beschikbaar komt in de
registry, wordt in het YAML-bestand automatisch de image.tag geüpdatet.

**5. Git Push & Git Update**

Na deze aanpassing voert de Image Automation Controller een commit en push uit
naar de Git-repository. Dit activeert opnieuw de standaard FluxCD flow: Source
Controller detecteert de wijziging → Helm Controller voert een upgrade uit →
Kubernetes krijgt de nieuwe versie uitgerold.

### 8.3.6 FluxCD - Voordelen
- Volledig Git-gebaseerd beheer met versiecontrole
- Self-healing: herstelt automatisch van afwijkingen t.o.v. de Git-state
- Multi-cluster support: makkelijk op te zetten met één Git-repo voor meerdere clusters
- Integratie met Helm maakt lifecycle management van applicaties eenvoudig
- Makkelijk uitbreidbaar met notificaties, secrets en image automation

### 8.3.7 FluxCD - Nadelen
 
- Geen ingebouwde GUI (in tegenstelling tot ArgoCD), wat debugging moeilijker maakt
voor beginners

- Minder directe feedback: je moet logs of de CLI gebruiken om status te zien

- Initieel iets complexere setup vergeleken met eenvoudige CI/CD pipelines

**Alternatieven**

- ArgoCD: Biedt een rijke webinterface en is zeer geschikt voor teams die visuele
controle wensen over hun deployments. ArgoCD vereist echter meer resources en
complexere setup, vooral bij multi-cluster omgevingen.

- Jenkins X: Combineert CI/CD in één framework, maar is zwaarder, moeilijker te
onderhouden en minder Kubernetes-native.

- Fleet (van Rancher): Gericht op zeer grote multi-cluster omgevingen, maar minder
geschikt voor kleine/middelgrote teams.
Voor ons project was FluxCD de beste keuze door de eenvoud, native Kubernetes-integratie
en naadloze compatibiliteit met Helm en Vault.

Voor ons project was FluxCD de beste keuze door de eenvoud, native Kubernetes-integratie
en naadloze compatibiliteit met Helm en Vault.


## 8.4 - Self-hosted GitLab runner

### 8.4.1 GitLab runner - Wat is het?

De GitLab Runner is een open-source component van GitLab dat verantwoordelijk is voor het
uitvoeren van CI/CD-pipelines. Het is de engine die taken zoals het bouwen, testen en
deployen van applicaties effectief uitvoert. Een runner kan op verschillende manieren worden
ingezet — van een eenvoudige virtuele machine tot een container in een Kubernetes-cluster.
In ons project kozen we voor een self-hosted runner die als Kubernetes workload draait binnen
de tooling cluster. We hebben gekozen voor een self-hosted runner omdat we dan
ongelimiteerd jobs kunnen uitvoeren, zonder dat het betalend is.

### 8.4.2 GitLab runner - Onderdelen van Gitlab Runner

De GitLab Runner-installatie omvat:

- Runner Agent: het proces dat jobs ophaalt van GitLab en uitvoert.
- Executor: het mechanisme waarmee taken worden uitgevoerd (bijv. docker, shell,
kubernetes).
- ServiceAccount + RBAC: nodig om binnen Kubernetes pods te kunnen aanmaken en
beheren.
- Helm Chart: om de runner als Kubernetes workload te installeren en beheren.
- Secrets/Registration Token: authenticatie om verbinding te maken met de juiste
GitLab project runner

### 8.4.3 GitLab runner - Hoe werkt het?

Wanneer een developer een commit maakt op GitLab, triggert dit een pipeline die in de .gitlab-
ci.yml gedefinieerd is. GitLab stuurt deze job naar een geregistreerde runner. Onze runner
draait in Kubernetes en gebruikt de kubernetes executor. Bij ontvangst van een job creëert de
runner een pod met containers die verantwoordelijk zijn voor de build, tests en eventuele
deploy-taken. Zodra de job klaar is, worden de pods automatisch opgeruimd.

### 8.4.4 GitLab runner - Waarom gekozen?

We kozen voor een self-hosted GitLab Runner in Kubernetes om meerdere redenen:
- **Volledige controle** over de uitvoering en configuratie van CI/CD-taken.
- **Schaalbaarheid:** Kubernetes kan eenvoudig meerdere builds parallel draaien.
- **Integratie met Vault:** we kunnen veilig secrets injecteren tijdens jobs.
- **Kostenbewust:** door geen gebruik te maken van shared runners vermijden we
beperkingen op snelheid of aantal minuten.
**Flexibele configuratie:** zoals het gebruik van custom images, node selectors en resource
limieten.

### 8.4.5 GitLab runner - Hoe geïmplementeerd?

Onze GitLab Runner is gedeployed binnen de tooling cluster via een volledig GitOps-gedreven
workflow. De runner is verantwoordelijk voor het uitvoeren van CI/CD-pipelines — met nadruk
op het builden van container images met Podman en het pushen naar AWS ECR.

We kozen bewust voor Podman in plaats van traditionele Docker-based oplossingen. Podman
is een daemonless container engine die compatibel is met de Docker CLI, maar veiliger en
beter geschikt voor Kubernetes-omgevingen. Omdat Podman geen achtergrondproces vereist
(zoals de Docker daemon), kunnen we builds uitvoeren zonder root rechten — wat de attack
surface verlaagt en beter aansluit bij de security best practices van cloud-native infrastructuur.
Bovendien ondersteunt Podman volledige OCI-compatibiliteit en integreert het naadloos met
rootless container builds.

Onze runner gebruikt een custom image (c1sv3r/aws-podman:1.0) waarin zowel Podman als
AWS CLI is geïnstalleerd. Dit stelt ons in staat om:

- Container Images te bouwen met podman build
- Te authenticeren met AWS ECR via de AWS CLI
- De images te pushen met podman push

**1. Git repository & Kustomizations**

De GitRepository haalt de configuratie op uit de tooling-gitops repo die de runner bevat.
Deze repo wordt periodiek gepolled door Flux:

```yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: gitlab-runner-repo
spec:
  url: ssh://git@gitlab.com/...
  interval: 1m
  ignore: |
    /*
    !/tooling/gitlab-runner/**
```

Vervolgens zijn er twee Kustomizations:
- **gitlab-runner-secrets:** beheert de noodzakelijke secrets, waaronder het
registratie-token via Vault

- **gitlab-runner-bootstrap:** installeert de HelmRelease voor de runner en
injecteert waarden via postBuild.substituteFrom

**2. HelmRelease-configuratie**

De runner wordt gedeclareerd met een HelmRelease, die verwijst naar de officiële
GitLab Helm chart:


```yaml
chart:
  spec:
    chart: gitlab-runner
    version: 0.64.0
    sourceRef:
      kind: HelmRepository
      name: gitlab
```

De values-sectie definieert o.a.:

- `gitlabUrl`: de GitLab-host die gebruikt wordt
- `runnerRegistrationToken`: het geheime token dat via Vault is opgehaald
- `rbac` and `serviceAccount`: inclusief IAM rol voor toegang tot AWS (EKS) en ECR
- `runners.executor`: op kubernetes, wat jobs als pods uitvoert
- `resources`: CPU- en memory-limieten voor builds
- `config`: geavanceerde instellingen voor logs, timeout, concurrency en meer


**3. Secrets via External Secrets Operator (ESO)**

Het registratie-token komt uit Vault, via een ExternalSecret resource:

```yaml
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: gitlab-runner-token
spec:
  secretStoreRef:
    name: vault-backend
  data:
    - secretKey: REGISTRATION_TOKEN
      remoteRef:
        key: kv/gitlab/runner
        property: registrationToken
```

Zo garanderen we dat gevoelige gegevens niet hardcoded in onze repository zitten en
enkel tijdens runtime beschikbaar zijn.

### 8.4.6 GitLab runner - Alternatieven

**1. Docker (classic daemon)**
Docker is de bekendste container engine en de standaard in veel CI-omgevingen.

**Voordelen:**

- breed ondersteund, vertrouwd CLI-patroon, veel documentatie

**Nadelen:**

- Vereist een draaiende Docker-daemon (root privileges of privileged mode)
- Moeilijk te integreren in rootless containers in Kubernetes
- Security concerns bij gebruik van een gedeelde daemon

**Waarom niet gekozen:** Het vereist een privileged pod of sidecar om de daemon
beschikbaar te maken, wat haaks staat op onze security principes.

**2. Kaniko**

Kaniko is een open-source tool van Google voor het bouwen van container images
binnen een container of Kubernetes-cluster, zonder dat er een daemon nodig is.

**Voordelen:**
- volledig daemonless, geschikt voor Kubernetes, veilig

**Nadelen:**
- Trager dan Podman bij grote builds
- Geen volledige compatibiliteit met bepaalde complexere Dockerfiles
- Minder configuratie vrijheid en debugging-mogelijkheden
Waarom niet gekozen: De support vanuit google is stilgelegd mits vorig jaar waardoor
dit naar onze mening geen robuust en langdurig alternatief is.

**3. Buildah**

Buildah is een low-level image builder, ook van de makers van Podman.

Voordelen:

- native OCI-support, zeer modulair, rootless support

Nadelen:
- Minder gebruiksvriendelijk dan Podman
- Geen drop-in vervanger voor docker build (andere syntax)
- Minder community-ondersteuning bij integratie in GitLab

- Waarom niet gekozen: Buildah is vooral interessant voor geavanceerde CI/CD-
pijplijnen met complexe scripting. Podman biedt dezelfde voordelen, maar
gebruiksvriendelijker en betere compatibiliteit met bestaande Docker-workflows.

### 8.4.7 GitLab runner - Voordelen

- **Volledige integratie met GitLab** via Helm
- **Schaalbaar:** jobs worden uitgevoerd als geïsoleerde pods in Kubernetes
- **Veilige secrets:** dankzij Vault en ESO
- **Flexibele configuratie:** inclusief RBAC, namespaces, eigen serviceaccount en IAM-integratie
- **Volledig GitOps-compatible:** gedeployed via FluxCD

### 8.4.8 GitLab runner - Nadelen

- **Complexiteit:** installatie vereist kennis van Helm, FluxCD en Vault-integratie.
- **Beheer:** vereist monitoring en logging van job-failures in eigen cluster.
- **Onderhoud:** upgrades van de chart en tokens vergen afstemming met de GitLab-
interface.
- **Netwerkrestricties:** Runner moet verbinding kunnen maken met gitlab.com (bij
private GitLab-instances kan dit uitdagender zijn).

---

## 8.5 Service Mesh (Istio)

### 8.5.1 Istio - Wat is het?

Istio is een open-source service mesh die de communicatie tussen microservices binnen een
Kubernetes-cluster beheert en beveiligt zonder dat je de services zelf moet aanpassen. Dit
gebeurt door gebruik te maken van zogenaamde sidecar proxies (meestal Envoy), die naast
elke service draaien en al het verkeer onderscheppen. Hierdoor kunnen beveiliging,
observability, traffic management en toegangscontrole centraal en op uniforme wijze worden
toegepast.

### 8.5.2 Istio - Onderdelen van Istio

Istio bestaat uit meerdere componenten die gezamenlijk het service mesh-concept realiseren:
- **Istiod (Control Plane):** Verantwoordelijk voor service discovery, configuratie, en
certificaatbeheer. Het pusht configuraties naar de sidecars.

- **Envoy sidecar proxy (Data Plane):** Wordt automatisch geïnjecteerd in elke pod en
fungeert als tussenlaag voor al het inkomend en uitgaand verkeer. Voert taken uit zoals
mTLS, retries, circuit breaking en metrics.
- **Ingress/Egress gateways:** Beheren al het verkeer dat de mesh binnenkomt (ingress)
of verlaat (egress). Wij gebruiken een Ingress Gateway voor toegang van buitenaf.
- **VirtualServices:** Declaratieve regels voor het routeren van verkeer naar de juiste
backend-service.
- **DestinationRules:** Bepalen hoe verkeer naar een specifieke service wordt behandeld
(bv. mTLS, load balancing).
- **AuthorizationPolicies:** Leggen vast welke services of service accounts toegang
mogen krijgen tot andere services binnen de mesh.


### 8.5.3 Istio - Hoe werkt het?

Elke pod in een Istio-enabled namespace krijgt automatisch een Envoy sidecar-container die
alle communicatie met andere pods intercept. Deze proxies communiceren met Istiod, die de
configuratie, service discovery, policies en TLS-certificaten aanlevert. Hierdoor kunnen
functies zoals mTLS (mutual TLS), retries, timeouts, circuit breaking, en traffic shaping (canary
releases, A/B testing) worden toegepast zonder code wijzigingen.

Bijvoorbeeld, wanneer service A een request stuurt naar service B, loopt dit verzoek via de
Envoy-proxy van A, door de mesh, naar de Envoy-proxy van B, waarna het verzoek wordt
afgeleverd aan de werkelijke applicatie container. Dit pad wordt gecontroleerd op basis van
geconfigureerde policies.

### 8.5.3 Istio - Waarom gekozen?

De keuze voor Istio in dit project werd gedreven door de noodzaak tot het implementeren van
zero-trust networking, gedetailleerde observability en centraal beheer van netwerkverkeer
binnen de applicatie cluster. In plaats van individuele netwerkregels en policies te schrijven
per microservice, biedt Istio een consistent model waarbij versleutelde communicatie,
toegangscontrole en monitoring standaard geïntegreerd zijn.

Bovendien is Istio breed gedragen in de industrie, met uitgebreide documentatie en een
actieve community. Aangezien het als graduated gezien is door cncf (Cloud Native Computing
Foundation) is Istio ook geschikt voor productieomgevingen en complexe scenario’s.

### 8.5.4 Istio - Hoe geïmplementeerd?

De volledige deployment van Istio binnen onze applicatie cluster is declaratief en GitOps-
gedreven, beheerd via FluxCD in combinatie met HelmReleases. De configuratie is opgesplitst
in logische componenten voor overzicht, onderhoudbaarheid en herbruikbaarheid. Alle
manifesten zijn opgeslagen in een centrale Git-repository, van waaruit FluxCD deze
automatisch synchroniseert naar de cluster.

**1. HelmRepository-configuratie**

We begonnen met het definiëren van een HelmRepository resource die verwijst naar
de officiële Istio Helm chart repository. Deze bevindt zich in de istio-system namespace:

```yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: HelmRepository
metadata:
  name: istio
  namespace: istio-system
spec:
  url: https://istio-release.storage.googleapis.com/charts
  interval: 1m
```

Deze repository dient als bron voor de installatie van de Istio-componenten via HelmReleases.

**2. Installatie van Istio via HelmReleases**
De installatie is opgesplitst in twee HelmReleases:
- Istio-base installeert de noodzakelijke CRD’s (Custom Resource Definitions).
- Istiod installeert de control plane en configureert mesh-specifieke parameters zoals toegang tot
stdout logging:

```yaml
values:
  meshConfig:
    accessLogFile: /dev/stdout
```

Deze HelmReleases worden via FluxCD opgevolgd en automatisch gesynchroniseerd
bij elke wijziging.

**3. Sidecar-injectie**

De app namespace is geconfigureerd met het label istio-injection=enabled, waardoor
alle pods automatisch een Envoy sidecar krijgen. Dit maakt het mogelijk om verkeer
tussen microservices te beheren, beveiligen en observeren zonder dat de
applicatiecode moet worden aangepast.

**4. Routing via VirtualServices**
Voor elke microservice in de cluster (zoals assets, carts, catalog, checkout, orders, ui)
hebben we een eigen VirtualService gedefinieerd. Deze configuraties bepalen hoe
intern verkeer naar de juiste service wordt gerouteerd.
Voorbeeld — VirtualService voor de catalog microservice:

```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: catalog
  namespace: app
spec:
  hosts:
    - catalog
  http:
    - route:
    - destination:
        host: catalog.app.svc.cluster.local
        port: 
        number: 8080
```

De ui service bevat als enige een gateway: mesh en een URI-prefix match (/), zodat
die ook als toegangspunt naar de rest van de applicatie kan functioneren.


**5. ServiceAccounts per microservice**

Elke microservice heeft een eigen ServiceAccount gekregen, wat essentieel is voor het afdwingen van
toegangsrechten via Istio Authorization Policies:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: checkout-sa
  namespace: app
```
Deze opdeling maakt het mogelijk om toegangsregels op een zeer gedetailleerd niveau
toe te passen, gebaseerd op de identiteit van de client-pod (via principal).

**6. PeerAuthentication - afdwingen van mTLS**

Om versleuteling en verificatie van serviceverkeer af te dwingen, hebben we een
PeerAuthentication resource aangemaakt in de namespace app:

```yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: app
spec:
  mtls:
    mode: STRICT
```

Deze configuratie zorgt ervoor dat enkel mutual TLS (mTLS)-verbindingen worden
toegestaan tussen pods in het cluster. Verkeer zonder sidecar of geldig certificaat wordt
geweigerd.

**7. Default-deny AuthorizationPolicy - blokkeer alles**

Om het zero-trust principe consequent door te voeren, definieerden we een standaard
AuthorizationPolicy zonder enige regels — wat alle communicatie initieel blokkeert:

```yaml
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: deny-all
  namespace: app
spec: {}
```

Deze default-deny policy zorgt ervoor dat geen enkele service met een andere mag
communiceren, tenzij dit expliciet wordt toegestaan.

**8. Beveiliging met Authorization Policies**

Voor elke relevante interactie tussen microservices is een inbound policy opgesteld.
Deze policies definiëren precies welke services met elkaar mogen communiceren, en
op basis van welke ServiceAccounts.

Bijvoorbeeld — enkel de assets-sa service mag communiceren met de activemq
service:

```yaml
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: allow-assets-to-activemq
  namespace: app
spec:
  selector:
    matchLabels:
    app: activemq
action: ALLOW
rules:
  - from:
  - source:
      principals: ["cluster.local/ns/app/sa/assets-sa"]
```

Ook inbound policies zijn gedefinieerd voor de assets-service. Bijvoorbeeld: de ui
service mag communiceren met assets:

```yaml
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: allow-assets-inbound
  namespace: app
spec:
  selector:
    matchLabels:
      app: assets
  action: ALLOW
  rules:
    - from:
    - source:
        principals: ["cluster.local/ns/app/sa/ui-sa"]
```

Deze zero-trust benadering garandeert dat enkel toegestane communicatie plaatsvindt
binnen de cluster.

Dankzij deze opbouw hebben we een volledig beveiligde, dynamisch configureerbare
en goed controleerbare service mesh opgezet, waarin alle interacties expliciet
gedefinieerd zijn — en volledig worden beheerd vanuit Git. De combinatie van FluxCD,
Helm en Istio maakt onze mesh consistent, transparant en auditeerbaar.

### 8.5.5 Istio - Voordelen

- **Beveiliging:** Automatische mTLS en policies per serviceaccount.
- **Controle:** Volledig beheer over intern verkeer zonder code wijzigingen.
- **Schaalbaarheid:** Policies en routing zijn eenvoudig uitbreidbaar naar nieuwe services.
- **Transparantie:** Metrics, logs en traces zonder extra instrumentatie.
- **GitOps-vriendelijk:** Volledig declaratief te beheren via FluxCD en Helm.

### 8.5.6 Istio - Nadelen

- **Complexiteit:** Configuratie vereist diepgaande kennis van Kubernetes én Istio-
- **Resourcegebruik:** Elke Envoy sidecar voegt CPU -en geheugengebruik toe.
- **Beheer:** Policies en routing regels kunnen snel omvangrijk worden bij veel
microservices.

### 8.5.7 Istio - Alternatieven

| Eigenschap                  | Istio        | AWS App Mesh | Linkerd    | Consul Connect |
|-----------------------------|--------------|--------------|------------|----------------|
| Complexiteit                | ⚠️ Hoog      | ✅ Laag       | ✅ Laag     | ⚠️ Gemiddeld   |
| Performance overhead        | ⚠️ Hoog      | ✅ Laag       | ✅ Laag     | ⚠️ Gemiddeld   |
| Security (mTLS, ACLs)       | ✅ Zeer goed  | ✅ Goed       | ✅ Basis    | ✅ Goed         |
| Observability               | ✅ Uitstekend | ⚠️ Beperkt   | ⚠️ Basis   | ⚠️ Beperkt     |
| Traffic management          | ✅Geavanceerd | ⚠️ Beperkt   | ✅ Basis    | ✅ Geavanceerd  |
| AWS-integratie              | ⚠️ Mogelijk  | ✅ Zeer goed  | ⚠️ Beperkt | ⚠️ Beperkt     |
| Hybride/multi-cloud support | ⚠️ Beperkt   | ❌ Alleen AWS | ⚠️ Beperkt | ✅ Uitstekend   |

Hoewel sommige alternatieven eenvoudiger zijn in opzet, biedt Istio de meest complete en
flexibele oplossing voor ons project. Het stelt ons in staat om niet alleen verkeer en beveiliging
te beheren, maar ook observability, service-identiteit en netwerkgedrag centraal af te dwingen
op een schaalbare manier.

---

## 8.6 HashiCorp Vault

### 8.6.7 HashiCorp Vault - Wat is het?

HashiCorp Vault is een geavanceerde, open-source oplossing voor secret management en
identiteit gebaseerde toegangscontrole binnen cloud-native omgevingen. Het stelt developers
en operators in staat om op een veilige en dynamische manier met secrets (zoals API-sleutels,
database wachtwoorden, TLS-certificaten en tokens) om te gaan — zowel statisch als
dynamisch. Vault biedt een centraal platform met ondersteuning voor encryptie, audit logs,
fine-grained access control en integratie met tal van systemen zoals Kubernetes, AWS IAM
en databases.

### 8.6.8 HashiCorp Vault - Onderdelen van Vault

De Vault-architectuur in ons project is opgebouwd uit meerdere samenwerkende
componenten, elk met een duidelijke verantwoordelijkheid binnen het secret
managementproces. Samen zorgen ze voor een veilige, geautomatiseerde en schaalbare
aanpak van het beheren van secrets in een Kubernetes-omgeving. Hieronder lichten we de
belangrijkste onderdelen toe:

**Vault**
De Vault vormt het hart van de oplossing. Het is de centrale service die verantwoordelijk is
voor de opslag, encryptie en toegang tot alle secrets. Binnen onze architectuur wordt Vault
opgezet als een Kubernetes-service via een Helm chart in de tooling cluster, en draait dus
volledig in-container binnen onze infrastructuur. Vault beheert de secret backends (zoals
databases en key-value stores), voert authenticatie uit en verwerkt alle toegangsverzoeken.

**Secrets Engines**

Vault ondersteunt verschillende types "Secrets Engines" die elk een specifieke taak vervullen.
In ons project maken we gebruik van de volgende twee engines:

**- Key-Value (KV) Engine**

De KV-engine fungeert als een eenvoudige, versleutelde key-value store voor het
opslaan van statische secrets zoals API-tokens, registratie-tokens voor GitLab Runner
en configuratiegegevens. Deze engine is geschikt voor secrets die handmatig of via
Terraform worden beheerd en zelden wijzigen.

**- Database Secrets Engine**

Deze engine laat Vault toe om op dynamische wijze tijdelijke database gebruikers aan
te maken met beperkte rechten en een TTL (Time To Live). Bij elke aanvraag genereert
Vault een unieke username/password-combinatie die na verloop automatisch wordt
ingetrokken. Dit verhoogt de veiligheid aanzienlijk in vergelijking met hardcoded
databasecredentials.

**Authenticatiemethode**

**- Kubernetes Auth Method**

Deze methode gebruikt de ingebouwde Kubernetes ServiceAccounts om pods te
authenticeren bij Vault. Pods presenteren een JWT-token dat Vault valideert via de
Kubernetes API. Op basis van vooraf gedefinieerde Vault Roles wordt de juiste
toegang verleend. Deze methode is ideaal voor Kubernetes-native workloads en
ondersteunt dynamische secrets en fine-grained toegangscontrole.

**- AppRole Auth Method**

AppRole is een methode gericht op machines of applicaties die niet automatisch
kunnen authenticeren via een platform identiteit. Het werkt met een combinatie van
role_id en secret_id die de applicatie moet gebruiken om toegang te krijgen tot Vault.
Dit is vooral geschikt voor niet-Kubernetes omgevingen of legacy applicaties.

**- AWS IAM Auth Method**

Deze methode maakt gebruik van AWS IAM-rollen en -policies om de identiteit van een
EC2-instantie, Lambda-functie of andere AWS-resources te verifiëren. De applicatie
vraagt een Vault-token aan door een IAM-signed request te doen, waardoor geen
aparte credentials nodig zijn. Dit is handig voor applicaties die in AWS draaien en
gebruik willen maken van Vault.

| Kenmerk                | Kubernetes auth method             | AppRole auth method              | AWS IAM auth method              |
|------------------------|------------------------------------|----------------------------------|----------------------------------|
| **Gebruiksscenario**   | Kubernetes-native workloads        | Machines / legacy apps           | AWS cloud workloads              |
| **Authenticatie**      | JWT token via Kubernetes API       | Role ID + Secret ID              | IAM-signed request               |
| **Crendetialbeheer**   | Geen extra credentials in pods     | Vereist beheer van secret_ids    | Geen extra credentials (IAM rol) |
| **Dynamische secrets** | Volledig ondersteund               | Ondersteund                      | Ondersteund                      |
| **Integratie met K8s** | Volledig                           | Niet specifiek                   | Beperkt, extra tooling nodig     |
| **Beheercomplexiteit** | Relatief laag (native K8s tooling) | Middelmatig (secret distributie) | Laag (AWS IAM policies)          |
| **Security model**     | Zero trust, identity based         | Secret-based                     | Identity via AWS infrastructure  |
| **Geschikt voor**      | Containerized apps in Kubernetes   | Traditionele of externe apps     | AWS-gebaseerde applicaties       |

**Waarom hebben wij gekozen voor Kubernetes Auth Method?**

Onze keuze voor de Kubernetes Auth Method is primair ingegeven door het feit dat onze
applicaties volledig binnen een Kubernetes-cluster draaien. De Kubernetes Auth methode
biedt een naadloze en veilige integratie door gebruik te maken van ServiceAccounts en de
Kubernetes API voor authenticatie. Dit betekent dat er geen statische credentials in de pods
moeten worden opgeslagen, wat het risico op lekken aanzienlijk vermindert.

Daarnaast zorgt deze methode voor fijne toegangscontrole via Vault Roles, gekoppeld aan
Kubernetes namespaces en service accounts, wat het beheer van rechten overzichtelijk en
schaalbaar maakt. Door deze native integratie kunnen we ook dynamische secrets volledig
automatiseren, wat aansluit bij onze ambitie voor security en operational excellence.

Kortom, de Kubernetes Auth Method biedt de beste balans tussen veiligheid, gebruiksgemak
en beheerbaarheid binnen onze cloud-native Kubernetes-omgeving.

**Vault Agent Injector**

De Vault Agent Injector is een mutating admission webhook die automatisch een sidecar-
container toevoegt aan elke pod met de juiste annotaties.

**Vault Agent**

Vault Agent authenticeert zich bij Vault via Kubernetes-auth en haalt de benodigde secrets op.
De secrets worden vervolgens als tijdelijke bestanden in de pod beschikbaar gemaakt. Dit
zorgt voor veilige injectie zonder dat secrets in de Kubernetes API moeten worden opgeslagen.
De agent ondersteunt tevens auto-renewal van leases bij dynamische secrets en templating
van bestandsinhoud.

**Helm + FluxCD**

De volledige installatie en configuratie van Vault verloopt declaratief via Helm en wordt
gemanaged door FluxCD. Helm wordt gebruikt voor het installeren van Vault zelf als
Kubernetes-resource, terwijl FluxCD via GitOps zorgt voor automatische synchronisatie met
onze Git-repository. Hierdoor zijn alle aanpassingen aan Vault volledig beheerbaar met
versies, reproduceerbaar en consistent over omgevingen heen. Flux triggert onder andere de
installatie van Vault, het opzetten van authenticatie, secrets engines, policies en init-jobs.

### 8.6.8 HashiCorp Vault - Hoe werkt het?

Vault wordt gedeployed in de tooling cluster met behulp van Helm en beheerd door FluxCD.
De deployment volgt deze stappen:

1. HelmRelease installeert Vault via FluxCD, inclusief init-jobs en configuratie.
2. Vault wordt automatisch unsealed via een init Job, zodat alle HA-instanties zich
kunnen aansluiten bij de primary Vault.
3. Kubernetes authenticatie wordt geconfigureerd.
4. Secrets Engines worden geactiveerd, zoals kv-v2 en database.
5. Policies worden geschreven voor toegang tot specifieke secret paden.
6. Vault Agent Injector plaatst een sidecar in pods die de juiste annotaties bevatten.
Deze sidecar haalt secrets op bij Vault en injecteert ze als files.
7. Pods die secrets gebruiken worden automatisch herstart wanneer nieuwe credentials
gegenereerd worden (bijvoorbeeld na rotatie van database-users).

Secrets worden dus nooit opgeslagen in de Kubernetes API, en dankzij dynamische
credentials blijven risico’s op misbruik of lekkage beperkt.

### 8.6.9 HashiCorp Vault - Waarom gekozen?

Wij kozen voor HashiCorp Vault vanwege:

- **Ondersteuning voor dynamische secrets:** Met name database-users worden on-
the-fly aangemaakt en automatisch verlopen.
- **Flexibele authenticatie:** Via Kubernetes-auth kunnen we op namespace -en
serviceaccount-niveau toegang regelen.
- **Veiligheid:** Secrets worden niet in plaintext opgeslagen in Kubernetes, en credentials
hebben een korte TTL
- **Integratie met GitOps:** Via Helm en Flux kunnen we Vault declaratief beheren.
- **Schaalbaarheid:** Vault is ontworpen voor high availability en is eenvoudig uit te breiden naar
meerdere clusters.

### 8.6.10 HashiCorp Vault - Hoe geïmplementeerd?

De implementatie van HashiCorp Vault in ons project is zorgvuldig opgebouwd rond veiligheid,
automatisering en integratie met GitOps-principes. Door een combinatie van Terraform, Helm,
FluxCD en Kubernetes-init-jobs hebben we een volledig reproduceerbare en dynamische
secret management oplossing opgezet.

**1. Deployment via Helm en FluxCD**

Vault wordt opgezet als een HelmRelease binnen de tooling cluster, beheerd door
FluxCD. De HelmRelease wordt aangestuurd vanuit een GitOps-repository en haalt zijn
chart op uit de officiële hashicorp Helm repository. Alle waardes voor de configuratie
worden geleverd via een Kubernetes Secret (vault-helm-values), zodat gevoelige
configuratiegegevens (zoals storage-backend of nodeSelectors) niet in plain YAML
zichtbaar zijn in Git.

```yaml
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: vault
  namespace: vault
spec:
  interval: 5m
  chart:
    spec:
      chart: vault
      version: "0.30.0"
      sourceRef:
        kind: HelmRepository
        name: hashicorp-helm
        namespace: repos
      valuesFrom:
        - kind: Secret
          name: vault-helm-values
          valuesKey: values.yaml
```

Na de installatie draait Vault als een StatefulSet met persistentie (EFS), en in HA-
configuratie voor productiegebruik. Vervolgens wordt vault automatisch unsealed via
een kms key die eerder door terraform werd aangemaakt.

**2. Initialisatie via Init Job**

Na deployment is Vault initieel nog niet klaar voor gebruik: hij moet eerst geïnitialiseerd
worden. Dit gebeurt via Kubernetes init-job, die automatisch door Flux wordt
uitgevoerd.

```shell
vault operator init -format=json > /vault/init.json
```

**3. Configuratie van vault**

De configuratie van Vault gebeurt via de CLI (vault command) of de webinterface (UI).
In onze use case is het grootste deel van de configuratie uitgevoerd via de CLI binnen
een Kubernetes-cluster. Hieronder overlopen we kort de stappen die we hebben
uitgevoerd:

**Kubernetes auth**
Om Vault te laten communiceren met workloads in Kubernetes (bijv. applicaties of
GitLab Runners), moet de Kubernetes-authenticatie ingeschakeld worden.

```shell
# Enable
vault auth enable kubernetes

vault write auth/kubernetes/config \
  token_reviewer_jwt="$JWT_TOKEN" \
  kubernetes_host="$KUBE_HOST" \
  kubernetes_ca_cert="$CA_CERT"

# Role declaration for auth
vault write auth/kubernetes/role/gitlab-runner \
  bound_service_account_names=gitlab \
  bound_service_account_namespaces=gitlab \
  policies=gitlab-policy \
  ttl=24h
```
```hcl
# Policy example
# gitlab-policy.hcl
path "kv/data/gitlab/api" {
  capabilities = ["read"]
}
```

```shell
vault policy write gitlab-policy gitlab-policy.hcl
```

**Enable secret engines**

Secret Engines zijn plug-ins in Vault die verschillende soorten secrets beheren (zoals
KV, databases, PKI, enz.).

```shell
vault secrets enable -path=kv kv-v2
vault secrets enable database
```

We gebruiken in onze setup voornamelijk de KV v2-engine voor statische secrets en
de database engine voor dynamische database credentials.

**Configuring key value secrets**

De Key-Value (KV) engine wordt gebruikt voor het opslaan van eenvoudige key value-
paren zoals API-sleutels of tokens.

```shell
vault kv put kv/gitlab/api \
  token=ghp_abc123xyz456 \
  url=https://gitlab.example.com
```

Toegang tot deze secrets wordt geregeld via policies die gekoppeld zijn aan specifieke
roles.

**Configuring Database secrets**

De Database Secret Engine wordt gebruikt voor het dynamisch aanmaken van
gebruikersaccounts met tijdelijke credentials in bijvoorbeeld PostgreSQL of MySQL.

```shell
vault write database/config/my-postgres-db \
  plugin_name=postgresql-database-plugin \
  allowed_roles="app-role" \
  connection_url="postgresql://{{username}}:{{password}}@db.example.com:5432/mydb" \
  username="vaultadmin" \
  password="securepassword"

vault write database/roles/app-role \
  db_name=my-postgres-db \
  creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD'{{password}}' VALID UNTIL '{{expiration}}';" \
  default_ttl="1h" \
  max_ttl="24h"
```

Wanneer een applicatie in Kubernetes via de app-role inlogt, krijgt ze een tijdelijk
gebruikersaccount in de database.

**4. Vault Agent Sidecar Injector**

Toegang tot secrets in de pods gebeurt via de Vault Agent Injector. Dit is een mutating
admission webhook die automatisch een sidecar toevoegt aan elke pod met de juiste
annotaties. Deze sidecar authenticeert zichzelf bij Vault en haalt de juiste secrets op,
die vervolgens als bestand in de pod worden geïnjecteerd:

Toegang tot secrets in de pods gebeurt via de Vault Agent Injector. Dit is een mutating
admission webhook die automatisch een sidecar toevoegt aan elke pod met de juiste
annotaties. Deze sidecar authenticeert zichzelf bij Vault en haalt de juiste secrets op,
die vervolgens als bestand in de pod worden geïnjecteerd:

```yaml
annotations:
  vault.hashicorp.com/agent-inject: "true"
  vault.hashicorp.com/role: "myapp-role"
  vault.hashicorp.com/agent-inject-secret-config.txt: "secret/myapp/config"
```

De sidecar zorgt ook voor automatische lease-vernieuwing en ondersteuning van
dynamische secrets, zoals tijdelijke database credentials. Hierdoor blijven de
credentials geldig zolang de pod leeft, zonder manuele interventie.

Alternatieven die overwogen zijn:

**Vault Secrets Operator (VSO)**

De Vault Secrets Operator gebruikt Kubernetes Custom Resource Definitions (CRD's)
om secrets declaratief te beheren. Deze operator haalt secrets uit Vault en maakt hier
native Kubernetes Secrets van, die vervolgens door applicaties als gebruikelijk gebruikt
kunnen worden.

**Vault CSI Provider**

De Vault CSI Provider maakt gebruik van de Kubernetes Secrets Store CSI Driver om
secrets dynamisch als tijdelijke bestanden in pods te mounten.

Vergelijking:

| Eigenschap                                    | Vault Agent Injector        | Vault Secrets Operator  | Vault CSI Provider         |
|-----------------------------------------------|-----------------------------|-------------------------|----------------------------|
| **Secret aflevering**                         | Sidecar volume              | Kubernetes Secret       | Ephemeral volume mount     |
| **Ondersteuning dynamische secrets**          | ✅ Ja                        | ❌ Nee (manuele rotatie) | ✅ Ja                       |
| **Leasebeheer**                               | ✅ Automatisch               | ❌  Nee                  | ✅ Automatisch              |
| **GitOps-compatibiliteit**                    | ⚠️ Beperkt (via annotaties) | ✅ Volledig (via CRD's)  | ✅ Volledig (via CRD's)     |
| **Gebruik van native K8s secrets**            | ❌ Nee                       | ✅ Ja                    | ❌ Nee                      |
| **Afhankelijkheid van Vault bij pod startup** | ✅ Ja                        | ❌  Nee                  | ✅ Ja                       |
| **Beste toepassing**                          | Dynamische credentials      | Statische configuratie  | Bestand-gebaseerde secrets |

**5. Veilige externe toegang via interne NLB**

Vault is niet publiek toegankelijk. We hebben ervoor gekozen om Vault enkel
beschikbaar te maken binnen onze VPC via een interne Network Load Balancer (NLB),
die gekoppeld is aan een Route 53 private DNS-entry vault.tooling.internal. Zo kunnen
services in de applicatie cluster toch communiceren met Vault in de tooling cluster,
zonder publieke endpoints of internet exposure.
De NLB wordt beheerd via een Kubernetes Service met de juiste annotaties voor intern
verkeer:

```yaml
annotations:
  service.beta.kubernetes.io/aws-load-balancer-type: "external"
  service.beta.kubernetes.io/aws-load-balancer-scheme: "internal"
  service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: "ip"
```

Hierdoor garanderen we netwerkbeveiliging, beschikbaarheid en flexibiliteit, terwijl
alles netjes binnen de AWS-infrastructuur blijft.

### 8.6.11 HashiCorp Vault - Voordelen

- **Sterke beveiliging:** Geen opslag van secrets in Kubernetes, automatische credential
- **Dynamisch:** Database-credentials zijn tijdelijk, automatisch gegenereerd en kunnen
niet hergebruikt worden.
- **Auditability:** Vault houdt een volledig audit-log bij van alle acties.
- **GitOps-integratie:** Dankzij Helm en Flux is alles declaratief en beheerbaar met versies.
- **Cluster-brede toegang:** Dankzij het gebruik van een interne NLB- en DNS-abstractie is Vault
bereikbaar vanuit elk cluster binnen de VPC.


### 8.6.12 HashiCorp Vault - Vault agent flow

```mermaid
sequenceDiagram
box Pod: applicatie
participant Deployment
participant VaultAgent
end
Deployment ->> VaultAgent: Agent geïnjecteerd door agent-injector
participant VaultServer
VaultAgent ->> VaultServer: Auth via /auth/kubernetes/login met SA
VaultServer -->> VaultAgent: Vault token + policies
VaultAgent ->> VaultServer: Vraag secret op (bijv. db-creds)
VaultServer -->> VaultAgent: Secret value
VaultAgent ->> Deployment: Plaatst secret op bijv. /vault/secrets
    
```

**1. Injectie van de Vault Agent:**
- Een "Pod: applicatie" wordt gelanceerd.
- De agent-injector (een Kubernetes admission controller) detecteert deze pod
en injecteert een Vault Agent als sidecar-container in dezelfde pod. Dat
betekent dat de Vault Agent naast de deployment container draait en gedeelde
toegang heeft tot het bestandssysteem van de pod.

**2. Authenticatie van de Vault Agent:**
- De Vault Agent maakt gebruik van het ServiceAccount van de pod om zich te
authenticeren bij de Vault Server via het pad /auth/kubernetes/login.
- Vault gebruikt de ServiceAccount-identiteit van de pod en matcht deze met een
vooraf gedefinieerde Vault role. Die role bepaalt welke policies en
toegangsrechten de agent krijgt.

**3. Ophalen van secrets:**
- Met het verkregen Vault token vraagt de "Pod: Vault Agent" een specifiek secret
op bij de "Vault Server" (bijvoorbeeld "db-creds" voor database referenties).
- De "Vault Server" levert de "Secret value" terug aan de Vault Agent.

**5. Beschikbaar stellen van secrets aan de applicatie:**
- De "Pod: Vault Agent" plaatst de ontvangen "Secret value" op een lokaal,
beveiligd pad binnen de pod, bijvoorbeeld "/vault/secrets/". Dit pad is
toegankelijk voor de applicatie-container (de "Pod: Deployment")

Dit hele proces dient een fundamenteel beveiligingsdoel: het elimineren van het need-to-know
principe voor applicaties wat betreft secrets. Traditioneel werden secrets vaak direct
hardcoded in applicatie configuraties gezet, of als omgevingsvariabelen ingesteld in
Kubernetes Deployments. Beide methoden zijn risicovol:

- **Hardcoded:** Gevoelige informatie belandt in de broncode of container-image, wat leidt
tot lekken bij het delen van code of images.

- **Omgevingsvariabelen/Kubernetes Secrets:** Hoewel beter, zijn Kubernetes Secrets
standaard Base64-gecodeerd en niet echt versleuteld in etcd. Ze kunnen ook
gemakkelijk worden gelezen door iedereen met toegang tot de Kubernetes API.
Bovendien vereist het beheren van de levenscyclus van deze secrets (rotatie,
intrekking) handmatige inspanning.

De voordelen van de Vault Agent flow:

- Geen secrets in de applicatiecode: De applicatie zelf moet geen kennis hebben van
Vault, geen Vault SDK implementeren, en geen Vault tokens beheren. Het enige wat
de applicatie ziet, is een lokaal bestandssysteem met daarin de benodigde secrets. Dit
verkleint het aanvalsoppervlak aanzienlijk.

- Sterke authenticatie: Door gebruik te maken van de Kubernetes ServiceAccount
authenticatiemethode, kan Vault op een cryptografisch veilige manier de identiteit van
de aanvragende pod verifiëren, zonder dat er geheime keys of referenties nodig zijn
die in de pod zelf bewaard moeten worden.

- Geautomatiseerde secret rotation: De Vault Agent kan geconfigureerd worden om
secrets periodiek te roteren. Wanneer een secret roteert in Vault, haalt de agent
automatisch de nieuwe waarde op en werkt deze bij op het lokale pad, zonder dat de
applicatie opnieuw opgestart moet worden.

- Audit Trail en Policies: Alle interacties tussen de Vault Agent en de Vault Server
worden gelogd door Vault, wat zorgt voor een complete audit trail. Bovendien kunnen
gedetailleerde policies worden toegepast in Vault, zodat elke applicatie alleen toegang
krijgt tot de specifieke secrets die het nodig heeft.

- Centralisatie van secret management: Vault fungeert als de centrale, beveiligde
opslagplaats voor alle geheimen, waardoor het beheer, de toegang en de levenscyclus
van secrets aanzienlijk vereenvoudigd worden in een complexe microservices-
architectuur zoals Kubernetes.

Kortom, de Vault Agent-flow biedt een robuuste, veilige en geautomatiseerde manier om
applicaties in Kubernetes toegang te geven tot geheimen, door de complexiteit en risico's van
secret management te scheiden van de applicatie zelf en te centraliseren in een
gespecialiseerde tool zoals HashiCorp Vault.


### 8.6.13 HashiCorp Vault - Database engine flow

```mermaid
sequenceDiagram
participant Applicatie
participant Vault
participant Database
    
Applicatie ->> Vault: Vraag database-credentials aan (lease)
Vault ->> Database: Maak tijdelijke gebruiker aan met policy + TTL
Database -->> Vault: Bevestig aanmaak
Vault -->> Applicatie: Geeft tijdelijke username/password terug
Applicatie ->> Database: Verbind met tijdelijke credentials
```

**1. Aanvraag van database-credentials (lease):**
- Een "Applicatie" vraagt database-credentials aan bij "Vault". De term "lease" benadrukt dat deze
credentials tijdelijk van aard zijn.

**2. Dynamische aanmaak van gebruiker in de database:**
- "Vault" ontvangt de aanvraag. Op basis van de geconfigureerde regels in de Database Secrets
Engine, instrueert Vault de "Database" om een tijdelijke gebruiker aan te maken.
- Bij deze aanmaak worden twee cruciale elementen meegegeven:
- **Policy:** De rechten die deze tijdelijke gebruiker heeft binnen de database (bijvoorbeeld alleen
SELECT-rechten op specifieke tabellen).
- **TTL (Time To Live):** De levensduur van deze tijdelijke gebruiker. Na deze periode wordt de
gebruiker automatisch ingetrokken of verwijderd door Vault.
  
**3. Bevestiging en teruggave van credentials:**
- De "Database" bevestigt de aanmaak van de tijdelijke gebruiker aan "Vault".
- "Vault" geeft de tijdelijke "username/password" combinatie terug aan de "Applicatie".

**4. Verbinding maken met de database:**
- De "Applicatie" gebruikt deze zojuist verkregen tijdelijke credentials om
verbinding te maken met de "Database".


---

## 8.7 External Secret Operator
  
### 8.7.1 External Secret Operator - Wat is het probleem?

In een GitOps-architectuur zoals die van FluxCD, worden alle resources gedeclareerd in Git.
Dat betekent ook dat secrets (zoals API-tokens, passwords of database credentials) niet
zomaar als plaintext in Git kunnen worden gezet — wat een ernstig beveiligingsrisico zou
vormen.

Tegelijk moeten Kubernetes workloads toegang hebben tot deze secrets, en willen we die
secrets beheren op één centrale, veilige plek zoals in HashiCorp Vault.
  
### 8.7.2 External Secret Operator - Wat is de oplossing?

De External Secrets Operator (ESO) fungeert als brug tussen externe secret stores (zoals
Vault) en Kubernetes. ESO leest secrets uit deze externe bronnen en converteert ze naar
Kubernetes Secrets, zodat applicaties ze kunnen gebruiken zonder dat ze ooit hardcoded in
Git terechtkomen.

Daarbovenop zorgt FluxCD voor een declaratieve integratie via secret substitution, waardoor
secrets alsnog in je YAML-configuraties kunnen worden toegevoegd — zonder de secrets zelf
in Git op te slaan.

Gemeenschappelijke componenten en hun functies:

**1. Secret Providers:** Dit zijn de externe systemen waar de secrets daadwerkelijk worden
opgeslagen.
 
- AWS Secrets: Verwijst naar AWS Secrets Manager, de secret management service van Amazon Web
Services.
- Vault: Verwijst naar HashiCorp Vault, een centraal systeem voor het beheer van secrets.

**2. ClusterSecretStores:** Dit zijn Kubernetes-objecten (Custom Resources) die fungeren als een
configuratie voor de External Secrets Operator. Ze definiëren hoe
de operator moet authenticeren en communiceren met een specifieke externe Secret Provider op
cluster-niveau.

- AWSSecretStore: Configureert de verbinding met AWS Secrets Manager (bijv.
AWS regio, authenticatiemethode).
- VaultSecretStore: Configureert de verbinding met HashiCorp Vault (bijv. Vault
adres, authenticatiemethode).

```mermaid
flowchart TD
subgraph Secret Providers
AWSSecrets[AWS Secrets]
Vault
end

subgraph ClusterSecretStores
AWSSecretStore
VaultSecretStore
end
    
subgraph ExternalSecrets
AWSExternalSecret
VaultExternalSecret
end
    
subgraph Kubernetes Cluster 
K8sSecretAWS[K8s Secret - van AWS]
K8sSeccretVault[K8s Secret - van Vault]
FluxSubstitution[Flux Substitution]
end
    
AWSSecrets --> AWSSecretStore
Vault --> VaultSecretStore
AWSSecretStore --> AWSExternalSecret
VaultSecretStore --> VaultExternalSecret
AWSExternalSecret --> K8sSecretAWS
VaultExternalSecret --> K8sSeccretVault
K8sSecretAWS --> FluxSubstitution
K8sSeccretVault --> FluxSubstitution
```

**3. ExternalSecrets:** Dit zijn Kubernetes-objecten (Custom Resources) die aangeven
welk specifiek secret van een externe Secret Provider moet worden opgehaald en hoe
het in Kubernetes moet worden gerepresenteerd. Deze worden vaak per namespace
of applicatie geïnstalleerd.

- **AWSExternalSecret:** Specificeert bijvoorbeeld de naam van een secret in
AWS Secrets Manager en de naam van het Kubernetes Secret dat hiervan
gemaakt moet worden.

- **VaultExternalSecret:** Specificeert bijvoorbeeld het pad naar een secret in
Vault en de naam van het Kubernetes Secret dat hiervan gemaakt moet
worden.

**4. Kubernetes Cluster:** Dit is de omgeving waar de applicaties draaien.

- **k8s Secret - van AWS en k8s Secret - van Vault:** Dit zijn de standaard
Kubernetes Secret-objecten die door de External Secrets Operator worden
aangemaakt en gesynchroniseerd. Ze bevatten de werkelijke secret values die
uit de externe providers zijn opgehaald. Deze Secrets kunnen vervolgens door
Kubernetes-pods worden gemount als bestanden of omgevingsvariabelen.

**5. Flux Substitution:** Dit element, onderaan het diagram, geeft aan dat er verdere
verwerking kan plaatsvinden nadat de secrets als k8s Secret objecten in de cluster zijn
geplaatst. Flux is een GitOps-tool die vaak wordt gebruikt voor CI/CD in Kubernetes.
"Substitution" suggereert dat waarden uit deze Kubernetes Secrets kunnen worden
gebruikt om bijvoorbeeld placeholders in configuratiebestanden te vullen, of om
verdere transformaties uit te voeren voordat ze door applicaties worden gebruikt. Dit is
een veelvoorkomend patroon in GitOps-omgevingen om de Secrets (die dynamisch
zijn) gescheiden te houden van de applicatie-configuratie (die vaak statisch in Git
staat).

---

# 9. Gebruikersscenario: externe toegang tot Vault

In moderne cloud-native infrastructuren is het beveiligen van gevoelige componenten zoals
een secret manager van cruciaal belang. HashiCorp Vault vormt het centrale secret
management in onze architectuur en mag onder geen beding publiek toegankelijk zijn.
Tegelijkertijd moeten zowel interne als externe systemen, zoals CI/CD pipelines, toegang
kunnen krijgen tot Vault. De uitdaging is dus: hoe maken we Vault extern beschikbaar, zonder
dat het publiekelijk blootgesteld wordt aan het internet?

**De gekozen oplossing: NLB + private DNS + VPN**

Om dit probleem op te lossen, hebben we gekozen voor een combinatie van:
- Een interne Network Load Balancer (NLB) in AWS om Vault intern bereikbaar te maken
- Een Route 53 Private Hosted Zone om een consistente, leesbare DNS-naam te
voorzien
- Een VPN-verbinding om externe toegang toe te staan zonder publieke poorten open
te stellen.

Deze opzet garandeert dat alle communicatie met Vault plaatsvindt binnen ons private AWS-
netwerk, zonder internet-exposure, maar mét gecontroleerde toegang van buitenaf.

## 9.1 Network Load Balancer (NLB)

### 9.1.1 Network Load Balancer - Wat is het?

Om Vault bereikbaar te maken zonder public internet-exposure, is in de tooling cluster een
Kubernetes Service van het type LoadBalancer ingericht die door AWS als interne NLB wordt
beheerd. Deze service stuurt al het binnenkomende TCP-verkeer op poort 8200 automatisch
door naar de Vault-pods. Omdat we de annotatie voor een interne load balancer gebruiken,
krijgt de NLB geen publiek IP-adres; in plaats daarvan is hij uitsluitend beschikbaar binnen de
VPC. Zo blijft al het Vault-verkeer binnen de grenzen van ons AWS-netwerk, wat een extra
veiligheidslaag oplevert en ons volledige controle geeft over wie er verbinding mag maken.
Een NLB kan zeer hoge volumes TCP-verkeer verwerken met minimale latentie en behoudt
daarbij IP-broninformatie. Omdat Vault over TCP op poort 8200 communiceert, is de NLB de
meest geschikte load-balancer in AWS voor onze use-case.

### 9.1.2 Network Load Balancer - Hoe werkt het?

De NLB luistert op poort 8200 en stuurt alle inkomende verbindingen door naar de Vault-pods.
Omdat we het type "internal" gebruiken, krijgt de load balancer geen publiek IP-adres en is
deze enkel bereikbaar binnen de VPC.

### 9.1.3 Network Load Balancer - Waarom gekozen?

Vault gebruikt TCP-verkeer op poort 8200, wat een TCP-load balancer vereist. Een NLB is de
best passende optie binnen AWS voor deze traffic layer. Bovendien blijft verkeer volledig
binnen de AWS-infrastructuur, wat de veiligheid aanzienlijk verhoogt.

### 9.1.4 Network Load Balancer - Hoe geïmplementeerd?

De NLB werd automatisch aangemaakt via een Kubernetes service met specifieke AWS-
annotaties. Door de combinatie van het type LoadBalancer en de annotatie
service.beta.kubernetes.io/aws-load-balancer-scheme: internal, wordt er automatisch een
interne NLB gegenereerd. Bij de selector annotatie, hebben we de naam “Vault” meegegeven,
wat ervoor zorgt dat hij automatisch alle Vault-pods in de target group gaat registreren.

### 9.1.5 Network Load Balancer - Voordelen
- Geen publiek IP → veiliger
- Lage latency, geschikt voor HA-toepassingen
- Volledige controle over subnet- en VPC-keuze

### 9.1.6 Network Load Balancer - Nadelen
- Extra componenten om te beheren
- Potentiële kosten bij langdurig gebruik
- Geen layer 7-functionaliteit zoals URL-routing

## 9.2 Network Load Balancer - Target group en health check

De NLB beschikt over één listener op poort 8200, gekoppeld aan een target group die de
individuele Vault-pod IP-adressen als backend bevat. Door de Kubernetes-selector in de
serviceconfiguratie worden alle actieve Vault-pods automatisch in deze target group
geregistreerd. Voor de health check van de target group hebben we het standaard Vault-
endpoint `/v1/sys/health` ingesteld. Hiermee controleren we niet alleen of de pods bereikbaar
zijn, maar ook of ze daadwerkelijk als Vault-instantie functioneren. Eventuele non-leader-
nodes in een HA-setup geven een HTTP 429-respons, wat we als “gezond” beschouwen om
false positives uit te sluiten.

## 9.3 Route 53 Private Hosted Zone

### 9.3.1 Route 53 Private Hosted Zone - Wat is het?

Hoewel AWS automatisch een NLB-DNS-naam genereert, is deze naam onhandig en niet-
statisch. We wilden een leesbare en consistente URL die binnen ons VPC betrouwbaar werkt.
Daarom hebben we in Route 53 een Private Hosted Zone “tooling.internal” opgezet, gekoppeld
aan ons VPC. Binnen deze zone is een CNAME-record “vault.tooling.internal” aangemaakt,
dat verwijst naar de interne DNS-naam van de NLB. Op deze manier kunnen we stelselmatig
en eenduidig een verbinding maken via een overzichtelijke en zelfverklaarde URL, terwijl de
onderliggende AWS-details verborgen blijven.

`vault.tooling.internal → vault-nlb-internal-xxxx.elb.eu-west-1.amazonaws.com`

### 9.3.1 Route 53 Private Hosted Zone - Waarom gekozen?

- Consistentie: in scripts, pipelines en policies wordt altijd naar dezelfde URL verwezen.
- Leesbaarheid: gebruikers moeten geen complexe hostnames onthouden.
- Flexibiliteit: achterliggende load balancer kan gewijzigd worden zonder wijzigingen
aan de clients.

### 9.3.1 Route 53 Private Hosted Zone - Hoe geïmplementeerd?

In Route 53 werd de volgende configuratie aangemaakt:

```
Zone: tooling.internal
Record: vault.tooling.internal → vault-nlb-internal-xxxx.elb.eu-west-1.amazonaws.com (CNAME)
```

Deze zone is gekoppeld aan het VPC-ID van de tooling cluster én de applicatie cluster via
VPC-peering.

### 9.3.2 Route 53 Private Hosted Zone - Voordelen

- **Beveiliging:** Vault blijft volledig binnen onze VPC, waardoor we geen publieke
security-groups of internet-ACLs moeten onderhouden.
- **Automatisering:** Kubernetes regelt registratie van Vault-pods in de target group.
- **Gebruiksgemak:** eenduidige DNS-naam verbetert leesbaarheid en vermindert kans
op fouten.


### 9.3.3 Route 53 Private Hosted Zone - Nadelen

- **Complexiteit:** extra componenten (NLB, target group, DNS-zone) vereisen actief
beheer en monitoring.
- **Kosten:** NLB-uren en Route 53-queries zijn niet gratis. In een kostenanalyse moet
hiermee rekening worden gehouden.
- **Failover en schaal:** health checks moeten correct zijn ingesteld voor HA-setups, en
subnets moeten in meerdere zones zijn geselecteerd.

## 9.4 VPN

### 9.4.1 VPN - Wat is het?

Een AWS Client VPN-endpoint werd gedeployed via Terraform als beveiligde gateway naar
het private netwerk waarin Vault draait. Enkel geauthenticeerde gebruikers met een geldig
clientcertificaat, ondertekend door onze eigen Root CA, kunnen verbinding maken en Vault
bereiken via private DNS (bijv. vault.service.internal).


### 9.4.2 VPN - Waarom gekozen?

- Geen publieke blootstelling van Vault: Vault is enkel bereikbaar binnen het private
netwerk via de VPN.
- Beheersbare toegang: Elke gebruiker krijgt een uniek, zelf-ondertekend
clientcertificaat, dat makkelijk te beheren, intrekken en auditen is.
- Automatiseerbaar & integreerbaar: Zowel de infrastructuur als het genereren van
het certificaat zijn geautomatiseerd met Terraform en een eenvoudig script.

### 9.4.3 VPN - Hoe geïmplementeerd?

**Infrastructuur met Terraform**

- Een TLS Root CA wordt gegenereerd met de tls provider in Terraform.
- De VPN-server krijgt een certificaat dat ondertekend is door de Root CA.
- Beide certificaten worden geïmporteerd in AWS Certificate Manager (ACM).
- Een AWS Client VPN Endpoint wordt geconfigureerd met:
- Certificaat-authenticatie
- Private subnet associaties
- Regels die verkeer toestaan naar het interne VPC-netwerk waar Vault draait.


**Clientcertificaten genereren**

Clientcertificaten worden niet handmatig beheerd, maar automatisch gegenereerd via een
script: `./generate-client.sh`

Het script doet het volgende:
1. Leest de Root CA uit Terraform outputs
2. Genereert een nieuwe client private key & CSR
3. Ondertekent de CSR met de Root CA
4. Bouwt een .ovpn-bestand met embedded certificaten:
- `<ca>...</ca>` → Root CA
- `<cert>...</cert>` → Client Cert
- `<key>...</key>` → Client Key


Verbinding maken met de VPN

Na het genereren van het configuratiebestand: `sudo openvpn --config client-config.ovpn`

Vault is daarna bereikbaar op het private netwerk via de DNS-naam (bijv.
https://vault.internal:8200).

# 10. Installatiehandleiding

De volledige infrastructuur van dit project kan met een minimum aan manuele tussenkomst
worden gedeployed dankzij een combinatie van Terraform en FluxCD. Hieronder volgt een
gestructureerde handleiding die beschrijft hoe een gebruiker de infrastructuur, clusters en
applicaties correct kan deployen.

## 10.1 Vereisten

Vooraleer je start, zorg ervoor dat de volgende tools en configuraties beschikbaar zijn op je
lokale machine:

- **AWS CLI**, correct geconfigureerd (via AWS-profiel of IAM-credentials)
- **Terraform** (≥ versie 1.4)
- **kubectl** (om met Kubernetes te communiceren)
- **Flux CLI** (voor GitOps management)
- **Toegang tot een AWS-account** met rechten om:
- EKS-clusters, VPC’s, IAM-rollen, Load Balancers en VPN’s aan te maken
- **Een Git repository** met GitOps-configuratie (bv. fork van onze originele repo)

## 10.2 Clonen van de infrastructuur repository

Start met het ophalen van de repository op GitLab:

```shell
git clone <>
cd /infra
```

## 10.3 Terraform initialisatie

Terraform wordt gebruikt voor het opzetten van de volledige AWS-omgeving. Begin met het
initialiseren van Terraform:

```shell
terraform init
terraform plan
terraform apply
```

Deze eerste apply zal volgende componenten aanmaken:
- VPC's en subnetten
- IAM-rollen en policies
- EKS-clusters (applicatie cluster en tooling cluster)

- Basisconfiguratie voor Kubernetes (zoals kubeconfig outputs)

## 10.4 GitOps-automatisering via FluxCD
Zodra de infrastructuur staat en de Load Balancer Controller actief is, kun je de resterende
modules van Terraform uitvoeren. In de main.tf file zijn deze initieel uitgecomment in de module
K8s.

- Uncomment de blokken die verwijzen naar:
- Kubernetes-modules
- Flux-bootstrap
- VPN-configuratie

Voer daarna opnieuw `terraform apply` uit. Flux zal nu automatisch:
- De GitOps-repo synchroniseren
- Helm charts installeren (Vault, Istio, GitLab Runner)
- Microservices deployen
- Policies, serviceaccounts en namespaces aanmaken

## 10.5 Vault recovery bij eerste bootstrap

Indien de Vault bootstrap crasht tijdens de eerste synchronisatie:

1. Verwijder de foutieve Kustomization en bijhorende secret:

```shell
kubectl delete kustomization vault-bootstrap -n flux-system
kubectl delete secret vault-bootstrap-secret -n flux-system
```

2. Forceer een nieuwe reconcile:

```shell
flux reconcile kustomization vault-bootstrap --with-source
```

Vault zal nu correct opgezet worden.

## 10.6 GitLab-runner instellen

Voor het correct functioneren van CI/CD is een geldige GitLab Runner token nodig.

1. Maak een runner aan in GitLab en kopieer het registratie-token.
2. Voeg het token toe aan Vault:
```shell
vault kv put kv/gitlab/runner registrationToken=<jouw_token>
```
3. Zorg dat de Vault policy en de ExternalSecret correct ingesteld zijn zodat Flux het token
kan ophalen en injecteren in de runner-installatie.

## 10.7 VPN Configuratie (voor externe toegang tot Vault)
In de “infrastructure” repository ga naar de vpn folder, run het `./generate-config.sh`
script. 
En connecteer via het commando: 

```shell
sudo openvpn –config client-config.ovpn`
```


## 10.8 Overzicht van de Deployment Flow

De deployment volgt deze gestructureerde stappen:
1. **Terraform apply (infralaag):** maakt netwerken, IAM, EKS.
2. **Terraform apply (Kubernetes-modules + Flux):** zet alle clusterconfiguratie klaar.
3. **Flux bootstrapt automatisch:** Istio, Vault, GitLab Runner, microservices, policies.
4. **CI/CD** wordt handmatig geconfigureerd waar nodig gitlab registration token
5. **VPN** Configuratie via script

## 10.9 Resultaat

Na uitvoering van deze stappen staat er een volledig werkende, veilige en modulaire
Kubernetes-architectuur in AWS met:
- Geïntegreerde GitOps-pipeline (Flux)
- Automatische CI/CD via GitLab Runner + Podman
- Secure secret management met Vault
- Interne toegang via VPN + Private DNS
- En een service mesh voor microservices verkeer

- Indien gewenst kan dit proces eenvoudig gerepliceerd worden naar andere regio’s door een
nieuwe variabele set en workspace aan te maken in Terraform.


# 11. Conclusie en reflectie

Een van de belangrijkste inzichten die we opdeden, is dat het ontwerpen van infrastructuur
vandaag veel meer is dan enkel het “draaiende krijgen” van applicaties. Het gaat over
veiligheid, schaalbaarheid, automatisering en vooral: reproduceerbaarheid. Dankzij het
gebruik van Infrastructure as Code (Terraform) en GitOps (FluxCD) leerden we hoe belangrijk
het is om infrastructuur te beschouwen als software: onderhevig aan versiebeheer, testbaar,
en continu verbeterbaar.

Daarnaast boden de technologieën die we gebruikten — zoals HashiCorp Vault voor secret
management en Istio voor service mesh-beveiliging — ons een diepgaande blik op de
complexiteit van moderne platform engineering. We leerden hoe bedrijven omgaan met
gevoelige informatie, en hoe je microservices veilig met elkaar laat communiceren in een zero-
trust omgeving. Deze inzichten overstijgen de puur technische uitvoering; ze gaven ons een
bredere kijk op hoe IT-afdelingen risico’s beheersen en kwaliteit borgen.

De gescheiden opzet van applicatie- en tooling cluster confronteerde ons ook met realistische
afwegingen rond beschikbaarheid, afhankelijkheden en beheerbaarheid. Door deze
componenten te isoleren, leerden we hoe je robuuste omgevingen opzet waarin kritieke tooling
beschikbaar blijft, zelfs wanneer applicaties falen of herschaald worden.

We ontwikkelden eveneens een sterkere vaardigheid in technische communicatie: het
documenteren van configuraties, het structureren van complexe omgevingen en het maken
van keuzes die niet alleen technisch juist zijn, maar ook begrijpbaar en overdraagbaar aan
collega’s of toekomstige teams. Het schrijven van dit systeemdossier zelf was hierbij een
oefening in helderheid en volledigheid.
