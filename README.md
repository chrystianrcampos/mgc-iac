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
                                           │  ┌──────────────────────────┐    │
                                           │  │  VPC + Subnets (A e B)   │    │
                                           │  └──────────────────────────┘    │
                                           │  ┌──────────────────────────┐    │
                                           │  │  VMs (Ubuntu + Docker)   │    │
                                           │  │  vm-1 (zona A)           │    │
                                           │  │  vm-2 (zona B)           │    │
                                           │  └──────────────────────────┘    │
                                           └──────────────────────────────────┘
```

## Recursos Provisionados

| Recurso | Tipo | Descrição |
| --- | --- | --- |
| **SSH Key** | `mgc_ssh_keys` | Chave pública SSH para acesso às VMs |
| **Security Group** | `mgc_network_security_groups` | Grupo com regras de ingress/egress |
| **VPC** | `mgc_network_vpcs` | Rede privada virtual |
| **Subnet Pool** | `mgc_network_subnetpools` | Pool de CIDRs `10.0.0.0/16` |
| **Subnet A** | `mgc_network_vpcs_subnets` | `10.0.1.0/24` — zona `br-ne1-a` |
| **Subnet B** | `mgc_network_vpcs_subnets` | `10.0.2.0/24` — zona `br-ne1-b` |
| **VMs** | `mgc_virtual_machine_instances` | Instâncias Ubuntu com Docker via `user_data` |

### Regras do Security Group

| Regra | Direção | Protocolo | Porta / Escopo |
| --- | --- | --- | --- |
| SSH IPv4 | ingress | TCP | 22 |
| SSH IPv6 | ingress | TCP | 22 |
| HTTP IPv4 | ingress | TCP | 80 |
| HTTP IPv6 | ingress | TCP | 80 |
| HTTPS IPv4 | ingress | TCP | 443 |
| HTTPS IPv6 | ingress | TCP | 443 |
| ICMP subnets | ingress | ICMP | por CIDR de cada subnet |
| Egress IPv4 | egress | — | all |
| Egress IPv6 | egress | — | all |

## Estrutura do Projeto

```text
.
├── main.tf                     # Provider, backend e chamadas de módulos
├── variables.tf                # Declaração de todas as variáveis
├── terraform.tfvars            # Seus valores reais (gitignored)
├── terraform.tfvars.example    # Template seguro para copiar
├── backend.hcl                 # Credenciais do object storage (gitignored)
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
    ├── vpcs/
    │   ├── main.tf             # mgc_network_vpcs + subnetpool + subnets
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

Edite `backend.hcl` com suas credenciais do object storage (veja [State Remoto](#state-remoto) abaixo).

### 4. Inicialize o OpenTofu

```bash
tofu init
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

O state é armazenado em um bucket de object storage usando o backend compatível com S3. Isso mantém o arquivo de state fora do disco local e viabiliza colaboração.

A configuração do backend é separada para evitar o commit de segredos:

| Arquivo | Commitado | Conteúdo |
| --- | --- | --- |
| `main.tf` (bloco `backend`) | ✓ | nome do bucket, caminho da key, region, skip flags |
| `backend.hcl` | ✗ gitignored | endpoint, access key, secret key |

Formato do `backend.hcl`:

```hcl
endpoint   = "https://<endpoint>"
access_key = "<ACCESS_KEY_ID>"
secret_key = "<SECRET_ACCESS_KEY>"
```

## Variáveis

| Variável | Descrição | Padrão | Sensível |
| --- | --- | --- | --- |
| `api_key` | Chave de API da Magalu Cloud | — | ✓ |
| `region` | Região da Magalu Cloud | `br-se1` | |
| `key_pair_id` | ID do par de chaves para autenticação | — | ✓ |
| `key_pair_secret` | Segredo do par de chaves para autenticação | — | ✓ |
| `ssh_public_key` | Chave pública SSH para acesso às VMs | — | |
| `ssh_key_name` | Nome da SSH key na Magalu Cloud | — | |
| `security_group_name` | Nome do security group | — | |
| `security_group_description` | Descrição do security group | — | |
| `virtual_machines` | Map de VMs a provisionar (ver exemplo) | — | |
| `vpc_name` | Nome da VPC | — | |
| `vpc_subnetpool_name` | Nome do subnet pool | — | |
| `vpc_subnetpool_description` | Descrição do subnet pool | — | |
| `vpc_dns_nameservers` | Servidores DNS das subnets | `["1.1.1.1", "8.8.8.8"]` | |

### Formato de `virtual_machines`

```hcl
virtual_machines = {
  vm-1 = {
    name              = "my-vm-1"
    machine_type      = "BV1-1-10"
    image             = "cloud-ubuntu-24.04 LTS"
    availability_zone = "br-ne1-a"
  }
}
```

## Segurança

- **`terraform.tfvars`** e **`backend.hcl`** são gitignored — nunca os commite.
- **`terraform.tfstate`** é gitignored — em modo local contém todos os valores de variáveis em texto plano.
- O state remoto é criptografado em repouso pelo provider de object storage.
- As credenciais da API são passadas via variáveis sensíveis e nunca aparecem no state em texto plano.
