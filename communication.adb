WITH c_types;
USE c_types;
WITH types_molog;
USE types_molog;
WITH registres;
USE registres;
WITH text_io;
USE text_io;

PACKAGE BODY communication IS



   TYPE header IS
      RECORD
         rbottom   : num_res;
         qcurr     : num_quest;
         fcurr     : num_objet;
         fenv      : num_env;
         cregle    : numero_regle;
         cclause   : num_clause;
         pred_top  : num_predicat;
         trail_top : num_trail;
         oper_top  : num_operande;
         r_top     : num_res;
         q_top     : num_quest;
         env_top   : num_env;
         cl_top    : num_clause;
         objet_top : num_objet;
      END RECORD;


   FUNCTION closethem RETURN c_int is
   BEGIN 
      RETURN 0;
   end closethem;


   FUNCTION isfree RETURN c_int IS
   BEGIN
      RETURN 0;
   END isfree;



   
   FUNCTION server RETURN c_int is
   begin
      return 0;
   end server;

   FUNCTION client RETURN c_int is
   begin
      return 0;
   end client;

   FUNCTION send (tab : IN c_pointer;
                  nb  : IN c_int) RETURN c_int is
   begin
      return 0;
   end send;

   FUNCTION sendback (tab : IN c_pointer;
                      nb  : IN c_int) RETURN c_int is
   begin
      return 0;
   end sendback;


   FUNCTION receive (tab : IN c_pointer;
                     nb  : IN c_int) RETURN c_int is
   begin
      return 0;
   end receive;




   FUNCTION is_free RETURN boolean IS
      ret : c_int;
   BEGIN
      ret := isfree;
      CASE ret IS
         WHEN 1 =>
            RETURN true;
         WHEN - 1 =>
            RETURN false;
         WHEN OTHERS =>
            RAISE erreur_connection;
      END CASE;
   END is_free;

   PROCEDURE waiting IS
      val   : c_int := 0;
      nb    : c_int;
      h     : header;
      ret   : c_int;
      point : c_pointer;
   BEGIN
      nb := val'SIZE / 8;
      --      put_line ("sending");
      ret := sendback (c_pointer (val'ADDRESS), nb);
      nb  := h'SIZE / 8;
      --      put_line ("waiting for reception");
      ret := receive (c_pointer (h'ADDRESS), nb);
      IF ret = 0 THEN
         RAISE erreur_connection;
      END IF;
      rbottom := h.rbottom;
      qcurr   := h.qcurr;
      fcurr   := h.fcurr;
      fenv    := h.fenv;
      cregle  := h.cregle;
      cclause := h.cclause;
      revenir (h.pred_top);
      revenir (h.trail_top);
      revenir (h.oper_top);
      revenir (h.r_top);
      revenir (h.q_top);
      revenir (h.env_top);
      revenir (h.cl_top);
      revenir (h.objet_top);

      --      put_line ("reception effectuee:" & numero_regle'IMAGE (h.cregle));
      prepare_predicat (point, nb);
      --put_line ("taille : " & c_int'IMAGE (nb));
      IF nb /= 0 THEN
         ret := receive (point, nb);
         IF ret = 0 THEN
            RAISE erreur_connection;
         END IF;
      END IF;
      --dump_predicat;
      
      prepare_trail (point, nb);
      --put_line ("taille : " & c_int'IMAGE (nb));
      IF nb /= 0 THEN
         ret := receive (point, nb);
         IF ret = 0 THEN
            RAISE erreur_connection;
         END IF;
      END IF;
      --dump_trail;
      
      prepare_operande (point, nb);
      --put_line ("taille : " & c_int'IMAGE (nb));
      IF nb /= 0 THEN
         ret := receive (point, nb);
         IF ret = 0 THEN
            RAISE erreur_connection;
         END IF;
      END IF;
      --dump_operande;
      
      prepare_res (point, nb);
      --put_line ("taille : " & c_int'IMAGE (nb));
      IF nb /= 0 THEN
         ret := receive (point, nb);
         IF ret = 0 THEN
            RAISE erreur_connection;
         END IF;
      END IF;
      --dump_res;
      
      prepare_quest (point, nb);
      --put_line ("taille : " & c_int'IMAGE (nb));
      IF nb /= 0 THEN
         ret := receive (point, nb);
         IF ret = 0 THEN
            RAISE erreur_connection;
         END IF;
      END IF;
      --dump_quest;
      
      prepare_env (point, nb);
      --put_line ("taille : " & c_int'IMAGE (nb));
      IF nb /= 0 THEN
         ret := receive (point, nb);
         IF ret = 0 THEN
            RAISE erreur_connection;
         END IF;
      END IF;
      --dump_env;
      
      prepare_clause (point, nb);
      --put_line ("taille : " & c_int'IMAGE (nb));
      IF nb /= 0 THEN
         ret := receive (point, nb);
         IF ret = 0 THEN
            RAISE erreur_connection;
         END IF;
      END IF;
      --dump_clause;
      
      prepare_objet (point, nb);
      --put_line ("taille : " & c_int'IMAGE (nb));
      IF nb /= 0 THEN
         ret := receive (point, nb);
         IF ret = 0 THEN
            RAISE erreur_connection;
         END IF;
      END IF;
      --dump_objet;
   END waiting;

   PROCEDURE send_all IS
      h     : header;
      nb    : c_int;
      ret   : c_int;
      point : c_pointer;
   BEGIN
      h.rbottom   := rbottom;
      h.qcurr     := qcurr;
      h.fcurr     := fcurr;
      h.fenv      := fenv;
      h.cregle    := cregle;
      h.cclause   := cclause;
      h.pred_top  := position;
      h.trail_top := position;
      h.oper_top  := position;
      h.r_top     := position;
      h.q_top     := position;
      h.env_top   := position;
      h.cl_top    := position;
      h.objet_top := position;
      nb          := h'SIZE / 8;
      ret         := send (c_pointer (h'ADDRESS), nb);
      IF ret = 0 THEN
         RAISE erreur_connection;
      END IF;
      --      put_line ("Apres send: "&numero_regle'IMAGE (h.cregle));
      prepare_predicat (point, nb);
      --put_line ("taille: " & c_int'IMAGE (nb));
      IF nb /= 0 THEN
         ret := send (point, nb);
         IF ret = 0 THEN
            RAISE erreur_connection;
         END IF;
      END IF;
      --dump_predicat;
      
      prepare_trail (point, nb);
      --put_line ("taille : " & c_int'IMAGE (nb));
      IF nb /= 0 THEN
         ret := send (point, nb);
         IF ret = 0 THEN
            RAISE erreur_connection;
         END IF;
      END IF;
      --dump_trail;
      
      prepare_operande (point, nb);
      --put_line ("taille : " & c_int'IMAGE (nb));
      IF nb /= 0 THEN
         ret := send (point, nb);
         IF ret = 0 THEN
            RAISE erreur_connection;
         END IF;
      END IF;
      --dump_operande;
      
      prepare_res (point, nb);
      --put_line ("taille : " & c_int'IMAGE (nb));
      IF nb /= 0 THEN
         ret := send (point, nb);
         IF ret = 0 THEN
            RAISE erreur_connection;
         END IF;
      END IF;
      --dump_res;
      
      prepare_quest (point, nb);
      --put_line ("taille : " & c_int'IMAGE (nb));
      IF nb /= 0 THEN
         ret := send (point, nb);
         IF ret = 0 THEN
            RAISE erreur_connection;
         END IF;
      END IF;
      --dump_quest;
      
      prepare_env (point, nb);
      --put_line ("taille : " & c_int'IMAGE (nb));
      IF nb /= 0 THEN
         ret := send (point, nb);
         IF ret = 0 THEN
            RAISE erreur_connection;
         END IF;
      END IF;
      --dump_env;
      
      prepare_clause (point, nb);
      --put_line ("taille : " & c_int'IMAGE (nb));
      IF nb /= 0 THEN
         ret := send (point, nb);
         IF ret = 0 THEN
            RAISE erreur_connection;
         END IF;
      END IF;
      --dump_clause;
      
      prepare_objet (point, nb);
      --put_line ("taille : " & c_int'IMAGE (nb));
      IF nb /= 0 THEN
         ret := send (point, nb);
         IF ret = 0 THEN
            RAISE erreur_connection;
         END IF;
      END IF;
      --dump_objet;
      
   END send_all;

   PROCEDURE open_master IS
      ret : c_int;
   BEGIN
      ret := client;
      IF ret = 0 THEN
         RAISE erreur_connection;
      END IF;
      ret := server;
      IF ret = 0 THEN
         RAISE erreur_connection;
      END IF;
   END open_master;

   PROCEDURE open_slave IS
      ret : c_int;
   BEGIN
      ret := server;
      IF ret = 0 THEN
         RAISE erreur_connection;
      END IF;
      ret := client;
      IF ret = 0 THEN
         RAISE erreur_connection;
      END IF;
   END open_slave;

   PROCEDURE close_all IS
      ret : c_int;
   BEGIN
      ret := closethem;
   END close_all;

END communication;
