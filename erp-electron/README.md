# 🍔 Império’s Burger – Sistema de Controle de Pedidos  
Projeto Integrado – UNIFEOB

## 🎓 Instituição
**UNIFEOB – Centro Universitário Octávio Bastos**  
Cursos: Ciência da Computação e Análise e Desenvolvimento de Sistemas  
Módulo: Desenvolvimento de Software Corporativo

## 👨‍💻 Equipe
- Gabrielly Simão Domingos  
- Gustavo Miguel Viti da Silva  
- João Vitor Toledo da Silva  
- Pedro de Freitas da Silva  
- Yasmin Beatriz Ruela da Silva

---

## 🏢 Empresa Beneficiada
**Império’s Burger**

Sistema desenvolvido para auxiliar o fluxo de atendimento e controle de pedidos da hamburgueria.

---

## 📚 Disciplinas Envolvidas

### 🔐 Segurança e Auditoria  
Aplicação de:
- Permissões de usuários  
- Views  
- Procedures  
- Criptografia  
- Técnicas contra SQL Injection  

### 🖥 Sistemas Operacionais  
Fundamentação no uso de:
- Windows  
- Linux  
- Conceitos de servidor  
- Noções de hardware

### 💻 Desenvolvimento de Software  
Tecnologias e padrões utilizados:
- HTML, CSS, JavaScript  
- React  
- Electron  
- TailwindCSS  
- IPC (comunicação entre processos)  
- Padrão MVC  
- Charts.js para gráficos e dashboards

### 📁 Estrutura de Dados  
Conceitos aplicados:
- Organização de dados  
- Pilhas  
- Listas  
- Mapas  
- Entre outras estruturas

### 🚀 Projeto de Desenvolvimento de Software  
Disciplina base utilizada para integrar todas as outras e orientar a construção do projeto completo.

---

## 🛠 Tecnologias Utilizadas

- Node.js  
- Electron  
- React  
- TailwindCSS  
- MySQL  
- Chart.js

---

## ⚙️ Como Instalar e Executar

### 1️⃣ Importar o Banco de Dados
- Abra o MySQL
- Execute o script localizado em:
```bash
database/bd.sql
```
Rodar o Sistema
```bash
npm start
```


## 📂 Estrutura do Projeto
```bash 
/
├─ server/ → Contém todo o back-end da aplicação (API e regras de negócio)
│  ├─ controllers/ → Controladores que processam requisições e aplicam regras
│  ├─ models/ → Modelos que representam tabelas e entidades do banco
│  ├─ routers/ → Arquivos que definem as rotas da API
│  └─ db.js → Configuração e conexão com o banco de dados
│
├─ src/ → Front-end React + Electron
│  ├─ components/ → Componentes reutilizáveis que compõem a interface
│  │  ├─ Charts → Componentes gráficos usando Chart.js
│  │  ├─ Dashboard → Componentes da tela de visão geral
│  │  ├─ Historico → Elementos da visualização de histórico de pedidos
│  │  ├─ Pedidos → Componentes usados na tela de pedidos
│  │  ├─ Produtos → Componentes relacionados a produtos
│  │  ├─ Usuarios → Componentes de gestão de usuários
│  │  ├─ Vendas → Componentes da área de vendas
│  │  ├─ Header.jsx → Cabeçalho da interface
│  │  └─ Menu.jsx → Menu lateral de navegação
│  │
│  ├─ hooks/ → Hooks personalizados reutilizáveis
│  ├─ images/ → Logos e imagens usadas no sistema
│  ├─ utils/ → Funções utilitárias de apoio ao código
│  ├─ App.jsx → Componente raiz que define o fluxo geral da aplicação
│  ├─ index.css → Estilos globais
│  └─ main.jsx → Ponto de entrada do React
│
├─ .env → Variáveis de ambiente sensíveis (não versionado)
├─ .gitignore → Arquivos ignorados pelo Git
├─ CHANGELOG.md → Registro de alterações do projeto
├─ index.html → Página base usada pelo React/Vite
├─ main.js → Configurações principais do Electron
├─ preload.js → Ponte segura entre Electron e front-end
├─ package.json → Scripts, dependências e metadados do projeto
├─ package-lock.json → Versões travadas das dependências
└─ vite.config.js → Configurações do Vite
```

## 📄 Licença

Projeto acadêmico desenvolvido exclusivamente para fins educacionais.
