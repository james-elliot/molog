-- $Log: registre_b.a,v $
-- Revision 1.2  1992/01/16  07:16:46  alliot
-- mineur
--
-- Revision 1.1  1991/12/18  15:03:21  alliot
-- Initial revision
--
--Revision 4.1  91/07/27  14:36:41  alliot
--Premiere version parallele fonctionnant
--Le paquetage genhash a ete degrade pour etre plus simple
--L'envoi des piles est fait de facon systematique et totale (peu efficace)
--L'envoi des donnees n'est pas en boucle mais du haut vers le bas
--
--Revision 3.3  91/07/22  20:07:03  alliot
--Modification de l'ordre des regles pour ameliorer la vitesse
--Gain de l'ordre d'un facteur 10
--
--Revision 3.2  91/07/22  14:52:59  alliot
--Rajout du type allfree qui correspond a une variable toujours libre
--Un objet allfree se represente par un _ 
--Le KUT fonctionne (ainsi que l'exemple des sages et des chapeaux ) Rajout des
--+ commandes: stack,explain,trace,allsol,firstsol
--
--Revision 3.1  91/07/20  21:31:28  alliot
--Implementation de S4
--Modification de l'unificateur avec suppression de quelques bugs
--Le KUT n'est pas implemente
--
--Revision 2.6  91/07/19  19:01:22  alliot
--modifications dans la selection des clauses et l'execution des 
--regles pour ameliorer la vitesse d'execution
--
--Revision 2.5  91/07/17  19:13:59  alliot
--Un top-level a ete rajoute. On peut a partir du top-level:
--  Ajouter des clauses
--  Poser des questions
--  Executer des commandes (ligne debutant par
--Les seules commandes definies sont load (chargement fichier)
--et restart (restart complet du systeme).
--
--Revision 2.4  91/07/17  11:26:14  alliot
--Le moteur d'inference n'execute plus de code pour la
--selection et l'execution de clause. Tout se trouve desormais dans les
--fonctions du paquetage selclause. On respecte ainsi exactement le
--modele formel.
--
--Revision 2.3  91/07/16  17:27:43  alliot
--Modification du parser:
--  On peut entrer une liste sous la forme \[a,b,c,d\]
--  On peut mettre des commentaires avec \@ en debut de ligne
--  Les lignes blanches et les espaces sont ignores.
--
--Revision 2.2  91/07/16  12:39:06  alliot
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

PACKAGE BODY registres IS

   PROCEDURE sauveregistres (gen : IN genre_backtrack) IS
      elt     : elt_backtrack (gen);
      elt_adr : num_backtrack;
   BEGIN
      elt.rbottom   := rbottom;
      elt.qcurr     := qcurr;
      elt.fcurr     := fcurr;
      elt.fenv      := fenv;
      elt.trail_top := position;
      elt.objet_top := position;
      elt.q_top     := position;
      elt.r_top     := position;
      elt.env_top   := position;
      CASE gen IS
         WHEN regle =>
            elt.cregle := cregle;
         WHEN clause =>
            elt.cclause := cclause;
         WHEN invalide =>
            NULL;
      END CASE;
      elt_adr := empiler (elt);
   END sauveregistres;

   FUNCTION restoreregistres RETURN genre_backtrack IS
      elt : elt_backtrack;
   BEGIN
      elt     := depiler;
      rbottom := elt.rbottom;
      qcurr   := elt.qcurr;
      fcurr   := elt.fcurr;
      fenv    := elt.fenv;
      revenir (elt.trail_top);
      revenir (elt.objet_top);
      revenir (elt.q_top);
      revenir (elt.r_top);
      revenir (elt.env_top);
      CASE elt.genre IS
         WHEN regle =>
            cregle := elt.cregle;
         WHEN clause =>
            cclause := elt.cclause;
         WHEN invalide =>
            NULL;
      END CASE;
      RETURN elt.genre;
   END restoreregistres;

END registres;
