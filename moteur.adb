-- $Log: moteur_b.a,v $
-- Revision 1.2  1992/01/16  07:16:46  alliot
-- mineur
--
-- Revision 1.1  1991/12/18  15:03:21  alliot
-- Initial revision
--
--Revision 4.1  91/07/27  14:36:26  alliot
--Premiere version parallele fonctionnant
--Le paquetage genhash a ete degrade pour etre plus simple
--L'envoi des piles est fait de facon systematique et totale (peu efficace)
--L'envoi des donnees n'est pas en boucle mais du haut vers le bas
--
--Revision 3.3  91/07/22  20:06:49  alliot
--Modification de l'ordre des regles pour ameliorer la vitesse
--Gain de l'ordre d'un facteur 10
--
--Revision 3.2  91/07/22  14:52:37  alliot
--Rajout du type allfree qui correspond a une variable toujours libre
--Un objet allfree se represente par un _
--Le KUT fonctionne (ainsi que l'exemple des sages et des chapeaux ) Rajout des
--+ commandes: stack,explain,trace,allsol,firstsol
--
--Revision 3.1  91/07/20  21:31:16  alliot
--Implementation de S4
--Modification de l'unificateur avec suppression de quelques bugs
--Le KUT n'est pas implemente
--
--Revision 2.6  91/07/19  19:01:03  alliot
--modifications dans la selection des clauses et l'execution des
--regles pour ameliorer la vitesse d'execution
--
--Revision 2.5  91/07/17  19:13:48  alliot
--Un top-level a ete rajoute. On peut a partir du top-level:
--  Ajouter des clauses
--  Poser des questions
--  Executer des commandes (ligne debutant par
--Les seules commandes definies sont load (chargement fichier)
--et restart (restart complet du systeme).
--
--Revision 2.4  91/07/17  11:25:43  alliot
--Le moteur d'inference n'execute plus de code pour la
--selection et l'execution de clause. Tout se trouve desormais dans les
--fonctions du paquetage selclause. On respecte ainsi exactement le
--modele formel.
--
--Revision 2.3  91/07/16  17:27:25  alliot
--Modification du parser:
--  On peut entrer une liste sous la forme \[a,b,c,d\]
--  On peut mettre des commentaires avec \@ en debut de ligne
--  Les lignes blanches et les espaces sont ignores.
--
--Revision 2.2  91/07/16  12:38:54  alliot
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
WITH selclause;
WITH registres;
WITH unification;
WITH text_io;
WITH operateurs;
WITH predef;
USE registres;
USE types_molog;
USE selclause;
USE text_io;
USE unification;
USE operateurs;
USE predef;
WITH afficher;


PACKAGE BODY moteur IS

   erreur_fait, erreur_pile_question : EXCEPTION;

   TYPE etats_machine IS
      (selectionner_regle,
       executer_regle,
       selectionner_clause,
       backtracker);

   PROCEDURE principal IS
      qtop                  : num_quest;
      eltquest              : elt_quest;
      qenv                  : num_env;
      numobj                : num_objet;
      obj                   : elt_objet;
      numquest              : num_quest;
--      eltclause             : elt_clause;
      retour                : genre_backtrack;
      etat                  : etats_machine := selectionner_clause;
      oper_quest, oper_fact : numero_operateur;
      retreg                : resultat_execution;
      retref                : resultat_reecriture;
      qnum                  : num_quest;
      rnum                  : num_res;
      eltres                : elt_res;
      adrback               : num_backtrack;
      eltback               : elt_backtrack;
      numback               : num_backtrack;
   BEGIN
      -- Boucle de mise en forme de la pile de la question.
      IF NOT daemon THEN
         qtop     := position;
         eltquest := recuperer (qtop);
         qenv     := eltquest.num_envi;
         numobj   := eltquest.num_struct;
         qcurr    := qtop + 1;
         rbottom  := position + 1;

         LOOP
            obj                 := recuperer (numobj);
            eltquest.num_struct := numobj;
            numquest            := empiler (eltquest);
            IF obj.genre = predicat THEN
               EXIT;
            ELSE
               numobj := obj.obj_qual;
            END IF;
         END LOOP;
      END IF;

      IF daemon THEN
         etat       := executer_regle;
         first_time := true;
      END IF;
      LOOP
         CASE etat IS
            WHEN selectionner_clause =>
               IF trace THEN
                  put_line ("selection de clause");
               END IF;
               cclause := premiereclause;
               IF cclause = null_clause THEN
                  IF trace THEN
                     put_line ("pas de clause");
                  END IF;
                  etat := backtracker;
               ELSE
                  IF trace THEN
                     put ("clause selectionnee: ");
                     afficher (cclause);
                     put ("Niveau :");
                     adrback := position;
                     afficher (adrback);
                  END IF;
                  etat := selectionner_regle;
               END IF;
            WHEN backtracker =>
               IF trace THEN
                  put ("backtrack a partir du niveau: ");
                  adrback := position;
                  afficher (adrback);
               END IF;
               LOOP
                  BEGIN
                     retour := restoreregistres;
                  EXCEPTION
                     WHEN pile_vide =>
                        RETURN;
                  END;
                  EXIT WHEN retour /= invalide;
               END LOOP;
               IF retour = regle THEN
                  IF trace THEN
                     put ("selection de regle. Regle precedente:");
                     afficher (cregle);
                  END IF;
                  cregle := reglesuivante (cregle);
                  IF cregle = plus_de_regle THEN
                     IF trace THEN
                        put_line ("plus de regle");
                     END IF;
                     etat := backtracker;
                  ELSE
                     etat := executer_regle;
                  END IF;
               ELSE
                  IF trace THEN
                     put ("selection de clause. Clause precedente:");
                     afficher (cclause);
                  END IF;
                  IF cclause = null_clause THEN
                     etat := backtracker;
                  ELSE
                     cclause := clausesuivante (cclause);
                     IF cclause = null_clause THEN
                        etat := backtracker;
                        IF trace THEN
                           put_line ("plus de clause");
                        END IF;
                     ELSE
                        IF trace THEN
                           put ("clause selectionnee: ");
                           afficher (cclause);
                           put ("Niveau :");
                           adrback := position;
                           afficher (adrback);
                        END IF;
                        etat := selectionner_regle;
                     END IF;
                  END IF;
               END IF;
            WHEN selectionner_regle =>
               IF trace THEN
                  put_line ("selection de regle");
               END IF;
               eltquest := recuperer (qcurr);
               obj      := recuperer (eltquest.num_struct);
               CASE obj.genre IS
                  WHEN predicat =>
                     oper_quest := null_operateur;
                  WHEN operateur =>
                     oper_quest := obj.nom_op;
                  WHEN OTHERS =>
                     RAISE erreur_pile_question;
               END CASE;
               IF fcurr = null_objet THEN
                  oper_fact := null_operateur;
               ELSE
                  obj := recuperer (fcurr);
                  CASE obj.genre IS
                     WHEN predicat =>
                        oper_fact := null_operateur;
                     WHEN operateur =>
                        oper_fact := obj.nom_op;
                     WHEN OTHERS =>
                        RAISE erreur_fait;
                  END CASE;
               END IF;
               cregle := premiereregle (oper_fact, oper_quest);
               IF cregle = plus_de_regle THEN
                  IF trace THEN
                     put_line ("pas de regle");
                  END IF;
                  etat := backtracker;
               ELSE
                  etat := executer_regle;
               END IF;
            WHEN executer_regle =>
               IF trace THEN
                  put_line ("execution de regle");
                  put ("fait:");
                  afficher (fcurr, fenv, true, true);
                  new_line;
                  put ("question:");
                  qnum := qcurr;
                  LOOP
                     eltquest := recuperer (qnum);
                     afficher (eltquest.num_struct, eltquest.num_envi);
                     EXIT WHEN qnum = position;
                     qnum := qnum + 1;
                  END LOOP;
                  new_line;
               END IF;
               IF cregle = plus_de_regle THEN
                  IF trace THEN
                     put_line ("pas de regle???");
                  END IF;
                  etat := backtracker;
               ELSE
                  IF trace THEN
                     put ("regle a executer:");
                     put_line (numero_regle'IMAGE (cregle));
                  END IF;
                  retreg := executeregle (cregle);
                  IF trace THEN
                     put ("Niveau: ");
                     adrback := position;
                     afficher (adrback);
                  END IF;
                  CASE retreg IS
                     WHEN echec =>
                        etat := backtracker;
                        IF trace THEN
                           put_line ("echec");
                        END IF;
                     WHEN reussi =>
                        etat := selectionner_regle;
                        IF trace THEN
                           put_line ("reussi");
                           rnum := rbottom;
                           IF rnum /= position + 1 THEN
                              put ("resolvante: ");
                              LOOP
                                 eltres := recuperer (rnum);
                                 afficher (eltres.num_struct, eltres.num_envi);
                                 EXIT WHEN rnum = position;
                                 rnum := rnum + 1;
                              END LOOP;
                           ELSE
                              put ("resolvante vide");
                           END IF;
                           new_line;
                        END IF;
                     WHEN fin =>
                        retref := reecrit;
                        IF trace THEN
                           put_line ("fin");
                        END IF;
                        CASE retref IS
                           WHEN ok =>
                              etat := selectionner_clause;
                           WHEN not_ok =>
                              etat := backtracker;
                           WHEN fin_fin =>
                              new_line;
                              put_line ("Ok");
                              IF explain THEN
                                 numback := null_backtrack + 1;

                                 WHILE numback /= position + 1 LOOP
                                    eltback := recuperer (numback);
                                    IF eltback.genre /= clause THEN
                                       put ("fait:");
                                       afficher (eltback.fcurr, eltback.fenv,
                                                 true, true);
                                       new_line;
                                    END IF;
                                    put ("question:");
                                    qnum := eltback.qcurr;
                                    LOOP
                                       eltquest := recuperer (qnum);
                                       afficher (eltquest.num_struct,
                                                 eltquest.num_envi);
                                       EXIT WHEN qnum = eltback.q_top;
                                       qnum := qnum + 1;
                                    END LOOP;
                                    new_line;
                                    CASE eltback.genre IS
                                       WHEN regle =>
                                          put ("regle: ");
                                          afficher (eltback.cregle);
                                       WHEN invalide =>
                                          put_line ("PDC invalide");
                                       WHEN clause =>
                                          put ("clause: ");
                                          afficher (eltback.cclause);
                                    END CASE;
                                    rnum := eltback.rbottom;
                                    IF rnum /= eltback.r_top + 1 THEN
                                       put ("resolvante: ");
                                       LOOP
                                          eltres := recuperer (rnum);
                                          afficher (eltres.num_struct,
                                                    eltres.num_envi);
                                          EXIT WHEN rnum = eltback.r_top;
                                          rnum := rnum + 1;
                                       END LOOP;
                                    ELSE
                                       put ("resolvante vide");
                                    END IF;
                                    new_line;
                                    new_line;
                                    numback := numback + 1;
                                 END LOOP;
                              END IF;
                              IF all_sol THEN
                                 etat := backtracker;
                              ELSE
                                 RETURN;
                              END IF;
                        END CASE;
                  END CASE;
                  IF trace THEN
                     new_line;
                  END IF;
               END IF;
         END CASE;
      END LOOP;

   END principal;


END moteur;

