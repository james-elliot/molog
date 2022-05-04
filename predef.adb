-- $Log: predef_b.a,v $
-- Revision 1.2  1992/01/16  07:16:46  alliot
-- mineur
--
-- Revision 1.1  1991/12/18  15:03:21  alliot
-- Initial revision
--
--Revision 4.1  91/07/27  14:36:38  alliot
--Premiere version parallele fonctionnant
--Le paquetage genhash a ete degrade pour etre plus simple
--L'envoi des piles est fait de facon systematique et totale (peu efficace)
--L'envoi des donnees n'est pas en boucle mais du haut vers le bas
--
--Revision 3.3  91/07/22  20:06:59  alliot
--Modification de l'ordre des regles pour ameliorer la vitesse
--Gain de l'ordre d'un facteur 10
--
--Revision 3.2  91/07/22  14:52:54  alliot
--Rajout du type allfree qui correspond a une variable toujours libre
--Un objet allfree se represente par un _ 
--Le KUT fonctionne (ainsi que l'exemple des sages et des chapeaux ) Rajout des
--+ commandes: stack,explain,trace,allsol,firstsol
--
--Revision 3.1  91/07/20  21:31:25  alliot
--Implementation de S4
--Modification de l'unificateur avec suppression de quelques bugs
--Le KUT n'est pas implemente
--
--Revision 2.6  91/07/19  19:01:16  alliot
--modifications dans la selection des clauses et l'execution des 
--regles pour ameliorer la vitesse d'execution
--
--Revision 2.5  91/07/17  19:13:56  alliot
--Un top-level a ete rajoute. On peut a partir du top-level:
--  Ajouter des clauses
--  Poser des questions
--  Executer des commandes (ligne debutant par
--Les seules commandes definies sont load (chargement fichier)
--et restart (restart complet du systeme).
--
--Revision 2.4  91/07/17  11:25:55  alliot
--Le moteur d'inference n'execute plus de code pour la
--selection et l'execution de clause. Tout se trouve desormais dans les
--fonctions du paquetage selclause. On respecte ainsi exactement le
--modele formel.
--
--Revision 2.3  91/07/16  17:27:38  alliot
--Modification du parser:
--  On peut entrer une liste sous la forme \[a,b,c,d\]
--  On peut mettre des commentaires avec \@ en debut de ligne
--  Les lignes blanches et les espaces sont ignores.
--
--Revision 2.2  91/07/16  12:39:03  alliot
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
WITH unification;
USE unification;
WITH afficher;
WITH text_io;
USE text_io;

PACKAGE BODY predef IS

   code_non_defini, not_numeric : EXCEPTION;

   fail   : CONSTANT numero_code := 1;
   succes : CONSTANT numero_code := 2;
   pred   : CONSTANT numero_code := 3;
   atomic : CONSTANT numero_code := 4;
   cut    : CONSTANT numero_code := 5;
   print  : CONSTANT numero_code := 6;
   sup    : CONSTANT numero_code := 7;
   inf    : CONSTANT numero_code := 8;
   sub    : CONSTANT numero_code := 9;
   add    : CONSTANT numero_code := 10;
   mul    : CONSTANT numero_code := 11;
   div    : CONSTANT numero_code := 12;

   nb_predef : CONSTANT numero_code := 12;

   noms_predef : ARRAY (1 .. nb_predef) OF string (1 .. 20) :=
      (OTHERS => (OTHERS => ascii.nul));

   FUNCTION is_predef (s : IN string) RETURN numero_code IS
   BEGIN
      FOR i IN noms_predef'RANGE LOOP
         IF s = noms_predef (i) THEN
            RETURN i;
         END IF;
      END LOOP;
      RETURN null_code;
   END is_predef;

   FUNCTION execute_predef (num_elt  : IN num_objet;
                            num_envi : IN num_env) RETURN boolean IS
      elt : elt_objet;
   BEGIN
      elt := recuperer (num_elt);
      CASE elt.code IS
         WHEN fail =>
            RETURN false;
         WHEN succes =>
            RETURN true;
         WHEN pred =>
            DECLARE
               num_obj2 : num_objet;
               num_env2 : num_env;
               num_oper : num_objet;
            BEGIN
               num_oper := recuperer (elt.arg_pred);
               deref (num_oper, num_envi, num_obj2, num_env2);
               elt := recuperer (num_obj2);
               IF elt.genre = predicat THEN
                  RETURN true;
               ELSE
                  RETURN false;
               END IF;
            END;
         WHEN atomic =>
            DECLARE
               num_obj2 : num_objet;
               num_env2 : num_env;
               num_oper : num_objet;
            BEGIN
               num_oper := recuperer (elt.arg_pred);
               deref (num_oper, num_envi, num_obj2, num_env2);
               elt := recuperer (num_obj2);
               IF elt.genre /= cons AND THEN elt.genre /= variable THEN
                  RETURN true;
               ELSE
                  RETURN false;
               END IF;
            END;
         WHEN cut =>
            DECLARE
               num_cl   : num_clause    := elt.clause;
               num_back : num_backtrack := position;
               elt_back : elt_backtrack;
--Vieux code
--            BEGIN
--               LOOP
--                  elt_back := recuperer (num_back);
--                  modifier ((genre     => invalide,
--                             rbottom   => elt_back.rbottom,
--                             qcurr     => elt_back.qcurr,
--                             fcurr     => elt_back.fcurr,
--                             fenv      => elt_back.fenv,
--                             trail_top => elt_back.trail_top,
--                             objet_top => elt_back.objet_top,
--                             q_top     => elt_back.q_top,
--                             r_top     => elt_back.r_top,
--                             env_top   => elt_back.env_top), num_back);
--                  EXIT WHEN elt_back.genre = clause AND THEN
--                            elt_back.cclause = num_cl;
--                  num_back := num_back - 1;
--               END LOOP;
--Nouveau code
            BEGIN
               LOOP
                  elt_back := recuperer (num_back);
                  num_back := num_back - 1;
                  EXIT WHEN elt_back.genre = clause AND THEN
                            elt_back.cclause = num_cl;
               END LOOP;
	    revenir(num_back);
            END;
--code commun
            RETURN true;
         WHEN print =>
            DECLARE
               num_obj2 : num_objet;
               num_env2 : num_env;
               num_oper : num_objet;
            BEGIN
               num_oper := recuperer (elt.arg_pred);
               deref (num_oper, num_envi, num_obj2, num_env2);
               afficher (num_obj2, num_env2);
               put (" ");
               RETURN true;
            END;
         WHEN sup =>
            DECLARE
               num_oper1, num_oper2 : num_objet;
               num_obj1, num_obj2   : num_objet;
               num_env1, num_env2   : num_env;
               elt1, elt2           : elt_objet;
               val1, val2           : valeur_flottant;
            BEGIN
               num_oper1 := recuperer (elt.arg_pred);
               deref (num_oper1, num_envi, num_obj1, num_env1);
               num_oper2 := recuperer (elt.arg_pred + integer (1));
               deref (num_oper2, num_envi, num_obj2, num_env2);
               elt1 := recuperer (num_obj1);
               elt2 := recuperer (num_obj2);

               CASE elt2.genre IS
                  WHEN entier =>
                     val2 := valeur_flottant (elt2.val_ent);
                  WHEN flottant =>
                     val2 := elt2.val_flot;
                  WHEN OTHERS =>
                     RAISE not_numeric;
               END CASE;
               CASE elt1.genre IS
                  WHEN entier =>
                     val1 := valeur_flottant (elt1.val_ent);
                  WHEN flottant =>
                     val1 := elt1.val_flot;
                  WHEN OTHERS =>
                     RAISE not_numeric;
               END CASE;
               RETURN val1 > val2;
            END;
         WHEN inf =>
            DECLARE
               num_oper1, num_oper2 : num_objet;
               num_obj1, num_obj2   : num_objet;
               num_env1, num_env2   : num_env;
               elt1, elt2           : elt_objet;
               val1, val2           : valeur_flottant;
            BEGIN
               num_oper1 := recuperer (elt.arg_pred);
               deref (num_oper1, num_envi, num_obj1, num_env1);
               num_oper2 := recuperer (elt.arg_pred + integer (1));
               deref (num_oper2, num_envi, num_obj2, num_env2);
               elt1 := recuperer (num_obj1);
               elt2 := recuperer (num_obj2);

               CASE elt2.genre IS
                  WHEN entier =>
                     val2 := valeur_flottant (elt2.val_ent);
                  WHEN flottant =>
                     val2 := elt2.val_flot;
                  WHEN OTHERS =>
                     RAISE not_numeric;
               END CASE;
               CASE elt1.genre IS
                  WHEN entier =>
                     val1 := valeur_flottant (elt1.val_ent);
                  WHEN flottant =>
                     val1 := elt1.val_flot;
                  WHEN OTHERS =>
                     RAISE not_numeric;
               END CASE;
               RETURN val1 < val2;
            END;
         WHEN add =>
            DECLARE
               num_oper1, num_oper2, num_oper3 : num_objet;
               num_obj1, num_obj2, num_eltr    : num_objet;
               num_env1, num_env2              : num_env;
               elt1, elt2, eltr                : elt_objet;
               val1, val2 : valeur_flottant;
            BEGIN
               num_oper1 := recuperer (elt.arg_pred);
               deref (num_oper1, num_envi, num_obj1, num_env1);
               num_oper2 := recuperer (elt.arg_pred + integer (1));
               deref (num_oper2, num_envi, num_obj2, num_env2);
               num_oper3 := recuperer (elt.arg_pred + integer (2));
               elt1      := recuperer (num_obj1);
               elt2      := recuperer (num_obj2);

               CASE elt2.genre IS
                  WHEN entier =>
                     val2 := valeur_flottant (elt2.val_ent);
                  WHEN flottant =>
                     val2 := elt2.val_flot;
                  WHEN OTHERS =>
                     RAISE not_numeric;
               END CASE;
               CASE elt1.genre IS
                  WHEN entier =>
                     val1 := valeur_flottant (elt1.val_ent);
                  WHEN flottant =>
                     val1 := elt1.val_flot;
                  WHEN OTHERS =>
                     RAISE not_numeric;
               END CASE;
               IF elt1.genre = entier AND elt2.genre = entier THEN
                  eltr := (genre   => entier,
                           val_ent => elt1.val_ent + elt2.val_ent,
                           clause  => null_clause);
               ELSE
                  eltr := (genre    => flottant,
                           val_flot => val1 + val2,
                           clause   => null_clause);
               END IF;
               num_eltr := empiler (eltr);
               RETURN unify (num_oper3, num_eltr, num_envi, special);
            END;
         WHEN sub =>
            DECLARE
               num_oper1, num_oper2, num_oper3 : num_objet;
               num_obj1, num_obj2, num_eltr    : num_objet;
               num_env1, num_env2              : num_env;
               elt1, elt2, eltr                : elt_objet;
               val1, val2 : valeur_flottant;
            BEGIN
               num_oper1 := recuperer (elt.arg_pred);
               deref (num_oper1, num_envi, num_obj1, num_env1);
               num_oper2 := recuperer (elt.arg_pred + integer (1));
               deref (num_oper2, num_envi, num_obj2, num_env2);
               num_oper3 := recuperer (elt.arg_pred + integer (2));
               elt1      := recuperer (num_obj1);
               elt2      := recuperer (num_obj2);

               CASE elt2.genre IS
                  WHEN entier =>
                     val2 := valeur_flottant (elt2.val_ent);
                  WHEN flottant =>
                     val2 := elt2.val_flot;
                  WHEN OTHERS =>
                     RAISE not_numeric;
               END CASE;
               CASE elt1.genre IS
                  WHEN entier =>
                     val1 := valeur_flottant (elt1.val_ent);
                  WHEN flottant =>
                     val1 := elt1.val_flot;
                  WHEN OTHERS =>
                     RAISE not_numeric;
               END CASE;
               IF elt1.genre = entier AND elt2.genre = entier THEN
                  eltr := (genre   => entier,
                           val_ent => elt1.val_ent - elt2.val_ent,
                           clause  => null_clause);
               ELSE
                  eltr := (genre    => flottant,
                           val_flot => val1 - val2,
                           clause   => null_clause);
               END IF;
               num_eltr := empiler (eltr);
               RETURN unify (num_oper3, num_eltr, num_envi, special);
            END;
         WHEN mul =>
            DECLARE
               num_oper1, num_oper2, num_oper3 : num_objet;
               num_obj1, num_obj2, num_eltr    : num_objet;
               num_env1, num_env2              : num_env;
               elt1, elt2, eltr                : elt_objet;
               val1, val2 : valeur_flottant;
            BEGIN
               num_oper1 := recuperer (elt.arg_pred);
               deref (num_oper1, num_envi, num_obj1, num_env1);
               num_oper2 := recuperer (elt.arg_pred + integer (1));
               deref (num_oper2, num_envi, num_obj2, num_env2);
               num_oper3 := recuperer (elt.arg_pred + integer (2));
               elt1      := recuperer (num_obj1);
               elt2      := recuperer (num_obj2);

               CASE elt2.genre IS
                  WHEN entier =>
                     val2 := valeur_flottant (elt2.val_ent);
                  WHEN flottant =>
                     val2 := elt2.val_flot;
                  WHEN OTHERS =>
                     RAISE not_numeric;
               END CASE;
               CASE elt1.genre IS
                  WHEN entier =>
                     val1 := valeur_flottant (elt1.val_ent);
                  WHEN flottant =>
                     val1 := elt1.val_flot;
                  WHEN OTHERS =>
                     RAISE not_numeric;
               END CASE;
               IF elt1.genre = entier AND elt2.genre = entier THEN
                  eltr := (genre   => entier,
                           val_ent => elt1.val_ent * elt2.val_ent,
                           clause  => null_clause);
               ELSE
                  eltr := (genre    => flottant,
                           val_flot => val1 * val2,
                           clause   => null_clause);
               END IF;
               num_eltr := empiler (eltr);
               RETURN unify (num_oper3, num_eltr, num_envi, special);
            END;
         WHEN div =>
            DECLARE
               num_oper1, num_oper2, num_oper3 : num_objet;
               num_obj1, num_obj2, num_eltr    : num_objet;
               num_env1, num_env2              : num_env;
               elt1, elt2, eltr                : elt_objet;
               val1, val2 : valeur_flottant;
            BEGIN
               num_oper1 := recuperer (elt.arg_pred);
               deref (num_oper1, num_envi, num_obj1, num_env1);
               num_oper2 := recuperer (elt.arg_pred + integer (1));
               deref (num_oper2, num_envi, num_obj2, num_env2);
               num_oper3 := recuperer (elt.arg_pred + integer (2));
               elt1      := recuperer (num_obj1);
               elt2      := recuperer (num_obj2);

               CASE elt2.genre IS
                  WHEN entier =>
                     val2 := valeur_flottant (elt2.val_ent);
                  WHEN flottant =>
                     val2 := elt2.val_flot;
                  WHEN OTHERS =>
                     RAISE not_numeric;
               END CASE;
               CASE elt1.genre IS
                  WHEN entier =>
                     val1 := valeur_flottant (elt1.val_ent);
                  WHEN flottant =>
                     val1 := elt1.val_flot;
                  WHEN OTHERS =>
                     RAISE not_numeric;
               END CASE;
               IF elt1.genre = entier AND elt2.genre = entier THEN
                  eltr := (genre   => entier,
                           val_ent => elt1.val_ent / elt2.val_ent,
                           clause  => null_clause);
               ELSE
                  eltr := (genre    => flottant,
                           val_flot => val1 / val2,
                           clause   => null_clause);
               END IF;
               num_eltr := empiler (eltr);
               RETURN unify (num_oper3, num_eltr, num_envi, special);
            END;
         WHEN OTHERS =>
            RAISE code_non_defini;
      END CASE;
   END execute_predef;

   FUNCTION nom_predef (num : IN numero_code) RETURN string IS
   BEGIN
      RETURN noms_predef (num);
   END nom_predef;

BEGIN
   noms_predef (fail) (1 .. 6)   := "fail 0";
   noms_predef (succes) (1 .. 8) := "succes 0";
   noms_predef (pred) (1 .. 6)   := "pred 1";
   noms_predef (atomic) (1 .. 8) := "atomic 1";
   noms_predef (cut) (1 .. 5)    := "cut 0";
   noms_predef (print) (1 .. 7)  := "print 1";
   noms_predef (sup) (1 .. 5)    := "sup 2";
   noms_predef (inf) (1 .. 5)    := "inf 2";
   noms_predef (sub) (1 .. 5)    := "sub 3";
   noms_predef (add) (1 .. 5)    := "add 3";
   noms_predef (mul) (1 .. 5)    := "mul 3";
   noms_predef (div) (1 .. 5)    := "div 3";
END predef;
