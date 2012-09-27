wordpressScaffold () {
	git clone https://github.com/WordPress/WordPress.git
	echo "move wordpress to root project"
	rm -rf WordPress/.git
	mv WordPress/* ./
	echo "delete temp folder"
	rm -rf WordPress/
	echo "clear the default structure folders"
	rm -rf wp-content/themes/*
	rm -rf wp-content/plugins/*
	echo "Inicializando repositório Git"
	git init
	echo "Qual a URL do seu repositório online?"
	read repository
	if [ "$repository" != "" ]; then
		git add .
		git commit -m 'project build'
		git remote add origin $repository
		echo "Adicionando remote"
		git push origin master
	fi
	echo "Baixando temas como submódulos"
	git submodule add git://github.com/retlehs/roots.git ./wp-content/themes/roots
	git submodule add git@mktvirtual.beanstalkapp.com:/wp-default-theme.git ./wp-content/themes/mktvirtual
	git submodule add git@github.com:brunomarks/Wordpress-Configurations.git ./Configurations
	git submodule init
	git submodule update

	echo "Setando idioma para pt_BR"
	sed "s/'WPLANG', ''/'WPLANG', 'pt_BR'/g" wp-config-sample.php > wp-config.php

	echo "Qual o nome da pasta do seu projeto?"
	read nome
	if [ "$nome" != "" ]; then
		mv ./Configurations/Sql/* ./

		echo "Criando dump do banco"
		sed 's/nproject/'$nome'/g' nproject.sql > my_project_dump.sql	
	fi
	echo "Qual a URL de onde você irá desenvolver?"
	read url
	if [ "$url" != "" ]; then
		echo "Criando documentação"
		
		echo "Documentando URL..."
		mkdir ./Docs
		mv ./Configurations/Docs/* ./Docs
		echo "Projecto criado em `date` por `whoami`"$'\r'$'\r' >> ./Docs/readme.md
		echo "#Documentação: "$'\r'$'\r' >> ./Docs/readme.md
		echo "#Projeto: "$nome $'\r'$'\r' >> ./Docs/readme.md
		echo "* [URL do projeto]("$url")"$'\r' >> ./Docs/readme.md
		echo "* [URL do repositório no GIT]("$repository")" >> ./Docs/readme.md
	fi

	echo "Configurando robots.txt & humans.txt"	
	mv ./Configurations/SEO/* ./

	echo "Configurando .gitignore"
	mv ./Configurations/Server/.htaccess ./
	mv ./Configurations/Server/.gitignore ./

	echo $'\r'"# BEGIN WordPress"$'\r' >> .htaccess
	echo "<IfModule mod_rewrite.c>"$'\r' >> .htaccess
	echo "RewriteEngine On"$'\r' >> .htaccess
	echo "RewriteBase /"$nome"/"$'\r' >> .htaccess
	echo "RewriteRule ^index\.php$ - [L]"$'\r' >> .htaccess
	echo "RewriteCond %{REQUEST_FILENAME} !-f"$'\r' >> .htaccess
	echo "RewriteCond %{REQUEST_FILENAME} !-d"$'\r' >> .htaccess
	echo "RewriteRule . /"$nome"/index.php [L]"$'\r' >> .htaccess
	echo "</IfModule>"$'\r' >> .htaccess

	echo "Configurando plugins \n \n"
	mv ./Configurations/Plugins/* ./wp-content/plugins/

	echo "Configurando mysql.sock"
	ln -s /Applications/MAMP/tmp/mysql/mysql.sock /tmp/mysql.sock

	
	echo "Qual o nome do Banco (database name)?"
	read database
	if [ "$database" != "" ]; then
		mysql -h localhost -u root -p root $database < my_project_dump.sql
		sed "s/database_name_here/"$database"/g" wp-config.php > wp-config2.php
		sed "s/username_here/root/g" wp-config2.php > wp-config.php
		sed "s/password_here/root/g" wp-config.php > wp-config2.php
		sed "s/'wp_'/"$name"_/g" wp-config2.php > wp-config.php
		rm wp-config2.php
		rm my_project_dump.sql
		rm nproject.sql
	fi

	echo "*********** Instalação concluída **************"
}


echo "Escolha o Framework/CMS: [c] CakePHP [w] Wordpress "
read platform

if [ "$platform" == "w" ]; then
	echo "Preparando instalação do Wordpress"
	wordpressScaffold
else
	echo "Preparando instalação CakePHP"
fi


#sed 's/robinho/ganso/g' nproject.sql > my_project_dump.sql
#compass create --syntax sass --sass-dir "dev/sass" --css-dir "css" --javascripts-dir "js" --images-dir "images"
##define('WP_HOME','http://torratorra2012.www/blog');
#define('WP_SITEURL','http://torratorra2012.www/blog');