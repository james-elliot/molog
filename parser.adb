-- $Log: parser_b.a,v $
-- Revision 1.2  1992/01/16  07:16:46  alliot
-- mineur
--
-- Revision 1.1  1991/12/18  15:03:21  alliot
-- Initial revision
--
--Revision 4.1  91/07/27  14:36:34  alliot
--Premiere version parallele fonctionnant
--Le paquetage genhash a ete degrade pour etre plus simple
--L'envoi des piles est fait de facon systematique et totale (peu efficace)
--L'envoi des donnees n'est pas en boucle mais du haut vers le bas
--
--Revision 3.3  91/07/22  20:06:56  alliot
--Modification de l'ordre des regles pour ameliorer la vitesse
--Gain de l'ordre d'un facteur 10
--
--Revision 3.2  91/07/22  14:52:47  alliot
--Rajout du type allfree qui correspond a une variable toujours libre
--Un objet allfree se represente par un _
--Le KUT fonctionne (ainsi que l'exemple des sages et des chapeaux ) Rajout des
--+ commandes: stack,explain,trace,allsol,firstsol
--
--Revision 3.1  91/07/20  21:31:22  alliot
--Implementation de S4
--Modification de l'unificateur avec suppression de quelques bugs
--Le KUT n'est pas implemente
--
--Revision 2.6  91/07/19  19:01:10  alliot
--modifications dans la selection des clauses et l'execution des
--regles pour ameliorer la vitesse d'execution
--
--Revision 2.5  91/07/17  19:13:53  alliot
--Un top-level a ete rajoute. On peut a partir du top-level:
--  Ajouter des clauses
--  Poser des questions
--  Executer des commandes (ligne debutant par
--Les seules commandes definies sont load (chargement fichier)
--et restart (restart complet du systeme).
--
--Revision 2.4  91/07/17  11:25:49  alliot
--Le moteur d'inference n'execute plus de code pour la
--selection et l'execution de clause. Tout se trouve desormais dans les
--fonctions du paquetage selclause. On respecte ainsi exactement le
--modele formel.
--
--Revision 2.3  91/07/16  17:27:33  alliot
--Modification du parser:
--  On peut entrer une liste sous la forme \[a,b,c,d\]
--  On peut mettre des commentaires avec \@ en debut de ligne
--  Les lignes blanches et les espaces sont ignores.
--
--Revision 2.2  91/07/16  12:38:59  alliot
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
WITH operateurs;
USE operateurs;
WITH predef;
USE predef;
WITH moteur;
USE moteur;
WITH text_io;
USE text_io;
WITH communication;
USE communication;

PACKAGE BODY parser IS

   SUBTYPE majuscule IS character RANGE 'A' .. 'Z';
   SUBTYPE minuscule IS character RANGE 'a' .. 'z';
   SUBTYPE chiffre IS character RANGE '0' .. '9';
   SUBTYPE indice IS nombre_arguments RANGE 1 .. 255;
   TYPE tableau_indices IS ARRAY (indice) OF integer;

   TYPE elt_pile_var IS
      RECORD
         nom  : string (1 .. 20);
         long : integer;
         num  : num_objet;
      END RECORD;
   pile        : ARRAY (0 .. 50) OF elt_pile_var;
   indice_pile : integer := - 1;

   adr_clause : num_clause;
   tete       : num_objet;
   FUNCTION parse_it (p     : IN string;
                      index : IN integer) RETURN num_objet;


   --p contient la string courante et p(index)='('
--En sortie, index contient l'index du caractere suivant la parenthese fermante
   --tab contient la liste des index pour chacun des arguments
   --nb_args contient le nombre des arguments

   PROCEDURE decoupe (p       : IN string;
                      index   : IN OUT integer;
                      tab     : OUT tableau_indices;
                      nb_args : OUT nombre_arguments) IS
      num   : nombre_arguments := 0;
      level : integer;
   BEGIN
      IF p (index) /= '(' THEN
         RAISE erreur_de_syntaxe;
      END IF;
      index   := index + 1;
      tab (1) := index;
      num     := 1;
      LOOP
         level := 0;
         LOOP
            IF level = 0 AND p (index) = ',' THEN
               EXIT;
            END IF;
            IF p (index) = '(' OR p (index) = '[' THEN
               level := level + 1;
            END IF;
            IF p (index) = ')' OR p (index) = ']' THEN
               level := level - 1;
            END IF;
            IF level = - 1 THEN
               EXIT;
            END IF;
            index := index + 1;
         END LOOP;
         index := index + 1;
         IF level = 0 THEN
            num       := num + 1;
            tab (num) := index;
         ELSE
            nb_args := num;
            EXIT;
         END IF;
      END LOOP;
   END decoupe;


   FUNCTION parse_variable (p     : IN string;
                            index : IN integer) RETURN num_objet IS
      nom  : string (1 .. 20) := (OTHERS => ascii.nul);
      temp : integer          := index;
      i    : integer          := 1;
      long : integer;
   BEGIN
      LOOP
         IF (p (temp) = '.') OR (p (temp) = '#') OR (p (temp) = '(') OR
            (p (temp) = '?') THEN
            RAISE erreur_de_syntaxe;
         END IF;
         IF (p (temp) = ')') OR (p (temp) = ',') OR (p (temp) = ']') THEN
            EXIT;
         END IF;
         nom (i) := p (temp);
         i       := i + 1;
         temp    := temp + 1;
      END LOOP;
      long := i - 1;
      FOR i IN 0 .. indice_pile LOOP
         IF (long = pile (i).long) AND THEN
            (nom (1 .. long) = pile (i).nom (1 .. long)) THEN
            RETURN pile (i).num;
         END IF;
      END LOOP;
      indice_pile := indice_pile + 1;
      pile (indice_pile).nom (1 .. long) := nom (1 .. long);
      pile (indice_pile).long            := long;
      pile (indice_pile).num             :=
         empiler ((clause => adr_clause,
                   genre  => variable,
                   dep    => deplacement (indice_pile)));
      RETURN pile (indice_pile).num;
   END parse_variable;


   FUNCTION parse_opm (p     : IN string;
                       index : IN integer) RETURN num_objet IS
      nom             : string (1 .. 256);
      size            : integer          := 0;
      nom_op          : numero_operateur := null_operateur;
      elem            : elt_objet (genre => operateur);
      temp            : integer;
      numero_objet    : num_objet;
      numero_operande : num_operande;
      nb_args         : nombre_arguments;
      args            : tableau_indices;
   BEGIN
      temp := index;
      LOOP
         IF p (temp) = '#' THEN
            RAISE erreur_de_syntaxe;
         END IF;
         IF p (temp) = ',' THEN
            RAISE erreur_de_syntaxe;
         END IF;
         IF p (temp) = '.' THEN
            RAISE erreur_de_syntaxe;
         END IF;
         IF p (temp) = '?' THEN
            RAISE erreur_de_syntaxe;
         END IF;
         IF p (temp) = ')' THEN
            RAISE erreur_de_syntaxe;
         END IF;
         IF p (temp) = ':' THEN
            EXIT;
         END IF;
         IF p (temp) = '(' THEN
            EXIT;
         END IF;
         size       := size + 1;
         nom (size) := p (temp);
         temp       := temp + 1;
      END LOOP;
      IF size = 0 THEN
         RAISE erreur_de_syntaxe;
      END IF;
      IF p (temp) = ':' THEN
         elem.nb_arg_op := 0;
      ELSE
         decoupe (p, temp, args, nb_args);
         elem.nb_arg_op := nb_args;
         elem.arg_op    := empiler (null_objet);
         FOR j IN 2 .. elem.nb_arg_op LOOP
            numero_operande := empiler (null_objet);
         END LOOP;
         FOR j IN 1 .. elem.nb_arg_op LOOP
            numero_objet := parse_it (p, args (j));
            modifier (numero_objet, elem.arg_op + (j - 1));
         END LOOP;
      END IF;

--      FOR j IN premier_operateur .. dernier_operateur LOOP
--         IF egal (j, nom (1 .. size), elem.nb_arg_op) THEN
--            nom_op := j;
--            EXIT;
--         END IF;
--      END LOOP;
      nom_op := is_operateur (nom(1..size), elem.nb_arg_op);
      IF nom_op = null_operateur THEN
         RAISE operateur_inconnu;
      END IF;
      elem.nom_op := nom_op;

      -- temp a ete modifie par decoupe et pointe sur le
      -- premier caractere apres la parenthese fermante,
      -- qui doit etre un ':'
      IF p (temp) /= ':' THEN
         RAISE erreur_de_syntaxe;
      END IF;
      elem.obj_qual := parse_it (p, temp + 1);
      elem.clause   := adr_clause;
      RETURN empiler (elem);
   END parse_opm;

   FUNCTION parse_predicat (p     : IN string;
                            index : IN integer) RETURN num_objet IS
      nom             : string (1 .. 20) := (OTHERS => ascii.nul);
      i, size         : integer          := 0;
      elem            : elt_objet (genre => predicat);
      temp            : integer;
      num_pred        : num_predicat;
      numero_objet    : num_objet;
      numero_operande : num_operande;
      nb_args         : nombre_arguments;
      args            : tableau_indices;
   BEGIN
      temp := index;
      LOOP
         IF p (temp) = '#' THEN
            RAISE erreur_de_syntaxe;
         END IF;
         IF p (temp) = ',' THEN
            EXIT;
         END IF;
         IF p (temp) = '.' THEN
            EXIT;
         END IF;
         IF p (temp) = '?' THEN
            EXIT;
         END IF;
         IF p (temp) = ')' THEN
            EXIT;
         END IF;
         IF p (temp) = ']' THEN
            EXIT;
         END IF;
         IF p (temp) = ':' THEN
            RAISE erreur_de_syntaxe;
         END IF;
         IF p (temp) = '(' THEN
            EXIT;
         END IF;
         size       := size + 1;
         nom (size) := p (temp);
         temp       := temp + 1;
      END LOOP;
      IF size = 0 THEN
         RAISE erreur_de_syntaxe;
      END IF;
      IF (p (temp) = ',') OR (p (temp) = ')') OR (p (temp) = '.') OR
         (p (temp) = '?') OR (p (temp) = ']') THEN
         elem.nb_arg_pred := 0;
      ELSE
         decoupe (p, temp, args, nb_args);
         elem.nb_arg_pred := nb_args;
         elem.arg_pred    := empiler (null_objet);
         FOR j IN 2 .. nb_args LOOP
            numero_operande := empiler (null_objet);
         END LOOP;
         FOR j IN 1 .. elem.nb_arg_pred LOOP
            numero_objet := parse_it (p, args (j));
            modifier (numero_objet, elem.arg_pred + (j - 1));
         END LOOP;
      END IF;
      i := nombre_arguments'IMAGE (elem.nb_arg_pred)'LAST;
      nom (size + 1 .. size + i) := nombre_arguments'IMAGE (elem.nb_arg_pred);
      elem.code                  := is_predef (nom);
      elem.clause                := adr_clause;
      IF elem.code = null_code THEN
         IF p (temp) = '.' THEN -- Predicat de tete.
            num_pred      := ajouter ((nom => nom, clause => adr_clause));
            elem.nom_pred := num_pred;
            tete          := empiler (elem);
            RETURN tete;
         ELSE
            num_pred      := ajouter ((nom => nom, clause => null_clause));
            elem.nom_pred := num_pred;
            RETURN empiler (elem);
         END IF;
      ELSE
         IF p (temp) = '.' THEN
            RAISE erreur_de_syntaxe;
         ELSE
            elem.type_pred := special;
            RETURN empiler (elem);
         END IF;
      END IF;
   END parse_predicat;


   FUNCTION parse_nombre (p     : IN string;
                          index : IN integer) RETURN num_objet IS
      zero   : CONSTANT integer := character'POS ('0');
      nb     : float            := 0.0;
      nf     : float            := 1.0;
      fl     : boolean          := false;
      nombre : elt_objet;
      temp   : integer := index;
   BEGIN
      LOOP
         nb   := nb + float ((character'POS (p (temp)) - zero));
         temp := temp + 1;
         EXIT WHEN (p (temp) NOT IN chiffre) AND (p (temp) /= '.');
         nb := nb * 10.0;
         IF p (temp) = '.' THEN
            IF fl THEN
               RAISE erreur_de_syntaxe;
            END IF;
            fl   := true;
            temp := temp + 1;
         END IF;
         IF fl THEN
            nf := nf * 10.0;
         END IF;
      END LOOP;
      nb := nb / nf;
      IF fl THEN
         nombre := (genre    => flottant,
                    clause   => adr_clause,
                    val_flot => valeur_flottant (nb));
      ELSE
         nombre := (genre   => entier,
                    clause  => adr_clause,
                    val_ent => valeur_entier (nb));
      END IF;
      RETURN empiler (nombre);
   END parse_nombre;


   PROCEDURE decoupe_cons (p          : IN string;
                           index      : IN OUT integer;
                           arg1, arg2 : OUT integer) IS
      num   : nombre_arguments := 0;
      level : integer;
   BEGIN
      IF p (index) /= '[' THEN
         RAISE erreur_de_syntaxe;
      END IF;
      index := index + 1;
      arg1  := index;
      num   := 1;
      LOOP
         level := 0;
         LOOP
            IF level = 0 AND p (index) = ',' THEN
               EXIT;
            END IF;
            IF p (index) = '(' OR p (index) = '[' THEN
               level := level + 1;
            END IF;
            IF p (index) = ')' OR p (index) = ']' THEN
               level := level - 1;
            END IF;
            IF level = - 1 THEN
               EXIT;
            END IF;
            index := index + 1;
         END LOOP;
         index := index + 1;
         IF level = 0 THEN
            num := num + 1;
            IF num > 2 THEN
               RAISE erreur_de_syntaxe;
            END IF;
            arg2 := index;
         ELSE
            EXIT;
         END IF;
      END LOOP;
      IF num < 2 THEN
         RAISE erreur_de_syntaxe;
      END IF;
   END decoupe_cons;

   -- Retourne false s'il n'y a
   PROCEDURE arg_suivant (p     : IN string;
                          index : IN OUT integer;
                          val   : OUT boolean) IS
      level : integer;
   BEGIN
      level := 0;
      LOOP
         IF level = 0 AND p (index) = ',' THEN
            EXIT;
         END IF;
         IF p (index) = '(' OR p (index) = '[' THEN
            level := level + 1;
         END IF;
         IF p (index) = ')' OR p (index) = ']' THEN
            level := level - 1;
         END IF;
         IF level = - 1 THEN
            EXIT;
         END IF;
         index := index + 1;
      END LOOP;
      index := index + 1;
      IF level = - 1 THEN
         val := false;
      ELSE
         val := true;
      END IF;
   END arg_suivant;



   FUNCTION parse_cons (p     : IN string;
                        index : IN integer) RETURN num_objet IS
      obj        : elt_objet (genre => cons);
--      arg1, arg2 : integer;
      new_index  : integer := index;
      old_index  : integer;
      cont       : boolean;
   BEGIN
      old_index := new_index;
      obj.car   := parse_it (p, old_index);
      arg_suivant (p, new_index, cont);
      old_index := new_index;
      arg_suivant (p, new_index, cont);
      IF NOT cont THEN
         obj.cdr := parse_it (p, old_index);
      ELSE
         obj.cdr := parse_cons (p, old_index);
      END IF;
      obj.clause := adr_clause;
      RETURN empiler (obj);
   END parse_cons;


   FUNCTION parse_it (p     : IN string;
                      index : IN integer) RETURN num_objet IS
   BEGIN
      IF p (index) = '_' THEN
         RETURN empiler ((clause => adr_clause, genre => allfree));
      END IF;
      IF p (index) = '[' THEN
         RETURN parse_cons (p, index + 1);
      END IF;
      IF p (index) = '#' THEN
         RETURN parse_opm (p, index + 1);
      END IF;
      IF p (index) IN majuscule THEN
         RETURN parse_variable (p, index);
      END IF;
      IF p (index) IN minuscule THEN
         RETURN parse_predicat (p, index);
      END IF;
      IF p (index) IN chiffre THEN
         RETURN parse_nombre (p, index);
      END IF;
      RAISE erreur_de_syntaxe;
   END parse_it;

   PROCEDURE real_parse (p : IN string) IS
      num           : num_objet;
      clause        : elt_clause;
      elt           : elt_quest;
      adr           : num_quest;
      nb            : natural;
      pile_pred     : num_predicat;
      pile_trail    : num_trail;
      pile_operande : num_operande;
      pile_quest    : num_quest;
      pile_res      : num_res;
      pile_env      : num_env;
      --    pile_clause:=position; Inutile pour l'instant (pas de assert)
      pile_objet     : num_objet;
      pile_backtrack : num_backtrack;
      file           : file_type;
      line           : string (1 .. 256);
      last           : natural;
   BEGIN
      IF p (p'FIRST) = '@' THEN
         RETURN;
      END IF;
      IF p (p'FIRST) = '!' THEN
         BEGIN
            IF p (p'FIRST + 1 .. p'FIRST + 4) = "load" THEN
               BEGIN
                  open (file, in_file, p (p'FIRST + 5 .. p'LAST));
                  LOOP
                     get_line (file, line, last);
                     put_line (line (1 .. last));
                     parse (line (1 .. last));
                  END LOOP;
                  close (file);
               EXCEPTION
                  WHEN name_error =>
                     put_line ("Le fichier " & p (p'FIRST + 5 .. p'LAST) &
                               " n'existe pas.");
                  WHEN end_error =>
                     NULL;
               END;
               RETURN;
            ELSIF p (p'FIRST + 1 .. p'FIRST + 5) = "reloa" THEN
               restart_all;
               BEGIN
                  open (file, in_file, p (p'FIRST + 7 .. p'LAST));
                  LOOP
                     get_line (file, line, last);
                     put_line (line (1 .. last));
                     parse (line (1 .. last));
                  END LOOP;
                  close (file);
               EXCEPTION
                  WHEN name_error =>
                     put_line ("Le fichier " & p (p'FIRST + 5 .. p'LAST) &
                               " n'existe pas.");
                  WHEN end_error =>
                     NULL;
               END;
               RETURN;
            ELSIF p (p'FIRST + 1 .. p'FIRST + 5) = "resta" THEN
               restart_all;
               RETURN;
            ELSIF p (p'FIRST + 1 .. p'FIRST + 5) = "stack" THEN
               stack := true;
               RETURN;
            ELSIF p (p'FIRST + 1 .. p'FIRST + 5) = "nosta" THEN
               stack := false;
               RETURN;
            ELSIF p (p'FIRST + 1 .. p'FIRST + 5) = "trace" THEN
               trace := true;
               RETURN;
            ELSIF p (p'FIRST + 1 .. p'FIRST + 5) = "notra" THEN
               trace := false;
               RETURN;
            ELSIF p (p'FIRST + 1 .. p'FIRST + 5) = "expla" THEN
               explain := true;
               RETURN;
            ELSIF p (p'FIRST + 1 .. p'FIRST + 5) = "noexp" THEN
               explain := false;
               RETURN;
            ELSIF p (p'FIRST + 1 .. p'FIRST + 5) = "allso" THEN
               all_sol := true;
               RETURN;
            ELSIF p (p'FIRST + 1 .. p'FIRST + 5) = "first" THEN
               all_sol := false;
               RETURN;
            ELSIF p (p'FIRST + 1 .. p'FIRST + 5) = "paral" THEN
               IF NOT parallel THEN
                  BEGIN
                     open_master;
                     parallel := true;
                     put_line ("Version parallele");
                  EXCEPTION
                     WHEN erreur_connection =>
                        put_line ("desole, impossible de lancer les demons");
                  END;
               END IF;
               RETURN;
            ELSIF p (p'FIRST + 1 .. p'FIRST + 5) = "nopar" THEN
               IF parallel THEN
                  parallel := false;
                  close_all;
               END IF;
               RETURN;
            END IF;
            put_line ("impossible d'executer " & p);
         EXCEPTION
            WHEN constraint_error =>
               put_line ("impossible de faire " & p);
         END;
         RETURN;
      END IF;

      IF p (p'LAST) = '.' THEN
         indice_pile   := - 1;
         clause.clause := null_objet;
         clause.nb_var := 0;
         clause.next   := null_clause;
         tete          := null_objet;
         adr_clause    := empiler (clause);
         num           := parse_it (p, p'FIRST);
         clause.clause := num;
         clause.nb_var := nombre_variables (indice_pile + 1);
         IF tete = null_objet THEN
            RAISE erreur_de_syntaxe;
         END IF;
         clause.pred := tete;
         modifier (clause, adr_clause);
      ELSIF p (p'LAST) = '?' THEN
         indice_pile    := - 1;
         pile_pred      := position;
         pile_trail     := position;
         pile_operande  := position;
         pile_quest     := position;
         pile_res       := position;
         pile_env       := position;
         pile_backtrack := position;
     --           pile_clause:=position; Inutile pour l'instant (pas de assert)
         pile_objet     := position;
         num            := parse_it (p, p'FIRST);
         elt.num_struct := num;
         nb             := natural (indice_pile + 1);
         IF nb = 0 THEN
            elt.num_envi := null_env;
         ELSE
            elt.num_envi := reserver (nb);
         END IF;
         adr := empiler (elt);
         IF stack THEN
            dump_all;
         END IF;
         principal;
         revenir (pile_pred);
         revenir (pile_trail);
         revenir (pile_operande);
         revenir (pile_quest);
         revenir (pile_res);
         revenir (pile_env);
--                                           revenir(pile_clause); Inutile pour l'in
--+stant
         --+ (pas
         --+ d'as
         --+sert)
         --+;
         revenir (pile_objet);
         revenir (pile_backtrack);
      ELSE
         RAISE erreur_de_syntaxe;
      END IF;
   END real_parse;

   PROCEDURE parse (p : IN string) IS
      q : string (p'RANGE);
      j : integer;
   BEGIN
      j := q'FIRST;
      FOR i IN p'RANGE LOOP
         IF p (i) /= ' ' THEN
            q (j) := p (i);
            j     := j + 1;
         END IF;
      END LOOP;
      IF j = q'FIRST THEN
         RETURN;
      END IF;
      real_parse (q (q'FIRST .. j - 1));
   END parse;



END parser;
