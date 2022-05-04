-- $Log: type_b.a,v $
-- Revision 1.2  1992/01/16  07:16:46  alliot
-- mineur
--
-- Revision 1.1  1991/12/18  15:03:21  alliot
-- Initial revision
--
--Revision 4.1  91/07/27  14:37:10  alliot
--Premiere version parallele fonctionnant
--Le paquetage genhash a ete degrade pour etre plus simple
--L'envoi des piles est fait de facon systematique et totale (peu efficace)
--L'envoi des donnees n'est pas en boucle mais du haut vers le bas
--
--Revision 3.3  91/07/22  20:07:10  alliot
--Modification de l'ordre des regles pour ameliorer la vitesse
--Gain de l'ordre d'un facteur 10
--
--Revision 3.2  91/07/22  14:53:10  alliot
--Rajout du type allfree qui correspond a une variable toujours libre
--Un objet allfree se represente par un _ 
--Le KUT fonctionne (ainsi que l'exemple des sages et des chapeaux ) Rajout des
--+ commandes: stack,explain,trace,allsol,firstsol
--
--Revision 3.1  91/07/20  21:31:35  alliot
--Implementation de S4
--Modification de l'unificateur avec suppression de quelques bugs
--Le KUT n'est pas implemente
--
--Revision 2.6  91/07/19  19:01:35  alliot
--modifications dans la selection des clauses et l'execution des 
--regles pour ameliorer la vitesse d'execution
--
--Revision 2.5  91/07/17  19:14:05  alliot
--Un top-level a ete rajoute. On peut a partir du top-level:
--  Ajouter des clauses
--  Poser des questions
--  Executer des commandes (ligne debutant par
--Les seules commandes definies sont load (chargement fichier)
--et restart (restart complet du systeme).
--
--Revision 2.4  91/07/17  11:26:26  alliot
--Le moteur d'inference n'execute plus de code pour la
--selection et l'execution de clause. Tout se trouve desormais dans les
--fonctions du paquetage selclause. On respecte ainsi exactement le
--modele formel.
--
--Revision 2.3  91/07/16  17:27:52  alliot
--Modification du parser:
--  On peut entrer une liste sous la forme \[a,b,c,d\]
--  On peut mettre des commentaires avec \@ en debut de ligne
--  Les lignes blanches et les espaces sont ignores.
--
--Revision 2.2  91/07/16  12:39:12  alliot
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

WITH text_io;
USE text_io;

PACKAGE BODY types_molog IS
   PACKAGE my_float_io IS NEW text_io.float_io (valeur_flottant);
   USE my_float_io;

   procedure afficher (val : in valeur_flottant) is
   begin
      my_float_io.put(val);
      new_line;
   end afficher;

   PROCEDURE afficher (num : IN num_objet) IS
   BEGIN
      put_line (num_objet'IMAGE (num));
   END afficher;

   PROCEDURE afficher (num : IN num_clause) IS
   BEGIN
      put_line (num_clause'IMAGE (num));
   END afficher;

   PROCEDURE afficher (num : IN num_env) IS
   BEGIN
      put_line (num_env'IMAGE (num));
   END afficher;

   PROCEDURE afficher (num : IN num_quest) IS
   BEGIN
      put_line (num_quest'IMAGE (num));
   END afficher;

   PROCEDURE afficher (num : IN num_res) IS
   BEGIN
      put_line (num_res'IMAGE (num));
   END afficher;

   PROCEDURE afficher (num : IN num_trail) IS
   BEGIN
      put_line (num_trail'IMAGE (num));
   END afficher;

   PROCEDURE afficher (num : IN num_backtrack) IS
   BEGIN
      put_line (num_backtrack'IMAGE (num));
   END afficher;

   PROCEDURE afficher (num : IN num_operande) IS
   BEGIN
      put_line (num_operande'IMAGE (num));
   END afficher;

   PROCEDURE afficher (num : IN num_predicat) IS
   BEGIN
      put_line (num_predicat'IMAGE (num));
   END afficher;

   PROCEDURE afficher (num : IN numero_operateur) IS
   BEGIN
      put_line (numero_operateur'IMAGE (num));
   END afficher;

   PROCEDURE afficher (num : IN numero_regle) IS
   BEGIN
      put_line (numero_regle'IMAGE (num));
   END afficher;



   PROCEDURE afficher (x : IN elt_predicat) IS
   BEGIN
      put_line ("nom: " & x.nom);
      put_line ("clause" & num_clause'IMAGE (x.clause));
   END afficher;



   PROCEDURE afficher (x : IN elt_backtrack) IS
   BEGIN
      put_line ("rbottom     : " & num_res'IMAGE (x.rbottom));
      put_line ("qcurr     : " & num_quest'IMAGE (x.qcurr));
      put_line ("fcurr     : " & num_objet'IMAGE (x.fcurr));
      put_line ("fenv      : " & num_env'IMAGE (x.fenv));
      put_line ("trail_top : " & num_trail'IMAGE (x.trail_top));
      put_line ("objet_top : " & num_objet'IMAGE (x.objet_top));
      put_line ("q_top    : " & num_quest'IMAGE (x.q_top));
      put_line ("r_top    : " & num_res'IMAGE (x.r_top));
      put_line ("env_top   : " & num_env'IMAGE (x.env_top));
      CASE x.genre IS
         WHEN regle =>
            put_line ("cregle    : " & numero_regle'IMAGE (x.cregle));
         WHEN clause =>
            put_line ("cclause   : " & num_clause'IMAGE (x.cclause));
         WHEN invalide =>
            put_line ("bloc invalide");
      END CASE;
   END afficher;

   PROCEDURE afficher (x : IN elt_quest) IS
   BEGIN
      put_line ("num_struct :" & num_objet'IMAGE (x.num_struct));
      put_line ("num_envi   :" & num_env'IMAGE (x.num_envi));
   END afficher;

   PROCEDURE afficher (x : IN elt_res) IS
   BEGIN
      put_line ("num_struct :" & num_objet'IMAGE (x.num_struct));
      put_line ("num_envi   :" & num_env'IMAGE (x.num_envi));
   END afficher;

   PROCEDURE afficher (x : IN elt_env) IS
   BEGIN
      put_line ("num_struct :" & num_objet'IMAGE (x.num_struct));
      put_line ("num_envi   :" & num_env'IMAGE (x.num_envi));
   END afficher;

   PROCEDURE afficher (x : IN elt_clause) IS
   BEGIN
      put_line ("clause :" & num_objet'IMAGE (x.clause));
      put_line ("nb_var :" & nombre_variables'IMAGE (x.nb_var));
      put_line ("next   :" & num_clause'IMAGE (x.next));
      put_line ("pred   :" & num_objet'IMAGE (x.pred));
   END afficher;

   PROCEDURE afficher (x : IN elt_objet) IS
   BEGIN
      put_line ("clause     : " & num_clause'IMAGE (x.clause));
      CASE x.genre IS
         WHEN operateur =>
            put_line ("nom_op    : " & numero_operateur'IMAGE (x.nom_op));
            put_line ("nb_arg_op : " & nombre_arguments'IMAGE (x.nb_arg_op));
            put_line ("arg_op    : " & num_operande'IMAGE (x.arg_op));
            put_line ("obj_qual  : " & num_objet'IMAGE (x.obj_qual));
         WHEN predicat =>
            put_line ("nom_pred    : " & num_predicat'IMAGE (x.nom_pred));
            put_line ("type_pred   : " & genre_predicat'IMAGE (x.type_pred));
            put_line ("nb_arg_pred : " &
                      nombre_arguments'IMAGE (x.nb_arg_pred));
            put_line ("arg_pred    : " & num_operande'IMAGE (x.arg_pred));
            put_line ("code        : " & numero_code'IMAGE (x.code));
         WHEN variable =>
            put_line ("dep : " & deplacement'IMAGE (x.dep));
         WHEN entier =>
            put_line ("val_ent : " & valeur_entier'IMAGE (x.val_ent));
         WHEN flottant =>
            put ("val_flot : ");
            put (x.val_flot);
            new_line;
         WHEN cons =>
            put_line ("car :" & num_objet'IMAGE (x.car));
            put_line ("cdr :" & num_objet'IMAGE (x.cdr));
         WHEN allfree =>
            put_line ("FREE");
      END CASE;
   END afficher;

   FUNCTION is_younger (num1, num2 : IN num_env) RETURN boolean IS
   BEGIN
      RETURN (num1 < num2);
   END is_younger;


   FUNCTION special RETURN num_env IS
   BEGIN
      RETURN pile_env.position + integer (1);
   END special;

   PROCEDURE dump_predicat IS
   BEGIN
      put_line ("pile des predicats");
      pile_predicat.dump;
   END dump_predicat;

   PROCEDURE dump_trail IS
   BEGIN
      put_line ("pile de trail");
      pile_trail.dump;
   END dump_trail;

   PROCEDURE dump_operande IS
   BEGIN
      put_line ("pile des operandes");
      pile_operande.dump;
   END dump_operande;

   PROCEDURE dump_backtrack IS
   BEGIN
      put_line ("pile de backtrack");
      pile_backtrack.dump;
   END dump_backtrack;

   PROCEDURE dump_quest IS
   BEGIN
      put_line ("pile de la question");
      pile_quest.dump;
   END dump_quest;

   PROCEDURE dump_res IS
   BEGIN
      put_line ("pile de la resolvante");
      pile_res.dump;
   END dump_res;

   PROCEDURE dump_env IS
   BEGIN
      put_line ("pile des environnements");
      pile_env.dump;
   END dump_env;

   PROCEDURE dump_clause IS
   BEGIN
      put_line ("pile des clauses");
      pile_clause.dump;
   END dump_clause;

   PROCEDURE dump_objet IS
   BEGIN
      put_line ("pile des objets");
      pile_objet.dump;
   END dump_objet;



   FUNCTION ajouter (x : IN elt_predicat) RETURN num_predicat IS
   BEGIN
      RETURN pile_predicat.ajouter (x);
   END ajouter;

   FUNCTION recuperer (i : IN num_predicat) RETURN elt_predicat IS
   BEGIN
      RETURN pile_predicat.recuperer (i);
   END recuperer;

   PROCEDURE revenir (i : IN num_predicat) IS
   BEGIN
      pile_predicat.revenir (i);
   END revenir;

   FUNCTION position RETURN num_predicat IS
   BEGIN
      RETURN pile_predicat.position;
   END position;

   FUNCTION empiler (x : IN elt_trail) RETURN num_trail IS
   BEGIN
      RETURN pile_trail.empiler (x);
   END empiler;



   FUNCTION reserver (n : IN positive) RETURN num_trail IS
   BEGIN
      RETURN pile_trail.reserver (n);
   END reserver;

   FUNCTION recuperer (i : IN num_trail) RETURN elt_trail IS
   BEGIN
      RETURN pile_trail.recuperer (i);
   END recuperer;

   PROCEDURE modifier (x : IN elt_trail;
                       i : IN num_trail) IS
   BEGIN
      pile_trail.modifier (x, i);
   END modifier;

   PROCEDURE revenir (i : IN num_trail) IS
      eltenv : elt_env;
      numenv : num_env;
   BEGIN
      FOR j IN i + integer (1) .. position LOOP
         numenv            := recuperer (j);
         eltenv            := recuperer (numenv);
         eltenv.num_struct := null_objet;
         eltenv.num_envi   := null_env;
         modifier (eltenv, numenv);
      END LOOP;
      pile_trail.revenir (i);
   END revenir;

   FUNCTION position RETURN num_trail IS
   BEGIN
      RETURN pile_trail.position;
   END position;

   FUNCTION empiler (x : IN elt_operande) RETURN num_operande IS
   BEGIN
      RETURN pile_operande.empiler (x);
   END empiler;

   FUNCTION reserver (n : IN positive) RETURN num_operande IS
   BEGIN
      RETURN pile_operande.reserver (n);
   END reserver;

   FUNCTION recuperer (i : IN num_operande) RETURN elt_operande IS
   BEGIN
      RETURN pile_operande.recuperer (i);
   END recuperer;

   PROCEDURE modifier (x : IN elt_operande;
                       i : IN num_operande) IS
   BEGIN
      pile_operande.modifier (x, i);
   END modifier;

   PROCEDURE revenir (i : IN num_operande) IS
   BEGIN
      pile_operande.revenir (i);
   END revenir;

   FUNCTION position RETURN num_operande IS
   BEGIN
      RETURN pile_operande.position;
   END position;

   FUNCTION empiler (x : IN elt_backtrack) RETURN num_backtrack IS
   BEGIN
      RETURN pile_backtrack.empiler (x);
   END empiler;

   FUNCTION reserver (n : IN positive) RETURN num_backtrack IS
   BEGIN
      RETURN pile_backtrack.reserver (n);
   END reserver;

   FUNCTION recuperer (i : IN num_backtrack) RETURN elt_backtrack IS
   BEGIN
      RETURN pile_backtrack.recuperer (i);
   EXCEPTION
      WHEN pile_backtrack.pile_vide =>
         RAISE pile_vide;
   END recuperer;

   FUNCTION depiler RETURN elt_backtrack IS
   BEGIN
      RETURN pile_backtrack.depiler;
   EXCEPTION
      WHEN pile_backtrack.pile_vide =>
         RAISE pile_vide;
   END depiler;

   PROCEDURE modifier (x : IN elt_backtrack;
                       i : IN num_backtrack) IS
   BEGIN
      pile_backtrack.modifier (x, i);
   END modifier;

   PROCEDURE revenir (i : IN num_backtrack) IS
   BEGIN
      pile_backtrack.revenir (i);
   END revenir;

   FUNCTION position RETURN num_backtrack IS
   BEGIN
      RETURN pile_backtrack.position;
   END position;

   FUNCTION empiler (x : IN elt_quest) RETURN num_quest IS
   BEGIN
      RETURN pile_quest.empiler (x);
   END empiler;

   FUNCTION reserver (n : IN positive) RETURN num_quest IS
   BEGIN
      RETURN pile_quest.reserver (n);
   END reserver;

   FUNCTION recuperer (i : IN num_quest) RETURN elt_quest IS
   BEGIN
      RETURN pile_quest.recuperer (i);
   END recuperer;

   PROCEDURE modifier (x : IN elt_quest;
                       i : IN num_quest) IS
   BEGIN
      pile_quest.modifier (x, i);
   END modifier;

   PROCEDURE revenir (i : IN num_quest) IS
   BEGIN
      pile_quest.revenir (i);
   END revenir;

   FUNCTION position RETURN num_quest IS
   BEGIN
      RETURN pile_quest.position;
   END position;

   FUNCTION empiler (x : IN elt_res) RETURN num_res IS
   BEGIN
      RETURN pile_res.empiler (x);
   END empiler;

   FUNCTION reserver (n : IN positive) RETURN num_res IS
   BEGIN
      RETURN pile_res.reserver (n);
   END reserver;

   FUNCTION recuperer (i : IN num_res) RETURN elt_res IS
   BEGIN
      RETURN pile_res.recuperer (i);
   END recuperer;

   PROCEDURE modifier (x : IN elt_res;
                       i : IN num_res) IS
   BEGIN
      pile_res.modifier (x, i);
   END modifier;

   PROCEDURE revenir (i : IN num_res) IS
   BEGIN
      pile_res.revenir (i);
   END revenir;

   FUNCTION position RETURN num_res IS
   BEGIN
      RETURN pile_res.position;
   END position;

   FUNCTION empiler (x : IN elt_env) RETURN num_env IS
   BEGIN
      RETURN pile_env.empiler (x);
   END empiler;

   FUNCTION reserver (n : IN positive) RETURN num_env IS
      elt : elt_env := (num_struct => null_objet, num_envi => null_env);
      first, last : num_env;
   BEGIN
      first := empiler (elt);
      FOR i IN 2 .. n LOOP
         last := empiler (elt);
      END LOOP;
      RETURN first;
   END reserver;

   FUNCTION recuperer (i : IN num_env) RETURN elt_env IS
   BEGIN
      RETURN pile_env.recuperer (i);
   END recuperer;

   PROCEDURE modifier (x : IN elt_env;
                       i : IN num_env) IS
   BEGIN
      pile_env.modifier (x, i);
   END modifier;

   PROCEDURE revenir (i : IN num_env) IS
   BEGIN
      pile_env.revenir (i);
   END revenir;

   FUNCTION position RETURN num_env IS
   BEGIN
      RETURN pile_env.position;
   END position;


   FUNCTION empiler (x : IN elt_clause) RETURN num_clause IS
   BEGIN
      RETURN pile_clause.empiler (x);
   END empiler;

   FUNCTION reserver (n : IN positive) RETURN num_clause IS
   BEGIN
      RETURN pile_clause.reserver (n);
   END reserver;

   FUNCTION recuperer (i : IN num_clause) RETURN elt_clause IS
   BEGIN
      RETURN pile_clause.recuperer (i);
   END recuperer;

   PROCEDURE modifier (x : IN elt_clause;
                       i : IN num_clause) IS
   BEGIN
      pile_clause.modifier (x, i);
   END modifier;

   PROCEDURE revenir (i : IN num_clause) IS
   BEGIN
      pile_clause.revenir (i);
   END revenir;

   FUNCTION position RETURN num_clause IS
   BEGIN
      RETURN pile_clause.position;
   END position;


   FUNCTION empiler (x : IN elt_objet) RETURN num_objet IS
   BEGIN
      RETURN pile_objet.empiler (x);
   END empiler;

   FUNCTION reserver (n : IN positive) RETURN num_objet IS
   BEGIN
      RETURN pile_objet.reserver (n);
   END reserver;

   FUNCTION recuperer (i : IN num_objet) RETURN elt_objet IS
   BEGIN
      RETURN pile_objet.recuperer (i);
   END recuperer;

   PROCEDURE modifier (x : IN elt_objet;
                       i : IN num_objet) IS
   BEGIN
      pile_objet.modifier (x, i);
   END modifier;

   PROCEDURE revenir (i : IN num_objet) IS
   BEGIN
      pile_objet.revenir (i);
   END revenir;

   FUNCTION position RETURN num_objet IS
   BEGIN
      RETURN pile_objet.position;
   END position;

   FUNCTION hash_pred (p : IN elt_predicat) RETURN hash_pred_val IS
      val : integer := 0;
   BEGIN
      FOR i IN p.nom'RANGE LOOP
         val := val + integer (character'POS (p.nom (i)));
      END LOOP;
      RETURN hash_pred_val ((val MOD 256));
   END hash_pred;

   FUNCTION egal_pred (x, y : IN elt_predicat) RETURN boolean IS
   BEGIN
      RETURN x.nom = y.nom;
   END egal_pred;

   FUNCTION keep_pred (x, y : IN elt_predicat) RETURN elt_predicat IS
      z          : elt_predicat := x;
      adr_clause : num_clause;
      clause     : elt_clause;
   BEGIN
      IF y.clause = null_clause THEN
         RETURN z;
      END IF;
      IF x.clause = null_clause THEN
         z.clause := y.clause;
         RETURN z;
      END IF;
      adr_clause := x.clause;
      LOOP
         clause := recuperer (adr_clause);
         EXIT WHEN clause.next = null_clause;
         adr_clause := clause.next;
      END LOOP;
      clause.next := y.clause;
      modifier (clause, adr_clause);
      RETURN z;
   END keep_pred;

   FUNCTION "+" (adr : IN num_predicat;
                 dep : IN integer) RETURN num_predicat IS
   BEGIN
      RETURN adr + num_predicat (dep);
   END "+";

   FUNCTION "+" (adr : IN num_trail;
                 dep : IN integer) RETURN num_trail IS
   BEGIN
      RETURN adr + num_trail (dep);
   END "+";

   FUNCTION "+" (adr : IN num_operande;
                 dep : IN integer) RETURN num_operande IS
   BEGIN
      RETURN adr + num_operande (dep);
   END "+";

   FUNCTION "+" (adr : IN num_operande;
                 dep : IN nombre_arguments) RETURN num_operande IS
   BEGIN
      RETURN adr + num_operande (dep);
   END "+";

   FUNCTION "+" (adr : IN num_backtrack;
                 dep : IN integer) RETURN num_backtrack IS
   BEGIN
      RETURN adr + num_backtrack (dep);
   END "+";

   FUNCTION "-" (adr : IN num_backtrack;
                 dep : IN integer) RETURN num_backtrack IS
   BEGIN
      RETURN adr - num_backtrack (dep);
   END "-";

   FUNCTION "+" (adr : IN num_quest;
                 dep : IN integer) RETURN num_quest IS
   BEGIN
      RETURN adr + num_quest (dep);
   END "+";

   FUNCTION "+" (adr : IN num_res;
                 dep : IN integer) RETURN num_res IS
   BEGIN
      RETURN adr + num_res (dep);
   END "+";

   FUNCTION "-" (adr : IN num_res;
                 dep : IN integer) RETURN num_res IS
   BEGIN
      RETURN adr - num_res (dep);
   END "-";

   FUNCTION "+" (adr : IN num_env;
                 dep : IN integer) RETURN num_env IS
   BEGIN
      RETURN adr + num_env (dep);
   END "+";

   FUNCTION "+" (adr : IN num_env;
                 dep : IN deplacement) RETURN num_env IS
   BEGIN
      RETURN adr + num_env (dep);
   END "+";

   FUNCTION "+" (adr : IN num_clause;
                 dep : IN integer) RETURN num_clause IS
   BEGIN
      RETURN adr + num_clause (dep);
   END "+";

   FUNCTION "+" (adr : IN num_objet;
                 dep : IN integer) RETURN num_objet IS
   BEGIN
      RETURN adr + num_objet (dep);
   END "+";

   PROCEDURE restart_all IS
   BEGIN
      pile_predicat.revenir (null_pred);
      pile_trail.revenir (null_trail);
      pile_operande.revenir (null_operande);
      pile_backtrack.revenir (null_backtrack);
      pile_res.revenir (null_res);
      pile_quest.revenir (null_quest);
      pile_env.revenir (null_env);
      pile_clause.revenir (null_clause);
      pile_objet.revenir (null_objet);
   END restart_all;

   PROCEDURE dump_all IS
   BEGIN
      dump_clause;
      dump_objet;
      dump_predicat;
      dump_operande;
      dump_quest;
      dump_res;
      dump_env;
      dump_backtrack;
      dump_trail;
   END dump_all;

   PROCEDURE prepare_predicat (adresse : OUT c_pointer;
                               size    : OUT c_int) IS
   BEGIN
      pile_predicat.prepare (adresse, size);
   END prepare_predicat;

   PROCEDURE prepare_trail (adresse : OUT c_pointer;
                            size    : OUT c_int) IS
   BEGIN
      pile_trail.prepare (adresse, size);
   END prepare_trail;

   PROCEDURE prepare_operande (adresse : OUT c_pointer;
                               size    : OUT c_int) IS
   BEGIN
      pile_operande.prepare (adresse, size);
   END prepare_operande;

   PROCEDURE prepare_backtrack (adresse : OUT c_pointer;
                                size    : OUT c_int) IS
   BEGIN
      pile_backtrack.prepare (adresse, size);
   END prepare_backtrack;

   PROCEDURE prepare_quest (adresse : OUT c_pointer;
                            size    : OUT c_int) IS
   BEGIN
      pile_quest.prepare (adresse, size);
   END prepare_quest;

   PROCEDURE prepare_env (adresse : OUT c_pointer;
                          size    : OUT c_int) IS
   BEGIN
      pile_env.prepare (adresse, size);
   END prepare_env;

   PROCEDURE prepare_res (adresse : OUT c_pointer;
                          size    : OUT c_int) IS
   BEGIN
      pile_res.prepare (adresse, size);
   END prepare_res;

   PROCEDURE prepare_clause (adresse : OUT c_pointer;
                             size    : OUT c_int) IS
   BEGIN
      pile_clause.prepare (adresse, size);
   END prepare_clause;

   PROCEDURE prepare_objet (adresse : OUT c_pointer;
                            size    : OUT c_int) IS
   BEGIN
      pile_objet.prepare (adresse, size);
   END prepare_objet;

BEGIN

   pile_predicat.initialiser ((nom    => (OTHERS => ascii.nul),
                               clause => null_clause));
   pile_trail.initialiser (null_env);
   pile_operande.initialiser (null_objet);
   --      pile_backtrack.initialiser();
   pile_res.initialiser ((num_struct => null_objet, num_envi => null_env));
   pile_env.initialiser ((num_struct => null_objet, num_envi => null_env));
   pile_quest.initialiser ((num_struct => null_objet, num_envi => null_env));
   pile_clause.initialiser ((clause => null_objet,
                             nb_var => 0,
                             next   => null_clause,
                             pred   => null_objet));
   pile_objet.initialiser ((genre => allfree, clause => null_clause));

END types_molog;
