Caso de Uso: Cadastro de Usuário
Ator: Usuário
Objetivo: Permitir que o usuário crie uma conta no sistema.

Pré-condições:
- O usuário deve possuir um e-mail válido.
- O sistema deve estar disponível.

Pós-condições:
- O usuário é registrado no sistema e pode realizar login.

Fluxo Principal:
1) Usuário acessa a opção de cadastro.
2) Usuário informa e-mail e senha.
3) Sistema valida os dados.
4) Sistema registra o usuário no banco de dados.
5) Sistema confirma o cadastro.

Fluxos Alternativos:
A1) Caso o e-mail já esteja cadastrado, o sistema exibe mensagem de erro.
A2) Caso os dados estejam inválidos, o sistema solicita correção.

Regras de Negócio:
- RN08 Os dados principais do sistema não devem ser excluídos fisicamente.

Requisitos Relacionados:
- RF01 O sistema deve permitir o cadastro de usuários utilizando email e senha.
- RNF04 Os dados do usuário devem ser protegidos utilizando mecanismos de segurança.
