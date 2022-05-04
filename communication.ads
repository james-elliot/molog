PACKAGE communication IS


   FUNCTION is_free RETURN boolean;

   PROCEDURE open_master;

   PROCEDURE open_slave;

   PROCEDURE close_all;

   PROCEDURE waiting;

   PROCEDURE send_all;

   erreur_connection : EXCEPTION;

END communication;
