#!/bin/bash

#QuickMessageSender
#by Tomasz Bieniek && Jakub Ludwiczak

gap="------------"
wrongChoice="!!!!Podano zly wybor!!!!"
back="Jesli chcesz wrocic wpisz: wroc"
path=$PWD

function mainPanel()
{
		cd $path
		echo $gap
		echo "1. Panel logowania"
		echo "2. Logowanie jako administrator"
		echo "3. Zakoncz program"
		echo $gap
		
		read -p "> " Choose

		case $Choose in
			1) clear 
			userLoginPanel ;;					
			2) clear
			adminLoginPanel ;;
			3) exit 0 ;;
			*) clear
			tput setaf 1
			echo $wrongChoice
			tput setaf 7
			mainPanel ;;
		esac
}

function adminLoginPanel()
{
		cd "$path/users/admin"
		clear
		echo $back
		echo $gap
		read -p "Podaj haslo admina> " APassword
		Check=$(cat password.txt)
		if([ "$Check" == "$APassword" ]) then
			clear
			echo "Zalogowano jako administrator"
			adminPanel
		elif( [ "$APassword" == "wroc" ] ) then
			clear
			mainPanel
		else
			clear
			echo "!!!!Podano zle haslo!!!!"
			adminLoginPanel
		fi
}

function adminPanel()
{
	cd "$path/users/admin"
	echo $gap
	echo "1. Stworz uzytkownika"
	echo "2. Usun uzytkownika"
	echo "3. Zmien haslo admina"
	echo "4. Wyslij wiadomosc"
	echo "5. Wyloguj sie"
	echo "6. Zakoncz program"
	echo $gap

	read -p "> " Choose
	
	case $Choose in
		1) clear
			createUser
			adminPanel ;;
		2) clear 
			deleteUser
			adminPanel ;;
		3) clear
			changePassword
			adminPanel ;;
		4) clear
			sendMessage ;;
		5) clear
			echo "Wylogowano sie z admina"
			mainPanel ;;
		6) clear
			echo "Program zakonczyl dzialanie"
			exit 0 ;;
		*) clear
			tput setaf 1
			echo $wrongChoice
			tput setaf 7
			adminPanel ;;
	esac
}

function userLoginPanel()
{
	cd "$path/users"
	while [ true ]
	do
		echo $back
		echo $gap
		
		read -p "Login> " Login
		
		if( [ "$Login" == "wroc" ] ) then
			mainPanel
		fi
		
		if(! [ -d "$path/users/$Login" ]) then
			echo setaf 3
			echo "Uzytkownik nie istnieje"
			echo setaf 7
		else
			cd "$path/users/$Login"
			if(! [ -f "password.txt" ] ) then
				read -p "Stworz haslo> " UPassword
				echo $UPassword > password.txt
				clear
				userPanel
			else
				read -p "Podaj haslo> " UPassword
				CheckPassword=$(cat password.txt)
				if( [ "$CheckPassword" == "$UPassword" ] ) then
					clear
					userPanel
				else
					clear
					tput setaf 1
					echo "!!!Podano zle haslo!!!"
					tput setaf 7
					echo $gap
					userLoginPanel
				fi
			fi
			break
		fi
	done
}

function userPanel()
{
	echo $gap
	echo "1. MailBox"
	echo "2. Zmien haslo"
	echo "3. Wyloguj sie"
	echo "4. Zakoncz program"
	echo $gap
	
	read Choose
	
	case $Choose in
		1) clear
			readMessage ;;
		2) changePassword
			userPanel ;;
		3) clear
			echo "Wylogowano pomyslnie"
			mainPanel ;;
		4) clear
			echo "Program zakonczyl dzialanie" 
			exit 0 ;;
		*) clear
			echo $wrongChoice
			userPanel ;;
	esac
}

function createUser()
{
	clear
	cd "$path/users"
	while [ true ]
	do
		echo $back
		echo $gap
		
		read -p "Podaj nazwe uzytkownika> " UserName
		
		if( [ "$Login" == "wroc" ] ) then
			adminPanel
		fi
		
		if ([ -d "$UserName" ]) then
			clear
			echo "Uzytkownik juz istnieje"
			echo $gap
		else
			mkdir $UserName
			cd "$path/users/$UserName"
			mkdir ./mailbox
			break
		fi
	done
	clear
	tput setaf 2
	echo "Konto uzytkownika zostalo utworzone"
	tput setaf 7
}

