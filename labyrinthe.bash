#!/bin/bash

clear

# Initialiser le labyrinthe
function init_labyrinthe 
{
	#Initialiser la matrice à 0
	for ((y=0; y<LAB_LONG; y++)) ; 
	do
		for ((x=0; x<LAB_LARG; x++)) ; 
		do
			labyrinthe[$((y * LAB_LARG + x))]=0
		done
		#Initialiser la premiere et la dernier colone à 1
		labyrinthe[$((y * LAB_LARG + 0))]=1
		labyrinthe[$((y * LAB_LARG + (LAB_LARG - 1)))]=1
	done
	#Initialiser la premiere et la dernier ligne à 1
	for ((x=0; x<LAB_LARG; x++)) ; 
	do
		labyrinthe[$x]=1 
		labyrinthe[$(((LAB_LONG - 1) * LAB_LARG + x))]=1
	done
}

#Sculpter le labyrinthe en commencant par offset 
function scul_labyrinthe 
{
	local index=$1
	local dir=$RANDOM
	local i=0
	labyrinthe[$index]=1
	while [ $i -le 4 ] ; 
	do
		local offset=0
		case $((dir % 4)) in
			0) offset=1 ;;
			1) offset=-1 ;;
			2) offset=$LAB_LARG ;;
			3) offset=$((-$LAB_LARG)) ;;
		esac
		local index2=$((index + offset))
		if [[ labyrinthe[$index2] -eq 0 ]] ; 
		then
			local nindex=$((index2 + offset))
			if [[ labyrinthe[$nindex] -eq 0 ]] ; 
			then
				labyrinthe[$index2]=1
				scul_labyrinthe $nindex
			fi
		fi
		i=$((i + 1))
		dir=$((dir + 1))
	done
}

#Initialiser les sortie aléatoirement
function sortie_labyrinthe
{	
	read -p "Entrer le nombre de sortie = " nbr_s
	local i=0
	local x=0
	local y=0
	while [ $i != $nbr_s ]
	do
		x=$((RANDOM%LAB_LONG))
		y=$((RANDOM%LAB_LARG))
		if [[ labyrinthe[$((x * LAB_LARG + y))] -eq 0 ]]
		then	
			if [[ ($x == 1) || ($x == $((LAB_LONG-2)) ) || ($y == 1) || ($y == $((LAB_LARG-2))) ]]
			then
				labyrinthe[$((x * LAB_LARG + y))]=4
				i=$((i + 1))
			fi
		fi	
	done
}

#Afficher le labyrinthe
function print_labyrinthes 
{
	for ((y=0; y<LAB_LONG; y++)) ;
	do
		for ((x = 0; x < LAB_LARG; x++ )) ; 
		do
			if [[ labyrinthe[$((y * LAB_LARG + x))] -eq 0 ]] ; 
			then
				#Un mur
				echo -n "[]" 
			elif [[ labyrinthe[$((y * LAB_LARG + x))] -eq 2 ]] ; 
			then
				#Le Minotaure
				echo -ne "\033[32mMM\033[0m"
			elif [[ labyrinthe[$((y * LAB_LARG + x))] -eq 3 ]] ; 
			then
				#Thésée
				echo -ne "\033[31mTT\033[0m" 
			elif [[ labyrinthe[$((y * LAB_LARG + x))] -eq 4 ]] ;
			then
				#Entrées/Sorties
				echo -ne "\033[33mES\033[0m"
      			else
				#Vide
				echo -n "  "
         		fi
		done	
		echo 
	done
}

#Afficher les valeurs de la matrice
function print_labyrinthe_val {
	for ((y=0; y<LAB_LONG; y++)) ;
	do
		for ((x = 0; x < LAB_LARG; x++ )) ; 
		do
			echo -n $((labyrinthe[$((y * LAB_LARG + x))]))
		done
		echo
	done	
}
#Chercher la position de Thésée et lancer l'algorithme pour trouver la sortie
function cherche_T
{
	local a
	for ((y=0; y<LAB_LONG; y++)) ; do
	      for ((x=0; x<LAB_LARG; x++)) ; do
			if [[ $((labyrinthe[$((y * LAB_LARG + x))])) -eq 3 ]]; then
				echo -ne "Les cordonnées de Thésée sont :$y $x\n"
				a=$((y * LAB_LARG + x))
			fi
		done
	done
	#Lancer l'algorithme de recherche de la sortie autour de Thésée
	if [[ $((labyrinthe[$a + 1])) -eq 1 ]]; 
	then
		cherche_S $(($a + 1)) 2			
	fi
	if [[ $((labyrinthe[$a - 1])) -eq 1 ]]; 
	then
		cherche_S $(($a - 1)) 4	
	fi
	if [[ $((labyrinthe[$a + LAB_LARG])) -eq 1 ]]; 
	then
		cherche_S $(($a + $LAB_LARG)) 3		
	fi
	if [[ $((labyrinthe[$a - LAB_LARG])) -eq 1 ]]; then
		cherche_S $(($a - $LAB_LARG)) 1
	fi
	#Si Thesée est bloquer entre des murs et des Minotaure fin d'algorithme en affichant un message
	if [[ (($((labyrinthe[$a + 1])) -ne 1)) || (($((labyrinthe[$a + 1])) -ne 4)) ]] && [[ (($((labyrinthe[$a - 1])) -ne 1)) || (($((labyrinthe[$a - 1])) -ne 4)) ]] && [[ (($((labyrinthe[$a + LAB_LARG])) -ne 1)) || (($((labyrinthe[$a + LAB_LARG])) -ne 4)) ]] && [[ (($((labyrinthe[$a - LAB_LARG])) -ne 1)) || (($((labyrinthe[$a - LAB_LARG])) -ne 4)) ]]; 
	then
		echo -ne "\033[31mThésée ne peut pas réussir à retrouver la sortir\n\033[0m"
		echo "*****************************************************************************************"
		echo "**                               Merci pour votre visite                               **" 
		echo "**les valeur de labyrinthe choiser sont sauvgarder dans un fichier appeler 'labyrinthe'**"
		echo "*****************************************************************************************"
		exit 
	fi
}

