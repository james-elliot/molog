-- $Log: selclause_b.a,v $
-- Revision 1.2  1992/01/16  07:16:46  alliot
-- mineur
--
-- Revision 1.1  1991/12/18  15:03:21  alliot
-- Initial revision
--
--Revision 4.1  91/07/27  14:36:44  alliot
--Premiere version parallele fonctionnant
--Le paquetage genhash a ete degrade pour etre plus simple
--L'envoi des piles est fait de facon systematique et totale (peu efficace)
--L'envoi des donnees n'est pas en boucle mais du haut vers le bas
--
--Revision 3.3  91/07/22  20:07:06  alliot
--Modification de l'ordre des regles pour ameliorer la vitesse
--Gain de l'ordre d'un facteur 10
--
--Revision 3.2  91/07/22  14:53:04  alliot
--Rajout du type allfree qui correspond a une variable toujours libre
--Un objet allfree se represente par un _
--Le KUT fonctionne (ainsi que l'exemple des sages et des chapeaux ) Rajout des
--+ commandes: stack,explain,trace,allsol,firstsol
--
--Revision 3.1  91/07/20  21:31:31  alliot
--Implementation de S4
--Modification de l'unificateur avec suppression de quelques bugs
--Le KUT n'est pas implemente
--
--Revision 2.6  91/07/19  19:01:27  alliot
--modifications dans la selection des clauses et l'execution des
--regles pour ameliorer la vitesse d'execution
--
--Revision 2.5  91/07/17  19:14:01  alliot
--Un top-level a ete rajoute. On peut a partir du top-level:
--  Ajouter des clauses
--  Poser des questions
--  Executer des commandes (ligne debutant par
--Les seules commandes definies sont load (chargement fichier)
--et restart (restart complet du systeme).
--
--Revision 2.4  91/07/17  11:26:22  alliot
--Le moteur d'inference n'execute plus de code pour la
--selection et l'execution de clause. Tout se trouve desormais dans les
--fonctions du paquetage selclause. On respecte ainsi exactement le
--modele formel.
--
--Revision 2.3  91/07/16  17:27:47  alliot
--Modification du parser:
--  On peut entrer une liste sous la forme \[a,b,c,d\]
--  On peut mettre des commentaires avec \@ en debut de ligne
--  Les lignes blanches et les espaces sont ignores.
--
--Revision 2.2  91/07/16  12:39:08  alliot
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
WITH registres;
USE registres;
WITH unification;
USE unification;
WITH predef;
USE predef;

PACKAGE BODY selclause IS

   FUNCTION premiereclause RETURN num_clause IS
      elt       : elt_predicat;
      qtop      : num_quest;
      eltquest  : elt_quest;
--      qenv      : num_env;
--      numobj    : num_objet;
      obj       : elt_objet;
--      numquest  : num_quest;
      eltclause : elt_clause;
      retour    : genre_backtrack;
   BEGIN
      qtop     := position;
      eltquest := recuperer (qtop);
      obj      := recuperer (eltquest.num_struct);

      IF obj.type_pred = special THEN
         cclause := pred_clause;
     --         sauveregistres (gen => clause); --Inutile car pas de backtrack.
         IF execute_predef (eltquest.num_struct, eltquest.num_envi) THEN
            fcurr := null_objet;
            RETURN cclause;
         ELSE
            RETURN null_clause;
         END IF;
      END IF;

      elt     := recuperer (obj.nom_pred);
      cclause := elt.clause;
      IF cclause = null_clause THEN
         RETURN null_clause;
      END IF;
      eltclause := recuperer (cclause);
      sauveregistres (gen => clause);
      IF eltclause.nb_var /= 0 THEN
         fenv := reserver (positive (eltclause.nb_var));
      ELSE
         fenv := special;
      END IF;
      IF unify (eltquest.num_struct, eltclause.pred, eltquest.num_envi, fenv)
          THEN
         fcurr := eltclause.clause;
         RETURN cclause;
      ELSE
         retour := restoreregistres;
         RETURN clausesuivante (cclause);
      END IF;

   END premiereclause;

   FUNCTION clausesuivante (num : IN num_clause) RETURN num_clause IS
      elt       : elt_clause;
      qtop      : num_quest;
      eltquest  : elt_quest;
  --    qenv      : num_env;
  --    numobj    : num_objet;
  --    obj       : elt_objet;
  --    numquest  : num_quest;
      eltclause : elt_clause;
      retour    : genre_backtrack;
   BEGIN
      IF num = null_clause OR num = pred_clause THEN
         RETURN null_clause;
      END IF;
      elt := recuperer (num);
      IF elt.next = null_clause THEN
         RETURN null_clause;
      END IF;
      cclause   := elt.next;
      qtop      := position;
      eltquest  := recuperer (qtop);
      eltclause := recuperer (cclause);
      sauveregistres (gen => clause);
      IF eltclause.nb_var /= 0 THEN
         fenv := reserver (positive (eltclause.nb_var));
      ELSE
         fenv := special;
      END IF;
      IF unify (eltquest.num_struct, eltclause.pred, eltquest.num_envi, fenv)
          THEN
         fcurr := eltclause.clause;
         RETURN cclause;
      ELSE
         retour := restoreregistres;
         RETURN clausesuivante (cclause);
      END IF;

   END clausesuivante;

END selclause;
