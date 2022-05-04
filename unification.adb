-- $Log: unify_b.a,v $
-- Revision 1.2  1992/01/16  07:16:46  alliot
-- mineur
--
-- Revision 1.1  1991/12/18  15:03:21  alliot
-- Initial revision
--
--Revision 4.1  91/07/27  14:37:16  alliot
--Premiere version parallele fonctionnant
--Le paquetage genhash a ete degrade pour etre plus simple
--L'envoi des piles est fait de facon systematique et totale (peu efficace)
--L'envoi des donnees n'est pas en boucle mais du haut vers le bas
--
--Revision 3.3  91/07/22  20:07:14  alliot
--Modification de l'ordre des regles pour ameliorer la vitesse
--Gain de l'ordre d'un facteur 10
--
--Revision 3.2  91/07/22  14:53:16  alliot
--Rajout du type allfree qui correspond a une variable toujours libre
--Un objet allfree se represente par un _ 
--Le KUT fonctionne (ainsi que l'exemple des sages et des chapeaux ) Rajout des
--+ commandes: stack,explain,trace,allsol,firstsol
--
--Revision 3.1  91/07/20  21:31:39  alliot
--Implementation de S4
--Modification de l'unificateur avec suppression de quelques bugs
--Le KUT n'est pas implemente
--
--Revision 2.6  91/07/19  19:01:42  alliot
--modifications dans la selection des clauses et l'execution des 
--regles pour ameliorer la vitesse d'execution
--
--Revision 2.5  91/07/17  19:14:10  alliot
--Un top-level a ete rajoute. On peut a partir du top-level:
--  Ajouter des clauses
--  Poser des questions
--  Executer des commandes (ligne debutant par
--Les seules commandes definies sont load (chargement fichier)
--et restart (restart complet du systeme).
--
--Revision 2.4  91/07/17  11:26:32  alliot
--Le moteur d'inference n'execute plus de code pour la
--selection et l'execution de clause. Tout se trouve desormais dans les
--fonctions du paquetage selclause. On respecte ainsi exactement le
--modele formel.
--
--Revision 2.3  91/07/16  17:27:56  alliot
--Modification du parser:
--  On peut entrer une liste sous la forme \[a,b,c,d\]
--  On peut mettre des commentaires avec \@ en debut de ligne
--  Les lignes blanches et les espaces sont ignores.
--
--Revision 2.2  91/07/16  12:39:18  alliot
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
WITH text_io;
USE text_io;

PACKAGE BODY unification IS

   PROCEDURE deref (num_obj1 : IN num_objet;
                    num_env1 : IN num_env;
                    num_obj2 : OUT num_objet;
                    num_env2 : OUT num_env) IS
      obj1       : elt_objet;
      env        : elt_env;
      access_env : num_env;
   BEGIN
      obj1 := recuperer (num_obj1);
      CASE obj1.genre IS
         WHEN variable =>
            access_env := num_env1 + obj1.dep;
            env        := recuperer (access_env);
            IF env.num_struct = null_objet THEN --Variable UNBOUND
               num_obj2 := num_obj1;
               num_env2 := num_env1;
            ELSE
               deref (env.num_struct, env.num_envi, num_obj2, num_env2);
            END IF;
         WHEN OTHERS =>
            num_obj2 := num_obj1;
            num_env2 := num_env1;
      END CASE;

   END deref;



   FUNCTION unify (num_objet1, num_objet2 : IN num_objet;
                   num_envi1, num_envi2   : IN num_env) RETURN boolean IS
      obj1, obj2              : elt_objet;
      num_oper1, num_oper2    : num_objet;
      env                     : elt_env;
      access_env, access_env2 : num_env;
      trail                   : elt_trail;
      access_trail            : num_trail;
      num_obj1                : num_objet := num_objet1;
      num_obj2                : num_objet := num_objet2;
      num_env1                : num_env   := num_envi1;
      num_env2                : num_env   := num_envi2;
      i : integer := 0;
   BEGIN

      LOOP
         obj1 := recuperer (num_obj1);
         EXIT WHEN obj1.genre /= variable;
         access_env := num_env1 + obj1.dep;
         env        := recuperer (access_env);
         EXIT WHEN env.num_struct = null_objet;
         num_obj1 := env.num_struct;
         num_env1 := env.num_envi;
--         i        := i + 1;
--         IF i = 100 THEN
--            dump_all;
--            RAISE program_error;
--         END IF;
      END LOOP;

      LOOP
         obj2 := recuperer (num_obj2);
         EXIT WHEN obj2.genre /= variable;
         access_env := num_env2 + obj2.dep;
         env        := recuperer (access_env);
         EXIT WHEN env.num_struct = null_objet;
         num_obj2 := env.num_struct;
         num_env2 := env.num_envi;
      END LOOP;



      CASE obj1.genre IS
         WHEN operateur =>
            CASE obj2.genre IS
               WHEN operateur =>
                  IF obj1.nom_op /= obj2.nom_op THEN
                     RETURN false;
                  END IF;
                  IF obj1.nb_arg_op /= obj2.nb_arg_op THEN
                     RETURN false;
                  END IF;
                  FOR i IN 0 .. obj1.nb_arg_op - 1 LOOP
                     num_oper1 := recuperer (obj1.arg_op + i);
                     num_oper2 := recuperer (obj2.arg_op + i);
                     IF NOT unify (num_oper1, num_oper2, num_env1, num_env2)
                         THEN
                        RETURN false;
                     END IF;
                  END LOOP;
                  RETURN true;
               WHEN variable =>
                  access_env := num_env2 + obj2.dep;
                  --On sait que la variable est UNBOUND car
                  --on a dereference les variables.
                  env.num_struct := num_obj1;
                  env.num_envi   := num_env1;
                  modifier (env, access_env);
                  -- Il faut TOUJOURS trailer les variables car sinon on peut
                  --lors d'une resolution modale effectuer une unification
                  --entre une variable de la question et une variable du fait
                  --et devoir la supprimer immediatement alors que les
                  --environnements seront toujours les memes puisqu'on
                  --n'aura pas selectionne une autre clause!!!
                  trail        := access_env;
                  access_trail := empiler (trail);
                  RETURN true;
               WHEN allfree =>
                  RETURN true;
               WHEN OTHERS =>
                  RETURN false;
            END CASE;
         WHEN predicat =>
            CASE obj2.genre IS
               WHEN predicat =>
                  IF obj1.nom_pred /= obj2.nom_pred THEN
                     RETURN false;
                  END IF;
                  IF obj1.nb_arg_pred /= obj2.nb_arg_pred THEN
                     RETURN false;
                  END IF;
                  FOR i IN 0 .. obj1.nb_arg_pred - 1 LOOP
                     num_oper1 := recuperer (obj1.arg_pred + i);
                     num_oper2 := recuperer (obj2.arg_pred + i);
                     IF NOT unify (num_oper1, num_oper2, num_env1, num_env2)
                         THEN
                        RETURN false;
                     END IF;
                  END LOOP;
                  RETURN true;
               WHEN variable =>
                  access_env     := num_env2 + obj2.dep;
                  env.num_struct := num_obj1;
                  env.num_envi   := num_env1;
                  modifier (env, access_env);
                  trail        := access_env;
                  access_trail := empiler (trail);
                  RETURN true;
               WHEN allfree =>
                  RETURN true;
               WHEN OTHERS =>
                  RETURN false;
            END CASE;
         WHEN entier =>
            CASE obj2.genre IS
               WHEN entier =>
                  IF obj1.val_ent /= obj2.val_ent THEN
                     RETURN false;
                  END IF;
                  RETURN true;
               WHEN flottant =>
                  IF obj1.val_ent /= valeur_entier (obj2.val_flot) THEN
                     RETURN false;
                  END IF;
                  RETURN true;
               WHEN variable =>
                  access_env     := num_env2 + obj2.dep;
                  env.num_struct := num_obj1;
                  env.num_envi   := num_env1;
                  modifier (env, access_env);
                  trail        := access_env;
                  access_trail := empiler (trail);
                  RETURN true;
               WHEN allfree =>
                  RETURN true;
               WHEN OTHERS =>
                  RETURN false;
            END CASE;
         WHEN flottant =>
            CASE obj2.genre IS
               WHEN entier =>
                  IF obj1.val_flot /= valeur_flottant (obj2.val_ent) THEN
                     RETURN false;
                  END IF;
                  RETURN true;
               WHEN flottant =>
                  IF obj1.val_flot /= obj2.val_flot THEN
                     RETURN false;
                  END IF;
                  RETURN true;
               WHEN variable =>
                  access_env     := num_env2 + obj2.dep;
                  env.num_struct := num_obj1;
                  env.num_envi   := num_env1;
                  modifier (env, access_env);
                  trail        := access_env;
                  access_trail := empiler (trail);
                  RETURN true;
               WHEN allfree =>
                  RETURN true;
               WHEN OTHERS =>
                  RETURN false;
            END CASE;
         WHEN variable =>
            access_env := num_env1 + obj1.dep;
            IF obj2.genre = allfree THEN
               RETURN true;
            END IF;
            IF obj2.genre /= variable THEN
               env.num_struct := num_obj2;
               env.num_envi   := num_env2;
               modifier (env, access_env);
               trail        := access_env;
               access_trail := empiler (trail);
               RETURN true;
            END IF;
  -- Ce sont deux variables UNBOUND. On unifie la plus jeune a la plus ancienne
            -- Le predicat is_younger est stupide
            access_env2 := num_env2 + obj2.dep;
            IF access_env = access_env2 THEN
               RETURN true;
            END IF;
            IF is_younger (access_env2, access_env) THEN
               env.num_struct := num_obj1;
               env.num_envi   := num_env1;
               modifier (env, access_env2);
               trail        := access_env2;
               access_trail := empiler (trail);
               RETURN true;
            ELSE
               env.num_struct := num_obj2;
               env.num_envi   := num_env2;
               modifier (env, access_env);
               trail        := access_env;
               access_trail := empiler (trail);
               RETURN true;
            END IF;
         WHEN cons =>
            CASE obj2.genre IS
               WHEN cons =>
                  IF unify (obj1.car, obj2.car, num_env1, num_env2) AND THEN
                     unify (obj1.cdr, obj2.cdr, num_env1, num_env2) THEN
                     RETURN true;
                  ELSE
                     RETURN false;
                  END IF;
               WHEN variable =>
                  access_env     := num_env2 + obj2.dep;
                  env.num_struct := num_obj1;
                  env.num_envi   := num_env1;
                  modifier (env, access_env);
                  trail        := access_env;
                  access_trail := empiler (trail);
                  RETURN true;
               WHEN allfree =>
                  RETURN true;
               WHEN OTHERS =>
                  RETURN false;
            END CASE;
         WHEN allfree =>
            RETURN true;
         WHEN OTHERS =>
            NULL;
      END CASE;
      RETURN true;
   END unify;



END unification;
