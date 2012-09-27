#!/bin/bash

# Lê os dados para acesso ao banco de dados
configDb() {
	echo "Digite o host do banco:"
	read host
	echo "Digite o usuario do banco:"
	read user
	echo "Digite a porta do banco:"
	read port
	echo "Digite o nome do banco a ser criado:"
	read base
	echo "Digite a senha do banco:"
	read pass
	
	if [ "$port" == "" ]; then
		port = 3306
	fi
}

# cria um link simbolico para rodar o client do mysql e cria o banco de dados para o projeto
createDb() {
	ln -s /Applications/MAMP/tmp/mysql/mysql.sock /tmp/mysql.sock
	echo "Criando o banco de dados..."
	mysql -h $host -u $user -p -P $port -e "create database $base"
}

# Configura o CakePHP para conectar ao banco
configCake() {
	echo "Configurando o cakephp para conectar ao banco..."
	sed "s/localhost/$host/g" app/Config/database.php.default > app/Config/database.php.host
	sed "s/user/$user/g" app/Config/database.php.host > app/Config/database.php.user
	sed "s/\=\>\ \'password\'/\=\>\ \'$pass\'/g"  app/Config/database.php.user > app/Config/database.php.pass
	sed "s/database_name/$base/g" app/Config/database.php.pass > app/Config/database.php.base
	sed "s/\/\// /g" app/Config/database.php.base > app/Config/database.php
	rm app/Config/database.php.host
	rm app/Config/database.php.user
	rm app/Config/database.php.pass
	rm app/Config/database.php.base
	rm app/Config/database.php.default
}

importDb(){
	echo "Criando as tabelas do projeto..."
	./app/Console/cake schema create
}

configRepo(){
	echo "Configurando o repositório"
	rm -rf .git
	echo "Deseja criar o repositório do seu projeto agora? (y/n)"
	read repo
	if [ "$repo" == "y" ]; then
		initRepo
	fi
}

initRepo(){
	git init
	echo "Repositorio criado!"
	git add .
	git commit -m 'Iniciando projeto'
	echo "Primeiro commit feito!"
	sleep 2
	echo "Digite a url do seu repositório online?"
	read url
	if [ "$url" != "" ]; then
		git remote add origin $url
		echo "Realizando o push..."
		git push origin master
	fi
}

# Done!
congratulations() {
	echo "****************************************************************************"
	echo "Parabéns, seu projeto está pronto para uso!"
	echo "Para adicionar o operador padrão do painel de controle, acesse /users/create"
	echo "E-mail:   mktvirtual@mktvirtual.com.br"
	echo "Senha:    123456"
	echo "Bom trabalho ;)"
	echo "****************************************************************************"
}

# clona o project do git@github.com:plastic/project.git
init() {
	# Folder do project
	echo "Digite o nome da pasta do projeto"
	read folder
	
	# Clonando o project em $folder
	echo "Clonando o projeto..."
	git clone git@github.com:plastic/project.git $folder
	clear
	
	# Atualizando os submodulos
	echo "Projeto clonado!!!!"
	echo "Deseja atualizar os submodulos agora? (y/n)"
	read modulos
	if [ "$modulos" == "y" ]; then
		cd $folder
		git submodule init
		git submodule update
	fi
	clear
	# Criando e importando o banco de dados
	echo "Deseja criar o banco para o projeto? (y/n)"
	read banco
	if [ "$banco" == "y" ]; then
		configDb
		createDb
		configCake
		importDb
		clear
		configRepo
		congratulations
	fi
}

clear

echo "******************************************************"
echo "************ Install CakePHP Project *****************"
echo "******************************************************"

init