#Fonction Recursive qui cherche la sortie 
function cherche_S
{
	local pos=$1
	#Vérifier si il y'a une sortie autour de "pos"
	if [[ (($((labyrinthe[$pos + 1]))  -eq 4)) || (($((labyrinthe[$pos - 1]))  -eq 4)) || (($((labyrinthe[$pos + LAB_LARG]))  -eq 4)) || (($((labyrinthe[$pos - LAB_LARG]))  -eq 4)) ]]; then
		echo -ne "\033[32mThésée peut réussir à retrouver la sortir\n\033[0m"	
		echo "*****************************************************************************************"
		echo "**                               Merci pour votre visite                               **" 
		echo "**les valeur de labyrinthe choiser sont sauvgarder dans un fichier appeler 'labyrinthe'**"
		echo "*****************************************************************************************"	
		exit
	else
	case $2 in
		1)	if [[ $((labyrinthe[$pos + 1])) -eq 1 ]]; 
			then
				cherche_S $(($pos + 1)) 2			
			fi
			if [[ $((labyrinthe[$pos - 1])) -eq 1 ]]; 
			then
				cherche_S $(($pos - 1)) 4	
			fi
			if [[ $((labyrinthe[$pos - LAB_LARG])) -eq 1 ]]; 
			then
				cherche_S $(($pos - $LAB_LARG)) 1
			fi ;;
		
		2)	if [[ $((labyrinthe[$pos + 1])) -eq 1 ]]; 
			then
				cherche_S $(($pos + 1)) 2			
			fi
			if [[ $((labyrinthe[$pos + LAB_LARG])) -eq 1 ]]; 
			then
				cherche_S $(($pos + $LAB_LARG)) 3		
			fi
			if [[ $((labyrinthe[$pos - LAB_LARG])) -eq 1 ]]; 
			then
				cherche_S $(($pos - $LAB_LARG)) 1
			fi ;;
	
		3) 	if [[ $((labyrinthe[$pos + 1])) -eq 1 ]]; 
			then
				cherche_S $(($pos + 1)) 2			
			fi
			if [[ $((labyrinthe[$pos - 1])) -eq 1 ]]; 
			then
				cherche_S $(($pos - 1)) 4	
			fi
			if [[ $((labyrinthe[$pos + LAB_LARG])) -eq 1 ]]; 
			then
				cherche_S $(($pos + $LAB_LARG)) 3		
			fi ;;
		
		4) 	if [[ $((labyrinthe[$pos - 1])) -eq 1 ]]; 
			then
				cherche_S $(($pos - 1)) 4	
			fi
			if [[ $((labyrinthe[$pos + LAB_LARG])) -eq 1 ]]; 
			then
				cherche_S $(($pos + $LAB_LARG)) 3		
			fi
			if [[ $((labyrinthe[$pos - LAB_LARG])) -eq 1 ]]; 
			then
				cherche_S $(($pos - $LAB_LARG)) 1
			fi ;;
	esac 
	fi
}

#Initialiser Thésée et Minotaure aléatoirement sur des vides
function MT_labyrinthe
{
	read -p "Entrer le nombre de Minotaure = " nbr_m
	local i=0
	local j=0
	local x=0
	local y=0
	while [ $j != 1 ]
	do
		x=$[($RANDOM % ($[$LAB_LONG - 4] + 1)) + 2]	
		y=$[($RANDOM % ($[$LAB_LARG - 4] + 1)) + 2]
		if [[ labyrinthe[$((x * LAB_LARG + y))] -eq 1 ]]
		then
			labyrinthe[$((x * LAB_LARG + y))]=3
			j=$((j + 1))
		fi
	done
	while [ $i != $nbr_m ] 
	do
		x=$[($RANDOM % ($[$LAB_LONG - 4] + 1)) + 2]	
		y=$[($RANDOM % ($[$LAB_LARG - 4] + 1)) + 2]
		if [[ labyrinthe[$((x * LAB_LARG + y))] -eq 1 ]]
		then
			labyrinthe[$((x * LAB_LARG + y))]=2
			i=$((i + 1))
		fi
	done
}

#L'appel des fonction
a=0
while [ $a != 1 ]
do
	echo "*****************************************************************************************"
	echo "**                          Bonjour dans le jeu de labyrinthe                          **"
	echo "*****************************************************************************************"
	read -p "Entrer le longueur de labyrinthe (Entrer un nombre impaire) = " LAB_LONG
	read -p "Entrer la largeur de labyrinthe (Entrer un nombre impaire) = " LAB_LARG
	init_labyrinthe
	scul_labyrinthe $((2 * LAB_LARG + 2))
	MT_labyrinthe
	sortie_labyrinthe
	print_labyrinthes
	read -p "Ce labyrinthe vous plait? (oui=1/non=0)  = " a
	if [ $a == 0 ]
	then
		clear
	fi
done
#Enregistrer les valeurs de labyrinthe choiser dans un fichier appeler labyrinthe 
print_labyrinthe_val > labyrinthe
cherche_T


