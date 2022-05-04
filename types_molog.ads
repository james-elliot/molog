-- $Log: type_s.a,v $
-- Revision 1.2  1992/01/16  07:16:46  alliot
-- mineur
--
-- Revision 1.1  1991/12/18  15:03:21  alliot
-- Initial revision
--
--Revision 4.1  91/07/27  14:37:13  alliot
--Premiere version parallele fonctionnant
--Le paquetage genhash a ete degrade pour etre plus simple
--L'envoi des piles est fait de facon systematique et totale (peu efficace)
--L'envoi des donnees n'est pas en boucle mais du haut vers le bas
--
--Revision 3.3  91/07/22  20:07:12  alliot
--Modification de l'ordre des regles pour ameliorer la vitesse
--Gain de l'ordre d'un facteur 10
--
--Revision 3.2  91/07/22  14:53:13  alliot
--Rajout du type allfree qui correspond a une variable toujours libre
--Un objet allfree se represente par un _ 
--Le KUT fonctionne (ainsi que l'exemple des sages et des chapeaux ) Rajout des
--+ commandes: stack,explain,trace,allsol,firstsol
--
--Revision 3.1  91/07/20  21:31:37  alliot
--Implementation de S4
--Modification de l'unificateur avec suppression de quelques bugs
--Le KUT n'est pas implemente
--
--Revision 2.6  91/07/19  19:01:39  alliot
--modifications dans la selection des clauses et l'execution des 
--regles pour ameliorer la vitesse d'execution
--
--Revision 2.5  91/07/17  19:14:08  alliot
--Un top-level a ete rajoute. On peut a partir du top-level:
--  Ajouter des clauses
--  Poser des questions
--  Executer des commandes (ligne debutant par
--Les seules commandes definies sont load (chargement fichier)
--et restart (restart complet du systeme).
--
--Revision 2.4  91/07/17  11:26:28  alliot
--Le moteur d'inference n'execute plus de code pour la
--selection et l'execution de clause. Tout se trouve desormais dans les
--fonctions du paquetage selclause. On respecte ainsi exactement le
--modele formel.
--
--Revision 2.3  91/07/16  17:27:54  alliot
--Modification du parser:
--  On peut entrer une liste sous la forme \[a,b,c,d\]
--  On peut mettre des commentaires avec \@ en debut de ligne
--  Les lignes blanches et les espaces sont ignores.
--
--Revision 2.2  91/07/16  12:39:15  alliot
--Code nettoye grace a DECADA qui a trouve des bugs implementation dependant
--Terminaison maintenant correcte grace a l'exportation de PILE_VIDE.
--SUppression de la fonction reserver dans les paquetages generiques.
--
--Revision 2.1  91/07/15  19:22:31  alliot
--Bug concernant l'initialisation des environnements supprime 
--Le moteur d'inference n'est plus recursif mais sous la 
--forme d'une machine de Turing
--Seule la logique classique est implementee.
--
--Revision 1.1  91/07/08  00:00:00  alliot
--Premiere version operationnelle.
--Il reste des bugs.
--Le cut fonctionne.
--Les listes sont implementees
--

WITH genpile;
WITH genhash;
WITH c_types;
USE c_types;
PACKAGE types_molog IS

   TYPE acces_string IS ACCESS string; -- Bien utile.

   -- Discriminant pour le type elt_objet.
   -- Il decrit l'ensemble des types de donnees connues de MOLOG
   TYPE genre_objet IS
      (operateur,
       predicat,
       variable,
       allfree,
       entier,
       flottant,
       cons);

   -- Discriminant du type elt_backtrack.
   -- Les points de choix peuvent etre de deux types:
   -- Point de choix pour une clause, ou point de choix pour
   -- une regle.
   TYPE genre_backtrack IS (regle, clause, invalide);

   -- Un predicat peut etre un predicat normal,
   -- ou un predicat pre-defini pris dans cette liste.
   TYPE genre_predicat IS (normal, special);

   -- Le nombre d'arguments pour un objet
   -- (operateur, predicat,variable)
   TYPE nombre_arguments IS NEW natural;

   -- Deplacement lie a la variable pour trouver dans l'environnement
   -- la valeur associee a cette variable.
   TYPE deplacement IS NEW natural;

   -- Nombre de variables d'une clause
   TYPE nombre_variables IS NEW natural;

   -- Valeur d'un objet entier
   TYPE valeur_entier IS  RANGE - 2 ** 31 .. 2 ** 31 - 1;
   FOR valeur_entier'SIZE USE 32;
   -- Valeur d'un flottant
   TYPE valeur_flottant IS NEW float;
   procedure afficher(val : in valeur_flottant);

   -- On construit ici les "types pointeurs" maison
   -- Comme on fait du parallelisme, on ne peut
   -- utiliser de veritables pointeurs. On construit
   -- donc un type prive, qui est un fait un indice
   -- dans un tableau.

   -- Pointeur dans la pile des objets
   TYPE num_objet IS PRIVATE;
   PROCEDURE afficher (num : IN num_objet);
   -- Pointeur dans la pile des clauses
   TYPE num_clause IS PRIVATE;
   PROCEDURE afficher (num : IN num_clause);
   -- Pointeur dans la pile des environnements
   TYPE num_env IS PRIVATE;
   PROCEDURE afficher (num : IN num_env);
   --Retourne vrai si num1 < num2. Permet de savoir lequel
   --des environnements est le plus recent.
   FUNCTION is_younger (num1, num2 : IN num_env) RETURN boolean;
   -- Pointeur dans la pile de la question et de la
   -- resolvante
   FUNCTION special RETURN num_env;
   --fonction qui retourne l'element qui suit le top courant
   -- Indispensdable pour des pbs de trailing. En effet, les
   -- clauses qui n'ont pas d'environnement doivent avoir un 
   -- numero d'environnement qui permette de faire courectement 
   -- le trailing
   TYPE num_quest IS PRIVATE;
   PROCEDURE afficher (num : IN num_quest);
   TYPE num_res IS PRIVATE;
   PROCEDURE afficher (num : IN num_res);
   -- Pointeur dans la pile de trail
   TYPE num_trail IS PRIVATE;
   PROCEDURE afficher (num : IN num_trail);
   -- Pointeur dans la pile de backtrack
   TYPE num_backtrack IS PRIVATE;
   PROCEDURE afficher (num : IN num_backtrack);
   -- Pointeur dans la pile des operandes
   TYPE num_operande IS PRIVATE;
   PROCEDURE afficher (num : IN num_operande);
   --Pointeur dans la pile des predicats
   TYPE num_predicat IS PRIVATE;
   PROCEDURE afficher (num : IN num_predicat);

   --Les operateurs predefinis ont un numero de code
   TYPE numero_code IS NEW natural;


   -- Les operateurs modaux sont decrits dans le
   -- paquetage operateur_s.ada
   TYPE numero_operateur IS NEW natural;
   PROCEDURE afficher (num : IN numero_operateur);
   -- Les regles sont decrites dans le paquetage
   -- regle_s.ada
   TYPE numero_regle IS NEW natural;
   PROCEDURE afficher (num : IN numero_regle);

   -- Un predicat est defini par son nom. On limite le nom 
   -- a 20 caracteres.
   -- Le champ clause est utile pour accelerer la recherche.
   TYPE elt_predicat IS
      RECORD
         nom    : string (1 .. 20);
         clause : num_clause;
      END RECORD;
   -- Premiere clause ayant ce predicat comme predicat de tete
   -- Affichage d'un element
   PROCEDURE afficher (x : IN elt_predicat);

   -- Fonctions du paquetage generique de gestion: genhash_s.ada
   -- Voir la description de ces fonctions dans le dit paquetage.
   FUNCTION ajouter (x : IN elt_predicat) RETURN num_predicat;
   FUNCTION recuperer (i : IN num_predicat) RETURN elt_predicat;
   PROCEDURE revenir (i : IN num_predicat);
   FUNCTION position RETURN num_predicat;
   PROCEDURE dump_predicat;
   PROCEDURE prepare_predicat (adresse : OUT c_pointer;
                               size    : OUT c_int);
   null_pred : CONSTANT num_predicat;
   -- On utilise une fonction permettant d'ajouter un entier a
   -- un pointeur, action qui permet de se deplacer facilement
   -- d'objet en objet dans une "pile".
   FUNCTION "+" (adr : IN num_predicat;
                 dep : IN integer) RETURN num_predicat;

   -- Un element de la pile de trail est un pointeur sur
   -- un environnement (celui de la variable a "trailer")
   SUBTYPE elt_trail IS num_env;
   -- Affichage
   --   procedure afficher(x:elt_trail);
   -- Voir au dessus.
   FUNCTION empiler (x : IN elt_trail) RETURN num_trail;
   FUNCTION reserver (n : IN positive) RETURN num_trail;
   FUNCTION recuperer (i : IN num_trail) RETURN elt_trail;
   PROCEDURE modifier (x : IN elt_trail;
                       i : IN num_trail);
   PROCEDURE revenir (i : IN num_trail);
   FUNCTION position RETURN num_trail;
   PROCEDURE dump_trail;
   PROCEDURE prepare_trail (adresse : OUT c_pointer;
                            size    : OUT c_int);
   null_trail : CONSTANT num_trail;
   FUNCTION "+" (adr : IN num_trail;
                 dep : IN integer) RETURN num_trail;

   -- Un element de la pile des operandes est un
   -- pointeur sur un objet. 
   SUBTYPE elt_operande IS num_objet;
   -- Affichage
   --   procedure afficher(x:elt_operande);
   -- Voir plus haut.
   FUNCTION empiler (x : IN elt_operande) RETURN num_operande;
   FUNCTION reserver (n : IN positive) RETURN num_operande;
   FUNCTION recuperer (i : IN num_operande) RETURN elt_operande;
   PROCEDURE modifier (x : IN elt_operande;
                       i : IN num_operande);
   PROCEDURE revenir (i : IN num_operande);
   FUNCTION position RETURN num_operande;
   PROCEDURE dump_operande;
   PROCEDURE prepare_operande (adresse : OUT c_pointer;
                               size    : OUT c_int);
   null_operande : CONSTANT num_operande;
   FUNCTION "+" (adr : IN num_operande;
                 dep : IN integer) RETURN num_operande;
   FUNCTION "+" (adr : IN num_operande;
                 dep : IN nombre_arguments) RETURN num_operande;

   -- Un element de la pile de backtrack contient l'ensemble des
   -- informations necessaires pour revenir sur un point de choix.
   -- Dans GIM, il existe deux types de point de choix: les points 
   -- de choix pour les clauses et les points de choix pour les
   -- regles.
   TYPE elt_backtrack (genre : genre_backtrack := regle) IS
      RECORD
         rbottom   : num_res;
         qcurr     : num_quest;
         fcurr     : num_objet;
         fenv      : num_env;
         trail_top : num_trail;
         objet_top : num_objet;
         q_top     : num_quest;
         r_top     : num_res;
         env_top   : num_env;
         CASE genre IS
            WHEN regle =>
               cregle : numero_regle;
            WHEN clause =>
               cclause : num_clause;
            WHEN invalide =>
               NULL;
         END CASE;
      END RECORD;
   -- Affichage
   PROCEDURE afficher (x : IN elt_backtrack);
   -- Voir plus haut.
   FUNCTION empiler (x : IN elt_backtrack) RETURN num_backtrack;
   FUNCTION reserver (n : IN positive) RETURN num_backtrack;
   FUNCTION recuperer (i : IN num_backtrack) RETURN elt_backtrack;
   FUNCTION depiler RETURN elt_backtrack;
   PROCEDURE modifier (x : IN elt_backtrack;
                       i : IN num_backtrack);
   PROCEDURE revenir (i : IN num_backtrack);
   FUNCTION position RETURN num_backtrack;
   PROCEDURE dump_backtrack;
   PROCEDURE prepare_backtrack (adresse : OUT c_pointer;
                                size    : OUT c_int);
   null_backtrack : CONSTANT num_backtrack;
   pile_vide      : EXCEPTION;

   FUNCTION "+" (adr : IN num_backtrack;
                 dep : IN integer) RETURN num_backtrack;
   FUNCTION "-" (adr : IN num_backtrack;
                 dep : IN integer) RETURN num_backtrack;

   -- Un element de la pile de la question (ou de la resolvante)
   -- est un pointeur sur un objet (operateur ou predicat)
   -- et un pointeur sur l'environnement dans lequel il doit etre
   -- evalue.
   TYPE elt_quest IS
      RECORD
         num_struct : num_objet;
         num_envi   : num_env;
      END RECORD;
   -- Affichage
   PROCEDURE afficher (x : IN elt_quest);
   -- Voir plus haut
   FUNCTION empiler (x : IN elt_quest) RETURN num_quest;
   FUNCTION reserver (n : IN positive) RETURN num_quest;
   FUNCTION recuperer (i : IN num_quest) RETURN elt_quest;
   PROCEDURE modifier (x : IN elt_quest;
                       i : IN num_quest);
   PROCEDURE revenir (i : IN num_quest);
   FUNCTION position RETURN num_quest;
   PROCEDURE dump_quest;
   PROCEDURE prepare_quest (adresse : OUT c_pointer;
                            size    : OUT c_int);
   null_quest : CONSTANT num_quest;
   FUNCTION "+" (adr : IN num_quest;
                 dep : IN integer) RETURN num_quest;

   -- Un element de la pile de la question (ou de la resolvante)
   -- est un pointeur sur un objet (operateur ou predicat)
   -- et un pointeur sur l'environnement dans lequel il doit etre
   -- evalue.
   TYPE elt_res IS
      RECORD
         num_struct : num_objet;
         num_envi   : num_env;
      END RECORD;
   -- Affichage
   PROCEDURE afficher (x : IN elt_res);
   -- Voir plus haut
   FUNCTION empiler (x : IN elt_res) RETURN num_res;
   FUNCTION reserver (n : IN positive) RETURN num_res;
   FUNCTION recuperer (i : IN num_res) RETURN elt_res;
   PROCEDURE modifier (x : IN elt_res;
                       i : IN num_res);
   PROCEDURE revenir (i : IN num_res);
   FUNCTION position RETURN num_res;
   PROCEDURE dump_res;
   PROCEDURE prepare_res (adresse : OUT c_pointer;
                          size    : OUT c_int);
   null_res : CONSTANT num_res;
   FUNCTION "+" (adr : IN num_res;
                 dep : IN integer) RETURN num_res;
   FUNCTION "-" (adr : IN num_res;
                 dep : IN integer) RETURN num_res;

   --Un element d'environnement contient un pointeur sur un objet et
   --un pointeur sur l'environnement dans lequel cet objet doit etre evalue.
   TYPE elt_env IS
      RECORD
         num_struct : num_objet;
         num_envi   : num_env;
      END RECORD;
   -- Affichage
   PROCEDURE afficher (x : IN elt_env);
   --Voir plus haut.
   FUNCTION empiler (x : IN elt_env) RETURN num_env;
   FUNCTION reserver (n : IN positive) RETURN num_env;
   FUNCTION recuperer (i : IN num_env) RETURN elt_env;
   PROCEDURE modifier (x : IN elt_env;
                       i : IN num_env);
   PROCEDURE revenir (i : IN num_env);
   FUNCTION position RETURN num_env;
   PROCEDURE dump_env;
   PROCEDURE prepare_env (adresse : OUT c_pointer;
                          size    : OUT c_int);
   null_env : CONSTANT num_env;
   FUNCTION "+" (adr : IN num_env;
                 dep : IN integer) RETURN num_env;
   FUNCTION "+" (adr : IN num_env;
                 dep : IN deplacement) RETURN num_env;

   --Une clause est decrite par un pointeur sur le premier element
   -- de l'arbre de la clause et le nombre de variables de la clause.
   -- Le champ next accelere la recherche.
   TYPE elt_clause IS
      RECORD
         clause : num_objet;
         nb_var : nombre_variables;
         next   : num_clause; -- Clause suivante ayant le meme predicat de tete
         pred   : num_objet;
      END RECORD;
   -- Predicat de tete	                                        
   -- Affichage
   PROCEDURE afficher (x : IN elt_clause);
   --Voir plus haut.
   FUNCTION empiler (x : IN elt_clause) RETURN num_clause;
   FUNCTION reserver (n : IN positive) RETURN num_clause;
   FUNCTION recuperer (i : IN num_clause) RETURN elt_clause;
   PROCEDURE modifier (x : IN elt_clause;
                       i : IN num_clause);
   PROCEDURE revenir (i : IN num_clause);
   FUNCTION position RETURN num_clause;
   PROCEDURE dump_clause;
   PROCEDURE prepare_clause (adresse : OUT c_pointer;
                             size    : OUT c_int);
   null_clause : CONSTANT num_clause;
   pred_clause : CONSTANT num_clause;
   FUNCTION "+" (adr : IN num_clause;
                 dep : IN integer) RETURN num_clause;

   --Un objet peut prendre plusieurs formes
   TYPE elt_objet (genre : genre_objet := operateur) IS
      RECORD
         clause : num_clause;
         CASE genre IS
            -- Un operateur est decrit par son numero
            -- le nombre de ses arguments, l'adresse du premier des arguments
            -- dans la pile des operandes ainsi que l'adresse de l'objet qu'il
            ---qualifie.
            WHEN operateur =>
               nom_op    : numero_operateur;
               nb_arg_op : nombre_arguments;
               arg_op    : num_operande;
               obj_qual  : num_objet;
           -- Un predicat est decrit par son numero, son type, le nombre de ses
               -- arguments et l'adresse du premier de ces arguments.
              -- Tous les predicats ayant le meme nom ont le meme numero, grace
               -- au paquetage generique genhash
            WHEN predicat =>
               nom_pred    : num_predicat;
               type_pred   : genre_predicat := normal;
               nb_arg_pred : nombre_arguments;
               arg_pred    : num_operande;
               code        : numero_code;
               -- On ne stocke pas le nom de la variable (inutile sauf au
               -- moment de la construction de l'arbre de la clause).
            WHEN variable =>
               dep : deplacement;
            WHEN allfree =>
               NULL;
            WHEN entier =>
               val_ent : valeur_entier;
            WHEN flottant =>
               val_flot : valeur_flottant;
            WHEN cons =>
               car : num_objet;
               cdr : num_objet;
         END CASE;
      END RECORD;
   -- Affichage
   PROCEDURE afficher (x : IN elt_objet);
   -- Voir plus haut.
   FUNCTION empiler (x : IN elt_objet) RETURN num_objet;
   FUNCTION reserver (n : IN positive) RETURN num_objet;
   FUNCTION recuperer (i : IN num_objet) RETURN elt_objet;
   PROCEDURE modifier (x : IN elt_objet;
                       i : IN num_objet);
   PROCEDURE revenir (i : IN num_objet);
   FUNCTION position RETURN num_objet;
   PROCEDURE dump_objet;
   PROCEDURE prepare_objet (adresse : OUT c_pointer;
                            size    : OUT c_int);
   null_objet : CONSTANT num_objet;
   FUNCTION "+" (adr : IN num_objet;
                 dep : IN integer) RETURN num_objet;


   PROCEDURE restart_all;
   PROCEDURE dump_all;


   trace    : boolean := false;
   explain  : boolean := false;
   stack    : boolean := false;
   all_sol  : boolean := false;
   parallel : boolean := false;
   daemon   : boolean := false;

PRIVATE
   -- Le type mon_pointeur est defini sur 31 bits par mesure
   -- de precaution (l'implementation de integer est 
   -- dependant-machine).
   TYPE mon_pointeur IS  RANGE 0 .. 2 ** 31 - 1;
   -- Chacun des types prives declares plus haut est un type derive
   -- du type mon_pointeur.
   TYPE num_objet IS NEW mon_pointeur;
   TYPE num_clause IS NEW mon_pointeur;
   TYPE num_env IS NEW mon_pointeur;
   TYPE num_quest IS NEW mon_pointeur;
   TYPE num_res IS NEW mon_pointeur;
   TYPE num_trail IS NEW mon_pointeur;
   TYPE num_backtrack IS NEW mon_pointeur;
   TYPE num_operande IS NEW mon_pointeur;
   TYPE num_predicat IS NEW mon_pointeur;

   -- On instancie le paquetage genhash pour le type predicat.
   -- La fonction hash_pred est la fonction de hachage qui permet
   -- d'accelerer la construction de la table des predicats.
   TYPE hash_pred_val IS  RANGE 0 .. 255;
   FUNCTION hash_pred (p : IN elt_predicat) RETURN hash_pred_val;
   -- La fonction keep_pred decide dans le cas ou les deux noms
   -- sont les memes quelles sont les operations a effectuees.
   -- En particulier, elle met a jour le champ clause de facon
   -- appropriee et modifie si necessaire le chainage des clauses
   -- entre elles.
   FUNCTION keep_pred (x, y : IN elt_predicat) RETURN elt_predicat;
   FUNCTION egal_pred (x, y : IN elt_predicat) RETURN boolean;
   PACKAGE pile_predicat IS NEW genhash (elt_predicat, num_predicat, 10000,
                                         hash_pred_val, hash_pred, keep_pred,
                                         egal_pred, afficher);
   null_pred : CONSTANT num_predicat := pile_predicat.element_null;

   --Instantiation des autres piles.
   PACKAGE pile_trail IS NEW genpile (elt_trail, num_trail, 10000, afficher);
   null_trail : CONSTANT num_trail := pile_trail.element_null;

   PACKAGE pile_operande IS NEW genpile (elt_operande, num_operande, 10000,
                                         afficher);
   null_operande : CONSTANT num_operande := pile_operande.element_null;

   PACKAGE pile_backtrack IS NEW genpile
       (elt_backtrack, num_backtrack, 10000, afficher);
   null_backtrack : CONSTANT num_backtrack := pile_backtrack.element_null;

   PACKAGE pile_res IS NEW genpile (elt_res, num_res, 10000, afficher);
   null_res : CONSTANT num_res := pile_res.element_null;

   PACKAGE pile_quest IS NEW genpile (elt_quest, num_quest, 10000, afficher);
   null_quest : CONSTANT num_quest := pile_quest.element_null;

   PACKAGE pile_env IS NEW genpile (elt_env, num_env, 10000, afficher);
   null_env : CONSTANT num_env := pile_env.element_null;

   PACKAGE pile_clause IS NEW genpile
       (elt_clause, num_clause, 10000, afficher);
   null_clause : CONSTANT num_clause := pile_clause.element_null;
   pred_clause : CONSTANT num_clause := num_clause'LAST;

   PACKAGE pile_objet IS NEW genpile (elt_objet, num_objet, 10000, afficher);
   null_objet : CONSTANT num_objet := pile_objet.element_null;


END types_molog;
