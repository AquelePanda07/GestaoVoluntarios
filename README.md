# Sistema: Gestao de Voluntarios

## 1. Nome do sistema
Gestao de Voluntarios

## 2. Nome do criador
Breno Carvalho Santos

## 3. Descricao do app
O aplicativo foi desenvolvido para apoiar a organizacao e o acompanhamento de pessoas voluntarias em uma instituicao.
Ele atende coordenadores, equipes administrativas e responsaveis por projetos sociais que precisam manter os registros atualizados.
O sistema permite autenticar usuarios, cadastrar novos voluntarios e consultar rapidamente a lista completa de participantes.
Tambem e possivel editar e excluir voluntarios, mantendo os dados sempre consistentes para tomada de decisao.
Os principais dados gerenciados sao: nome do voluntario, lotacao, tempo de atuacao, imagem, dados de usuario (nome, e-mail e senha) e historico de registros no banco.

## 4. Funcionalidade aplicada ao tema escolhido pela dupla
A funcionalidade principal aplicada ao tema e o CRUD completo de voluntarios integrado a autenticacao de usuarios.
Na pratica, o sistema permite cadastrar, listar, atualizar e excluir voluntarios, com interface em Flutter e integracao com API PHP.
Isso facilita a gestao diaria da equipe de voluntariado e reduz o controle manual em planilhas.

## 5. Link do repositorio publico no GitHub
Preencher com o link oficial do repositorio:
https://github.com/AquelePanda07/GestaoVoluntarios.git

## 6. Passo a passo para clonar e rodar o projeto

### Versao do Flutter e banco de dados
- Flutter: usar versao compativel com Dart SDK `^3.12.2` (sugestao: canal stable mais recente compativel).
- Banco de dados utilizado: MySQL (via XAMPP), com scripts SQL na pasta `xampp_api/schema.sql`.

### Passos
1. Clonar o repositorio:
	```
	git clone https://github.com/AquelePanda07/GestaoVoluntarios.git
	```
2. Entrar na pasta do projeto:
	```bash
	cd voluntarios
	```
3. Instalar as dependencias do Flutter:
	```bash
	flutter pub get
	```
4. Configurar o backend local no XAMPP:
	- Copiar a pasta `xampp_api` para `htdocs/voluntarios_api`.
	- Iniciar Apache e MySQL no XAMPP.
	- Criar/importar o banco executando o arquivo `xampp_api/schema.sql` no phpMyAdmin.
5. (Opcional) Ajustar URL da API ao executar o app:
	```bash
	flutter run --dart-define=API_BASE_URL=http://localhost/voluntarios_api
	```
6. Rodar o aplicativo:
	```bash
	flutter run
	```

## 7. Link do video no YouTube (nao listado)
Preencher com o link do video nao listado:
https://www.youtube.com/watch?v=SEU_VIDEO_ID
