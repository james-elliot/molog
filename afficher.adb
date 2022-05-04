-- $Log: afficher.a,v $
-- Revision 1.2  1992/01/16  07:13:13  alliot
-- Changements mineur de Tarski
-- (Nom, petits details sur l'impression)
-- Cette version sera distribuee.
--
-- Revision 1.1  1991/12/18  15:03:21  alliot
-- Initial revision
--
--Revision 4.1  91/07/27  14:35:04  alliot
--Premiere version parallele fonctionnant
--Le paquetage genhash a ete degrade pour etre plus simple
--L'envoi des piles est fait de facon systematique et totale (peu efficace)
--L'envoi des donnees n'est pas en boucle mais du haut vers le bas
--
--Revision 3.3  91/07/22  20:06:41  alliot
--Modification de l'ordre des regles pour ameliorer la vitesse
--Gain de l'ordre d'un facteur 10
--
--Revision 3.2  91/07/22  14:51:39  alliot
--Rajout du type allfree qui correspond a une variable toujours libre
--Un objet allfree se represente par un _ 
--Le KUT fonctionne (ainsi que l'exemple des sages et des chapeaux ) Rajout des
--+ commandes: stack,explain,trace,allsol,firstsol
--
--Revision 3.1  91/07/20  21:31:09  alliot
--Implementation de S4
--Modification de l'unificateur avec suppression de quelques bugs
--Le KUT n'est pas implemente
--
--Revision 2.6  91/07/19  19:00:45  alliot
--modifications dans la selection des clauses et l'execution des 
--regles pour ameliorer la vitesse d'execution
--
--Revision 2.5  91/07/17  19:13:40  alliot
--Un top-level a ete rajoute. On peut a partir du top-level:
--  Ajouter des clauses
--  Poser des questions
--  Executer des commandes (ligne debutant par
--Les seules commandes definies sont load (chargement fichier)
--et restart (restart complet du systeme).
--
--Revision 2.4  91/07/17  11:25:32  alliot
--Le moteur d'inference n'execute plus de code pour la
--selection et l'execution de clause. Tout se trouve desormais dans les
--fonctions du paquetage selclause. On respecte ainsi exactement le
--modele formel.
--
--Revision 2.3  91/07/16  17:27:15  alliot
--Modification du parser:
--  On peut entrer une liste sous la forme \[a,b,c,d\]
--  On peut mettre des commentaires avec \@ en debut de ligne
--  Les lignes blanches et les espaces sont ignores.
--
--Revision 2.2  91/07/16  12:38:46  alliot
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

WITH types_molog;
USE types_molog;
WITH predef;
USE predef;
WITH operateurs;
USE operateurs;
WITH unification;
USE unification;
WITH text_io;
USE text_io;

PROCEDURE afficher (num_obj1  : IN num_objet;
                    num_env1  : IN num_env;
                    flag_cons : IN boolean := true;
                    flag_opm  : IN boolean := false) IS
   num_obj2, num_obj3 : num_objet;
   num_env2, num_env3 : num_env;
   nom                : string (1 .. 20);
   elt, elt3          : elt_objet;
BEGIN
   deref (num_obj1, num_env1, num_obj2, num_env2);
   IF num_obj2 = null_objet THEN
      put ("NULL");
      RETURN;
   END IF;
   elt := recuperer (num_obj2);
   CASE elt.genre IS
      WHEN operateur =>
         put ("#" & nom_operateur (elt.nom_op));
         IF elt.nb_arg_op /= 0 THEN
            put ("(");
            FOR i IN 0 .. elt.nb_arg_op - 1 LOOP
               num_obj2 := recuperer (elt.arg_op + i);
               afficher (num_obj2, num_env2, flag_cons, true);
               IF i /= elt.nb_arg_op - 1 THEN
                  put (",");
               END IF;
            END LOOP;
            put (")");
         END IF;
         put (":");
         IF flag_opm THEN
            afficher (elt.obj_qual, num_env2, flag_cons, true);
         END IF;
      WHEN predicat =>
         IF elt.type_pred = normal THEN
            nom := recuperer (elt.nom_pred).nom;
         ELSE
            nom := nom_predef (elt.code);
         END IF;
         FOR i IN 1 .. 20 LOOP
            EXIT WHEN nom (i) = ' ';
            put (nom (i));
         END LOOP;
         IF elt.nb_arg_pred /= 0 THEN
            put ("(");
            FOR i IN 0 .. elt.nb_arg_pred - 1 LOOP
               num_obj2 := recuperer (elt.arg_pred + i);
               afficher (num_obj2, num_env2, flag_cons, true);
               IF i /= elt.nb_arg_pred - 1 THEN
                  put (",");
               END IF;
            END LOOP;
            put (")");
         END IF;
      WHEN variable =>
         put ("UNBOUND");
      WHEN entier =>
         put (valeur_entier'IMAGE (elt.val_ent));
      WHEN flottant =>
         afficher (elt.val_flot);
      WHEN cons =>
         IF flag_cons THEN
            put ("[");
         END IF;
         afficher (elt.car, num_env2, true, true);
         put (",");
         deref (elt.cdr, num_env2, num_obj3, num_env3);
         elt3 := recuperer (num_obj3);
         IF elt3.genre = cons THEN
            afficher (elt.cdr, num_env2, false, true);
         ELSE
            afficher (elt.cdr, num_env2, true, true);
         END IF;
         IF flag_cons THEN
            put ("]");
         END IF;
      WHEN allfree =>
         put ("FREE");
   END CASE;
EXCEPTION
   WHEN OTHERS =>
      put ("EMPTY");
END afficher;

