-- $Log: operateur_b.a,v $
-- Revision 1.2  1992/01/16  07:16:46  alliot
-- mineur
--
-- Revision 1.1  1991/12/18  15:03:21  alliot
-- Initial revision
--
--Revision 4.1  91/07/27  14:36:30  alliot
--Premiere version parallele fonctionnant
--Le paquetage genhash a ete degrade pour etre plus simple
--L'envoi des piles est fait de facon systematique et totale (peu efficace)
--L'envoi des donnees n'est pas en boucle mais du haut vers le bas
--
--Revision 3.3  91/07/22  20:06:52  alliot
--Modification de l'ordre des regles pour ameliorer la vitesse
--Gain de l'ordre d'un facteur 10
--
--Revision 3.2  91/07/22  14:52:43  alliot
--Rajout du type allfree qui correspond a une variable toujours libre
--Un objet allfree se represente par un _
--Le KUT fonctionne (ainsi que l'exemple des sages et des chapeaux ) Rajout des
--+ commandes: stack,explain,trace,allsol,firstsol
--
--Revision 3.1  91/07/20  21:31:19  alliot
--Implementation de S4
--Modification de l'unificateur avec suppression de quelques bugs
--Le KUT n'est pas implemente
--
--Revision 2.6  91/07/19  19:01:07  alliot
--modifications dans la selection des clauses et l'execution des
--regles pour ameliorer la vitesse d'execution
--
--Revision 2.5  91/07/17  19:13:50  alliot
--Un top-level a ete rajoute. On peut a partir du top-level:
--  Ajouter des clauses
--  Poser des questions
--  Executer des commandes (ligne debutant par
--Les seules commandes definies sont load (chargement fichier)
--et restart (restart complet du systeme).
--
--Revision 2.4  91/07/17  11:25:47  alliot
--Le moteur d'inference n'execute plus de code pour la
--selection et l'execution de clause. Tout se trouve desormais dans les
--fonctions du paquetage selclause. On respecte ainsi exactement le
--modele formel.
--
--Revision 2.3  91/07/16  17:27:30  alliot
--Modification du parser:
--  On peut entrer une liste sous la forme \[a,b,c,d\]
--  On peut mettre des commentaires avec \@ en debut de ligne
--  Les lignes blanches et les espaces sont ignores.
--
--Revision 2.2  91/07/16  12:38:56  alliot
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
WITH registres;
USE registres;
WITH unification;
USE unification;
WITH communication;
USE communication;
WITH text_io;
USE text_io;

PACKAGE BODY operateurs IS
   TYPE numero_code IS NEW natural;
   code_invalide : CONSTANT numero_code := 0;

   TYPE regle IS
      RECORD
         next_regle : numero_regle := plus_de_regle;
         code       : numero_code  := code_invalide;
      END RECORD;

   premier : CONSTANT numero_operateur := 1;
   dernier : CONSTANT numero_operateur := 6; -- S4 + KUT
   noms    : ARRAY (premier .. dernier) OF acces_string;
   nb_args : ARRAY (premier .. dernier) OF nombre_arguments;
   et      : CONSTANT numero_operateur := 1;
   nec     : CONSTANT numero_operateur := 2;
   pos     : CONSTANT numero_operateur := 3;
   posi    : CONSTANT numero_operateur := 4;
   kut     : CONSTANT numero_operateur := 5;
   fuz     : CONSTANT numero_operateur := 6;

   premiere_regle  : CONSTANT numero_regle := 1;
   derniere_regle  : CONSTANT numero_regle := 1000;
   regles          : ARRAY (premiere_regle .. derniere_regle) OF regle;
   premieresregles : ARRAY (null_operateur .. dernier,
     null_operateur .. dernier) OF numero_regle :=
      (OTHERS => (OTHERS => plus_de_regle));

   code_regle_inconnu, erreur_reecriture : EXCEPTION;

   FUNCTION nb_operateurs RETURN natural IS
   BEGIN
      RETURN natural (dernier - premier) + 1;
   END nb_operateurs;

   FUNCTION premier_operateur RETURN numero_operateur IS
   BEGIN
      RETURN premier;
   END premier_operateur;

   FUNCTION dernier_operateur RETURN numero_operateur IS
   BEGIN
      RETURN dernier;
   END dernier_operateur;

   FUNCTION egal (num : IN numero_operateur;
                  nom : IN string;
                  nb  : IN nombre_arguments) RETURN boolean IS
   BEGIN
      IF (noms (num).ALL = nom) AND (nb_args (num) = nb) THEN
         RETURN true;
      ELSE
         RETURN false;
      END IF;
   END egal;

   FUNCTION is_operateur  (nom : IN string;
                           nb  : IN nombre_arguments) RETURN numero_operateur is
   BEGIN
      FOR i in premier..dernier LOOP
         IF (noms (i).ALL = nom) AND (nb_args (i) = nb) THEN
            RETURN i;
         END IF;
      END LOOP;
      RETURN null_operateur;
   END is_operateur;


   FUNCTION nom_operateur (num : IN numero_operateur) RETURN string IS
   BEGIN
      RETURN noms (num).ALL;
   END nom_operateur;

   FUNCTION premiereregle
       (num1, num2 : IN numero_operateur) RETURN numero_regle IS
   BEGIN
      RETURN premieresregles (num1, num2);
   END premiereregle;

   FUNCTION reglesuivante (num : IN numero_regle) RETURN numero_regle IS
   BEGIN
      RETURN regles (num).next_regle;
   END reglesuivante;

   FUNCTION executeregle (num : IN numero_regle) RETURN resultat_execution IS
      back   : boolean      := true;
      numero : numero_regle := num;
   BEGIN
      IF numero = 0 THEN
         RETURN echec;
      END IF;
      IF (trace OR explain OR regles (numero).next_regle /= plus_de_regle)
          AND NOT first_time THEN
         IF parallel AND THEN regles (numero).next_regle /= plus_de_regle
             AND THEN is_free THEN
            IF trace THEN
               put_line ("sending:" & numero_regle'IMAGE (cregle));
            END IF;
            send_all;
            IF trace THEN
               put_line ("end sending");
            END IF;
            cregle := regles (numero).next_regle;
            numero := cregle;
            sauveregistres (gen => types_molog.regle);
            back := false;
         ELSE
            sauveregistres (gen => types_molog.regle);
            back := false;
         END IF;
      END IF;
      IF first_time THEN
         first_time := false;
      END IF;

      CASE regles (numero).code IS
         WHEN 1 => -- predicat , predicat
            DECLARE
               eltres : elt_res;
               adrres : num_res;
            BEGIN
               -- Empilement de l'objet nul.
     -- Inutile de faire l'unification des predicats qui a deja ete effectue.
               eltres.num_struct := null_objet;
               eltres.num_envi   := null_env;
               adrres            := empiler (eltres);
               -- On empile l'element nul
               RETURN fin;
            END;

         WHEN 2 =>
            -- Ex: predicat , ET(A).
            -- De facon generale, toute operation consistant a
-- empiler l'element courant de la question dans la resolvante.
            -- et a faire avancer la question
            DECLARE
               eltres   : elt_res;
               adrres   : num_res;
               eltquest : elt_quest;
            BEGIN
               eltquest          := recuperer (qcurr);
               eltres.num_struct := eltquest.num_struct;
               eltres.num_envi   := eltquest.num_envi;
               adrres            := empiler (eltres);
               qcurr             := qcurr + 1;
               RETURN reussi;
            END;
         WHEN 3 =>
            -- Ex: ET(A):, predicat
            -- De facon generale, toute operation consistant a
       -- empiler l'element courant du fait dans la resolvante.
            --et a faire avancer le fait
            DECLARE
               eltobjet : elt_objet;
               eltres   : elt_res;
               adrres   : num_res;
            BEGIN
               eltres.num_struct := fcurr;
               eltres.num_envi   := fenv;
               eltobjet          := recuperer (fcurr);
               fcurr             := eltobjet.obj_qual;
               adrres            := empiler (eltres);
               RETURN reussi;
            END;
         WHEN 4 =>
            -- Fait avancer la question d'un cran
            -- Ex: predicat,POS ou POS,POS
            qcurr := qcurr + 1;
            RETURN reussi;
         WHEN 5 =>
            --Fait avancer le fait d'un cran
            -- Ex: NEC, predicat
            DECLARE
               eltobjet : elt_objet;
            BEGIN
               eltobjet := recuperer (fcurr);
               fcurr    := eltobjet.obj_qual;
               RETURN reussi;
            END;
         WHEN 6 =>
            --Unifie les deux elements courants du fait et de la question
            --Et empile un des deux (peut importe lequel), sur
            --La pile de la resolvante si l'unification reussit.
            --Puis fait avancer le pointeur sur le fait et le
            --pointeur sur la resolvante
            DECLARE
               eltobjet   : elt_objet;
               eltres     : elt_res;
               adrres     : num_res;
               eltquest   : elt_quest;
               curr_trail : num_trail;
            BEGIN
               eltquest   := recuperer (qcurr);
               curr_trail := position;
               IF unify (fcurr, eltquest.num_struct, fenv, eltquest.num_envi)
                   THEN
                  eltres.num_struct := fcurr;
                  eltres.num_envi   := fenv;
                  adrres            := empiler (eltres);
                  eltobjet          := recuperer (fcurr);
                  fcurr             := eltobjet.obj_qual;
                  qcurr             := qcurr + 1;
                  RETURN reussi;
               ELSE
                  --Grosse Ruse!!!
                  -- SI on n'a pas sauvegarder les registres,
                  -- l'unification aura modifie l'unification de
                  -- variable avant d'echouer et ces variables
                  -- ne seront pas restaures!
                  IF back THEN
                     revenir (curr_trail);
                  END IF;
                  RETURN echec;
               END IF;
            END;
         WHEN 8 =>
            --Unifie le premier operande du fait et le premier
            --operande de la question
            --Empile l'element courant de la question sur
            --La pile de la resolvante si l'unification reussit.
            --Puis fait avancer le pointeur sur la question seulement
            DECLARE
               obj1, obj2           : elt_objet;
               eltres               : elt_res;
               adrres               : num_res;
               eltquest             : elt_quest;
               num_oper1, num_oper2 : num_objet;
               curr_trail           : num_trail;
            BEGIN
               obj1       := recuperer (fcurr);
               eltquest   := recuperer (qcurr);
               obj2       := recuperer (eltquest.num_struct);
               num_oper1  := recuperer (obj1.arg_op);
               num_oper2  := recuperer (obj2.arg_op);
               curr_trail := position;
               IF unify (num_oper1, num_oper2, fenv, eltquest.num_envi) THEN
                  eltres.num_struct := eltquest.num_struct;
                  eltres.num_envi   := eltquest.num_envi;
                  adrres            := empiler (eltres);
                  qcurr             := qcurr + 1;
                  RETURN reussi;
               ELSE
                  IF back THEN
                     revenir (curr_trail);
                  END IF;
                  RETURN echec;
               END IF;
            END;
         WHEN 9 =>
            --Unifie le premier operande du fait et le premier
            --operande de la question
            --Empile l'element courant du fait sur
            --La pile de la resolvante si l'unification reussit.
            --Puis fait avancer le pointeur sur le fait seulement
            DECLARE
               obj1, obj2           : elt_objet;
               eltres               : elt_res;
               adrres               : num_res;
               eltquest             : elt_quest;
               num_oper1, num_oper2 : num_objet;
               curr_trail           : num_trail;
            BEGIN
               obj1       := recuperer (fcurr);
               eltquest   := recuperer (qcurr);
               obj2       := recuperer (eltquest.num_struct);
               num_oper1  := recuperer (obj1.arg_op);
               num_oper2  := recuperer (obj2.arg_op);
               curr_trail := position;
               IF unify (num_oper1, num_oper2, fenv, eltquest.num_envi) THEN
                  eltres.num_struct := fcurr;
                  eltres.num_envi   := fenv;
                  adrres            := empiler (eltres);
                  fcurr             := obj1.obj_qual;
                  RETURN reussi;
               ELSE
                  IF back THEN
                     revenir (curr_trail);
                  END IF;
                  RETURN echec;
               END IF;
            END;
         WHEN 10 =>
            --Unifie les deux elements courants du fait et de la question
            --Et empile l'argument de la question sur
            --La pile de la resolvante si l'unification ECHOUE.
            --Puis fait avancer le pointeur sur la question
            --SI l'unification reussit, provoque un backtrack
            --jusqu'a la derniere clause
            DECLARE
--               eltobjet   : elt_objet;
               eltres     : elt_res;
               adrres     : num_res;
               eltquest   : elt_quest;
               curr_trail : num_trail;
            BEGIN
               eltquest   := recuperer (qcurr);
               curr_trail := position;
               IF NOT unify (fcurr, eltquest.num_struct, fenv,
                             eltquest.num_envi) THEN
                  IF back THEN
                     revenir (curr_trail);
                  END IF;
                  eltres.num_struct := eltquest.num_struct;
                  eltres.num_envi   := eltquest.num_envi;
                  adrres            := empiler (eltres);
                  qcurr             := qcurr + 1;
                  RETURN reussi;
               ELSE
                  --Backtrack jusqu'a la dernier clause.
                  DECLARE
                     num_cl   : num_clause    := recuperer (fcurr).clause;
                     num_back : num_backtrack := position;
                     elt_back : elt_backtrack;
                  BEGIN
                     LOOP
                        elt_back := recuperer (num_back);
                        EXIT WHEN elt_back.genre = clause AND THEN
                                  elt_back.cclause = num_cl;
                        modifier ((genre     => invalide,
                                   rbottom   => elt_back.rbottom,
                                   qcurr     => elt_back.qcurr,
                                   fcurr     => elt_back.fcurr,
                                   fenv      => elt_back.fenv,
                                   trail_top => elt_back.trail_top,
                                   objet_top => elt_back.objet_top,
                                   q_top     => elt_back.q_top,
                                   r_top     => elt_back.r_top,
                                   env_top   => elt_back.env_top), num_back);
                        num_back := num_back - 1;
                     END LOOP;
                  END;
                  RETURN echec;
               END IF;
            END;
         WHEN 11 =>
            --Unifie le premier operande du fait et le premier
            --operande de la question
            --Empile l'element courant de la question sur
            --La pile de la resolvante si l'unification reussit.
            --Puis fait avancer le pointeur sur le fait seulement
            DECLARE
               obj1, obj2           : elt_objet;
               eltres               : elt_res;
               adrres               : num_res;
               eltquest             : elt_quest;
               num_oper1, num_oper2 : num_objet;
               curr_trail           : num_trail;
            BEGIN
               obj1       := recuperer (fcurr);
               eltquest   := recuperer (qcurr);
               obj2       := recuperer (eltquest.num_struct);
               num_oper1  := recuperer (obj1.arg_op);
               num_oper2  := recuperer (obj2.arg_op);
               curr_trail := position;
               IF unify (num_oper1, num_oper2, fenv, eltquest.num_envi) THEN
                  eltres.num_struct := eltquest.num_struct;
                  eltres.num_envi   := eltquest.num_envi;
                  adrres            := empiler (eltres);
                  fcurr             := obj1.obj_qual;
                  RETURN reussi;
               ELSE
                  IF back THEN
                     revenir (curr_trail);
                  END IF;
                  RETURN echec;
               END IF;
            END;

         WHEN OTHERS =>
            RAISE code_regle_inconnu;
      END CASE;
   END executeregle;

   FUNCTION reecrit RETURN resultat_reecriture IS
      eltres   : elt_res;
      premier  : num_res := rbottom;
      place    : num_res;
      eltquest : elt_quest;
      eltobj   : elt_objet;
      adrquest : num_quest;
      dernier  : num_res := position;
      numobj   : num_objet;
      mini     : valeur_flottant;
   BEGIN

      rbottom := position + 1;
      eltres  := recuperer (dernier);
      IF eltres.num_struct /= null_objet THEN
         RAISE erreur_reecriture;
      END IF;

      place := dernier - 1;
      mini:=1.0;

      WHILE place /= premier - 1 LOOP
         eltres := recuperer (place);
         eltobj := recuperer (eltres.num_struct);
         IF eltobj.genre /= operateur THEN
            RAISE erreur_reecriture;
         END IF;
         EXIT WHEN eltobj.nom_op = et;
         IF eltobj.nom_op = fuz THEN
            numobj   := recuperer(eltobj.arg_op);
            eltobj   := recuperer(numobj);
            IF eltobj.genre /= flottant THEN raise erreur_reecriture; END IF;
            IF mini>eltobj.val_flot THEN mini:=eltobj.val_flot; END IF;
         END IF;
         place := place - 1;
      END LOOP;

      dernier := place;
      IF dernier = premier - 1 THEN
         put("Vraisemblance:");
         afficher(mini);
         RETURN fin_fin;
      END IF;

      qcurr := position + 1; --La nouvelle question commence a qcurr
      -- qui est le top actuel+1
     --On empile tous les niveaux sauf le sommet qu'il faut "remettre en forme"
      place := premier;
      WHILE place /= dernier LOOP
         eltres              := recuperer (place);
         eltquest.num_struct := eltres.num_struct;
         eltquest.num_envi   := eltres.num_envi;
         adrquest            := empiler (eltquest);
         place               := place + 1;
      END LOOP;

      eltres := recuperer (dernier);
      numobj := recuperer (recuperer (eltres.num_struct).arg_op);

      eltquest.num_envi := eltres.num_envi;

      LOOP
         eltobj              := recuperer (numobj);
         eltquest.num_struct := numobj;
         adrquest            := empiler (eltquest);
         IF eltobj.genre = predicat THEN
            EXIT;
         ELSE
            numobj := eltobj.obj_qual;
         END IF;
      END LOOP;
      RETURN ok;

   END reecrit;

BEGIN
   noms (et)      := NEW string'("ET");
   nb_args (et)   := 1;
   noms (nec)     := NEW string'("NEC");
   nb_args (nec)  := 1;
   noms (pos)     := NEW string'("POS");
   nb_args (pos)  := 1;
   noms (posi)    := NEW string'("POSI");
   nb_args (posi) := 2;
   noms (kut)     := NEW string'("KUT");
   nb_args (kut)  := 1;
   noms (fuz)     := NEW string'("FUZ");
   nb_args (fuz)  := 1;

   premieresregles (null_operateur, null_operateur) := 1;
   premieresregles (null_operateur, et)             := 2;
   premieresregles (null_operateur, pos)            := 4;
   premieresregles (null_operateur, nec)            := plus_de_regle;
   premieresregles (null_operateur, posi)           := plus_de_regle;

   premieresregles (et, null_operateur) := 3;
   premieresregles (et, et)             := 2;
   premieresregles (et, pos)            := 3;
   premieresregles (et, nec)            := plus_de_regle;
   --Il n'y a jamais de nec dans une question (skolem)
   premieresregles (et, posi) := 3;

   premieresregles (pos, null_operateur) := plus_de_regle; --Etait 3
   premieresregles (pos, et)             := plus_de_regle; --Etait 2
   premieresregles (pos, pos)            := plus_de_regle;
   --Etait 4 mais il n'y a pas de pos dans le fait
   premieresregles (pos, nec)  := plus_de_regle;
   premieresregles (pos, posi) := plus_de_regle;

   premieresregles (nec, null_operateur) := 5;
   premieresregles (nec, et)             := 2;
   premieresregles (nec, pos)            := 6;
   premieresregles (nec, nec)            := plus_de_regle;
   premieresregles (nec, posi)           := 8;

   premieresregles (posi, null_operateur) := plus_de_regle;
   premieresregles (posi, et)             := 2;
   premieresregles (posi, pos)            := 9;
   premieresregles (posi, nec)            := plus_de_regle;
   premieresregles (posi, posi)           := 10;

   premieresregles (kut, null_operateur) := 3;
   premieresregles (kut, et)             := 3;
   premieresregles (kut, pos)            := 3;
   premieresregles (kut, nec)            := 3;
   premieresregles (kut, posi)           := 3;

   premieresregles (null_operateur, kut) := 2;
   premieresregles (et, kut)             := 2;
   premieresregles (pos, kut)            := 2;
   premieresregles (nec, kut)            := 2;
   premieresregles (posi, kut)           := 2;

   premieresregles (kut, kut) := 11;


   premieresregles (fuz, null_operateur) := 3;
   premieresregles (fuz, et)             := 3;
   premieresregles (fuz, pos)            := 3;
   premieresregles (fuz, nec)            := 3;
   premieresregles (fuz, posi)           := 3;

   premieresregles (null_operateur, fuz) := 2;
   premieresregles (et, fuz)             := 2;
   premieresregles (pos, fuz)            := 2;
   premieresregles (nec, fuz)            := 2;
   premieresregles (posi, fuz)           := 2;

   premieresregles (kut, fuz)            := 3; --kut est place avant fuz
   premieresregles (fuz, kut)            := 2; --idem
   premieresregles (fuz, fuz)            := 2; -- 2 ou 3 sans importance

   --L'ordonnancement des regles est capital pour la vitesse du programme
   --Le facteur peut etre de 20 ou 30
   regles (1).code        := 1;
   regles (2).code        := 2;
   regles (3).code        := 3;
   regles (4).code        := 4; -- Pred,POS
   regles (5).code        := 5; -- NEC,Pred
   regles (6).code        := 8; -- NEC,POS
   regles (6).next_regle  := 23;
   regles (23).code       := 11;
   regles (23).next_regle := 24;
   regles (24).code       := 5;
   regles (24).next_regle := 25;
   regles (25).code       := 4;
   regles (8).code        := 8; --NEC,POSI
   regles (8).next_regle  := 21;
   regles (21).code       := 5;
   regles (9).code        := 9; --POSI,POS
   regles (9).next_regle  := 22;
   regles (22).code       := 4;
   regles (10).code       := 6; --POSI,POSI
   regles (11).code       := 10; --KUT,KUT
END operateurs;

