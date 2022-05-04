-- $Log: genhash_b.a,v $
-- Revision 1.2  1992/01/16  07:16:46  alliot
-- mineur
--
-- Revision 1.1  1991/12/18  15:03:21  alliot
-- Initial revision
--
--Revision 4.1  91/07/27  14:36:20  alliot
--Premiere version parallele fonctionnant
--Le paquetage genhash a ete degrade pour etre plus simple
--L'envoi des piles est fait de facon systematique et totale (peu efficace)
--L'envoi des donnees n'est pas en boucle mais du haut vers le bas
--
--Revision 3.3  91/07/22  20:06:43  alliot
--Modification de l'ordre des regles pour ameliorer la vitesse
--Gain de l'ordre d'un facteur 10
--
--Revision 3.2  91/07/22  14:51:41  alliot
--Rajout du type allfree qui correspond a une variable toujours libre
--Un objet allfree se represente par un _
--Le KUT fonctionne (ainsi que l'exemple des sages et des chapeaux ) Rajout des
--+ commandes: stack,explain,trace,allsol,firstsol
--
--Revision 3.1  91/07/20  21:31:11  alliot
--Implementation de S4
--Modification de l'unificateur avec suppression de quelques bugs
--Le KUT n'est pas implemente
--
--Revision 2.6  91/07/19  19:00:52  alliot
--modifications dans la selection des clauses et l'execution des
--regles pour ameliorer la vitesse d'execution
--
--Revision 2.5  91/07/17  19:13:42  alliot
--Un top-level a ete rajoute. On peut a partir du top-level:
--  Ajouter des clauses
--  Poser des questions
--  Executer des commandes (ligne debutant par
--Les seules commandes definies sont load (chargement fichier)
--et restart (restart complet du systeme).
--
--Revision 2.4  91/07/17  11:25:34  alliot
--Le moteur d'inference n'execute plus de code pour la
--selection et l'execution de clause. Tout se trouve desormais dans les
--fonctions du paquetage selclause. On respecte ainsi exactement le
--modele formel.
--
--Revision 2.3  91/07/16  17:27:18  alliot
--Modification du parser:
--  On peut entrer une liste sous la forme \[a,b,c,d\]
--  On peut mettre des commentaires avec \@ en debut de ligne
--  Les lignes blanches et les espaces sont ignores.
--
--Revision 2.2  91/07/16  12:38:48  alliot
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

WITH unchecked_deallocation;
WITH text_io;
USE text_io;

PACKAGE BODY genhash IS

   TYPE pile IS ARRAY (indice RANGE <>) OF objet;
   TYPE acces_pile IS ACCESS pile;
   NOT_YET_IMPLEMENTED : exception;
   top  : indice     := indice'FIRST;
   size : indice     := taille;
   last : indice     := indice'FIRST + size;
   pil  : acces_pile := NEW pile (indice'FIRST + 1 .. last);
   PROCEDURE my_deallocation IS NEW unchecked_deallocation (pile, acces_pile);

   FUNCTION ajouter (x : IN objet) RETURN indice IS
      new_pile : acces_pile;
      new_last : indice;
      new_size : indice;
--      hash_val : hash_value;
--      new_elem : indice;
   BEGIN
      IF (top >= last) THEN
         new_size := size + size;
         new_last := indice'FIRST + new_size;
         new_pile := NEW pile (pil'FIRST .. new_last);
         FOR i IN pil'FIRST .. last LOOP
            new_pile (i) := pil (i);
         END LOOP;
         my_deallocation (pil);
         pil  := new_pile;
         size := new_size;
         last := new_last;
      END IF;

      FOR i IN pil'FIRST .. top LOOP
         IF egal (pil (i), x) THEN
            pil (i) := keep (pil (i), x);
            RETURN i;
         END IF;
      END LOOP;

      top       := top + 1;
      pil (top) := x;
      RETURN top;
   END ajouter;


   FUNCTION recuperer (i : IN indice) RETURN objet IS
   BEGIN
      IF i > last THEN
         RAISE indice_trop_grand;
      END IF;
      RETURN pil (i);
   END recuperer;

   PROCEDURE revenir (i : IN indice) IS
   BEGIN
--      raise NOT_YET_IMPLEMENTED;
      top := i;
   END revenir;

   FUNCTION position RETURN indice IS
   BEGIN
      RETURN top;
   END position;

   PROCEDURE dump IS
   BEGIN
      FOR i IN pil'FIRST .. top LOOP
         put_line ("objet numero: " & indice'IMAGE (i));
         affiche (pil (i));
         new_line;
      END LOOP;
   END dump;

   PROCEDURE prepare (adresse : OUT c_pointer;
                      size    : OUT c_int) IS
   BEGIN
      adresse := c_pointer (pil (pil'FIRST)'ADDRESS);
      size    := c_int (pil (pil'FIRST .. top)'SIZE / 8);
   END prepare;

   PROCEDURE initialiser (x : IN objet) IS
   BEGIN
      FOR i IN pil'FIRST .. pil'LAST LOOP
         pil (i) := x;
      END LOOP;
   END initialiser;
END genhash;