function deleteUser()
{
	cd "$path/users"
	
	echo $back
	echo "Usuwanie uzytkownika"
	echo $gap
	
	read -p "Podaj login uzytkownika, ktorego chcesz usunac> " Login
	
	if( [ "$Login" == "wroc" ] ) then
		clear
		adminPanel
	fi
	
	if( [ "$Login" == "admin" ] ) then
		tput setaf 1
		echo "Nie mozna usunac admina"
		tput setaf 7
		deleteUser
	fi
	
	rm -r $Login
	
	clear
	tput setaf 3
	echo "Konto uzytkownika $Login zostalo usuniete"
	tput setaf 7
}

function sendMessage()
{
	echo "1. Wyslij wszystkim"
	echo "2. Wyslij danej osobie"
	echo $gap
	read -p "> " Choose
	case $Choose in
		1) clear
			sendMessageToAll ;;
		2) clear
			sendMessageToUser ;;
		*) clear
			tput setaf 1
			echo $wrongChoice
			tput setaf 7
			echo $gap
			sendMessage ;;
	esac
			
}

function sendMessageToAll()
{
	read -p "Podaj tresc wiadomosci> " contentOfMessage
	read -p "Podaj nazwe wiadomosci> " nameOfMessage
	clear
	FILES="$path/users/*"
	for f in $FILES;
	do
		if( [ "$f" == "$path/users/admin" ] ) then
			echo "Admin"
			continue
		fi
		cd "$f/mailbox"
		echo $contentOfMessage > "$nameOfMessage.txt"
		tput setaf 2
		echo "Wiadomosc zostala wyslana wszystkim"
		tput setaf 7
		chmod 777 "$nameOfMessage.txt"
	done
	adminPanel
}

function sendMessageToUser()
{
	read -p "Podaj nazwe uzytkownika, ktoremu chcesz wyslac wiadomosc> " nameOfUser
	if(! [ -d "$path/users/$nameOfUser" ]) then
		clear
		tput setaf 3
		echo "Uzytkownik nie istnieje"
		tput setaf 7
		sendMessageToUser
	fi
	
	read -p "Podaj tresc wiadomosci> " contentOfMessage
	read -p "Podaj nazwe wiadomosci> " nameOfMessage
	cd "$path/users/$nameOfUser/mailbox"
	echo $contentOfMessage > "$nameOfMessage.txt"
	tput setaf 2
	echo "Wiadomosc wyslana pomyslnie"
	tput setaf 7
	adminPanel
}

function readMessage()
{
	cd "mailbox"
	flag=`ls -s`
	if ( [ "$flag" == "total 0" ] ) then
		echo "Skrzynka jest pusta"
		userPanel
	fi	
	dir
	echo $gap
	read -p "Podaj nazwe wiadomosci, ktora chcesz otworzyc> " nameOfMessage
	clear
	rMessage=$(cat $nameOfMessage.txt)
	echo $rMessage
	rm -r "$nameOfMessage.txt"
	cd ..
	userPanel
}


function changePassword()
{
	echo "---ZMIANA HASLA---"
	read -p "Podaj haslo do zmiany> " Password
	echo $Password > password.txt
	clear
	echo "Haslo zostalo zmienione"
	echo "Zaloguj sie ponownie"
	userLoginPanel
	
}

#First initialization of app
if(! [ -d "users" ]) then
	if [[ $EUID -ne 1 ]]; then #[ $(id -u) -ne 0 ]
		read -p "Utworz haslo admina>" AdminPassword
		mkdir -p users/admin
		cd "$path/users/admin"
		echo $AdminPassword > password.txt
		echo "Haslo admina zostalo utworzone, prosze ponownie uruchomic program"
		chmod 777 password.txt
		exit 0
	else
		echo "Pierwsza inicjalizacja skryptu wymaga uprawnien roota"
		exit 1
	fi

fi

#Run
clear
mainPanel
