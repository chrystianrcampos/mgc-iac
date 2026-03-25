# mgc-iac

Infraestrutura como Código para provisionamento de recursos na **Magalu Cloud** utilizando **OpenTofu** e o provider oficial `magalucloud/mgc`. Gerencia instâncias de VM, chaves SSH, security groups e VPCs.

## Arquitetura

```text
                          API Magalu Cloud
  ┌──────────────┐                         ┌──────────────────────────────────┐
  │  OpenTofu    │ ──────────────────────► │         Magalu Cloud             │
  │  (local)     │   magalucloud/mgc       │                                  │
  └──────────────┘                         │  ┌──────────┐  ┌──────────────┐  │
                                           │  │ SSH Keys │  │ Security     │  │
                                           │  │          │  │ Groups       │  │
                                           │  └──────────┘  └──────────────┘  │
                                           │  ┌────────────────────────────┐  │
                                           │  │  Virtual Machine (VM)      │  │
                                           │  │  Ubuntu + Docker           │  │
                                           │  └────────────────────────────┘  │
                                           └──────────────────────────────────┘
```

## Recursos Provisionados

| Recurso | Tipo | Descrição |
| --- | --- | --- |
| **SSH Key** | `mgc_ssh_keys` | Chave pública SSH para acesso às VMs |
| **Security Group** | `mgc_network_security_groups` | Grupo com regras de ingress/egress |
| **VM** | `mgc_virtual_machine_instances` | Instância Ubuntu com Docker instalado via user_data |

### Regras do Security Group

| Regra | Direção | Protocolo | Porta |
| --- | --- | --- | --- |
| SSH IPv4 | ingress | TCP | 22 |
| SSH IPv6 | ingress | TCP | 22 |
| HTTP IPv4 | ingress | TCP | 80 |
| HTTP IPv6 | ingress | TCP | 80 |
| HTTPS IPv4 | ingress | TCP | 443 |
| HTTPS IPv6 | ingress | TCP | 443 |
| Egress IPv4 | egress | — | all |
| Egress IPv6 | egress | — | all |

## Estrutura do Projeto

```text
.
├── main.tf                     # Provider, backend, data sources, locals e chamadas de módulos
├── variables.tf                # Declaração de todas as variáveis
├── terraform.tfvars            # Seus valores reais (gitignored)
├── terraform.tfvars.example    # Template seguro para copiar
├── backend.hcl                 # Credenciais do R2 (gitignored)
├── backend.hcl.example         # Template seguro para copiar
└── modules/
    ├── ssh_keys/
    │   ├── main.tf             # mgc_ssh_keys
    │   ├── variables.tf
    │   └── outputs.tf
    ├── security_groups/
    │   ├── main.tf             # mgc_network_security_groups + rules
    │   ├── variables.tf
    │   └── outputs.tf
    └── virtual_machines/
        ├── main.tf             # mgc_virtual_machine_instances
        ├── variables.tf
        └── outputs.tf
```

## Pré-requisitos

- [OpenTofu](https://opentofu.org/docs/intro/install/) >= 1.6
- Conta na [Magalu Cloud](https://magalu.cloud) com credenciais de API

## Configuração

### 1. Clone o repositório

```bash
git clone <repo-url>
cd mgc-iac
```

### 2. Crie o arquivo de variáveis

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edite `terraform.tfvars` com seus valores reais (veja [Variáveis](#variáveis) abaixo).

### 3. Crie o arquivo de credenciais do backend

```bash
cp backend.hcl.example backend.hcl
```

Edite `backend.hcl` com suas credenciais do Cloudflare R2 (veja [State Remoto](#state-remoto) abaixo).

### 4. Inicialize o OpenTofu

```bash
tofu init -backend-config=backend.hcl
```

### 5. Revise o plano

```bash
tofu plan
```

### 6. Aplique

```bash
tofu apply
```

## State Remoto

O state é armazenado em um bucket **Cloudflare R2** usando o backend compatível com S3. Isso mantém o arquivo de state fora do disco local e viabiliza colaboração.

A configuração do backend é separada para evitar o commit de segredos:

| Arquivo | Commitado | Conteúdo |
| --- | --- | --- |
| `main.tf` (bloco `backend`) | ✓ | nome do bucket, caminho da key, region, skip flags |
| `backend.hcl` | ✗ gitignored | endpoint R2 (contém o Account ID), access key, secret key |

Para criar um token de API R2, acesse **Cloudflare Dashboard → R2 → Manage R2 API Tokens** e crie um token com permissão **Object Read & Write** com escopo no seu bucket.

Formato do `backend.hcl`:

```hcl
endpoint   = "https://<ACCOUNT_ID>.r2.cloudflarestorage.com"
access_key = "<R2_ACCESS_KEY_ID>"
secret_key = "<R2_SECRET_ACCESS_KEY>"
```

## Variáveis

| Variável | Descrição | Padrão | Sensível |
| --- | --- | --- | --- |
| `api_key` | Chave de API da Magalu Cloud | — | ✓ |
| `region` | Região da Magalu Cloud | `br-se1` | |
| `availabiliy_zone` | Zona de disponibilidade | — | |
| `key_pair_id` | ID do par de chaves para autenticação | — | ✓ |
| `key_pair_secret` | Segredo do par de chaves para autenticação | — | ✓ |
| `ssh_public_key` | Chave pública SSH para acesso às VMs | — | |
| `vm_default_name` | Nome da VM | — | |
| `vm_default_machine_type` | Tipo de máquina (ex: `BV2-4-10`) | — | |
| `vm_default_image` | Imagem do SO (ex: `cloud-ubuntu-24.04 LTS`) | — | |

## Segurança

- **`terraform.tfvars`** e **`backend.hcl`** são gitignored — nunca os commite.
- **`terraform.tfstate`** é gitignored — em modo local contém todos os valores de variáveis em texto plano.
- O state remoto no R2 é criptografado em repouso pela Cloudflare por padrão.
- As credenciais da API são passadas via variáveis sensíveis e nunca aparecem no state em texto plano.
